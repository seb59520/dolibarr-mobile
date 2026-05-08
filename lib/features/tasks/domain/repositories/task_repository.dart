import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/tasks/domain/entities/task.dart';
import 'package:dolibarr_mobile/features/tasks/domain/entities/task_filters.dart';

abstract interface class TaskRepository {
  Stream<List<Task>> watchList(TaskFilters filters, {int? userId});

  Stream<Task?> watchById(int localId);

  /// Stream des tâches d'un projet (par PK locale du projet).
  Stream<List<Task>> watchByProjectLocal(int projectLocalId);

  Future<Result<int>> refreshPage({
    required TaskFilters filters,
    required int page,
    int limit = 100,
    int? userId,
  });

  Future<Result<int>> refreshForProject(int projectRemoteId);

  Future<Result<Task>> refreshById(int remoteId);

  // Écritures
  Future<Result<int>> createLocal(Task draft);
  Future<Result<void>> updateLocal(Task entity);
  Future<Result<void>> deleteLocal(int localId);

  // Brouillons
  Stream<Map<String, Object?>?> watchDraft({int? refLocalId});
  Future<void> saveDraft({
    required Map<String, Object?> fields,
    int? refLocalId,
  });
  Future<void> discardDraft({int? refLocalId});
}
