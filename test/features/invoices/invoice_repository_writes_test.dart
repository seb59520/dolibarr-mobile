import 'package:dolibarr_mobile/core/network/network_info.dart';
import 'package:dolibarr_mobile/core/storage/pending_operation_dao.dart';
import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/invoices/data/datasources/invoice_local_dao.dart';
import 'package:dolibarr_mobile/features/invoices/data/datasources/invoice_remote_datasource.dart';
import 'package:dolibarr_mobile/features/invoices/data/repositories/invoice_repository_impl.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice_line.dart';
import 'package:dolibarr_mobile/features/thirdparties/data/datasources/draft_local_dao.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements InvoiceRemoteDataSource {}

class _MockDao extends Mock implements InvoiceLocalDao {}

class _MockNetwork extends Mock implements NetworkInfo {}

class _MockDraftDao extends Mock implements DraftLocalDao {}

class _MockOutbox extends Mock implements PendingOperationDao {}

Invoice _entity({
  int localId = 0,
  int? remoteId,
  int? socidLocal,
  int? socidRemote,
  DateTime? tms,
  SyncStatus syncStatus = SyncStatus.synced,
}) {
  return Invoice(
    localId: localId,
    remoteId: remoteId,
    socidLocal: socidLocal,
    socidRemote: socidRemote,
    dateInvoice: DateTime(2026, 5, 9),
    localUpdatedAt: DateTime(2026, 5, 9),
    tms: tms,
    syncStatus: syncStatus,
  );
}

