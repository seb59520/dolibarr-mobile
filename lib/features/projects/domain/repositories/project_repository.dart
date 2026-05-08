import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/projects/domain/entities/project.dart';
import 'package:dolibarr_mobile/features/projects/domain/entities/project_filters.dart';

/// Accès aux projets — lecture + écriture offline-first.
abstract interface class ProjectRepository {
  Stream<List<Project>> watchList(ProjectFilters filters, {int? userId});

  Stream<Project?> watchById(int localId);

  /// Stream des projets d'un tiers (par PK locale du tiers).
  Stream<List<Project>> watchByThirdPartyLocal(int thirdPartyLocalId);

  Future<Result<int>> refreshPage({
    required ProjectFilters filters,
    required int page,
    int limit = 100,
    int? userId,
  });

  Future<Result<Project>> refreshById(int remoteId);

  // -------------- Écritures (Outbox + Optimistic UI) ----------------

  /// Crée un projet localement (`pendingCreate`) et enqueue une op
  /// create. Si le tiers parent est en pendingCreate, la cascade
  /// `dependsOnLocalId` est câblée automatiquement.
  Future<Result<int>> createLocal(Project draft);

  /// Met à jour un projet en `pendingUpdate` et enqueue update.
  Future<Result<void>> updateLocal(Project entity);

  /// Marque le projet en `pendingDelete` et enqueue une op delete.
  /// Si le projet n'a pas de `remoteId`, suppression locale immédiate.
  Future<Result<void>> deleteLocal(int localId);

  // ----------------------- Brouillons -------------------------------

  Stream<Map<String, Object?>?> watchDraft({int? refLocalId});
  Future<void> saveDraft({
    required Map<String, Object?> fields,
    int? refLocalId,
  });
  Future<void> discardDraft({int? refLocalId});
}
