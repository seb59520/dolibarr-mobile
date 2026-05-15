// ignore_for_file: avoid_redundant_argument_values

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dolibarr_mobile/core/errors/failure.dart';
import 'package:dolibarr_mobile/features/expenses/data/datasources/ocr_remote_datasource.dart';
import 'package:dolibarr_mobile/features/expenses/domain/entities/extracted_ticket.dart';
import 'package:flutter_test/flutter_test.dart';

/// Adapter Dio statique : retourne toujours le même payload/status pour
/// permettre les assertions de parsing sans dépendance au backend réel.
class _StaticAdapter implements HttpClientAdapter {
  _StaticAdapter({this.body, this.status = 200, this.dioErrorType});
  final String? body;
  final int status;
  final DioExceptionType? dioErrorType;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (dioErrorType != null) {
      throw DioException(
        requestOptions: options,
        type: dioErrorType!,
        response: Response<dynamic>(
          requestOptions: options,
          statusCode: status,
        ),
      );
    }
    if (status >= 400) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: options,
          statusCode: status,
          data: body == null ? null : jsonDecode(body!),
        ),
      );
    }
    return ResponseBody.fromString(
      body ?? '{}',
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

OcrRemoteDataSourceImpl _ds({
  String? body,
  int status = 200,
  DioExceptionType? dioErrorType,
}) {
  final dio = Dio()
    ..httpClientAdapter = _StaticAdapter(
      body: body,
      status: status,
      dioErrorType: dioErrorType,
    );
  return OcrRemoteDataSourceImpl(client: dio);
}

void main() {
  group('OcrRemoteDataSource.extractTicket', () {
    test('parse une réponse OCR complète', () async {
      const body = '''
{
  "merchant": "Carrefour Lille",
  "dateIso": "2026-05-10",
  "currency": "EUR",
  "amountHt": 14.16,
  "amountVat": 2.83,
  "amountTtc": 16.99,
  "vatRate": 20.0,
  "suggestedFeeTypeCode": "TF_LUNCH",
  "confidence": 0.91,
  "rawText": "CARREFOUR 14,16 TVA 20%"
}
''';
      final ds = _ds(body: body);
      final dto = await ds.extractTicket(
        jpegBytes: Uint8List.fromList(const [0, 1, 2]),
        endpoint: 'https://ocr.example',
        bearer: 'tok',
      );
      expect(dto.merchant, 'Carrefour Lille');
      expect(dto.dateIso, DateTime(2026, 5, 10));
      expect(dto.amountTtc, 16.99);
      expect(dto.vatRate, 20.0);
      expect(
        dto.suggestedFeeTypeCode,
        SuggestedFeeTypeCode.tfLunch,
      );
      expect(dto.confidence, 0.91);
    });

    test('tolère les champs manquants', () async {
      const body = '{"merchant": "Inconnu", "rawText": "??"}';
      final ds = _ds(body: body);
      final dto = await ds.extractTicket(
        jpegBytes: Uint8List(8),
        endpoint: 'https://ocr.example',
        bearer: 'tok',
      );
      expect(dto.amountTtc, isNull);
      expect(dto.suggestedFeeTypeCode, isNull);
      expect(dto.rawText, '??');
    });

    test('un suggestedFeeTypeCode inconnu retombe sur null', () async {
      const body = '{"suggestedFeeTypeCode": "FOO_BAR"}';
      final ds = _ds(body: body);
      final dto = await ds.extractTicket(
        jpegBytes: Uint8List(4),
        endpoint: 'https://ocr.example',
        bearer: 'tok',
      );
      expect(dto.suggestedFeeTypeCode, isNull);
    });

    test('401 → DioException remappable en OcrFailure', () async {
      final ds = _ds(status: 401, body: '{"detail":"bad token"}');
      expect(
        () => ds.extractTicket(
          jpegBytes: Uint8List(4),
          endpoint: 'https://ocr.example',
          bearer: 'tok',
        ),
        throwsA(isA<DioException>()),
      );
    });

    test('timeout → DioException de type receiveTimeout', () async {
      final ds = _ds(dioErrorType: DioExceptionType.receiveTimeout);
      expect(
        () => ds.extractTicket(
          jpegBytes: Uint8List(4),
          endpoint: 'https://ocr.example',
          bearer: 'tok',
        ),
        throwsA(isA<DioException>()),
      );
    });

    test(
      'appelle la bonne URL et le bon header Authorization',
      () async {
        final received = <RequestOptions>[];
        final dio = Dio()
          ..httpClientAdapter = _SpyAdapter(received: received);
        final ds = OcrRemoteDataSourceImpl(client: dio);
        await ds.extractTicket(
          jpegBytes: Uint8List.fromList(const [0]),
          endpoint: 'https://ocr.example/',
          bearer: 'sk-42',
        );
        expect(received, hasLength(1));
        final opts = received.first;
        // Slash final supprimé puis path normalisé.
        expect(opts.uri.toString(), 'https://ocr.example/api/extract_ticket');
        expect(opts.headers['Authorization'], 'Bearer sk-42');
      },
    );
  });

  group('OcrRemoteDataSource.healthCheck', () {
    test('retourne true si `{"ok": true}`', () async {
      final ds = _ds(body: '{"ok": true, "model": "qwen2.5vl:7b"}');
      expect(await ds.healthCheck(endpoint: 'https://ocr.example'), isTrue);
    });

    test('retourne false sur 500', () async {
      final ds = _ds(status: 500, body: '{"detail":"down"}');
      expect(await ds.healthCheck(endpoint: 'https://ocr.example'), isFalse);
    });

    test('retourne false si `ok` est faux', () async {
      final ds = _ds(body: '{"ok": false}');
      expect(await ds.healthCheck(endpoint: 'https://ocr.example'), isFalse);
    });
  });

  group('mapDioToOcrFailure', () {
    test('401 → message "Jeton OCR invalide"', () {
      final e = DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: RequestOptions(path: ''),
          statusCode: 401,
        ),
      );
      final f = mapDioToOcrFailure(e);
      expect(f, isA<OcrFailure>());
      expect(f.message, contains('Jeton OCR'));
    });

    test('timeout → message "n’a pas répondu à temps"', () {
      final e = DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.receiveTimeout,
      );
      final f = mapDioToOcrFailure(e);
      expect(f.message, contains('temps'));
    });

    test('413 → message "trop volumineuse"', () {
      final e = DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: RequestOptions(path: ''),
          statusCode: 413,
        ),
      );
      final f = mapDioToOcrFailure(e);
      expect(f.message, contains('volumineuse'));
    });
  });
}

class _SpyAdapter implements HttpClientAdapter {
  _SpyAdapter({required this.received});
  final List<RequestOptions> received;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    received.add(options);
    return ResponseBody.fromString(
      '{"merchant":"X"}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
