import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/thirdparties/domain/entities/third_party.dart';
import 'package:dolibarr_mobile/features/thirdparties/domain/entities/third_party_filters.dart';

/// Accès aux tiers (lecture pour l'Étape 6 ; écritures Étape 7).
abstract interface class ThirdPartyRepository {
  /// Stream SWR de la liste filtrée. Retourne le cache filtré
  /// localement immédiatement, puis se met à jour quand le serveur
  /// répond.
  Stream<List<ThirdParty>> watchList(ThirdPartyFilters filters, {int? userId});

  /// Stream du détail d'un tiers depuis le cache local.
  Stream<ThirdParty?> watchById(int localId);

  /// Force un refresh API d'une page (limit/page) et merge dans Drift.
  /// Retourne le nombre d'items reçus (utile pour la pagination UI).
  Future<Result<int>> refreshPage({
    required ThirdPartyFilters filters,
    required int page,
    int limit = 100,
    int? userId,
  });

  /// Refetch la fiche détail depuis l'API et la met en cache.
  Future<Result<ThirdParty>> refreshById(int remoteId);

  // -------------- Écritures (Outbox + Optimistic UI) ----------------

  /// Crée un nouveau tiers localement (`pendingCreate`) et enqueue une
  /// `PendingOperation` que le SyncEngine consommera. Retourne le
  /// `localId` Drift.
  Future<Result<int>> createLocal(ThirdParty draft);

  /// Met à jour un tiers existant en `pendingUpdate` (sauf si déjà
  /// `pendingCreate`, auquel cas on reste en pendingCreate) et enqueue
  /// une `PendingOperation` update.
  Future<Result<void>> updateLocal(ThirdParty entity);

  /// Marque le tiers en `pendingDelete` et enqueue une op delete.
  /// Si le tiers n'a pas de `remoteId` (jamais poussé), suppression
  /// locale immédiate sans op.
  Future<Result<void>> deleteLocal(int localId);

  // ----------------------- Brouillons -------------------------------

  Stream<Map<String, Object?>?> watchDraft({int? refLocalId});
  Future<void> saveDraft({
    required Map<String, Object?> fields,
    int? refLocalId,
  });
  Future<void> discardDraft({int? refLocalId});
}
