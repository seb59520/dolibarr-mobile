import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dolibarr_mobile/core/errors/exceptions.dart';
import 'package:dolibarr_mobile/core/network/interceptors/error_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';

/// Adapter qui répond toujours avec le statusCode demandé.
class _StaticAdapter implements HttpClientAdapter {
  _StaticAdapter(this.statusCode);
  final int statusCode;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
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

Dio _dio(int status, NetworkEventBus bus) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://example.invalid',
      validateStatus: (s) => s != null && s < 400,
    ),
  )
    ..httpClientAdapter = _StaticAdapter(status)
    ..interceptors.add(ErrorInterceptor(bus));
  return dio;
}

void main() {
  late NetworkEventBus bus;

  setUp(() => bus = NetworkEventBus());
  tearDown(() async => bus.dispose());

  test('401 émet SessionExpired et propage UnauthorizedException',
      () async {
    final events = <NetworkEvent>[];
    final sub = bus.events.listen(events.add);

    try {
      await _dio(401, bus).get<dynamic>('/');
      fail('attendu DioException');
    } on DioException catch (e) {
      expect(e.error, isA<UnauthorizedException>());
    }
    await Future<void>.delayed(Duration.zero);
    expect(events.whereType<SessionExpired>(), isNotEmpty);
    await sub.cancel();
  });

  test('403 propage ForbiddenException sans émettre', () async {
    final events = <NetworkEvent>[];
    final sub = bus.events.listen(events.add);

    try {
      await _dio(403, bus).get<dynamic>('/');
      fail('attendu DioException');
    } on DioException catch (e) {
      expect(e.error, isA<ForbiddenException>());
    }
    await Future<void>.delayed(Duration.zero);
    expect(events.whereType<SessionExpired>(), isEmpty);
    await sub.cancel();
  });

  test('503 propage ServerException', () async {
    try {
      await _dio(503, bus).get<dynamic>('/');
      fail('attendu DioException');
    } on DioException catch (e) {
      expect(e.error, isA<ServerException>());
    }
  });
}
