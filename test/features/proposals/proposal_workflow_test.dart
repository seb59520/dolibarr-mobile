import 'dart:convert';

import 'package:dolibarr_mobile/core/network/network_info.dart';
import 'package:dolibarr_mobile/core/storage/pending_operation_dao.dart';
import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/proposals/data/datasources/proposal_local_dao.dart';
import 'package:dolibarr_mobile/features/proposals/data/datasources/proposal_remote_datasource.dart';
import 'package:dolibarr_mobile/features/proposals/data/repositories/proposal_repository_impl.dart';
import 'package:dolibarr_mobile/features/proposals/domain/entities/proposal.dart';
import 'package:dolibarr_mobile/features/thirdparties/data/datasources/draft_local_dao.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements ProposalRemoteDataSource {}

class _MockDao extends Mock implements ProposalLocalDao {}

class _MockNetwork extends Mock implements NetworkInfo {}

class _MockDraftDao extends Mock implements DraftLocalDao {}

class _MockOutbox extends Mock implements PendingOperationDao {}

Proposal _entity({
  int localId = 5,
  int? remoteId = 100,
  ProposalStatus status = ProposalStatus.draft,
}) {
  return Proposal(
    localId: localId,
    remoteId: remoteId,
    socidRemote: 1,
    status: status,
    dateProposal: DateTime(2026, 5, 9),
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
  late ProposalRepositoryImpl repo;

  setUp(() {
    remote = _MockRemote();
    dao = _MockDao();
    network = _MockNetwork();
    draftDao = _MockDraftDao();
    outbox = _MockOutbox();
    repo = ProposalRepositoryImpl(
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
      when(() => dao.upsertFromServer(any())).thenAnswer((_) async {});
      when(() => dao.findByRemoteId(any())).thenAnswer(
        (_) async => _entity(status: ProposalStatus.validated),
      );

      final result = await repo.validate(5);
      expect(result.isSuccess, isTrue);
      verify(() => remote.validate(100)).called(1);
      verify(() => remote.fetchById(100)).called(1);
    });

    test('devis sans remoteId → ValidationFailure', () async {
      when(() => dao.watchById(5))
          .thenAnswer((_) => Stream.value(_entity(remoteId: null)));

      final result = await repo.validate(5);
      expect(result.isFailure, isTrue);
      verifyNever(() => remote.validate(any()));
    });
  });

  group('close', () {
    test('signed → remote.close(2) + refresh', () async {
      when(() => dao.watchById(5)).thenAnswer(
        (_) => Stream.value(_entity(status: ProposalStatus.validated)),
      );
      when(
        () => remote.close(any(), any(), note: any(named: 'note')),
      ).thenAnswer((_) async => {});
      when(() => remote.fetchById(any())).thenAnswer(
        (_) async => {'id': 100, 'fk_statut': 2},
      );
      when(() => dao.upsertFromServer(any())).thenAnswer((_) async {});
      when(() => dao.findByRemoteId(any())).thenAnswer(
        (_) async => _entity(status: ProposalStatus.signed),
      );

      final result = await repo.close(5, ProposalStatus.signed, note: 'OK');
      expect(result.isSuccess, isTrue);
      verify(() => remote.close(100, 2, note: 'OK')).called(1);
    });

    test('refused → remote.close(-1)', () async {
      when(() => dao.watchById(5)).thenAnswer(
        (_) => Stream.value(_entity(status: ProposalStatus.validated)),
      );
      when(
        () => remote.close(any(), any(), note: any(named: 'note')),
      ).thenAnswer((_) async => {});
      when(() => remote.fetchById(any())).thenAnswer((_) async => {});
      when(() => dao.upsertFromServer(any())).thenAnswer((_) async {});
      when(() => dao.findByRemoteId(any())).thenAnswer(
        (_) async => _entity(status: ProposalStatus.refused),
      );

      final result = await repo.close(5, ProposalStatus.refused);
      expect(result.isSuccess, isTrue);
      verify(() => remote.close(100, -1, note: null)).called(1);
    });

    test('draft → refus (statut non final)', () async {
      final result = await repo.close(5, ProposalStatus.draft);
      expect(result.isFailure, isTrue);
      verifyNever(
        () => remote.close(any(), any(), note: any(named: 'note')),
      );
    });
  });

  group('setInvoiced', () {
    test('appelle remote.setInvoiced + refresh', () async {
      when(() => dao.watchById(5)).thenAnswer(
        (_) => Stream.value(_entity(status: ProposalStatus.signed)),
      );
      when(() => remote.setInvoiced(any())).thenAnswer((_) async => {});
      when(() => remote.fetchById(any())).thenAnswer((_) async => {});
      when(() => dao.upsertFromServer(any())).thenAnswer((_) async {});
      when(() => dao.findByRemoteId(any())).thenAnswer(
        (_) async => _entity(status: ProposalStatus.signed),
      );

      final result = await repo.setInvoiced(5);
      expect(result.isSuccess, isTrue);
      verify(() => remote.setInvoiced(100)).called(1);
    });
  });

  group('downloadPdf', () {
    test('décode le base64 → bytes', () async {
      final bytes = [37, 80, 68, 70, 45, 49, 46, 52]; // "%PDF-1.4"
      final b64 = base64.encode(bytes);
      when(() => dao.watchById(5))
          .thenAnswer((_) => Stream.value(_entity()));
      when(() => remote.downloadPdf(any())).thenAnswer(
        (_) async => (content: b64, filename: 'PR2026-0001.pdf'),
      );

      final result = await repo.downloadPdf(5);
      expect(
        (result as Success<({List<int> bytes, String filename})>).value.bytes,
        bytes,
      );
      expect(result.value.filename, 'PR2026-0001.pdf');
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

    test('devis sans remoteId → ValidationFailure', () async {
      when(() => dao.watchById(5))
          .thenAnswer((_) => Stream.value(_entity(remoteId: null)));

      final result = await repo.downloadPdf(5);
      expect(result.isFailure, isTrue);
      verifyNever(() => remote.downloadPdf(any()));
    });
  });
}
