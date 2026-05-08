import 'dart:convert';

import 'package:dolibarr_mobile/core/storage/app_database.dart';
import 'package:dolibarr_mobile/core/storage/collections/pending_operations.dart';
import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:drift/drift.dart';

part 'pending_operation_dao.g.dart';

/// DAO partagé pour la file Outbox. Utilisé par les repositories pour
/// enqueuer les écritures locales et par le SyncEngine (Étape 9) pour
/// les consommer.
@DriftAccessor(tables: [PendingOperations])
class PendingOperationDao extends DatabaseAccessor<AppDatabase>
    with _$PendingOperationDaoMixin {
  PendingOperationDao(super.attachedDatabase);

  /// Enqueue une opération. Retourne l'id de la nouvelle ligne.
  Future<int> enqueue({
    required PendingOpType opType,
    required PendingOpEntity entityType,
    required int targetLocalId,
    int? targetRemoteId,
    Map<String, Object?> payload = const {},
    DateTime? expectedTms,
    int? dependsOnLocalId,
  }) {
    return into(pendingOperations).insert(
      PendingOperationsCompanion.insert(
        opType: opType,
        entityType: entityType,
        targetLocalId: targetLocalId,
        targetRemoteId: Value(targetRemoteId),
        payload: Value(jsonEncode(payload)),
        expectedTms: Value(expectedTms),
        dependsOnLocalId: Value(dependsOnLocalId),
        createdAt: DateTime.now(),
      ),
    );
  }

  /// Stream de toutes les opérations en attente (pour l'écran "Opérations
  /// en attente" Étape 9).
  Stream<List<PendingOperationRow>> watchAll() {
    final query = select(pendingOperations)
      ..orderBy([(p) => OrderingTerm(expression: p.createdAt)]);
    return query.watch();
  }

  /// Compte les opérations qui ne sont pas en succès (in_progress, failed,
  /// queued, conflict, dead). Sert au badge de l'AppBar.
  Stream<int> watchPendingCount() {
    return (selectOnly(pendingOperations)
          ..addColumns([pendingOperations.id.count()])
          ..where(
            pendingOperations.status.equalsValue(PendingOpStatus.queued) |
                pendingOperations.status.equalsValue(PendingOpStatus.failed) |
                pendingOperations.status
                    .equalsValue(PendingOpStatus.inProgress) |
                pendingOperations.status
                    .equalsValue(PendingOpStatus.conflict),
          ))
        .map((r) => r.read(pendingOperations.id.count()) ?? 0)
        .watchSingle();
  }

  /// Annule (delete) toutes les ops liées à une entité locale donnée
  /// (utile quand on supprime un draft pendingCreate jamais poussé).
  Future<int> deleteForLocal({
    required PendingOpEntity entityType,
    required int targetLocalId,
  }) {
    return (delete(pendingOperations)
          ..where(
            (p) =>
                p.entityType.equalsValue(entityType) &
                p.targetLocalId.equals(targetLocalId),
          ))
        .go();
  }

  /// Cherche l'op `create` la plus récente queued/inProgress pour une
  /// entité locale donnée — utile pour câbler `dependsOnLocalId` lors
  /// de la création d'un enfant dont le parent n'est pas encore poussé.
  /// Retourne `null` si aucun create en attente n'est trouvé.
  Future<int?> findLatestPendingCreate({
    required PendingOpEntity entityType,
    required int targetLocalId,
  }) async {
    final row = await (select(pendingOperations)
          ..where(
            (p) =>
                p.entityType.equalsValue(entityType) &
                p.targetLocalId.equals(targetLocalId) &
                p.opType.equalsValue(PendingOpType.create) &
                (p.status.equalsValue(PendingOpStatus.queued) |
                    p.status.equalsValue(PendingOpStatus.inProgress) |
                    p.status.equalsValue(PendingOpStatus.failed)),
          )
          ..orderBy([(p) => OrderingTerm.desc(p.createdAt)])
          ..limit(1))
        .getSingleOrNull();
    return row?.id;
  }

  /// Liste des ops effectivement dispatchables maintenant : queued ou
  /// failed avec `nextRetryAt <= now`, sans dépendance bloquante. Les
  /// dépendances déjà résolues (op parent supprimée, donc id absent)
  /// sont nettoyées par `completeAndUnblockChildren` avant cet appel.
  Future<List<PendingOperationRow>> dispatchable({DateTime? now}) {
    final cutoff = now ?? DateTime.now();
    return (select(pendingOperations)
          ..where(
            (p) =>
                (p.status.equalsValue(PendingOpStatus.queued) |
                        (p.status.equalsValue(PendingOpStatus.failed) &
                            (p.nextRetryAt.isSmallerOrEqualValue(cutoff) |
                                p.nextRetryAt.isNull()))) &
                p.dependsOnLocalId.isNull(),
          )
          ..orderBy([(p) => OrderingTerm(expression: p.createdAt)]))
        .get();
  }

  /// Récupère une op par son id (ou null).
  Future<PendingOperationRow?> findById(int id) {
    return (select(pendingOperations)..where((p) => p.id.equals(id)))
        .getSingleOrNull();
  }

  /// Marque une op `inProgress` au moment où le SyncEngine la dispatche.
  Future<void> markInProgress(int opId) async {
    await (update(pendingOperations)..where((p) => p.id.equals(opId)))
        .write(
      PendingOperationsCompanion(
        status: const Value(PendingOpStatus.inProgress),
        lastAttemptAt: Value(DateTime.now()),
      ),
    );
  }

  /// Marque l'op `failed` avec un message + planifie le prochain retry
  /// selon le backoff exponentiel calculé par le caller.
  Future<void> markFailed({
    required int opId,
    required String message,
    required DateTime nextRetryAt,
  }) async {
    final row = await findById(opId);
    final attempts = (row?.attempts ?? 0) + 1;
    await (update(pendingOperations)..where((p) => p.id.equals(opId)))
        .write(
      PendingOperationsCompanion(
        status: const Value(PendingOpStatus.failed),
        lastError: Value(message),
        attempts: Value(attempts),
        nextRetryAt: Value(nextRetryAt),
        lastAttemptAt: Value(DateTime.now()),
      ),
    );
  }

  /// Marque l'op en conflit (résolution utilisateur requise).
  Future<void> markConflict({
    required int opId,
    required String message,
  }) async {
    await (update(pendingOperations)..where((p) => p.id.equals(opId)))
        .write(
      PendingOperationsCompanion(
        status: const Value(PendingOpStatus.conflict),
        lastError: Value(message),
        lastAttemptAt: Value(DateTime.now()),
      ),
    );
  }

  /// Marque l'op morte (échec définitif après épuisement des retries
  /// ou erreur 4xx non récupérable). Reste visible dans l'UI pour audit.
  Future<void> markDead({
    required int opId,
    required String message,
  }) async {
    await (update(pendingOperations)..where((p) => p.id.equals(opId)))
        .write(
      PendingOperationsCompanion(
        status: const Value(PendingOpStatus.dead),
        lastError: Value(message),
        lastAttemptAt: Value(DateTime.now()),
      ),
    );
  }

  /// Termine une op avec succès : la supprime ET débloque les ops
  /// enfants qui dépendaient d'elle (clear `dependsOnLocalId`). Le tout
  /// dans une transaction pour éviter les états intermédiaires.
  Future<void> completeAndUnblockChildren(int opId) async {
    await transaction(() async {
      await (update(pendingOperations)
            ..where((p) => p.dependsOnLocalId.equals(opId)))
          .write(
        const PendingOperationsCompanion(dependsOnLocalId: Value(null)),
      );
      await (delete(pendingOperations)..where((p) => p.id.equals(opId)))
          .go();
    });
  }

  /// Force le retry d'une op donnée : remet `queued` + nextRetryAt null.
  Future<void> retryNow(int opId) async {
    await (update(pendingOperations)..where((p) => p.id.equals(opId)))
        .write(
      const PendingOperationsCompanion(
        status: Value(PendingOpStatus.queued),
        nextRetryAt: Value(null),
      ),
    );
  }

  /// Supprime une op (utilisé par l'UI pour discarder).
  Future<int> deleteById(int opId) {
    return (delete(pendingOperations)..where((p) => p.id.equals(opId))).go();
  }
}
