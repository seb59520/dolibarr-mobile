import 'package:dolibarr_mobile/features/invoices/data/datasources/invoice_payment_local_dao.dart';
import 'package:dolibarr_mobile/features/invoices/presentation/providers/invoice_providers.dart';
import 'package:dolibarr_mobile/features/stats/data/repositories/stats_repository_impl.dart';
import 'package:dolibarr_mobile/features/stats/data/services/payment_sync_service.dart';
import 'package:dolibarr_mobile/features/stats/domain/entities/stats_snapshot.dart';
import 'package:dolibarr_mobile/features/stats/domain/repositories/stats_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final invoicePaymentLocalDaoProvider =
    Provider<InvoicePaymentLocalDao>((ref) {
  final invoiceDao = ref.watch(invoiceLocalDaoProvider);
  return InvoicePaymentLocalDao(invoiceDao.attachedDatabase);
});

final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  return StatsRepositoryImpl(
    invoiceDao: ref.watch(invoiceLocalDaoProvider),
    paymentDao: ref.watch(invoicePaymentLocalDaoProvider),
  );
});

final paymentSyncServiceProvider = Provider<PaymentSyncService>((ref) {
  return PaymentSyncService(
    invoiceDao: ref.watch(invoiceLocalDaoProvider),
    paymentDao: ref.watch(invoicePaymentLocalDaoProvider),
    remote: ref.watch(invoiceRemoteDataSourceProvider),
  );
});

final statsSnapshotProvider =
    StreamProvider.autoDispose<StatsSnapshot>((ref) {
  return ref.watch(statsRepositoryProvider).watchSnapshot();
});
