import 'package:dolibarr_mobile/core/di/providers.dart';
import 'package:dolibarr_mobile/features/products/data/datasources/product_local_dao.dart';
import 'package:dolibarr_mobile/features/products/data/datasources/product_remote_datasource.dart';
import 'package:dolibarr_mobile/features/products/data/repositories/product_repository_impl.dart';
import 'package:dolibarr_mobile/features/products/domain/entities/product.dart';
import 'package:dolibarr_mobile/features/products/domain/repositories/product_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final productRemoteDataSourceProvider =
    Provider<ProductRemoteDataSource>((ref) {
  return ProductRemoteDataSourceImpl(ref.watch(dioProvider));
});

final productLocalDaoProvider = Provider<ProductLocalDao>((ref) {
  return ProductLocalDao(ref.watch(appDatabaseProvider));
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(
    remote: ref.watch(productRemoteDataSourceProvider),
    dao: ref.watch(productLocalDaoProvider),
    network: ref.watch(networkInfoProvider),
  );
});

final productsListProvider =
    StreamProvider.autoDispose.family<List<Product>, String>((ref, search) {
  return ref.watch(productRepositoryProvider).watch(search: search);
});
