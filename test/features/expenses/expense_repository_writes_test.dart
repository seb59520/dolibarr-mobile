import 'package:dolibarr_mobile/core/network/network_info.dart';
import 'package:dolibarr_mobile/core/storage/pending_operation_dao.dart';
import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/expenses/data/datasources/expense_local_dao.dart';
import 'package:dolibarr_mobile/features/expenses/data/datasources/expense_remote_datasource.dart';
import 'package:dolibarr_mobile/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:dolibarr_mobile/features/expenses/domain/entities/expense_line.dart';
import 'package:dolibarr_mobile/features/expenses/domain/entities/expense_report.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements ExpenseRemoteDataSource {}

class _MockDao extends Mock implements ExpenseLocalDao {}

class _MockNetwork extends Mock implements NetworkInfo {}

class _MockOutbox extends Mock implements PendingOperationDao {}

ExpenseReport _entity({
  int localId = 0,
  int? remoteId,
  DateTime? tms,
  SyncStatus syncStatus = SyncStatus.synced,
}) {
  return ExpenseReport(
    localId: localId,
    remoteId: remoteId,
    fkUserAuthor: 5,
    fkUserValid: 5,
    dateDebut: DateTime(2026, 5),
    dateFin: DateTime(2026, 5, 31),
    localUpdatedAt: DateTime(2026, 5, 15),
    tms: tms,
    syncStatus: syncStatus,
  );
}

ExpenseLine _line({
  int localId = 0,
  int? remoteId,
  int? expenseReportLocal,
  int? expenseReportRemote,
  DateTime? tms,
  SyncStatus syncStatus = SyncStatus.synced,
}) {
  return ExpenseLine(
    localId: localId,
    remoteId: remoteId,
    expenseReportLocal: expenseReportLocal,
    expenseReportRemote: expenseReportRemote,
    fkCTypeFees: 3,
    codeCTypeFees: 'TF_LUNCH',
    date: DateTime(2026, 5, 12),
    comments: 'Déjeuner client',
    valueUnit: '15',
    tvaTx: '10',
    localUpdatedAt: DateTime(2026, 5, 15),
    tms: tms,
    syncStatus: syncStatus,
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(PendingOpType.create);
    registerFallbackValue(PendingOpEntity.expenseReport);
    registerFallbackValue(_entity());
    registerFallbackValue(_line());
  });

  late _MockRemote remote;
  late _MockDao dao;
  late _MockNetwork network;
  late _MockOutbox outbox;
  late ExpenseRepositoryImpl repo;

  setUp(() {
    remote = _MockRemote();
    dao = _MockDao();
    network = _MockNetwork();
    outbox = _MockOutbox();
    repo = ExpenseRepositoryImpl(
      remote: remote,
      dao: dao,
      network: network,
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
    test('insère localement et enqueue create expenseReport', () async {
      when(() => dao.insertLocal(any())).thenAnswer((_) async => 42);
      final result = await repo.createLocal(_entity());
      expect((result as Success<int>).value, 42);
      final captured = verify(
        () => outbox.enqueue(
          opType: captureAny(named: 'opType'),
          entityType: captureAny(named: 'entityType'),
          targetLocalId: captureAny(named: 'targetLocalId'),
          targetRemoteId: any(named: 'targetRemoteId'),
          payload: captureAny(named: 'payload'),
          expectedTms: any(named: 'expectedTms'),
          dependsOnLocalId: any(named: 'dependsOnLocalId'),
        ),
      ).captured;
      expect(captured[0], PendingOpType.create);
      expect(captured[1], PendingOpEntity.expenseReport);
      expect(captured[2], 42);
      final payload = captured[3] as Map<String, Object?>;
      // Les timestamps sont sérialisés en unix epoch.
      expect(payload['fk_user_author'], 5);
      expect(payload['fk_user_valid'], 5);
      expect(payload['date_debut'], isA<int>());
      expect(payload['date_fin'], isA<int>());
    });
  });

  group('header updateLocal', () {
    test('enqueue update avec expectedTms', () async {
      final tms = DateTime(2026, 5);
      when(() => dao.updateLocal(any())).thenAnswer((_) async {});
      final entity = _entity(localId: 7, remoteId: 99, tms: tms);
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
          entityType: PendingOpEntity.expenseReport,
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
    test('note parente synchronisée → pas de cascade', () async {
      when(() => dao.insertLocalLine(any())).thenAnswer((_) async => 70);
      final result = await repo.createLocalLine(
        _line(expenseReportLocal: 10, expenseReportRemote: 500),
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
          payload: captureAny(named: 'payload'),
          expectedTms: any(named: 'expectedTms'),
          dependsOnLocalId: captureAny(named: 'dependsOnLocalId'),
        ),
      ).captured;
      expect(captured[0], PendingOpType.create);
      expect(captured[1], PendingOpEntity.expenseLine);
      expect(captured[2], 70);
      final payload = captured[3] as Map<String, Object?>;
      // Champs API attendus (vatrate, pas tva_tx).
      expect(payload['fk_c_type_fees'], 3);
      expect(payload['vatrate'], '10');
      expect(payload['value_unit'], '15');
      expect(payload['qty'], '1');
      expect(payload['date'], isA<int>());
      // pas de dépendance car parent synced
      expect(captured[4], isNull);
    });

    test(
        'note en pendingCreate → cascade dependsOnLocalId vers '
        'op create expenseReport', () async {
      when(() => dao.insertLocalLine(any())).thenAnswer((_) async => 71);
      when(
        () => outbox.findLatestPendingCreate(
          entityType: PendingOpEntity.expenseReport,
          targetLocalId: 10,
        ),
      ).thenAnswer((_) async => 555);

      final result = await repo.createLocalLine(
        _line(expenseReportLocal: 10),
      );
      expect(result.isSuccess, isTrue);
      verify(
        () => outbox.findLatestPendingCreate(
          entityType: PendingOpEntity.expenseReport,
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
          entityType: PendingOpEntity.expenseLine,
          targetLocalId: 11,
        ),
      ).called(1);
    });

    test('remoteId présent → markLinePendingDelete + op delete',
        () async {
      when(() => dao.findLineByLocalId(5)).thenAnswer(
        (_) async => _line(
          localId: 5,
          remoteId: 99,
          expenseReportRemote: 500,
        ),
      );
      when(() => dao.markLinePendingDelete(any()))
          .thenAnswer((_) async {});
      final result = await repo.deleteLocalLine(5);
      expect(result.isSuccess, isTrue);
      verify(() => dao.markLinePendingDelete(5)).called(1);
    });
  });
}
