import 'package:dio/dio.dart';
import 'package:dolibarr_mobile/core/constants/api_paths.dart';
import 'package:dolibarr_mobile/core/utils/logger.dart';

/// Logger structuré des appels API. Actif en debug uniquement (no-op
/// release via `AppLogger`).
///
/// La clé `DOLAPIKEY` est masquée dans la sortie pour éviter sa fuite
/// dans les logs de session.
final class LoggingInterceptor extends Interceptor {
  LoggingInterceptor() : _log = AppLogger('http');

  final AppLogger _log;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    _log.d(
      '→ ${options.method} ${options.uri} '
      'headers=${_redact(options.headers)}',
    );
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final size = _bodySize(response.data);
    _log.d(
      '← ${response.statusCode} ${response.requestOptions.uri} '
      '($size bytes)',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log.w(
      '✗ ${err.response?.statusCode ?? '-'} '
      '${err.requestOptions.uri} '
      'type=${err.type} message=${err.message}',
      error: err,
    );
    handler.next(err);
  }

  Map<String, Object?> _redact(Map<String, dynamic> headers) {
    final out = <String, Object?>{};
    headers.forEach((k, v) {
      out[k] = k == ApiHeaders.dolApiKey ? '***' : v;
    });
    return out;
  }

  int _bodySize(Object? data) {
    if (data is String) return data.length;
    if (data is List) return data.length;
    if (data is Map) return data.length;
    return 0;
  }
}
