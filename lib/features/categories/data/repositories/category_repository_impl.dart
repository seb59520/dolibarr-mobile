import 'package:dolibarr_mobile/core/errors/error_mapper.dart';
import 'package:dolibarr_mobile/core/network/network_info.dart';
import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/categories/data/datasources/category_local_dao.dart';
import 'package:dolibarr_mobile/features/categories/data/datasources/category_remote_datasource.dart';
import 'package:dolibarr_mobile/features/categories/domain/entities/category.dart';
import 'package:dolibarr_mobile/features/categories/domain/repositories/category_repository.dart';

/// Stale-While-Revalidate : retourne le cache immédiatement (Stream Drift),
/// puis lance une requête API en arrière-plan ; le résultat met à jour
/// la table, ce qui réémet sur le stream.
final class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl({
    required CategoryRemoteDataSource remote,
    required CategoryLocalDao dao,
    required NetworkInfo network,
  })  : _remote = remote,
        _dao = dao,
        _network = network;

  final CategoryRemoteDataSource _remote;
  final CategoryLocalDao _dao;
  final NetworkInfo _network;

  @override
  Stream<List<Category>> watchByType(CategoryType type) {
    // SWR : déclenche le refresh dès le 1er abonnement (fire & forget).
    if (_network.isOnline) {
      // ignore: unawaited_futures
      refresh(type);
    }
    return _dao.watchByType(type);
  }

  @override
  Future<Result<void>> refresh(CategoryType type) async {
    try {
      final fresh = await _remote.fetchByType(type);
      await _dao.replaceAllForType(type, fresh);
      return const Success<void>(null);
    } catch (e, st) {
      return FailureResult<void>(ErrorMapper.toFailure(e, st));
    }
  }
}