InvoiceLine _line({
  int localId = 0,
  int? remoteId,
  int? invoiceLocal,
  int? invoiceRemote,
  String label = 'Prestation',
  DateTime? tms,
  SyncStatus syncStatus = SyncStatus.synced,
}) {
  return InvoiceLine(
    localId: localId,
    remoteId: remoteId,
    invoiceLocal: invoiceLocal,
    invoiceRemote: invoiceRemote,
    label: label,
    subprice: '100',
    tvaTx: '20',
    localUpdatedAt: DateTime(2026, 5, 9),
    tms: tms,
    syncStatus: syncStatus,
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(PendingOpType.create);
    registerFallbackValue(PendingOpEntity.invoice);
    registerFallbackValue(_entity());
    registerFallbackValue(_line());
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

    when(
      () => outbox.enqueue(
        opType: any(named: 'opType'),
        entityType: any(named: 'entityType'),
        targetLocalId: any(named: 'targetLocalId'),
        targetRemoteId: any(named: 'targetRemoteId'),
        payload: any(named: 'payload'),
        expectedTms: any(named: 'expectedTms'),
        dependsOnLocalId: any(named: 'dependsOnLocalId'),
      ),
    ).thenAnswer((_) async => 1);

    when(
      () => outbox.deleteForLocal(
        entityType: any(named: 'entityType'),
        targetLocalId: any(named: 'targetLocalId'),
      ),
    ).thenAnswer((_) async => 1);

    when(
      () => outbox.findLatestPendingCreate(
        entityType: any(named: 'entityType'),
        targetLocalId: any(named: 'targetLocalId'),
      ),
    ).thenAnswer((_) async => null);
  });

  group('header createLocal', () {
    test('parent synchronisé → pas de cascade, payload contient socid',
        () async {
      when(() => dao.insertLocal(any())).thenAnswer((_) async => 50);
      final result = await repo.createLocal(
        _entity(socidLocal: 5, socidRemote: 200),
      );
      expect((result as Success<int>).value, 50);
      final captured = verify(
        () => outbox.enqueue(
          opType: captureAny(named: 'opType'),
          entityType: captureAny(named: 'entityType'),
          targetLocalId: captureAny(named: 'targetLocalId'),
          targetRemoteId: any(named: 'targetRemoteId'),
          payload: captureAny(named: 'payload'),
          expectedTms: any(named: 'expectedTms'),
          dependsOnLocalId: captureAny(named: 'dependsOnLocalId'),
        ),
      ).captured;
      expect(captured[0], PendingOpType.create);
      expect(captured[1], PendingOpEntity.invoice);
      expect(captured[2], 50);
      final payload = captured[3] as Map<String, Object?>;
      expect(payload['socid'], 200);
      expect(captured[4], isNull);
    });

    test('parent en pendingCreate → dependsOnLocalId vers tiers',
        () async {
      when(() => dao.insertLocal(any())).thenAnswer((_) async => 70);
      when(
        () => outbox.findLatestPendingCreate(
          entityType: PendingOpEntity.thirdparty,
          targetLocalId: 5,
        ),
      ).thenAnswer((_) async => 999);

      final result = await repo.createLocal(_entity(socidLocal: 5));
      expect(result.isSuccess, isTrue);
      final captured = verify(
        () => outbox.enqueue(
          opType: any(named: 'opType'),
          entityType: any(named: 'entityType'),
          targetLocalId: any(named: 'targetLocalId'),
          targetRemoteId: any(named: 'targetRemoteId'),
          payload: any(named: 'payload'),
          expectedTms: any(named: 'expectedTms'),
          dependsOnLocalId: captureAny(named: 'dependsOnLocalId'),
        ),
      ).captured;
      expect(captured.first, 999);
    });
  });

  group('header updateLocal', () {
    test('met à jour + enqueue update avec expectedTms', () async {
      final tms = DateTime(2026, 4);
      when(() => dao.updateLocal(any())).thenAnswer((_) async {});
      final entity =
          _entity(localId: 7, remoteId: 99, socidRemote: 1, tms: tms);
      final result = await repo.updateLocal(entity);
      expect(result.isSuccess, isTrue);
      final captured = verify(
        () => outbox.enqueue(
          opType: captureAny(named: 'opType'),
          entityType: any(named: 'entityType'),
          targetLocalId: captureAny(named: 'targetLocalId'),
          targetRemoteId: captureAny(named: 'targetRemoteId'),
          payload: any(named: 'payload'),
          expectedTms: captureAny(named: 'expectedTms'),
          dependsOnLocalId: any(named: 'dependsOnLocalId'),
        ),
      ).captured;
      expect(captured[0], PendingOpType.update);
      expect(captured[1], 7);
      expect(captured[2], 99);
      expect(captured[3], tms);
    });
  });

  group('header deleteLocal', () {
    test('remoteId null → hardDelete + ops removées', () async {
      when(() => dao.watchById(11))
          .thenAnswer((_) => Stream.value(_entity(localId: 11)));
      when(() => dao.hardDelete(any())).thenAnswer((_) async => 1);
      final result = await repo.deleteLocal(11);
      expect(result.isSuccess, isTrue);
      verify(
        () => outbox.deleteForLocal(
          entityType: PendingOpEntity.invoice,
          targetLocalId: 11,
        ),
      ).called(1);
    });

    test('remoteId présent → markPendingDelete + op delete', () async {
      when(() => dao.watchById(5)).thenAnswer(
        (_) => Stream.value(_entity(localId: 5, remoteId: 200)),
      );
      when(() => dao.markPendingDelete(any())).thenAnswer((_) async {});
      final result = await repo.deleteLocal(5);
      expect(result.isSuccess, isTrue);
      verify(() => dao.markPendingDelete(5)).called(1);
    });
  });

  group('line createLocalLine', () {
    test('facture parente synchronisée → pas de cascade', () async {
      when(() => dao.insertLocalLine(any())).thenAnswer((_) async => 70);
      final result = await repo.createLocalLine(
        _line(invoiceLocal: 10, invoiceRemote: 500),
      );
      expect((result as Success<int>).value, 70);
      verifyNever(
        () => outbox.findLatestPendingCreate(
          entityType: any(named: 'entityType'),
          targetLocalId: any(named: 'targetLocalId'),
        ),
      );
      final captured = verify(
        () => outbox.enqueue(
          opType: captureAny(named: 'opType'),
          entityType: captureAny(named: 'entityType'),
          targetLocalId: captureAny(named: 'targetLocalId'),
          targetRemoteId: any(named: 'targetRemoteId'),
          payload: any(named: 'payload'),
          expectedTms: any(named: 'expectedTms'),
          dependsOnLocalId: captureAny(named: 'dependsOnLocalId'),
        ),
      ).captured;
      expect(captured[0], PendingOpType.create);
      expect(captured[1], PendingOpEntity.invoiceLine);
      expect(captured[2], 70);
      expect(captured[3], isNull);
    });

    test(
        'facture en pendingCreate → cascade dependsOnLocalId vers '
        'op create invoice', () async {
      when(() => dao.insertLocalLine(any())).thenAnswer((_) async => 71);
      when(
        () => outbox.findLatestPendingCreate(
          entityType: PendingOpEntity.invoice,
          targetLocalId: 10,
        ),
      ).thenAnswer((_) async => 555);

      final result = await repo.createLocalLine(_line(invoiceLocal: 10));
      expect(result.isSuccess, isTrue);
      verify(
        () => outbox.findLatestPendingCreate(
          entityType: PendingOpEntity.invoice,
          targetLocalId: 10,
        ),
      ).called(1);
      final captured = verify(
        () => outbox.enqueue(
          opType: any(named: 'opType'),
          entityType: any(named: 'entityType'),
          targetLocalId: any(named: 'targetLocalId'),
          targetRemoteId: any(named: 'targetRemoteId'),
          payload: any(named: 'payload'),
          expectedTms: any(named: 'expectedTms'),
          dependsOnLocalId: captureAny(named: 'dependsOnLocalId'),
        ),
      ).captured;
      expect(captured.first, 555);
    });
  });

  group('line deleteLocalLine', () {
    test('remoteId null → hardDeleteLine + ops removées', () async {
      when(() => dao.findLineByLocalId(11))
          .thenAnswer((_) async => _line(localId: 11));
      when(() => dao.hardDeleteLine(any())).thenAnswer((_) async => 1);
      final result = await repo.deleteLocalLine(11);
      expect(result.isSuccess, isTrue);
      verify(
        () => outbox.deleteForLocal(
          entityType: PendingOpEntity.invoiceLine,
          targetLocalId: 11,
        ),
      ).called(1);
    });

    test('remoteId présent → markLinePendingDelete + op delete',
        () async {
      when(() => dao.findLineByLocalId(5)).thenAnswer(
        (_) async =>
            _line(localId: 5, remoteId: 99, invoiceRemote: 500),
      );
      when(() => dao.markLinePendingDelete(any()))
          .thenAnswer((_) async {});
      final result = await repo.deleteLocalLine(5);
      expect(result.isSuccess, isTrue);
      verify(() => dao.markLinePendingDelete(5)).called(1);
    });
  });

  group('drafts', () {
    test('saveDraft délègue avec entityType invoice', () async {
      when(
        () => draftDao.save(
          entityType: any(named: 'entityType'),
          fields: any(named: 'fields'),
          refLocalId: any(named: 'refLocalId'),
        ),
      ).thenAnswer((_) async {});
      await repo.saveDraft(refLocalId: 7, fields: {'ref_client': 'X'});
      verify(
        () => draftDao.save(
          entityType: 'invoice',
          fields: {'ref_client': 'X'},
          refLocalId: 7,
        ),
      ).called(1);
    });
  });
}
