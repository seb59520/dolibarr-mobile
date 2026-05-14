import 'package:dolibarr_mobile/core/di/providers.dart';
import 'package:dolibarr_mobile/core/preferences/tweaks.dart';
import 'package:dolibarr_mobile/features/invoices/presentation/providers/invoice_providers.dart';
import 'package:dolibarr_mobile/features/proposals/data/datasources/proposal_local_dao.dart';
import 'package:dolibarr_mobile/features/proposals/data/datasources/proposal_remote_datasource.dart';
import 'package:dolibarr_mobile/features/proposals/data/repositories/proposal_repository_impl.dart';
import 'package:dolibarr_mobile/features/proposals/domain/entities/proposal.dart';
import 'package:dolibarr_mobile/features/proposals/domain/entities/proposal_filters.dart';
import 'package:dolibarr_mobile/features/proposals/domain/entities/proposal_line.dart';
import 'package:dolibarr_mobile/features/proposals/domain/repositories/proposal_repository.dart';
import 'package:dolibarr_mobile/features/thirdparties/presentation/providers/third_party_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final proposalRemoteDataSourceProvider =
    Provider<ProposalRemoteDataSource>((ref) {
  return ProposalRemoteDataSourceImpl(ref.watch(dioProvider));
});

final proposalLocalDaoProvider = Provider<ProposalLocalDao>((ref) {
  return ProposalLocalDao(ref.watch(appDatabaseProvider));
});

final proposalRepositoryProvider = Provider<ProposalRepository>((ref) {
  return ProposalRepositoryImpl(
    remote: ref.watch(proposalRemoteDataSourceProvider),
    dao: ref.watch(proposalLocalDaoProvider),
    network: ref.watch(networkInfoProvider),
    draftDao: ref.watch(draftLocalDaoProvider),
    outbox: ref.watch(pendingOperationDaoProvider),
    invoiceRemote: ref.watch(invoiceRemoteDataSourceProvider),
    invoiceDao: ref.watch(invoiceLocalDaoProvider),
  );
});

final proposalFiltersProvider =
    NotifierProvider<ProposalFiltersNotifier, ProposalFilters>(
  ProposalFiltersNotifier.new,
);

const _kProposalSortBy = 'proposals.sortBy';
const _kProposalSortDesc = 'proposals.sortDescending';

class ProposalFiltersNotifier extends Notifier<ProposalFilters> {
  @override
  ProposalFilters build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final sortByName = prefs.getString(_kProposalSortBy);
    final sortBy = ProposalSortBy.values.firstWhere(
      (v) => v.name == sortByName,
      orElse: () => ProposalSortBy.dateProposal,
    );
    final sortDesc = prefs.getBool(_kProposalSortDesc) ?? true;
    return ProposalFilters(
      sortBy: sortBy,
      sortDescending: sortDesc,
    );
  }

  void setSearch(String search) =>
      state = state.copyWith(search: search);

  void toggleStatus(ProposalStatus s) {
    final next = {...state.statuses};
    if (next.contains(s)) {
      next.remove(s);
    } else {
      next.add(s);
    }
    state = state.copyWith(statuses: next);
  }

  /// Active un critère de tri. Si déjà actif → inverse le sens.
  Future<void> setSort(ProposalSortBy by) async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (state.sortBy == by) {
      final next = !state.sortDescending;
      state = state.copyWith(sortDescending: next);
      await prefs.setBool(_kProposalSortDesc, next);
    } else {
      state = state.copyWith(sortBy: by, sortDescending: true);
      await prefs.setString(_kProposalSortBy, by.name);
      await prefs.setBool(_kProposalSortDesc, true);
    }
  }

  void reset() => state = const ProposalFilters();
}

final proposalsListProvider =
    StreamProvider.autoDispose<List<Proposal>>((ref) {
  final filters = ref.watch(proposalFiltersProvider);
  return ref.watch(proposalRepositoryProvider).watchList(filters);
});

final proposalByIdProvider =
    StreamProvider.autoDispose.family<Proposal?, int>((ref, localId) {
  return ref.watch(proposalRepositoryProvider).watchById(localId);
});

final proposalsByThirdPartyLocalProvider =
    StreamProvider.autoDispose.family<List<Proposal>, int>((ref, localId) {
  return ref
      .watch(proposalRepositoryProvider)
      .watchByThirdPartyLocal(localId);
});

final proposalLinesByProposalLocalProvider = StreamProvider.autoDispose
    .family<List<ProposalLine>, int>((ref, proposalLocalId) {
  return ref
      .watch(proposalRepositoryProvider)
      .watchLinesByProposalLocal(proposalLocalId);
});
