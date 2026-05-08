import 'package:dolibarr_mobile/core/errors/error_mapper.dart';
import 'package:dolibarr_mobile/core/network/network_info.dart';
import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/projects/data/datasources/project_local_dao.dart';
import 'package:dolibarr_mobile/features/projects/data/datasources/project_remote_datasource.dart';
import 'package:dolibarr_mobile/features/projects/domain/entities/project.dart';
import 'package:dolibarr_mobile/features/projects/domain/entities/project_filters.dart';
import 'package:dolibarr_mobile/features/projects/domain/repositories/project_repository.dart';

final class ProjectRepositoryImpl implements ProjectRepository {
  ProjectRepositoryImpl({
    required ProjectRemoteDataSource remote,
    required ProjectLocalDao dao,
    required NetworkInfo network,
  })  : _remote = remote,
        _dao = dao,
        _network = network;

  final ProjectRemoteDataSource _remote;
  final ProjectLocalDao _dao;
  final NetworkInfo _network;

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
}
