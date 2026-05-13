import 'package:dolibarr_mobile/core/errors/exceptions.dart';
import 'package:dolibarr_mobile/features/invoices/data/datasources/invoice_local_dao.dart';
import 'package:dolibarr_mobile/features/invoices/data/datasources/invoice_payment_local_dao.dart';
import 'package:dolibarr_mobile/features/invoices/data/datasources/invoice_remote_datasource.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice_filters.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice_payment.dart';
import 'package:dolibarr_mobile/features/stats/data/services/payment_sync_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockInvoiceDao extends Mock implements InvoiceLocalDao {}

class _MockPaymentDao extends Mock implements InvoicePaymentLocalDao {}

class _MockRemote extends Mock implements InvoiceRemoteDataSource {}

Invoice _inv({
  required int localId,
  required InvoiceStatus status,
  required DateTime date,
  int? remoteId,
}) =>
    Invoice(
      localId: localId,
      remoteId: remoteId,
      status: status,
      dateInvoice: date,
      localUpdatedAt: date,
    );

void main() {
  final now = DateTime(2026, 5, 13);

  late _MockInvoiceDao invoiceDao;
  late _MockPaymentDao paymentDao;
  late _MockRemote remote;
  late PaymentSyncService svc;

  setUp(() {
    invoiceDao = _MockInvoiceDao();
    paymentDao = _MockPaymentDao();
    remote = _MockRemote();
    svc = PaymentSyncService(
      invoiceDao: invoiceDao,
      paymentDao: paymentDao,
      remote: remote,
      clock: () => now,
    );

    registerFallbackValue(<InvoicePayment>[]);
    registerFallbackValue(const InvoiceFilters());
    when(() => paymentDao.replaceForInvoice(any(), any()))
        .thenAnswer((_) async {});
  });

  test(
    'ne scanne que les factures avec remoteId, statut valid/paid, '
    'dateInvoice dans la fenêtre 13 mois',
    () async {
      when(() => invoiceDao.watchFiltered(any())).thenAnswer(
        (_) => Stream.value([
          _inv(
            localId: 1,
            remoteId: 100,
            status: InvoiceStatus.validated,
            date: DateTime(2026, 4),
          ),
          // hors fenêtre (avril 2025 sort de la fenêtre 13 mois qui
          // commence en mai 2025).
          _inv(
            localId: 2,
            remoteId: 101,
            status: InvoiceStatus.paid,
            date: DateTime(2025, 4),
          ),
          // pas de remoteId → on saute.
          _inv(
            localId: 3,
            status: InvoiceStatus.validated,
            date: DateTime(2026, 4),
          ),
        ]),
      );

      when(() => remote.fetchPayments(100)).thenAnswer(
        (_) async => [
          {'id': '1', 'amount': '500', 'datep': '1714521600'},
        ],
      );

      final res = await svc.syncRecent();

      expect(res.invoicesScanned, 1);
      expect(res.paymentsUpserted, 1);
      expect(res.hasErrors, isFalse);
      verify(() => remote.fetchPayments(100)).called(1);
      verifyNever(() => remote.fetchPayments(101));
      verifyNever(() => remote.fetchPayments(any(that: equals(0))));
    },
  );

  test('NetworkException stoppe la boucle et marque une erreur', () async {
    when(() => invoiceDao.watchFiltered(any())).thenAnswer(
      (_) => Stream.value([
        _inv(
          localId: 1,
          remoteId: 100,
          status: InvoiceStatus.validated,
          date: DateTime(2026, 4),
        ),
        _inv(
          localId: 2,
          remoteId: 101,
          status: InvoiceStatus.validated,
          date: DateTime(2026, 3),
        ),
      ]),
    );

    when(() => remote.fetchPayments(any()))
        .thenThrow(const NetworkException());

    final res = await svc.syncRecent();

    expect(res.paymentsUpserted, 0);
    expect(res.errors, hasLength(1));
    expect(res.errors.first, contains('Réseau'));
    // Boucle stoppée après la première exception → un seul appel.
    verify(() => remote.fetchPayments(any())).called(1);
  });

  test('passe le filtre validated + paid au DAO', () async {
    when(() => invoiceDao.watchFiltered(any()))
        .thenAnswer((_) => Stream.value(const []));

    await svc.syncRecent();

    final captured = verify(() => invoiceDao.watchFiltered(captureAny()))
        .captured
        .single as InvoiceFilters;
    expect(
      captured.statuses,
      containsAll([InvoiceStatus.validated, InvoiceStatus.paid]),
    );
  });
}
