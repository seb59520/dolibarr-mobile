import 'dart:convert';

import 'package:dolibarr_mobile/core/network/network_info.dart';
import 'package:dolibarr_mobile/core/storage/pending_operation_dao.dart';
import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/invoices/data/datasources/invoice_local_dao.dart';
import 'package:dolibarr_mobile/features/invoices/data/datasources/invoice_remote_datasource.dart';
import 'package:dolibarr_mobile/features/invoices/data/repositories/invoice_repository_impl.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice.dart';
import 'package:dolibarr_mobile/features/thirdparties/data/datasources/draft_local_dao.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements InvoiceRemoteDataSource {}

class _MockDao extends Mock implements InvoiceLocalDao {}

class _MockNetwork extends Mock implements NetworkInfo {}

class _MockDraftDao extends Mock implements DraftLocalDao {}

class _MockOutbox extends Mock implements PendingOperationDao {}

Invoice _entity({
  int localId = 5,
  int? remoteId = 100,
  InvoiceStatus status = InvoiceStatus.draft,
  int paye = 0,
}) {
  return Invoice(
    localId: localId,
    remoteId: remoteId,
    socidRemote: 1,
    status: status,
    paye: paye,
    dateInvoice: DateTime(2026, 5, 9),
    localUpdatedAt: DateTime(2026, 5, 9),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(_entity());
  });

  late _MockRemote remote;
  late _MockDao dao;
  late _MockNetwork network;
  late _MockDraftDao draftDao;
  late _MockOutbox outbox;
  late InvoiceRepositoryImpl repo;

  setUp(() {
    remote = _MockRemote();
    dao = _MockDao();
    network = _MockNetwork();
    draftDao = _MockDraftDao();
    outbox = _MockOutbox();
    repo = InvoiceRepositoryImpl(
      remote: remote,
      dao: dao,
      network: network,
      draftDao: draftDao,
      outbox: outbox,
    );
  });

  group('validate', () {
    test('appelle remote.validate puis refresh fetchById', () async {
      when(() => dao.watchById(5))
          .thenAnswer((_) => Stream.value(_entity()));
      when(() => remote.validate(any())).thenAnswer((_) async => {});
      when(() => remote.fetchById(any())).thenAnswer(
        (_) async => {'id': 100, 'fk_statut': 1, 'tms': 1900000000},
      );
      when(() => dao.upsertFromServer(any()))
          .thenAnswer((_) async {});
      when(() => dao.findByRemoteId(any())).thenAnswer(
        (_) async => _entity(status: InvoiceStatus.validated),
      );

      final result = await repo.validate(5);
      expect(result.isSuccess, isTrue);
      verify(() => remote.validate(100)).called(1);
      verify(() => remote.fetchById(100)).called(1);
    });

    test('facture sans remoteId → ValidationFailure', () async {
      when(() => dao.watchById(5))
          .thenAnswer((_) => Stream.value(_entity(remoteId: null)));

      final result = await repo.validate(5);
      expect(result.isFailure, isTrue);
      verifyNever(() => remote.validate(any()));
    });
  });

  group('markAsPaid', () {
    test('appelle remote.markAsPaid', () async {
      when(() => dao.watchById(5)).thenAnswer(
        (_) => Stream.value(_entity(status: InvoiceStatus.validated)),
      );
      when(() => remote.markAsPaid(any())).thenAnswer((_) async => {});
      when(() => remote.fetchById(any())).thenAnswer(
        (_) async => {'id': 100, 'paye': 1, 'fk_statut': 1},
      );
      when(() => dao.upsertFromServer(any())).thenAnswer((_) async {});
      when(() => dao.findByRemoteId(any())).thenAnswer(
        (_) async => _entity(status: InvoiceStatus.paid, paye: 1),
      );

      final result = await repo.markAsPaid(5);
      expect(result.isSuccess, isTrue);
      verify(() => remote.markAsPaid(100)).called(1);
    });
  });

  group('downloadPdf', () {
    test('décode le base64 → bytes', () async {
      final bytes = [37, 80, 68, 70, 45, 49, 46, 52]; // "%PDF-1.4"
      final b64 = base64.encode(bytes);
      when(() => dao.watchById(5))
          .thenAnswer((_) => Stream.value(_entity()));
      when(() => remote.downloadPdf(any())).thenAnswer(
        (_) async => (content: b64, filename: 'FA2026-0001.pdf'),
      );

      final result = await repo.downloadPdf(5);
      expect((result as Success<({List<int> bytes, String filename})>)
          .value.bytes, bytes);
      expect(result.value.filename, 'FA2026-0001.pdf');
    });

    test('décode le base64 même avec sauts de ligne', () async {
      const b64 = 'JVBERi0x\nLjQ=';
      when(() => dao.watchById(5))
          .thenAnswer((_) => Stream.value(_entity()));
      when(() => remote.downloadPdf(any())).thenAnswer(
        (_) async => (content: b64, filename: 'x.pdf'),
      );

      final result = await repo.downloadPdf(5);
      expect(result.isSuccess, isTrue);
    });
  });

  group('createPayment', () {
    test(
      'envoie datepaye seconds + accountid + closepaidinvoices=yes',
      () async {
        when(() => dao.watchById(5)).thenAnswer(
          (_) => Stream.value(_entity(status: InvoiceStatus.validated)),
        );
        when(() => remote.createPayment(any(), any()))
            .thenAnswer((_) async => 42);
        when(() => remote.fetchById(any())).thenAnswer((_) async => {});
        when(() => dao.upsertFromServer(any())).thenAnswer((_) async {});

        final date = DateTime(2026, 5, 10);
        final result = await repo.createPayment(
          localId: 5,
          date: date,
          accountId: 1,
          paymentTypeCode: 'VIR',
          note: 'OK',
        );
        expect((result as Success<int>).value, 42);
        final captured = verify(
          () => remote.createPayment(100, captureAny()),
        ).captured;
        final payload = captured.first as Map<String, Object?>;
        expect(payload['datepaye'], date.millisecondsSinceEpoch ~/ 1000);
        expect(payload['accountid'], 1);
        expect(payload['closepaidinvoices'], 'yes');
        // Le repo résout VIR → 2 (ID Dolibarr c_paiement) car
        // l'endpoint exige un int.
        expect(payload['paymentid'], 2);
        expect(payload['comment'], 'OK');
        expect(payload.containsKey('amount'), isFalse);
      },
    );
  });
}
