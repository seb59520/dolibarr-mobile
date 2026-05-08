import 'package:dolibarr_mobile/core/network/network_info.dart';
import 'package:dolibarr_mobile/core/storage/pending_operation_dao.dart';
import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/tasks/data/datasources/task_local_dao.dart';
import 'package:dolibarr_mobile/features/tasks/data/datasources/task_remote_datasource.dart';
import 'package:dolibarr_mobile/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:dolibarr_mobile/features/tasks/domain/entities/task.dart';
import 'package:dolibarr_mobile/features/thirdparties/data/datasources/draft_local_dao.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements TaskRemoteDataSource {}

class _MockDao extends Mock implements TaskLocalDao {}

class _MockNetwork extends Mock implements NetworkInfo {}

class _MockDraftDao extends Mock implements DraftLocalDao {}

class _MockOutbox extends Mock implements PendingOperationDao {}

Task _entity({
  int localId = 0,
  int? remoteId,
  int? projectLocal,
  int? projectRemote,
  String label = 'Cadrage',
  TaskStatus status = TaskStatus.inProgress,
  DateTime? tms,
  SyncStatus syncStatus = SyncStatus.synced,
}) {
  return Task(
    localId: localId,
    remoteId: remoteId,
    projectLocal: projectLocal,
    projectRemote: projectRemote,
    label: label,
    status: status,
    localUpdatedAt: DateTime(2026, 5, 9),
    tms: tms,
    syncStatus: syncStatus,
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(PendingOpType.create);
    registerFallbackValue(PendingOpEntity.task);
    registerFallbackValue(_entity());
  });

  late _MockRemote remote;
  late _MockDao dao;
  late _MockNetwork network;
  late _MockDraftDao draftDao;
  late _MockOutbox outbox;
  late TaskRepositoryImpl repo;

  setUp(() {
    remote = _MockRemote();
    dao = _MockDao();
    network = _MockNetwork();
    draftDao = _MockDraftDao();
    outbox = _MockOutbox();
    repo = TaskRepositoryImpl(
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

  group('createLocal', () {
    test('parent synchronisé (projectRemote présent) → pas de cascade',
        () async {
      when(() => dao.insertLocal(any())).thenAnswer((_) async => 50);

      final result = await repo.createLocal(
        _entity(projectLocal: 5, projectRemote: 200),
      );

      expect((result as Success<int>).value, 50);
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
      expect(captured[1], PendingOpEntity.task);
      expect(captured[2], 50);
      final payload = captured[3] as Map<String, Object?>;
      expect(payload['fk_projet'], 200);
      expect(payload['label'], 'Cadrage');
      expect(captured[4], isNull);
    });

    test(
        'projet non poussé → cascade dependsOnLocalId vers op create '
        'projet', () async {
      when(() => dao.insertLocal(any())).thenAnswer((_) async => 70);
      when(
        () => outbox.findLatestPendingCreate(
          entityType: PendingOpEntity.project,
          targetLocalId: 5,
        ),
      ).thenAnswer((_) async => 999);

      final result = await repo.createLocal(_entity(projectLocal: 5));

      expect(result.isSuccess, isTrue);
      verify(
        () => outbox.findLatestPendingCreate(
          entityType: PendingOpEntity.project,
          targetLocalId: 5,
        ),
      ).called(1);
      final captured = verify(
        () => outbox.enqueue(
          opType: any(named: 'opType'),
          entityType: any(named: 'entityType'),
          targetLocalId: any(named: 'targetLocalId'),
          targetRemoteId: any(named: 'targetRemoteId'),
          payload: captureAny(named: 'payload'),
          expectedTms: any(named: 'expectedTms'),
          dependsOnLocalId: captureAny(named: 'dependsOnLocalId'),
        ),
      ).captured;
      final payload = captured[0] as Map<String, Object?>;
      expect(payload.containsKey('fk_projet'), isFalse);
      expect(captured[1], 999);
    });
  });

  group('updateLocal', () {
    test('met à jour et enqueue update avec expectedTms', () async {
      final tms = DateTime(2026, 4, 2);
      when(() => dao.updateLocal(any())).thenAnswer((_) async {});
      final entity = _entity(
        localId: 7,
        remoteId: 99,
        projectRemote: 1,
        tms: tms,
      );

      final result = await repo.updateLocal(entity);

      expect(result.isSuccess, isTrue);
      verify(() => dao.updateLocal(entity)).called(1);
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

  group('deleteLocal', () {
    test('remoteId null → hardDelete + ops removées', () async {
      when(() => dao.watchById(11))
          .thenAnswer((_) => Stream.value(_entity(localId: 11)));
      when(() => dao.hardDelete(any())).thenAnswer((_) async => 1);

      final result = await repo.deleteLocal(11);

      expect(result.isSuccess, isTrue);
      verify(
        () => outbox.deleteForLocal(
          entityType: PendingOpEntity.task,
          targetLocalId: 11,
        ),
      ).called(1);
      verify(() => dao.hardDelete(11)).called(1);
    });

    test('remoteId présent → markPendingDelete + op delete', () async {
      final tms = DateTime(2026, 3, 15);
      when(() => dao.watchById(5)).thenAnswer(
        (_) => Stream.value(
          _entity(localId: 5, remoteId: 200, tms: tms),
        ),
      );
      when(() => dao.markPendingDelete(any())).thenAnswer((_) async {});

      final result = await repo.deleteLocal(5);

      expect(result.isSuccess, isTrue);
      verify(() => dao.markPendingDelete(5)).called(1);
    });
  });

  group('drafts', () {
    test('saveDraft délègue avec entityType task', () async {
      when(
        () => draftDao.save(
          entityType: any(named: 'entityType'),
          fields: any(named: 'fields'),
          refLocalId: any(named: 'refLocalId'),
        ),
      ).thenAnswer((_) async {});

      await repo.saveDraft(refLocalId: 7, fields: {'label': 'X'});

      verify(
        () => draftDao.save(
          entityType: 'task',
          fields: {'label': 'X'},
          refLocalId: 7,
        ),
      ).called(1);
    });

    test('discardDraft délègue avec entityType task', () async {
      when(
        () => draftDao.discard(
          entityType: any(named: 'entityType'),
          refLocalId: any(named: 'refLocalId'),
        ),
      ).thenAnswer((_) async {});

      await repo.discardDraft();

      verify(
        () => draftDao.discard(
          entityType: 'task',
          refLocalId: any(named: 'refLocalId'),
        ),
      ).called(1);
    });
  });
}
