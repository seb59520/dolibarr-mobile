import 'package:dolibarr_mobile/core/errors/error_mapper.dart';
import 'package:dolibarr_mobile/core/network/network_info.dart';
import 'package:dolibarr_mobile/core/storage/pending_operation_dao.dart';
import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/tasks/data/datasources/task_local_dao.dart';
import 'package:dolibarr_mobile/features/tasks/data/datasources/task_remote_datasource.dart';
import 'package:dolibarr_mobile/features/tasks/domain/entities/task.dart';
import 'package:dolibarr_mobile/features/tasks/domain/entities/task_filters.dart';
import 'package:dolibarr_mobile/features/tasks/domain/repositories/task_repository.dart';
import 'package:dolibarr_mobile/features/thirdparties/data/datasources/draft_local_dao.dart';

const _draftEntityType = 'task';

final class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl({
    required TaskRemoteDataSource remote,
    required TaskLocalDao dao,
    required NetworkInfo network,
    required DraftLocalDao draftDao,
    required PendingOperationDao outbox,
  })  : _remote = remote,
        _dao = dao,
        _network = network,
        _draftDao = draftDao,
        _outbox = outbox;

  final TaskRemoteDataSource _remote;
  final TaskLocalDao _dao;
  final NetworkInfo _network;
  final DraftLocalDao _draftDao;
  final PendingOperationDao _outbox;

  @override
  Stream<List<Task>> watchList(TaskFilters filters, {int? userId}) {
    if (_network.isOnline) {
      // ignore: unawaited_futures
      refreshPage(filters: filters, page: 0, userId: userId);
    }
    return _dao.watchFiltered(filters);
  }

  @override
  Stream<Task?> watchById(int localId) => _dao.watchById(localId);

  @override
  Stream<List<Task>> watchByProjectLocal(int projectLocalId) =>
      _dao.watchByProjectLocal(projectLocalId);

  @override
  Future<Result<int>> refreshPage({
    required TaskFilters filters,
    required int page,
    int limit = 100,
    int? userId,
  }) async {
    try {
      final rows = await _remote.fetchPage(
        filters: filters,
        page: page,
        limit: limit,
        userId: userId,
      );
      await _dao.upsertManyFromServer(rows);
      return Success(rows.length);
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }

  @override
  Future<Result<int>> refreshForProject(int projectRemoteId) async {
    try {
      final rows = await _remote.fetchByProject(projectRemoteId);
      await _dao.upsertManyFromServer(rows);
      return Success(rows.length);
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }

  @override
  Future<Result<Task>> refreshById(int remoteId) async {
    try {
      final json = await _remote.fetchById(remoteId);
      await _dao.upsertFromServer(json);
      final fresh = await _dao.findByRemoteId(remoteId);
      if (fresh == null) {
        throw StateError('Tâche $remoteId introuvable après upsert');
      }
      return Success(fresh);
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }

  @override
  Future<Result<int>> createLocal(Task draft) async {
    try {
      final localId = await _dao.insertLocal(draft);

      // Cascade : si le projet parent n'a pas de remoteId, on cherche
      // son op create en attente pour bloquer la tâche derrière.
      int? dependsOnLocalId;
      if (draft.projectRemote == null && draft.projectLocal != null) {
        dependsOnLocalId = await _outbox.findLatestPendingCreate(
          entityType: PendingOpEntity.project,
          targetLocalId: draft.projectLocal!,
        );
      }

      await _outbox.enqueue(
        opType: PendingOpType.create,
        entityType: PendingOpEntity.task,
        targetLocalId: localId,
        payload: _payloadFor(draft),
        dependsOnLocalId: dependsOnLocalId,
      );
      return Success(localId);
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }

  @override
  Future<Result<void>> updateLocal(Task entity) async {
    try {
      await _dao.updateLocal(entity);
      await _outbox.enqueue(
        opType: PendingOpType.update,
        entityType: PendingOpEntity.task,
        targetLocalId: entity.localId,
        targetRemoteId: entity.remoteId,
        payload: _payloadFor(entity),
        expectedTms: entity.tms,
      );
      return const Success<void>(null);
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }

  @override
  Future<Result<void>> deleteLocal(int localId) async {
    try {
      final current = await _dao.watchById(localId).first;
      if (current == null) return const Success<void>(null);
      if (current.remoteId == null) {
        await _outbox.deleteForLocal(
          entityType: PendingOpEntity.task,
          targetLocalId: localId,
        );
        await _dao.hardDelete(localId);
        return const Success<void>(null);
      }
      await _dao.markPendingDelete(localId);
      await _outbox.enqueue(
        opType: PendingOpType.delete,
        entityType: PendingOpEntity.task,
        targetLocalId: localId,
        targetRemoteId: current.remoteId,
        expectedTms: current.tms,
      );
      return const Success<void>(null);
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }

  @override
  Stream<Map<String, Object?>?> watchDraft({int? refLocalId}) =>
      _draftDao.watch(entityType: _draftEntityType, refLocalId: refLocalId);

  @override
  Future<void> saveDraft({
    required Map<String, Object?> fields,
    int? refLocalId,
  }) =>
      _draftDao.save(
        entityType: _draftEntityType,
        fields: fields,
        refLocalId: refLocalId,
      );

  @override
  Future<void> discardDraft({int? refLocalId}) =>
      _draftDao.discard(
        entityType: _draftEntityType,
        refLocalId: refLocalId,
      );

  Map<String, Object?> _payloadFor(Task t) {
    return {
      // fk_projet : préférer remote ; le SyncEngine patchera après
      // push du projet parent (cf. dependsOnLocalId).
      if (t.projectRemote != null) 'fk_projet': t.projectRemote,
      if (t.ref != null) 'ref': t.ref,
      'label': t.label,
      if (t.description != null) 'description': t.description,
      'status': t.status.apiValue,
      'progress': t.progress,
      if (t.plannedHours != null) 'planned_workload': t.plannedHours,
      if (t.fkUser != null) 'fk_user': t.fkUser,
      if (t.dateStart != null)
        'date_start': t.dateStart!.millisecondsSinceEpoch ~/ 1000,
      if (t.dateEnd != null)
        'date_end': t.dateEnd!.millisecondsSinceEpoch ~/ 1000,
      if (t.extrafields.isNotEmpty) 'array_options': t.extrafields,
    };
  }
}
