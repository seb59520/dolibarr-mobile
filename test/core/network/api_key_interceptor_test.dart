import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dolibarr_mobile/core/constants/api_paths.dart';
import 'package:dolibarr_mobile/core/network/interceptors/api_key_interceptor.dart';
import 'package:dolibarr_mobile/core/storage/secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSecureStorage extends Mock implements SecureStorage {}

void main() {
  late _MockSecureStorage storage;
  late ApiKeyInterceptor interceptor;
  late Dio dio;

  setUp(() {
    storage = _MockSecureStorage();
    interceptor = ApiKeyInterceptor(storage);
    dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'))
      ..interceptors.add(interceptor)
      // Stub adapter qui capture la requête au lieu de l'envoyer.
      ..httpClientAdapter = _CapturingAdapter();
  });

  test('ajoute DOLAPIKEY si présente dans secure_storage', () async {
    when(() => storage.readApiKey()).thenAnswer((_) async => 'abc123');

    final response =
        await dio.get<dynamic>('/echo', options: Options(method: 'GET'));
    final headers = response.requestOptions.headers;
    expect(headers[ApiHeaders.dolApiKey], 'abc123');
    expect(headers[ApiHeaders.contentType], ApiHeaders.applicationJson);
    expect(headers[ApiHeaders.accept], ApiHeaders.applicationJson);
  });

  test('omet DOLAPIKEY si absente du secure_storage', () async {
    when(() => storage.readApiKey()).thenAnswer((_) async => null);

    final response =
        await dio.get<dynamic>('/echo', options: Options(method: 'GET'));
    expect(response.requestOptions.headers[ApiHeaders.dolApiKey], isNull);
  });

  test('omet DOLAPIKEY si valeur vide', () async {
    when(() => storage.readApiKey()).thenAnswer((_) async => '');

    final response =
        await dio.get<dynamic>('/echo', options: Options(method: 'GET'));
    expect(response.requestOptions.headers[ApiHeaders.dolApiKey], isNull);
  });
}

/// Adapter Dio qui retourne une réponse vide en réfléchissant la requête.
class _CapturingAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '{}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
