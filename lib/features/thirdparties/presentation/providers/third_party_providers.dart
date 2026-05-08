import 'package:dolibarr_mobile/core/di/providers.dart';
import 'package:dolibarr_mobile/core/storage/pending_operation_dao.dart';
import 'package:dolibarr_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:dolibarr_mobile/features/thirdparties/data/datasources/draft_local_dao.dart';
import 'package:dolibarr_mobile/features/thirdparties/data/datasources/third_party_local_dao.dart';
import 'package:dolibarr_mobile/features/thirdparties/data/datasources/third_party_remote_datasource.dart';
import 'package:dolibarr_mobile/features/thirdparties/data/repositories/third_party_repository_impl.dart';
import 'package:dolibarr_mobile/features/thirdparties/domain/entities/third_party.dart';
import 'package:dolibarr_mobile/features/thirdparties/domain/entities/third_party_filters.dart';
import 'package:dolibarr_mobile/features/thirdparties/domain/repositories/third_party_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final thirdPartyRemoteDataSourceProvider =
    Provider<ThirdPartyRemoteDataSource>((ref) {
  return ThirdPartyRemoteDataSourceImpl(ref.watch(dioProvider));
});

final thirdPartyLocalDaoProvider = Provider<ThirdPartyLocalDao>((ref) {
  return ThirdPartyLocalDao(ref.watch(appDatabaseProvider));
});

final draftLocalDaoProvider = Provider<DraftLocalDao>((ref) {
  return DraftLocalDao(ref.watch(appDatabaseProvider));
});

final pendingOperationDaoProvider = Provider<PendingOperationDao>((ref) {
  return PendingOperationDao(ref.watch(appDatabaseProvider));
});

final thirdPartyRepositoryProvider = Provider<ThirdPartyRepository>((ref) {
  return ThirdPartyRepositoryImpl(
    remote: ref.watch(thirdPartyRemoteDataSourceProvider),
    dao: ref.watch(thirdPartyLocalDaoProvider),
    network: ref.watch(networkInfoProvider),
    draftDao: ref.watch(draftLocalDaoProvider),
    outbox: ref.watch(pendingOperationDaoProvider),
  );
});

/// Filtres courants — modifiés depuis la liste / les bottom-sheet.
final thirdPartyFiltersProvider =
    NotifierProvider<ThirdPartyFiltersNotifier, ThirdPartyFilters>(
  ThirdPartyFiltersNotifier.new,
);

class ThirdPartyFiltersNotifier extends Notifier<ThirdPartyFilters> {
  @override
  ThirdPartyFilters build() => const ThirdPartyFilters();

  void setSearch(String search) =>
      state = state.copyWith(search: search);

  void toggleKind(ThirdPartyKind kind) {
    final next = {...state.kinds};
    if (next.contains(kind)) {
      next.remove(kind);
    } else {
      next.add(kind);
    }
    state = state.copyWith(kinds: next);
  }

  void setActiveOnly({required bool value}) =>
      state = state.copyWith(activeOnly: value);

  void setMyOnly({required bool value}) =>
      state = state.copyWith(myOnly: value);

  void setCategories(Set<int> ids) =>
      state = state.copyWith(categoryIds: ids);

  void reset() => state = const ThirdPartyFilters();
}

/// Liste réactive de tiers selon les filtres + l'utilisateur connecté.
final thirdPartiesListProvider =
    StreamProvider.autoDispose<List<ThirdParty>>((ref) {
  final filters = ref.watch(thirdPartyFiltersProvider);
  final auth = ref.watch(authNotifierProvider);
  final userId = auth is AuthAuthenticated ? auth.session.userId : null;
  return ref.watch(thirdPartyRepositoryProvider).watchList(
        filters,
        userId: userId,
      );
});

/// Détail réactif d'un tiers par son `localId` Drift.
final thirdPartyByIdProvider =
    StreamProvider.autoDispose.family<ThirdParty?, int>((ref, localId) {
  return ref.watch(thirdPartyRepositoryProvider).watchById(localId);
});
