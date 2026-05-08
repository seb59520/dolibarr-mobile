import 'package:dolibarr_mobile/core/network/network_info.dart';
import 'package:dolibarr_mobile/core/storage/pending_operation_dao.dart';
import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/thirdparties/data/datasources/draft_local_dao.dart';
import 'package:dolibarr_mobile/features/thirdparties/data/datasources/third_party_local_dao.dart';
import 'package:dolibarr_mobile/features/thirdparties/data/datasources/third_party_remote_datasource.dart';
import 'package:dolibarr_mobile/features/thirdparties/data/repositories/third_party_repository_impl.dart';
import 'package:dolibarr_mobile/features/thirdparties/domain/entities/third_party.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements ThirdPartyRemoteDataSource {}

class _MockDao extends Mock implements ThirdPartyLocalDao {}

class _MockNetwork extends Mock implements NetworkInfo {}

class _MockDraftDao extends Mock implements DraftLocalDao {}

class _MockOutbox extends Mock implements PendingOperationDao {}

ThirdParty _entity({
  int localId = 0,
  int? remoteId,
  String name = 'Acme',
  bool isCustomer = true,
  DateTime? tms,
  SyncStatus syncStatus = SyncStatus.synced,
}) {
  return ThirdParty(
    localId: localId,
    remoteId: remoteId,
    name: name,
    localUpdatedAt: DateTime(2026, 5, 8),
    clientFlags: isCustomer ? 1 : 0,
    tms: tms,
    syncStatus: syncStatus,
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(PendingOpType.create);
    registerFallbackValue(PendingOpEntity.thirdparty);
    registerFallbackValue(_entity());
  });

  late _MockRemote remote;
  late _MockDao dao;
  late _MockNetwork network;
  late _MockDraftDao draftDao;
  late _MockOutbox outbox;
  late ThirdPartyRepositoryImpl repo;

  setUp(() {
    remote = _MockRemote();
    dao = _MockDao();
    network = _MockNetwork();
    draftDao = _MockDraftDao();
    outbox = _MockOutbox();
    repo = ThirdPartyRepositoryImpl(
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
  });

  group('createLocal', () {
    test('insère localement et enqueue une op create', () async {
      when(() => dao.insertLocal(any())).thenAnswer((_) async => 42);

      final result = await repo.createLocal(_entity(name: 'Beta'));

      expect((result as Success<int>).value, 42);
      verify(() => dao.insertLocal(any())).called(1);
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
      expect(captured[1], PendingOpEntity.thirdparty);
      expect(captured[2], 42);
      final payload = captured[3] as Map<String, Object?>;
      expect(payload['name'], 'Beta');
    });
  });

  group('updateLocal', () {
    test('met à jour et enqueue update avec expectedTms', () async {
      final tms = DateTime(2026, 4, 2);
      when(() => dao.updateLocal(any())).thenAnswer((_) async {});
      final entity = _entity(localId: 7, remoteId: 99, tms: tms);

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
    test(
        'remoteId null → hardDelete + suppression des ops liées + pas '
        "d'enqueue", () async {
      when(() => dao.watchById(11))
          .thenAnswer((_) => Stream.value(_entity(localId: 11)));
      when(() => dao.hardDelete(any())).thenAnswer((_) async => 1);

      final result = await repo.deleteLocal(11);

      expect(result.isSuccess, isTrue);
      verify(
        () => outbox.deleteForLocal(
          entityType: PendingOpEntity.thirdparty,
          targetLocalId: 11,
        ),
      ).called(1);
      verify(() => dao.hardDelete(11)).called(1);
      verifyNever(
        () => outbox.enqueue(
          opType: any(named: 'opType'),
          entityType: any(named: 'entityType'),
          targetLocalId: any(named: 'targetLocalId'),
        ),
      );
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
      verifyNever(() => dao.hardDelete(any()));
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
      expect(captured[0], PendingOpType.delete);
      expect(captured[1], 5);
      expect(captured[2], 200);
      expect(captured[3], tms);
    });

    test('entité absente → no-op succès', () async {
      when(() => dao.watchById(123))
          .thenAnswer((_) => Stream.value(null));

      final result = await repo.deleteLocal(123);

      expect(result.isSuccess, isTrue);
      verifyNever(() => dao.hardDelete(any()));
      verifyNever(() => dao.markPendingDelete(any()));
    });
  });

  group('drafts', () {
    test('saveDraft délègue au DAO avec le bon entityType', () async {
      when(
        () => draftDao.save(
          entityType: any(named: 'entityType'),
          refLocalId: any(named: 'refLocalId'),
          fields: any(named: 'fields'),
        ),
      ).thenAnswer((_) async {});

      await repo.saveDraft(refLocalId: 7, fields: {'name': 'X'});

      verify(
        () => draftDao.save(
          entityType: 'thirdparty',
          refLocalId: 7,
          fields: {'name': 'X'},
        ),
      ).called(1);
    });

    test('discardDraft délègue avec entityType thirdparty', () async {
      when(
        () => draftDao.discard(
          entityType: any(named: 'entityType'),
          refLocalId: any(named: 'refLocalId'),
        ),
      ).thenAnswer((_) async {});

      await repo.discardDraft();

      verify(
        () => draftDao.discard(
          entityType: 'thirdparty',
          refLocalId: any(named: 'refLocalId'),
        ),
      ).called(1);
    });
  });
}
