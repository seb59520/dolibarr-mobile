import 'package:dolibarr_mobile/core/di/providers.dart';
import 'package:dolibarr_mobile/features/extrafields/data/datasources/extrafield_local_dao.dart';
import 'package:dolibarr_mobile/features/extrafields/data/datasources/extrafield_remote_datasource.dart';
import 'package:dolibarr_mobile/features/extrafields/data/repositories/extrafield_repository_impl.dart';
import 'package:dolibarr_mobile/features/extrafields/domain/entities/extrafield_definition.dart';
import 'package:dolibarr_mobile/features/extrafields/domain/repositories/extrafield_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final extrafieldRemoteDataSourceProvider =
    Provider<ExtrafieldRemoteDataSource>((ref) {
  return ExtrafieldRemoteDataSourceImpl(ref.watch(dioProvider));
});

final extrafieldLocalDaoProvider = Provider<ExtrafieldLocalDao>((ref) {
  return ExtrafieldLocalDao(ref.watch(appDatabaseProvider));
});

final extrafieldRepositoryProvider = Provider<ExtrafieldRepository>((ref) {
  return ExtrafieldRepositoryImpl(
    remote: ref.watch(extrafieldRemoteDataSourceProvider),
    dao: ref.watch(extrafieldLocalDaoProvider),
    network: ref.watch(networkInfoProvider),
  );
});

/// Définitions des extrafields pour un type d'entité donné.
final extrafieldsByEntityTypeProvider =
    StreamProvider.family<List<ExtrafieldDefinition>, String>(
  (ref, entityType) =>
      ref.watch(extrafieldRepositoryProvider).watchByEntityType(entityType),
);
