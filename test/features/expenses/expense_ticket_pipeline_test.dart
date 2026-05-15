import 'dart:typed_data';

import 'package:dolibarr_mobile/core/errors/failure.dart';
import 'package:dolibarr_mobile/core/network/network_info.dart';
import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/expenses/data/datasources/expense_remote_datasource.dart';
import 'package:dolibarr_mobile/features/expenses/data/datasources/ocr_remote_datasource.dart';
import 'package:dolibarr_mobile/features/expenses/data/expense_ticket_pipeline.dart';
import 'package:dolibarr_mobile/features/expenses/domain/entities/expense_filters.dart';
import 'package:dolibarr_mobile/features/expenses/domain/entities/extracted_ticket.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockOcr extends Mock implements OcrRemoteDataSource {}

class _MockRemote extends Mock implements ExpenseRemoteDataSource {}

class _MockNetwork extends Mock implements NetworkInfo {}

void main() {
  setUpAll(() {
    registerFallbackValue(const ExpenseFilters());
    registerFallbackValue(Uint8List(0));
  });

  late _MockOcr ocr;
  late _MockRemote remote;
  late _MockNetwork network;
  late ExpenseTicketPipeline pipeline;

  setUp(() {
    ocr = _MockOcr();
    remote = _MockRemote();
    network = _MockNetwork();
    when(() => network.isOnline).thenReturn(true);
    pipeline = ExpenseTicketPipeline(
      ocr: ocr,
      remote: remote,
      network: network,
      currentUserId: () => 5,
      resolveFeeType: (code) async {
        if (code == 'TF_LUNCH') return 3;
        if (code == 'EX_FUE_VP') return 7;
        return null;
      },
    );
  });

  group('extract', () {
    test('renvoie NetworkFailure si offline', () async {
      when(() => network.isOnline).thenReturn(false);
      final result = await pipeline.extract(
        jpegBytes: Uint8List(0),
        endpoint: 'https://ocr',
        bearer: 't',
      );
      expect(result, isA<FailureResult<ExtractedTicketDto>>());
      expect(
        (result as FailureResult<ExtractedTicketDto>).failure,
        isA<NetworkFailure>(),
      );
    });

    test('renvoie OcrFailure si bearer vide', () async {
      final result = await pipeline.extract(
        jpegBytes: Uint8List(0),
        endpoint: 'https://ocr',
        bearer: '   ',
      );
      expect(result, isA<FailureResult<ExtractedTicketDto>>());
      expect(
        (result as FailureResult<ExtractedTicketDto>).failure,
        isA<OcrFailure>(),
      );
    });

    test('chemin nominal → Success', () async {
      const dto = ExtractedTicketDto(merchant: 'X', amountTtc: 12);
      when(
        () => ocr.extractTicket(
          jpegBytes: any(named: 'jpegBytes'),
          endpoint: any(named: 'endpoint'),
          bearer: any(named: 'bearer'),
        ),
      ).thenAnswer((_) async => dto);

      final result = await pipeline.extract(
        jpegBytes: Uint8List(4),
        endpoint: 'https://ocr',
        bearer: 'tok',
      );
      expect(result, isA<Success<ExtractedTicketDto>>());
      expect(
        (result as Success<ExtractedTicketDto>).value,
        equals(dto),
      );
    });
  });

  group('push', () {
    test('échec si TTC manquant → ValidationFailure', () async {
      final result = await pipeline.push(
        overrides: const ExpenseTicketOverrides(
          feeTypeCode: 'TF_LUNCH',
        ),
      );
      expect(result, isA<FailureResult<TicketPushOutcome>>());
      expect(
        (result as FailureResult<TicketPushOutcome>).failure,
        isA<ValidationFailure>(),
      );
    });

    test('échec si type inconnu → ValidationFailure', () async {
      final result = await pipeline.push(
        overrides: const ExpenseTicketOverrides(
          amountTtc: 10,
          feeTypeCode: 'WTF_UNKNOWN',
        ),
      );
      expect(result, isA<FailureResult<TicketPushOutcome>>());
      expect(
        (result as FailureResult<TicketPushOutcome>).failure,
        isA<ValidationFailure>(),
      );
    });

    test(
      'cas nominal create → fetchPage→empty, create, fetchById, '
      'createLine, uploadDocument',
      () async {
        // 1. fetchPage : aucun brouillon existant.
        when(
          () => remote.fetchPage(
            filters: any(named: 'filters'),
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => const <Map<String, Object?>>[]);
        // 2. create draft → renvoie remoteId 42.
        when(() => remote.create(any())).thenAnswer((_) async => 42);
        // 3. fetchById → renvoie payload avec ref.
        when(() => remote.fetchById(42)).thenAnswer(
          (_) async => <String, Object?>{
            'id': 42,
            'ref': 'ND2026-0042',
            'fk_statut': 0,
          },
        );
        // 4. createLine → id ligne 99.
        when(
          () => remote.createLine(42, any()),
        ).thenAnswer((_) async => 99);
        // 5. uploadDocument OK.
        when(
          () => remote.uploadDocument(
            ref: any(named: 'ref'),
            filename: any(named: 'filename'),
            base64Content: any(named: 'base64Content'),
          ),
        ).thenAnswer((_) async => 'expensereport/ND2026-0042/ticket.jpg');

        final result = await pipeline.push(
          overrides: ExpenseTicketOverrides(
            amountTtc: 16.99,
            vatRate: 20,
            feeTypeCode: 'TF_LUNCH',
            merchant: 'Carrefour',
            date: DateTime(2026, 5, 10),
          ),
          jpegBytes: Uint8List.fromList(const [1, 2, 3]),
        );
        expect(result, isA<Success<TicketPushOutcome>>());
        final outcome = (result as Success<TicketPushOutcome>).value;
        expect(outcome.reportRemoteId, 42);
        expect(outcome.reportRef, 'ND2026-0042');
        expect(outcome.lineRemoteId, 99);
        expect(outcome.documentUploaded, isTrue);

        // Vérifie que `create` a bien injecté fk_user_author=5.
        final captured = verify(() => remote.create(captureAny())).captured;
        expect(captured.first, isA<Map<String, Object?>>());
        final payload = captured.first as Map<String, Object?>;
        expect(payload['fk_user_author'], 5);
        expect(payload['fk_user_valid'], 5);
        expect(payload['date_debut'], isNotNull);

        // Vérifie que la ligne porte fk_c_type_fees=3 (TF_LUNCH).
        final lineCaptured =
            verify(() => remote.createLine(42, captureAny())).captured;
        final linePayload = lineCaptured.first as Map<String, Object?>;
        expect(linePayload['fk_c_type_fees'], 3);
        expect(linePayload['value_unit'], '16.99');
        expect(linePayload['vatrate'], '20.0');
        expect(linePayload['comments'], 'Carrefour');
      },
    );

    test(
      'cas existant draft → réutilise et ne crée pas',
      () async {
        when(
          () => remote.fetchPage(
            filters: any(named: 'filters'),
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) async => <Map<String, Object?>>[
            {
              'id': 100,
              'rowid': 100,
              'ref': 'ND2026-0100',
              'fk_statut': 0,
              'fk_user_author': 5,
            },
          ],
        );
        when(() => remote.fetchById(100)).thenAnswer(
          (_) async => <String, Object?>{
            'id': 100,
            'ref': 'ND2026-0100',
            'fk_statut': 0,
          },
        );
        when(
          () => remote.createLine(100, any()),
        ).thenAnswer((_) async => 11);
        when(
          () => remote.uploadDocument(
            ref: any(named: 'ref'),
            filename: any(named: 'filename'),
            base64Content: any(named: 'base64Content'),
          ),
        ).thenAnswer((_) async => 'ok');

        final result = await pipeline.push(
          overrides: const ExpenseTicketOverrides(
            amountTtc: 5,
            feeTypeCode: 'EX_FUE_VP',
          ),
        );
        expect(result, isA<Success<TicketPushOutcome>>());
        // Aucun create attendu : on a réutilisé le brouillon existant.
        verifyNever(() => remote.create(any()));
      },
    );

    test(
      "uploadDocument en erreur n'invalide pas tout le pipeline",
      () async {
        when(
          () => remote.fetchPage(
            filters: any(named: 'filters'),
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => const <Map<String, Object?>>[]);
        when(() => remote.create(any())).thenAnswer((_) async => 7);
        when(() => remote.fetchById(7)).thenAnswer(
          (_) async => <String, Object?>{
            'id': 7,
            'ref': 'ND2026-0007',
            'fk_statut': 0,
          },
        );
        when(
          () => remote.createLine(7, any()),
        ).thenAnswer((_) async => 1);
        when(
          () => remote.uploadDocument(
            ref: any(named: 'ref'),
            filename: any(named: 'filename'),
            base64Content: any(named: 'base64Content'),
          ),
        ).thenThrow(Exception('ECM down'));

        final result = await pipeline.push(
          overrides: const ExpenseTicketOverrides(
            amountTtc: 8,
            feeTypeCode: 'TF_LUNCH',
          ),
          jpegBytes: Uint8List.fromList(const [9]),
        );
        expect(result, isA<Success<TicketPushOutcome>>());
        final outcome = (result as Success<TicketPushOutcome>).value;
        expect(outcome.documentUploaded, isFalse);
        // La ligne a bien été créée malgré l'échec ECM.
        expect(outcome.lineRemoteId, 1);
      },
    );
  });
}
