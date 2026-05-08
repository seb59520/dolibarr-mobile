import 'package:dolibarr_mobile/core/errors/error_mapper.dart';
import 'package:dolibarr_mobile/core/network/network_info.dart';
import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/thirdparties/data/datasources/third_party_local_dao.dart';
import 'package:dolibarr_mobile/features/thirdparties/data/datasources/third_party_remote_datasource.dart';
import 'package:dolibarr_mobile/features/thirdparties/domain/entities/third_party.dart';
import 'package:dolibarr_mobile/features/thirdparties/domain/entities/third_party_filters.dart';
import 'package:dolibarr_mobile/features/thirdparties/domain/repositories/third_party_repository.dart';

final class ThirdPartyRepositoryImpl implements ThirdPartyRepository {
  ThirdPartyRepositoryImpl({
    required ThirdPartyRemoteDataSource remote,
    required ThirdPartyLocalDao dao,
    required NetworkInfo network,
  })  : _remote = remote,
        _dao = dao,
        _network = network;

  final ThirdPartyRemoteDataSource _remote;
  final ThirdPartyLocalDao _dao;
  final NetworkInfo _network;

  @override
  Stream<List<ThirdParty>> watchList(
    ThirdPartyFilters filters, {
    int? userId,
  }) {
    if (_network.isOnline) {
      // Premier refresh fire-and-forget — la pagination suivante
      // est pilotée par l'UI via `refreshPage(page: N)`.
      // ignore: unawaited_futures
      refreshPage(filters: filters, page: 0, userId: userId);
    }
    return _dao.watchFiltered(filters);
  }

  @override
  Stream<ThirdParty?> watchById(int localId) => _dao.watchById(localId);

  @override
  Future<Result<int>> refreshPage({
    required ThirdPartyFilters filters,
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
  Future<Result<ThirdParty>> refreshById(int remoteId) async {
    try {
      final json = await _remote.fetchById(remoteId);
      await _dao.upsertFromServer(json);
      final fresh = await _dao.findByRemoteId(remoteId);
      if (fresh == null) {
        throw StateError('Tier $remoteId introuvable après upsert');
      }
      return Success(fresh);
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }
}
