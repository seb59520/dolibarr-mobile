import 'package:dolibarr_mobile/core/errors/error_mapper.dart';
import 'package:dolibarr_mobile/core/network/network_info.dart';
import 'package:dolibarr_mobile/core/storage/pending_operation_dao.dart';
import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/projects/data/datasources/project_local_dao.dart';
import 'package:dolibarr_mobile/features/projects/data/datasources/project_remote_datasource.dart';
import 'package:dolibarr_mobile/features/projects/domain/entities/project.dart';
import 'package:dolibarr_mobile/features/projects/domain/entities/project_filters.dart';
import 'package:dolibarr_mobile/features/projects/domain/repositories/project_repository.dart';
import 'package:dolibarr_mobile/features/thirdparties/data/datasources/draft_local_dao.dart';

const _draftEntityType = 'project';

final class ProjectRepositoryImpl implements ProjectRepository {
  ProjectRepositoryImpl({
    required ProjectRemoteDataSource remote,
    required ProjectLocalDao dao,
    required NetworkInfo network,
    required DraftLocalDao draftDao,
    required PendingOperationDao outbox,
  })  : _remote = remote,
        _dao = dao,
        _network = network,
        _draftDao = draftDao,
        _outbox = outbox;

  final ProjectRemoteDataSource _remote;
  final ProjectLocalDao _dao;
  final NetworkInfo _network;
  final DraftLocalDao _draftDao;
  final PendingOperationDao _outbox;

  @override
  Stream<List<Project>> watchList(
    ProjectFilters filters, {
    int? userId,
  }) {
    if (_network.isOnline) {
      // ignore: unawaited_futures
      refreshPage(filters: filters, page: 0, userId: userId);
    }
    return _dao.watchFiltered(filters);
  }

  @override
  Stream<Project?> watchById(int localId) => _dao.watchById(localId);

  @override
  Stream<List<Project>> watchByThirdPartyLocal(int thirdPartyLocalId) =>
      _dao.watchByThirdPartyLocal(thirdPartyLocalId);

  @override
  Future<Result<int>> refreshPage({
    required ProjectFilters filters,
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
  Future<Result<Project>> refreshById(int remoteId) async {
    try {
      final json = await _remote.fetchById(remoteId);
      await _dao.upsertFromServer(json);
      final fresh = await _dao.findByRemoteId(remoteId);
      if (fresh == null) {
        throw StateError('Projet $remoteId introuvable après upsert');
      }
      return Success(fresh);
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }

  @override
  Future<Result<int>> createLocal(Project draft) async {
    try {
      final localId = await _dao.insertLocal(draft);

      // Cascade : si le tiers parent n'a pas de remoteId, on cherche
      // son op create en attente pour bloquer le projet derrière.
      int? dependsOnLocalId;
      if (draft.socidRemote == null && draft.socidLocal != null) {
        dependsOnLocalId = await _outbox.findLatestPendingCreate(
          entityType: PendingOpEntity.thirdparty,
          targetLocalId: draft.socidLocal!,
        );
      }

      await _outbox.enqueue(
        opType: PendingOpType.create,
        entityType: PendingOpEntity.project,
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
  Future<Result<void>> updateLocal(Project entity) async {
    try {
      await _dao.updateLocal(entity);
      await _outbox.enqueue(
        opType: PendingOpType.update,
        entityType: PendingOpEntity.project,
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
          entityType: PendingOpEntity.project,
          targetLocalId: localId,
        );
        await _dao.hardDelete(localId);
        return const Success<void>(null);
      }
      await _dao.markPendingDelete(localId);
      await _outbox.enqueue(
        opType: PendingOpType.delete,
        entityType: PendingOpEntity.project,
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

  /// Construit le payload JSON envoyé à `POST/PUT /projects`.
  Map<String, Object?> _payloadFor(Project p) {
    return {
      // socid : préférer remote ; le sync engine patchera après push
      // du parent (cf. dependsOnLocalId).
      if (p.socidRemote != null) 'socid': p.socidRemote,
      if (p.ref != null) 'ref': p.ref,
      'title': p.title,
      if (p.description != null) 'description': p.description,
      'fk_statut': p.status.apiValue,
      'public': p.publicLevel,
      if (p.fkUserResp != null) 'fk_user_resp': p.fkUserResp,
      if (p.dateStart != null)
        'date_start': p.dateStart!.millisecondsSinceEpoch ~/ 1000,
      if (p.dateEnd != null)
        'date_end': p.dateEnd!.millisecondsSinceEpoch ~/ 1000,
      if (p.budgetAmount != null) 'budget_amount': p.budgetAmount,
      if (p.oppStatus != null) 'fk_opp_status': p.oppStatus,
      if (p.oppAmount != null) 'opp_amount': p.oppAmount,
      if (p.oppPercent != null) 'opp_percent': p.oppPercent,
      if (p.extrafields.isNotEmpty) 'array_options': p.extrafields,
    };
  }
}
