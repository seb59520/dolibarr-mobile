import 'package:dolibarr_mobile/core/di/providers.dart';
import 'package:dolibarr_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:dolibarr_mobile/features/projects/data/datasources/project_local_dao.dart';
import 'package:dolibarr_mobile/features/projects/data/datasources/project_remote_datasource.dart';
import 'package:dolibarr_mobile/features/projects/data/repositories/project_repository_impl.dart';
import 'package:dolibarr_mobile/features/projects/domain/entities/project.dart';
import 'package:dolibarr_mobile/features/projects/domain/entities/project_filters.dart';
import 'package:dolibarr_mobile/features/projects/domain/repositories/project_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final projectRemoteDataSourceProvider =
    Provider<ProjectRemoteDataSource>((ref) {
  return ProjectRemoteDataSourceImpl(ref.watch(dioProvider));
});

final projectLocalDaoProvider = Provider<ProjectLocalDao>((ref) {
  return ProjectLocalDao(ref.watch(appDatabaseProvider));
});

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepositoryImpl(
    remote: ref.watch(projectRemoteDataSourceProvider),
    dao: ref.watch(projectLocalDaoProvider),
    network: ref.watch(networkInfoProvider),
  );
});

final projectFiltersProvider =
    NotifierProvider<ProjectFiltersNotifier, ProjectFilters>(
  ProjectFiltersNotifier.new,
);

class ProjectFiltersNotifier extends Notifier<ProjectFilters> {
  @override
  ProjectFilters build() => const ProjectFilters();

  void setSearch(String search) =>
      state = state.copyWith(search: search);

  void toggleStatus(ProjectStatus s) {
    final next = {...state.statuses};
    if (next.contains(s)) {
      next.remove(s);
    } else {
      next.add(s);
    }
    state = state.copyWith(statuses: next);
  }

  void setMineOnly({required bool value}) =>
      state = state.copyWith(mineOnly: value);

  void reset() => state = const ProjectFilters();
}

final projectsListProvider =
    StreamProvider.autoDispose<List<Project>>((ref) {
  final filters = ref.watch(projectFiltersProvider);
  final auth = ref.watch(authNotifierProvider);
  final userId = auth is AuthAuthenticated ? auth.session.userId : null;
  return ref.watch(projectRepositoryProvider).watchList(
        filters,
        userId: userId,
      );
});

final projectByIdProvider =
    StreamProvider.autoDispose.family<Project?, int>((ref, localId) {
  return ref.watch(projectRepositoryProvider).watchById(localId);
});

/// Projets d'un tiers (par PK locale du tiers).
final projectsByThirdPartyLocalProvider =
    StreamProvider.autoDispose.family<List<Project>, int>((ref, localId) {
  return ref
      .watch(projectRepositoryProvider)
      .watchByThirdPartyLocal(localId);
});
