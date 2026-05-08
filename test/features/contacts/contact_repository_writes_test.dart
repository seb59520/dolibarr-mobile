import 'package:dolibarr_mobile/core/network/network_info.dart';
import 'package:dolibarr_mobile/core/storage/pending_operation_dao.dart';
import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/contacts/data/datasources/contact_local_dao.dart';
import 'package:dolibarr_mobile/features/contacts/data/datasources/contact_remote_datasource.dart';
import 'package:dolibarr_mobile/features/contacts/data/repositories/contact_repository_impl.dart';
import 'package:dolibarr_mobile/features/contacts/domain/entities/contact.dart';
import 'package:dolibarr_mobile/features/thirdparties/data/datasources/draft_local_dao.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements ContactRemoteDataSource {}

class _MockDao extends Mock implements ContactLocalDao {}

class _MockNetwork extends Mock implements NetworkInfo {}

class _MockDraftDao extends Mock implements DraftLocalDao {}

class _MockOutbox extends Mock implements PendingOperationDao {}

Contact _entity({
  int localId = 0,
  int? remoteId,
  int? socidLocal,
  int? socidRemote,
  String firstname = 'Paul',
  String lastname = 'Martin',
  DateTime? tms,
  SyncStatus syncStatus = SyncStatus.synced,
}) {
  return Contact(
    localId: localId,
    remoteId: remoteId,
    socidLocal: socidLocal,
    socidRemote: socidRemote,
    firstname: firstname,
    lastname: lastname,
    localUpdatedAt: DateTime(2026, 5, 8),
    tms: tms,
    syncStatus: syncStatus,
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(PendingOpType.create);
    registerFallbackValue(PendingOpEntity.contact);
    registerFallbackValue(_entity());
  });

  late _MockRemote remote;
  late _MockDao dao;
  late _MockNetwork network;
  late _MockDraftDao draftDao;
  late _MockOutbox outbox;
  late ContactRepositoryImpl repo;

  setUp(() {
    remote = _MockRemote();
    dao = _MockDao();
    network = _MockNetwork();
    draftDao = _MockDraftDao();
    outbox = _MockOutbox();
    repo = ContactRepositoryImpl(
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
    test('parent synchronisé (socidRemote présent) → pas de cascade',
        () async {
      when(() => dao.insertLocal(any())).thenAnswer((_) async => 50);

      final result = await repo.createLocal(
        _entity(socidLocal: 5, socidRemote: 200),
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
      expect(captured[1], PendingOpEntity.contact);
      expect(captured[2], 50);
      final payload = captured[3] as Map<String, Object?>;
      expect(payload['socid'], 200);
      expect(captured[4], isNull);
    });

    test(
        'parent non poussé (socidLocal seul) → cascade dependsOnLocalId '
        "depuis l'op create du parent", () async {
      when(() => dao.insertLocal(any())).thenAnswer((_) async => 70);
      when(
        () => outbox.findLatestPendingCreate(
          entityType: PendingOpEntity.thirdparty,
          targetLocalId: 5,
        ),
      ).thenAnswer((_) async => 999);

      final result = await repo.createLocal(_entity(socidLocal: 5));

      expect(result.isSuccess, isTrue);
      verify(
        () => outbox.findLatestPendingCreate(
          entityType: PendingOpEntity.thirdparty,
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
      expect(payload.containsKey('socid'), isFalse);
      expect(captured[1], 999);
    });

    test("parent inconnu de l'Outbox → pas de cascade mais succès",
        () async {
      when(() => dao.insertLocal(any())).thenAnswer((_) async => 71);

      final result = await repo.createLocal(_entity(socidLocal: 7));
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
      expect(captured.first, isNull);
    });
  });

  group('updateLocal', () {
    test('met à jour et enqueue update avec expectedTms', () async {
      final tms = DateTime(2026, 4, 2);
      when(() => dao.updateLocal(any())).thenAnswer((_) async {});
      final entity = _entity(
        localId: 7,
        remoteId: 99,
        socidRemote: 1,
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
          entityType: PendingOpEntity.contact,
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
  });

  group('drafts', () {
    test('saveDraft délègue avec entityType contact', () async {
      when(
        () => draftDao.save(
          entityType: any(named: 'entityType'),
          fields: any(named: 'fields'),
          refLocalId: any(named: 'refLocalId'),
        ),
      ).thenAnswer((_) async {});

      await repo.saveDraft(refLocalId: 7, fields: {'firstname': 'X'});

      verify(
        () => draftDao.save(
          entityType: 'contact',
          fields: {'firstname': 'X'},
          refLocalId: 7,
        ),
      ).called(1);
    });

    test('discardDraft délègue avec entityType contact', () async {
      when(
        () => draftDao.discard(
          entityType: any(named: 'entityType'),
          refLocalId: any(named: 'refLocalId'),
        ),
      ).thenAnswer((_) async {});

      await repo.discardDraft();

      verify(
        () => draftDao.discard(
          entityType: 'contact',
          refLocalId: any(named: 'refLocalId'),
        ),
      ).called(1);
    });
  });
}
