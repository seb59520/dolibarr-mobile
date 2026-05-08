import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dolibarr_mobile/core/network/interceptors/retry_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';

/// Adapter qui répond systématiquement avec le statusCode fourni et
/// compte le nombre d'invocations.
class _CountingAdapter implements HttpClientAdapter {
  _CountingAdapter(this.statusCode);
  final int statusCode;
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    return ResponseBody.fromString(
      '{}',
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio _dio(_CountingAdapter adapter, {int maxRetries = 3}) {
  // validateStatus: jette pour TOUTES les réponses non-2xx pour que
  // l'`onError` de l'intercepteur se déclenche.
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://example.invalid',
      validateStatus: (s) => s != null && s < 300,
    ),
  )..httpClientAdapter = adapter;
  dio.interceptors.add(
    RetryInterceptor(
      dio: dio,
      maxRetries: maxRetries,
      sleep: (_) async {},
    ),
  );
  return dio;
}

void main() {
  test('ne retry pas un 400', () async {
    final adapter = _CountingAdapter(400);
    final dio = _dio(adapter);
    await expectLater(
      () => dio.get<dynamic>('/'),
      throwsA(isA<DioException>()),
    );
    expect(adapter.calls, 1);
  });

  test('retry sur 503 jusqu’à maxRetries+1 appels au total', () async {
    final adapter = _CountingAdapter(503);
    final dio = _dio(adapter, maxRetries: 2);
    await expectLater(
      () => dio.get<dynamic>('/'),
      throwsA(isA<DioException>()),
    );
    expect(adapter.calls, 3);
  });

  test('retry sur 429 (rate-limit)', () async {
    final adapter = _CountingAdapter(429);
    final dio = _dio(adapter, maxRetries: 1);
    await expectLater(
      () => dio.get<dynamic>('/'),
      throwsA(isA<DioException>()),
    );
    expect(adapter.calls, 2);
  });
}
