import 'dart:async';

import 'package:dio/dio.dart';
import 'package:dolibarr_mobile/core/errors/error_mapper.dart';
import 'package:dolibarr_mobile/core/errors/exceptions.dart';

/// Bus d'événements globaux émis par la couche réseau.
///
/// Le router écoute `onSessionExpired` pour rediriger vers `/login` en
/// préservant la route cible.
final class NetworkEventBus {
  final StreamController<NetworkEvent> _controller =
      StreamController<NetworkEvent>.broadcast();

  Stream<NetworkEvent> get events => _controller.stream;

  Stream<SessionExpired> get onSessionExpired =>
      events.where((e) => e is SessionExpired).cast<SessionExpired>();

  void emit(NetworkEvent event) => _controller.add(event);

  Future<void> dispose() => _controller.close();
}

sealed class NetworkEvent {
  const NetworkEvent();
}

final class SessionExpired extends NetworkEvent {
  const SessionExpired();
}

/// Convertit toute `DioException` en exception interne typée et émet
/// `SessionExpired` sur le bus en cas de 401 (déclenche le re-login global).
final class ErrorInterceptor extends Interceptor {
  ErrorInterceptor(this._eventBus);

  final NetworkEventBus _eventBus;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = ErrorMapper.fromDio(err);
    if (exception is UnauthorizedException) {
      _eventBus.emit(const SessionExpired());
    }
    final wrapped = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      message: exception.toString(),
      error: exception,
    );
    handler.next(wrapped);
  }
}
