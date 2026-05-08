import 'package:dio/dio.dart';
import 'package:dolibarr_mobile/core/config/app_config.dart';
import 'package:dolibarr_mobile/core/network/interceptors/api_key_interceptor.dart';
import 'package:dolibarr_mobile/core/network/interceptors/error_interceptor.dart';
import 'package:dolibarr_mobile/core/network/interceptors/logging_interceptor.dart';
import 'package:dolibarr_mobile/core/network/interceptors/retry_interceptor.dart';
import 'package:dolibarr_mobile/core/storage/secure_storage.dart';
import 'package:flutter/foundation.dart';

/// Construit le `Dio` racine de l'app avec les 4 intercepteurs branchés
/// dans l'ordre requis :
/// 1. `ApiKeyInterceptor` (header DOLAPIKEY)
/// 2. `LoggingInterceptor` (debug uniquement)
/// 3. `RetryInterceptor` (timeout / 5xx → backoff exponentiel)
/// 4. `ErrorInterceptor` (mapping + bus SessionExpired)
abstract final class DioClientFactory {
  static Dio create({
    required AppConfig config,
    required SecureStorage storage,
    required NetworkEventBus eventBus,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.apiBaseUrl,
        connectTimeout: config.connectTimeout,
        receiveTimeout: config.receiveTimeout,
      ),
    );
    dio.interceptors
      ..add(ApiKeyInterceptor(storage))
      ..addAll(kDebugMode ? [LoggingInterceptor()] : const [])
      ..add(RetryInterceptor(dio: dio))
      ..add(ErrorInterceptor(eventBus));
    return dio;
  }
}
