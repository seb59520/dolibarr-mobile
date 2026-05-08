import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart' as pkg;

/// Wrapper minimaliste autour de `package:logger`.
///
/// Émet uniquement en mode debug : en release, `logger` est un no-op
/// (les méthodes ne sont jamais appelées car le check `kDebugMode` est
/// inliné par le compilateur, ce qui élimine aussi la chaîne de log).
final class AppLogger {
  AppLogger(String tag)
      : _tag = tag,
        _impl = pkg.Logger(
          printer: pkg.PrettyPrinter(
            methodCount: 0,
            errorMethodCount: 5,
            printEmojis: false,
            dateTimeFormat: pkg.DateTimeFormat.onlyTimeAndSinceStart,
          ),
          level: kDebugMode ? pkg.Level.debug : pkg.Level.off,
        );

  final String _tag;
  final pkg.Logger _impl;

  void d(String message, {Object? error, StackTrace? stack}) {
    if (kDebugMode) {
      _impl.d('[$_tag] $message', error: error, stackTrace: stack);
    }
  }

  void i(String message) {
    if (kDebugMode) _impl.i('[$_tag] $message');
  }

  void w(String message, {Object? error, StackTrace? stack}) {
    if (kDebugMode) {
      _impl.w('[$_tag] $message', error: error, stackTrace: stack);
    }
  }

  void e(String message, {Object? error, StackTrace? stack}) {
    if (kDebugMode) {
      _impl.e('[$_tag] $message', error: error, stackTrace: stack);
    }
  }
}
