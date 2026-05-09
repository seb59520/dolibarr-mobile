import 'package:dolibarr_mobile/core/errors/error_mapper.dart';
import 'package:dolibarr_mobile/core/network/network_info.dart';
import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/products/data/datasources/product_local_dao.dart';
import 'package:dolibarr_mobile/features/products/data/datasources/product_remote_datasource.dart';
import 'package:dolibarr_mobile/features/products/domain/entities/product.dart';
import 'package:dolibarr_mobile/features/products/domain/repositories/product_repository.dart';

final class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl({
    required ProductRemoteDataSource remote,
    required ProductLocalDao dao,
    required NetworkInfo network,
  })  : _remote = remote,
        _dao = dao,
        _network = network;

  final ProductRemoteDataSource _remote;
  final ProductLocalDao _dao;
  final NetworkInfo _network;

  @override
  Stream<List<Product>> watch({String search = ''}) {
    if (_network.isOnline) {
      // SWR : déclenche un refresh en arrière-plan sans bloquer le watch.
      // ignore: unawaited_futures
      refresh();
    }
    return _dao.watch(search: search);
  }

  @override
  Future<Result<int>> refresh() async {
    try {
      final items = await _remote.fetchAllForSell();
      await _dao.replaceAll(items);
      return Success(items.length);
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }
}
