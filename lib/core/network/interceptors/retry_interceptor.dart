import 'dart:async';
import 'dart:math' as math;

import 'package:dio/dio.dart';

/// Retry exponentiel sur les erreurs réseau et 5xx.
///
/// 3 tentatives max après l'appel initial, délai 250ms × 2^n + jitter.
/// Les codes 4xx (sauf 408 timeout, 429 rate-limit) ne sont JAMAIS rejoués.
final class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.baseDelay = const Duration(milliseconds: 250),
    Future<void> Function(Duration)? sleep,
  }) : _sleep = sleep ?? Future.delayed;

  final Dio dio;
  final int maxRetries;
  final Duration baseDelay;
  final Future<void> Function(Duration) _sleep;

  static const String _retryCountKey = '_retry_count';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_shouldRetry(err)) {
      handler.next(err);
      return;
    }
    final options = err.requestOptions;
    final attempt = (options.extra[_retryCountKey] as int? ?? 0) + 1;
    if (attempt > maxRetries) {
      handler.next(err);
      return;
    }
    options.extra[_retryCountKey] = attempt;

    await _sleep(_backoffDelay(attempt));
    try {
      final response = await dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  bool _shouldRetry(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return true;
    }
    final code = err.response?.statusCode;
    if (code == null) return false;
    if (code == 408 || code == 429) return true;
    return code >= 500 && code < 600;
  }

  Duration _backoffDelay(int attempt) {
    final exp = math.pow(2, attempt - 1).toInt();
    final jitter = math.Random().nextInt(100);
    return baseDelay * exp + Duration(milliseconds: jitter);
  }
}
