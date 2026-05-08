import 'dart:async';
import 'dart:convert';

import 'package:dolibarr_mobile/core/errors/exceptions.dart';
import 'package:dolibarr_mobile/core/network/network_info.dart';
import 'package:dolibarr_mobile/core/storage/app_database.dart';
import 'package:dolibarr_mobile/core/storage/pending_operation_dao.dart';
import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:dolibarr_mobile/core/sync/sync_engine.dart';
import 'package:dolibarr_mobile/features/contacts/data/datasources/contact_local_dao.dart';
import 'package:dolibarr_mobile/features/contacts/data/datasources/contact_remote_datasource.dart';
import 'package:dolibarr_mobile/features/contacts/domain/entities/contact.dart';
import 'package:dolibarr_mobile/features/projects/data/datasources/project_local_dao.dart';
import 'package:dolibarr_mobile/features/projects/data/datasources/project_remote_datasource.dart';
import 'package:dolibarr_mobile/features/tasks/data/datasources/task_local_dao.dart';
import 'package:dolibarr_mobile/features/tasks/data/datasources/task_remote_datasource.dart';
import 'package:dolibarr_mobile/features/thirdparties/data/datasources/third_party_local_dao.dart';
import 'package:dolibarr_mobile/features/thirdparties/data/datasources/third_party_remote_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockOutbox extends Mock implements PendingOperationDao {}

class _MockTpRemote extends Mock implements ThirdPartyRemoteDataSource {}

class _MockTpDao extends Mock implements ThirdPartyLocalDao {}

class _MockCtRemote extends Mock implements ContactRemoteDataSource {}

class _MockCtDao extends Mock implements ContactLocalDao {}

class _MockPjRemote extends Mock implements ProjectRemoteDataSource {}

class _MockPjDao extends Mock implements ProjectLocalDao {}

class _MockTskRemote extends Mock implements TaskRemoteDataSource {}

class _MockTskDao extends Mock implements TaskLocalDao {}

class _StubNetwork implements NetworkInfo {
  _StubNetwork({bool online = true}) : _online = online;
  final bool _online;
  final _ctrl = StreamController<bool>.broadcast();

  @override
  bool get isOnline => _online;

  @override
  Stream<bool> get onStatusChange => _ctrl.stream;

  @override
  Future<bool> refresh() async => _online;

  @override
  Future<void> dispose() async {
    await _ctrl.close();
  }
}

