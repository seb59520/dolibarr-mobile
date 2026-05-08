import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/projects/domain/entities/project.dart';
import 'package:dolibarr_mobile/features/projects/domain/entities/project_filters.dart';

/// Accès aux projets — lecture pour l'Étape 11, écritures Étape 12.
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
}
