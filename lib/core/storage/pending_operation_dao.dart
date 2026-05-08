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
}