PendingOperationRow _row({
  int id = 1,
  PendingOpType opType = PendingOpType.create,
  PendingOpEntity entityType = PendingOpEntity.thirdparty,
  int targetLocalId = 10,
  int? targetRemoteId,
  Map<String, Object?> payload = const {'name': 'Acme'},
  DateTime? expectedTms,
  int? dependsOnLocalId,
  int attempts = 0,
}) {
  return PendingOperationRow(
    id: id,
    opType: opType,
    entityType: entityType,
    targetLocalId: targetLocalId,
    targetRemoteId: targetRemoteId,
    payload: jsonEncode(payload),
    expectedTms: expectedTms,
    dependsOnLocalId: dependsOnLocalId,
    attempts: attempts,
    createdAt: DateTime(2026, 5, 9),
    status: PendingOpStatus.queued,
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(PendingOpType.create);
    registerFallbackValue(PendingOpEntity.thirdparty);
  });

  late _MockOutbox outbox;
  late _MockTpRemote tpRemote;
  late _MockTpDao tpDao;
  late _MockCtRemote ctRemote;
  late _MockCtDao ctDao;
  late _MockPjRemote pjRemote;
  late _MockPjDao pjDao;
  late _MockTskRemote tskRemote;
  late _MockTskDao tskDao;
  late _StubNetwork network;
  late SyncEngine engine;

  late DateTime now;

  setUp(() {
    outbox = _MockOutbox();
    tpRemote = _MockTpRemote();
    tpDao = _MockTpDao();
    ctRemote = _MockCtRemote();
    ctDao = _MockCtDao();
    pjRemote = _MockPjRemote();
    pjDao = _MockPjDao();
    tskRemote = _MockTskRemote();
    tskDao = _MockTskDao();
    network = _StubNetwork();
    now = DateTime(2026, 5, 9, 12);

    engine = SyncEngine(
      outbox: outbox,
      thirdpartyRemote: tpRemote,
      thirdpartyDao: tpDao,
      contactRemote: ctRemote,
      contactDao: ctDao,
      projectRemote: pjRemote,
      projectDao: pjDao,
      taskRemote: tskRemote,
      taskDao: tskDao,
      network: network,
      now: () => now,
    );

    // Defaults
    when(() => outbox.markInProgress(any())).thenAnswer((_) async {});
    when(() => outbox.completeAndUnblockChildren(any()))
        .thenAnswer((_) async {});
    when(
      () => outbox.markFailed(
        opId: any(named: 'opId'),
        message: any(named: 'message'),
        nextRetryAt: any(named: 'nextRetryAt'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => outbox.markConflict(
        opId: any(named: 'opId'),
        message: any(named: 'message'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => outbox.markDead(
        opId: any(named: 'opId'),
        message: any(named: 'message'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => tpDao.markSyncedWithRemote(
        localId: any(named: 'localId'),
        remoteId: any(named: 'remoteId'),
        tms: any(named: 'tms'),
      ),
    ).thenAnswer((_) async {});
    when(() => tpDao.markConflict(any())).thenAnswer((_) async {});
    when(() => tpDao.clearAfterServerDelete(any()))
        .thenAnswer((_) async => 1);
    when(
      () => ctDao.patchSocidRemoteByParent(
        parentLocalId: any(named: 'parentLocalId'),
        parentRemoteId: any(named: 'parentRemoteId'),
      ),
    ).thenAnswer((_) async => 0);
    when(
      () => ctDao.markSyncedWithRemote(
        localId: any(named: 'localId'),
        remoteId: any(named: 'remoteId'),
        tms: any(named: 'tms'),
      ),
    ).thenAnswer((_) async {});
    when(() => ctDao.markConflict(any())).thenAnswer((_) async {});
    when(() => ctDao.clearAfterServerDelete(any()))
        .thenAnswer((_) async => 1);

    // Cascade thirdparty → projects (no-op par défaut, certains tests
    // override pour vérifier l'appel).
    when(
      () => pjDao.patchSocidRemoteByParent(
        parentLocalId: any(named: 'parentLocalId'),
        parentRemoteId: any(named: 'parentRemoteId'),
      ),
    ).thenAnswer((_) async => 0);

    // Cascade project → tasks.
    when(
      () => tskDao.patchProjectRemoteByParent(
        parentLocalId: any(named: 'parentLocalId'),
        parentRemoteId: any(named: 'parentRemoteId'),
      ),
    ).thenAnswer((_) async => 0);
  });

  group('runOnce — thirdparty create', () {
    test(
        'create succès → markSynced + cascade patch contacts + '
        'completeAndUnblockChildren', () async {
      final op = _row();

      when(() => tpRemote.create(any())).thenAnswer((_) async => 555);
      when(() => tpRemote.fetchById(555)).thenAnswer(
        (_) async => {'id': 555, 'tms': 1715000000},
      );

      // Premier appel retourne [op], suivants retournent [].
      var calls = 0;
      when(() => outbox.dispatchable(now: any(named: 'now')))
          .thenAnswer((_) async => calls++ == 0 ? [op] : []);

      final report = await engine.runOnce();

      expect(report.processed, 1);
      expect(report.succeeded, 1);
      verify(() => tpRemote.create(any())).called(1);
      verify(
        () => tpDao.markSyncedWithRemote(
          localId: 10,
          remoteId: 555,
          tms: any(named: 'tms'),
        ),
      ).called(1);
      verify(
        () => ctDao.patchSocidRemoteByParent(
          parentLocalId: 10,
          parentRemoteId: 555,
        ),
      ).called(1);
      verify(() => outbox.completeAndUnblockChildren(op.id)).called(1);
    });

    test('échec NetworkException → markFailed avec backoff incrémenté',
        () async {
      final op = _row();
      var calls = 0;
      when(() => outbox.dispatchable(now: any(named: 'now')))
          .thenAnswer((_) async => calls++ == 0 ? [op] : []);
      when(() => tpRemote.create(any()))
          .thenThrow(const NetworkException('timeout'));

      final report = await engine.runOnce();

      expect(report.failed, 1);
      final captured = verify(
        () => outbox.markFailed(
          opId: captureAny(named: 'opId'),
          message: captureAny(named: 'message'),
          nextRetryAt: captureAny(named: 'nextRetryAt'),
        ),
      ).captured;
      expect(captured[0], op.id);
      expect(captured[1], contains('Réseau'));
      // attempts passe à 1 → backoff = 60 * 2^1 = 120s
      final next = captured[2] as DateTime;
      expect(next.difference(now).inSeconds, 120);
      verifyNever(
        () => tpDao.markSyncedWithRemote(
          localId: any(named: 'localId'),
          remoteId: any(named: 'remoteId'),
          tms: any(named: 'tms'),
        ),
      );
    });

    test('épuisement des tentatives → markDead', () async {
      final op = _row(attempts: kMaxAttempts - 1);
      var calls = 0;
      when(() => outbox.dispatchable(now: any(named: 'now')))
          .thenAnswer((_) async => calls++ == 0 ? [op] : []);
      when(() => tpRemote.create(any()))
          .thenThrow(const ServerException(statusCode: 502));

      final report = await engine.runOnce();

      expect(report.dead, 1);
      verify(
        () => outbox.markDead(
          opId: op.id,
          message: any(named: 'message'),
        ),
      ).called(1);
      verifyNever(
        () => outbox.markFailed(
          opId: any(named: 'opId'),
          message: any(named: 'message'),
          nextRetryAt: any(named: 'nextRetryAt'),
        ),
      );
    });
  });

  group('runOnce — thirdparty update', () {
    test('tms serveur > expectedTms → conflit + markConflict entité',
        () async {
      // expectedTms = 2025-01-01, serveur = 2026-05-08 → conflit.
      final op = _row(
        opType: PendingOpType.update,
        targetRemoteId: 200,
        expectedTms: DateTime(2025),
      );
      var calls = 0;
      when(() => outbox.dispatchable(now: any(named: 'now')))
          .thenAnswer((_) async => calls++ == 0 ? [op] : []);
      // 1746662400 = 2025-05-08 ; postérieur à 2025-01-01.
      when(() => tpRemote.fetchById(200))
          .thenAnswer((_) async => {'id': 200, 'tms': 1746662400});

      final report = await engine.runOnce();

      expect(report.conflicts, 1);
      verify(() => tpDao.markConflict(op.targetLocalId)).called(1);
      verifyNever(() => tpRemote.update(any(), any()));
    });

    test('tms serveur ≤ expectedTms → PUT effectif + markSynced',
        () async {
      // expectedTms = 2026-05-08 13:00, serveur = 2025-05-08 → pas de conflit.
      final op = _row(
        opType: PendingOpType.update,
        targetRemoteId: 200,
        expectedTms: DateTime(2026, 5, 8, 13),
      );
      var calls = 0;
      when(() => outbox.dispatchable(now: any(named: 'now')))
          .thenAnswer((_) async => calls++ == 0 ? [op] : []);
      when(() => tpRemote.fetchById(200))
          .thenAnswer((_) async => {'id': 200, 'tms': 1746662400});
      when(() => tpRemote.update(200, any()))
          .thenAnswer((_) async => {'id': 200, 'tms': 1746663000});

      final report = await engine.runOnce();

      expect(report.succeeded, 1);
      verify(() => tpRemote.update(200, any())).called(1);
      verify(
        () => tpDao.markSyncedWithRemote(
          localId: op.targetLocalId,
          remoteId: 200,
          tms: any(named: 'tms'),
        ),
      ).called(1);
    });
  });

  group('runOnce — contact create cascade', () {
    test(
        "create contact dont parent vient d'être pushed → injecte socid "
        "depuis l'entité fraîche", () async {
      final op = _row(
        entityType: PendingOpEntity.contact,
        targetLocalId: 99,
      );
      var calls = 0;
      when(() => outbox.dispatchable(now: any(named: 'now')))
          .thenAnswer((_) async => calls++ == 0 ? [op] : []);

      // L'entité contact en cache a maintenant un socidRemote (cascade).
      final contact = Contact(
        localId: 99,
        firstname: 'Paul',
        socidLocal: 10,
        socidRemote: 555,
        localUpdatedAt: DateTime(2026, 5, 9),
      );
      when(() => ctDao.watchById(99))
          .thenAnswer((_) => Stream.value(contact));
      when(() => ctRemote.create(any())).thenAnswer((_) async => 600);
      when(() => ctRemote.fetchById(600)).thenAnswer(
        (_) async => {'id': 600, 'tms': 1746663000},
      );

      final report = await engine.runOnce();

      expect(report.succeeded, 1);
      final payloadCaptured =
          verify(() => ctRemote.create(captureAny())).captured.first
              as Map<String, Object?>;
      expect(payloadCaptured['socid'], 555);
      verify(
        () => ctDao.markSyncedWithRemote(
          localId: 99,
          remoteId: 600,
          tms: any(named: 'tms'),
        ),
      ).called(1);
    });

    test('create contact sans socidRemote disponible → markDead validation',
        () async {
      final op = _row(
        entityType: PendingOpEntity.contact,
        targetLocalId: 99,
      );
      var calls = 0;
      when(() => outbox.dispatchable(now: any(named: 'now')))
          .thenAnswer((_) async => calls++ == 0 ? [op] : []);

      final contact = Contact(
        localId: 99,
        firstname: 'Paul',
        socidLocal: 10,
        localUpdatedAt: DateTime(2026, 5, 9),
      );
      when(() => ctDao.watchById(99))
          .thenAnswer((_) => Stream.value(contact));

      final report = await engine.runOnce();

      expect(report.dead, 1);
      verify(
        () => outbox.markDead(
          opId: op.id,
          message: any(named: 'message'),
        ),
      ).called(1);
      verifyNever(() => ctRemote.create(any()));
    });
  });

  group('runOnce — delete', () {
    test('thirdparty delete succès → clearAfterServerDelete', () async {
      final op = _row(
        opType: PendingOpType.delete,
        targetRemoteId: 200,
      );
      var calls = 0;
      when(() => outbox.dispatchable(now: any(named: 'now')))
          .thenAnswer((_) async => calls++ == 0 ? [op] : []);
      when(() => tpRemote.delete(200)).thenAnswer((_) async {});

      final report = await engine.runOnce();

      expect(report.succeeded, 1);
      verify(() => tpDao.clearAfterServerDelete(op.targetLocalId))
          .called(1);
    });

    test('delete 404 → considéré comme succès (déjà supprimé)', () async {
      final op = _row(
        opType: PendingOpType.delete,
        targetRemoteId: 200,
      );
      var calls = 0;
      when(() => outbox.dispatchable(now: any(named: 'now')))
          .thenAnswer((_) async => calls++ == 0 ? [op] : []);
      when(() => tpRemote.delete(200))
          .thenThrow(const NotFoundException('gone'));

      final report = await engine.runOnce();

      expect(report.succeeded, 1);
      verify(() => tpDao.clearAfterServerDelete(op.targetLocalId))
          .called(1);
    });
  });

  group('backoffFor', () {
    test('attempts=1 → 120s', () {
      expect(backoffFor(1), const Duration(seconds: 120));
    });
    test('attempts=4 → 960s', () {
      expect(backoffFor(4), const Duration(seconds: 960));
    });
    test('clamp à 30 minutes pour gros attempts', () {
      expect(backoffFor(20), const Duration(seconds: 30 * 60));
    });
  });
}
