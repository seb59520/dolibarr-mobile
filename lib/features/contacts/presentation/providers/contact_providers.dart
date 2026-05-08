import 'package:dolibarr_mobile/core/di/providers.dart';
import 'package:dolibarr_mobile/features/contacts/data/datasources/contact_local_dao.dart';
import 'package:dolibarr_mobile/features/contacts/data/datasources/contact_remote_datasource.dart';
import 'package:dolibarr_mobile/features/contacts/data/repositories/contact_repository_impl.dart';
import 'package:dolibarr_mobile/features/contacts/domain/entities/contact.dart';
import 'package:dolibarr_mobile/features/contacts/domain/entities/contact_filters.dart';
import 'package:dolibarr_mobile/features/contacts/domain/repositories/contact_repository.dart';
import 'package:dolibarr_mobile/features/thirdparties/presentation/providers/third_party_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final contactRemoteDataSourceProvider =
    Provider<ContactRemoteDataSource>((ref) {
  return ContactRemoteDataSourceImpl(ref.watch(dioProvider));
});

final contactLocalDaoProvider = Provider<ContactLocalDao>((ref) {
  return ContactLocalDao(ref.watch(appDatabaseProvider));
});

final contactRepositoryProvider = Provider<ContactRepository>((ref) {
  return ContactRepositoryImpl(
    remote: ref.watch(contactRemoteDataSourceProvider),
    dao: ref.watch(contactLocalDaoProvider),
    network: ref.watch(networkInfoProvider),
    draftDao: ref.watch(draftLocalDaoProvider),
    outbox: ref.watch(pendingOperationDaoProvider),
  );
});

final contactFiltersProvider =
    NotifierProvider<ContactFiltersNotifier, ContactFilters>(
  ContactFiltersNotifier.new,
);

class ContactFiltersNotifier extends Notifier<ContactFilters> {
  @override
  ContactFilters build() => const ContactFilters();

  void setSearch(String search) =>
      state = state.copyWith(search: search);

  void setHasEmail({required bool value}) =>
      state = state.copyWith(hasEmail: value);

  void setHasPhone({required bool value}) =>
      state = state.copyWith(hasPhone: value);

  void setThirdParty(int? remoteId) => state = remoteId == null
      ? state.copyWith(clearThirdParty: true)
      : state.copyWith(thirdPartyRemoteId: remoteId);

  void reset() => state = const ContactFilters();
}

final contactsListProvider =
    StreamProvider.autoDispose<List<Contact>>((ref) {
  final filters = ref.watch(contactFiltersProvider);
  return ref.watch(contactRepositoryProvider).watchList(filters);
});

final contactByIdProvider =
    StreamProvider.autoDispose.family<Contact?, int>((ref, localId) {
  return ref.watch(contactRepositoryProvider).watchById(localId);
});

/// Contacts d'un tiers (par PK locale du tiers).
final contactsByThirdPartyLocalProvider =
    StreamProvider.autoDispose.family<List<Contact>, int>((ref, localId) {
  return ref
      .watch(contactRepositoryProvider)
      .watchByThirdPartyLocal(localId);
});
