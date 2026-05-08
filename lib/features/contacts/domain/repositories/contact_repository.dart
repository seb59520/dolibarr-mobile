import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/contacts/domain/entities/contact.dart';
import 'package:dolibarr_mobile/features/contacts/domain/entities/contact_filters.dart';

/// Accès aux contacts (lecture + écriture offline-first).
abstract interface class ContactRepository {
  /// Stream SWR de la liste filtrée. Retourne le cache filtré localement
  /// immédiatement, puis se met à jour quand le serveur répond.
  Stream<List<Contact>> watchList(ContactFilters filters);

  /// Stream du détail d'un contact depuis le cache local.
  Stream<Contact?> watchById(int localId);

  /// Stream des contacts rattachés à un tiers (par PK locale du tiers,
  /// pour suivre les contacts dont le parent est encore pendingCreate).
  Stream<List<Contact>> watchByThirdPartyLocal(int thirdPartyLocalId);

  /// Force un refresh API d'une page filtrée.
  Future<Result<int>> refreshPage({
    required ContactFilters filters,
    required int page,
    int limit = 100,
  });

  /// Refetch un contact par `rowid` Dolibarr.
  Future<Result<Contact>> refreshById(int remoteId);

  /// Refetch les contacts d'un tiers (`/thirdparties/:id/contacts`).
  Future<Result<int>> refreshForThirdParty(int thirdPartyRemoteId);

  // -------------- Écritures (Outbox + Optimistic UI) ----------------

  /// Crée un contact localement (`pendingCreate`) et enqueue une op create.
  /// Si le tiers parent est lui-même en pendingCreate, l'op est marquée
  /// comme dépendante de l'op create du parent (cascade Outbox).
  Future<Result<int>> createLocal(Contact draft);

  /// Met à jour un contact existant en `pendingUpdate` et enqueue update.
  Future<Result<void>> updateLocal(Contact entity);

  /// Marque le contact en `pendingDelete` et enqueue une op delete.
  /// Si le contact n'a pas de `remoteId`, suppression locale immédiate.
  Future<Result<void>> deleteLocal(int localId);

  // ----------------------- Brouillons -------------------------------

  Stream<Map<String, Object?>?> watchDraft({int? refLocalId});
  Future<void> saveDraft({
    required Map<String, Object?> fields,
    int? refLocalId,
  });
  Future<void> discardDraft({int? refLocalId});
}
