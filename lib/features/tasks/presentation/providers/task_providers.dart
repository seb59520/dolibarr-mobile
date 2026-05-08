import 'package:dolibarr_mobile/core/di/providers.dart';
import 'package:dolibarr_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:dolibarr_mobile/features/tasks/data/datasources/task_local_dao.dart';
import 'package:dolibarr_mobile/features/tasks/data/datasources/task_remote_datasource.dart';
import 'package:dolibarr_mobile/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:dolibarr_mobile/features/tasks/domain/entities/task.dart';
import 'package:dolibarr_mobile/features/tasks/domain/repositories/task_repository.dart';
import 'package:dolibarr_mobile/features/thirdparties/presentation/providers/third_party_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final taskRemoteDataSourceProvider = Provider<TaskRemoteDataSource>((ref) {
  return TaskRemoteDataSourceImpl(ref.watch(dioProvider));
});

final taskLocalDaoProvider = Provider<TaskLocalDao>((ref) {
  return TaskLocalDao(ref.watch(appDatabaseProvider));
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(
    remote: ref.watch(taskRemoteDataSourceProvider),
    dao: ref.watch(taskLocalDaoProvider),
    network: ref.watch(networkInfoProvider),
    draftDao: ref.watch(draftLocalDaoProvider),
    outbox: ref.watch(pendingOperationDaoProvider),
  );
});

final taskByIdProvider =
    StreamProvider.autoDispose.family<Task?, int>((ref, localId) {
  return ref.watch(taskRepositoryProvider).watchById(localId);
});

final tasksByProjectLocalProvider =
    StreamProvider.autoDispose.family<List<Task>, int>((ref, localId) {
  return ref.watch(taskRepositoryProvider).watchByProjectLocal(localId);
});

/// Stream du nb d'utilisateur courant (utile aux filtres mineOnly).
final currentUserIdProvider = Provider<int?>((ref) {
  final auth = ref.watch(authNotifierProvider);
  return auth is AuthAuthenticated ? auth.session.userId : null;
});
