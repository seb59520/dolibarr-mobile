import 'package:dolibarr_mobile/core/errors/error_mapper.dart';
import 'package:dolibarr_mobile/core/network/network_info.dart';
import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/extrafields/data/datasources/extrafield_local_dao.dart';
import 'package:dolibarr_mobile/features/extrafields/data/datasources/extrafield_remote_datasource.dart';
import 'package:dolibarr_mobile/features/extrafields/domain/entities/extrafield_definition.dart';
import 'package:dolibarr_mobile/features/extrafields/domain/repositories/extrafield_repository.dart';

final class ExtrafieldRepositoryImpl implements ExtrafieldRepository {
  ExtrafieldRepositoryImpl({
    required ExtrafieldRemoteDataSource remote,
    required ExtrafieldLocalDao dao,
    required NetworkInfo network,
  })  : _remote = remote,
        _dao = dao,
        _network = network;

  final ExtrafieldRemoteDataSource _remote;
  final ExtrafieldLocalDao _dao;
  final NetworkInfo _network;

  @override
  Stream<List<ExtrafieldDefinition>> watchByEntityType(String entityType) {
    if (_network.isOnline) {
      // ignore: unawaited_futures
      refresh();
    }
    return _dao.watchByEntityType(entityType);
  }

  @override
  Future<Result<void>> refresh() async {
    try {
      final fresh = await _remote.fetchAll();
      await _dao.replaceAll(fresh);
      return const Success<void>(null);
    } catch (e, st) {
      return FailureResult<void>(ErrorMapper.toFailure(e, st));
    }
  }
}
