import 'package:dolibarr_mobile/core/di/providers.dart';
import 'package:dolibarr_mobile/core/preferences/tweaks.dart';
import 'package:dolibarr_mobile/features/invoices/data/datasources/invoice_local_dao.dart';
import 'package:dolibarr_mobile/features/invoices/data/datasources/invoice_remote_datasource.dart';
import 'package:dolibarr_mobile/features/invoices/data/repositories/invoice_repository_impl.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice_filters.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice_line.dart';
import 'package:dolibarr_mobile/features/invoices/domain/repositories/invoice_repository.dart';
import 'package:dolibarr_mobile/features/thirdparties/presentation/providers/third_party_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final invoiceRemoteDataSourceProvider =
    Provider<InvoiceRemoteDataSource>((ref) {
  return InvoiceRemoteDataSourceImpl(ref.watch(dioProvider));
});

final invoiceLocalDaoProvider = Provider<InvoiceLocalDao>((ref) {
  return InvoiceLocalDao(ref.watch(appDatabaseProvider));
});

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  return InvoiceRepositoryImpl(
    remote: ref.watch(invoiceRemoteDataSourceProvider),
    dao: ref.watch(invoiceLocalDaoProvider),
    network: ref.watch(networkInfoProvider),
    draftDao: ref.watch(draftLocalDaoProvider),
    outbox: ref.watch(pendingOperationDaoProvider),
  );
});

final invoiceFiltersProvider =
    NotifierProvider<InvoiceFiltersNotifier, InvoiceFilters>(
  InvoiceFiltersNotifier.new,
);

/// Clés `SharedPreferences` pour la persistance du tri.
const _kInvoiceSortBy = 'invoices.sortBy';
const _kInvoiceSortDesc = 'invoices.sortDescending';

class InvoiceFiltersNotifier extends Notifier<InvoiceFilters> {
  @override
  InvoiceFilters build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final sortByName = prefs.getString(_kInvoiceSortBy);
    final sortBy = InvoiceSortBy.values.firstWhere(
      (v) => v.name == sortByName,
      orElse: () => InvoiceSortBy.dateInvoice,
    );
    final sortDesc = prefs.getBool(_kInvoiceSortDesc) ?? true;
    return InvoiceFilters(
      sortBy: sortBy,
      sortDescending: sortDesc,
    );
  }

  void setSearch(String search) =>
      state = state.copyWith(search: search);

  void toggleStatus(InvoiceStatus s) {
    final next = {...state.statuses};
    if (next.contains(s)) {
      next.remove(s);
    } else {
      next.add(s);
    }
    state = state.copyWith(statuses: next);
  }

  void setUnpaidOnly({required bool value}) =>
      state = state.copyWith(unpaidOnly: value);

  void setDateFrom(DateTime? d) => state = d == null
      ? state.copyWith(clearDateFrom: true)
      : state.copyWith(dateFrom: d);

  void setDateTo(DateTime? d) => state = d == null
      ? state.copyWith(clearDateTo: true)
      : state.copyWith(dateTo: d);

  /// Active un critère de tri. Si déjà actif → inverse le sens.
  Future<void> setSort(InvoiceSortBy by) async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (state.sortBy == by) {
      final next = !state.sortDescending;
      state = state.copyWith(sortDescending: next);
      await prefs.setBool(_kInvoiceSortDesc, next);
    } else {
      state = state.copyWith(sortBy: by, sortDescending: true);
      await prefs.setString(_kInvoiceSortBy, by.name);
      await prefs.setBool(_kInvoiceSortDesc, true);
    }
  }

  void reset() => state = const InvoiceFilters();
}

final invoicesListProvider =
    StreamProvider.autoDispose<List<Invoice>>((ref) {
  final filters = ref.watch(invoiceFiltersProvider);
  return ref.watch(invoiceRepositoryProvider).watchList(filters);
});

final invoiceByIdProvider =
    StreamProvider.autoDispose.family<Invoice?, int>((ref, localId) {
  return ref.watch(invoiceRepositoryProvider).watchById(localId);
});

final invoicesByThirdPartyLocalProvider =
    StreamProvider.autoDispose.family<List<Invoice>, int>((ref, localId) {
  return ref
      .watch(invoiceRepositoryProvider)
      .watchByThirdPartyLocal(localId);
});

final invoiceLinesByInvoiceLocalProvider = StreamProvider.autoDispose
    .family<List<InvoiceLine>, int>((ref, invoiceLocalId) {
  return ref
      .watch(invoiceRepositoryProvider)
      .watchLinesByInvoiceLocal(invoiceLocalId);
});
