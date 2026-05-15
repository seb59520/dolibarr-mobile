import 'package:dolibarr_mobile/core/di/providers.dart';
import 'package:dolibarr_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:dolibarr_mobile/features/expenses/data/datasources/expense_local_dao.dart';
import 'package:dolibarr_mobile/features/expenses/data/datasources/expense_remote_datasource.dart';
import 'package:dolibarr_mobile/features/expenses/data/expense_ticket_pipeline.dart';
import 'package:dolibarr_mobile/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:dolibarr_mobile/features/expenses/domain/entities/expense_filters.dart';
import 'package:dolibarr_mobile/features/expenses/domain/entities/expense_line.dart';
import 'package:dolibarr_mobile/features/expenses/domain/entities/expense_report.dart';
import 'package:dolibarr_mobile/features/expenses/domain/entities/expense_type.dart';
import 'package:dolibarr_mobile/features/expenses/domain/repositories/expense_repository.dart';
import 'package:dolibarr_mobile/features/expenses/presentation/providers/ocr_providers.dart';
import 'package:dolibarr_mobile/features/thirdparties/presentation/providers/third_party_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final expenseRemoteDataSourceProvider =
    Provider<ExpenseRemoteDataSource>((ref) {
  return ExpenseRemoteDataSourceImpl(ref.watch(dioProvider));
});

final expenseLocalDaoProvider = Provider<ExpenseLocalDao>((ref) {
  return ExpenseLocalDao(ref.watch(appDatabaseProvider));
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepositoryImpl(
    remote: ref.watch(expenseRemoteDataSourceProvider),
    dao: ref.watch(expenseLocalDaoProvider),
    network: ref.watch(networkInfoProvider),
    outbox: ref.watch(pendingOperationDaoProvider),
  );
});

final expenseFiltersProvider =
    NotifierProvider<ExpenseFiltersNotifier, ExpenseFilters>(
  ExpenseFiltersNotifier.new,
);

class ExpenseFiltersNotifier extends Notifier<ExpenseFilters> {
  @override
  ExpenseFilters build() => const ExpenseFilters();

  void setSearch(String search) =>
      state = state.copyWith(search: search);

  void toggleStatus(ExpenseReportStatus s) {
    final next = {...state.statuses};
    if (next.contains(s)) {
      next.remove(s);
    } else {
      next.add(s);
    }
    state = state.copyWith(statuses: next);
  }

  void setDateFrom(DateTime? d) => state = d == null
      ? state.copyWith(clearDateFrom: true)
      : state.copyWith(dateFrom: d);

  void setDateTo(DateTime? d) => state = d == null
      ? state.copyWith(clearDateTo: true)
      : state.copyWith(dateTo: d);

  void setSort(ExpenseSortBy by) {
    if (state.sortBy == by) {
      state = state.copyWith(sortDescending: !state.sortDescending);
    } else {
      state = state.copyWith(sortBy: by, sortDescending: true);
    }
  }

  void reset() => state = const ExpenseFilters();
}

final expenseListProvider =
    StreamProvider.autoDispose<List<ExpenseReport>>((ref) {
  final filters = ref.watch(expenseFiltersProvider);
  return ref.watch(expenseRepositoryProvider).watchList(filters);
});

final expenseDetailProvider =
    StreamProvider.autoDispose.family<ExpenseReport?, int>((ref, localId) {
  return ref.watch(expenseRepositoryProvider).watchById(localId);
});

final expenseLinesByReportLocalProvider = StreamProvider.autoDispose
    .family<List<ExpenseLine>, int>((ref, reportLocalId) {
  return ref
      .watch(expenseRepositoryProvider)
      .watchLinesByReportLocal(reportLocalId);
});

/// Cache local du dictionnaire `c_type_fees`. Pull réalisé une fois au
/// premier usage. Le repo expose `refreshTypes()` pour rafraîchir au
/// besoin (depuis un écran de paramétrage ultérieur).
final expenseTypesProvider =
    StreamProvider.autoDispose<List<ExpenseType>>((ref) {
  final repo = ref.watch(expenseRepositoryProvider)
    // ignore: unawaited_futures
    ..refreshTypes();
  return repo.watchTypes();
});

/// Pipeline scan → OCR → push (étape 29).
final expenseTicketPipelineProvider = Provider<ExpenseTicketPipeline>((ref) {
  return ExpenseTicketPipeline(
    ocr: ref.watch(ocrRemoteDataSourceProvider),
    remote: ref.watch(expenseRemoteDataSourceProvider),
    network: ref.watch(networkInfoProvider),
    currentUserId: () {
      final auth = ref.read(authNotifierProvider);
      if (auth is AuthAuthenticated) return auth.session.userId;
      throw StateError(
        'Aucun utilisateur connecté — '
        'impossible de pousser une note de frais.',
      );
    },
    resolveFeeType: (code) =>
        ref.read(expenseLocalDaoProvider).resolveTypeIdByCode(code),
  );
});
