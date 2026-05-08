import 'package:dolibarr_mobile/core/di/providers.dart';
import 'package:dolibarr_mobile/features/categories/data/datasources/category_local_dao.dart';
import 'package:dolibarr_mobile/features/categories/data/datasources/category_remote_datasource.dart';
import 'package:dolibarr_mobile/features/categories/data/repositories/category_repository_impl.dart';
import 'package:dolibarr_mobile/features/categories/domain/entities/category.dart';
import 'package:dolibarr_mobile/features/categories/domain/repositories/category_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final categoryRemoteDataSourceProvider =
    Provider<CategoryRemoteDataSource>((ref) {
  return CategoryRemoteDataSourceImpl(ref.watch(dioProvider));
});

final categoryLocalDaoProvider = Provider<CategoryLocalDao>((ref) {
  return CategoryLocalDao(ref.watch(appDatabaseProvider));
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(
    remote: ref.watch(categoryRemoteDataSourceProvider),
    dao: ref.watch(categoryLocalDaoProvider),
    network: ref.watch(networkInfoProvider),
  );
});

/// Liste réactive des catégories d'un type donné.
final categoriesByTypeProvider =
    StreamProvider.family<List<Category>, CategoryType>((ref, type) {
  return ref.watch(categoryRepositoryProvider).watchByType(type);
});
