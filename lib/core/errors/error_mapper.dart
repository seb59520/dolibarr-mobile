import 'package:dio/dio.dart';
import 'package:dolibarr_mobile/core/errors/exceptions.dart';
import 'package:dolibarr_mobile/core/errors/failure.dart';

/// Convertit les exceptions techniques en `Failure` métier.
///
/// Utilisé par les repositories pour borner la propagation des exceptions
/// au seul périmètre de la couche `data`.
abstract final class ErrorMapper {
  /// Convertit une `DioException` en exception interne (avant remontée
  /// au repository qui la transformera en `Failure`).
  static Exception fromDio(DioException error) {
    final response = error.response;
    final statusCode = response?.statusCode;
    final apiMessage = _extractApiMessage(response?.data);

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return NetworkException(error.message ?? 'Erreur réseau');
      case DioExceptionType.cancel:
        return const NetworkException('Requête annulée');
      case DioExceptionType.badCertificate:
        return const NetworkException('Certificat TLS invalide');
      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        break;
    }

    if (statusCode == null) {
      return NetworkException(error.message ?? 'Réponse invalide');
    }
    if (statusCode == 401) {
      return UnauthorizedException(apiMessage);
    }
    if (statusCode == 403) {
      return ForbiddenException(apiMessage);
    }
    if (statusCode == 404) {
      return NotFoundException(apiMessage);
    }
    if (statusCode == 400 || statusCode == 422) {
      return ValidationException(message: apiMessage);
    }
    return ServerException(statusCode: statusCode, message: apiMessage);
  }

  /// Convertit une exception interne ou une exception inconnue en `Failure`.
  static Failure toFailure(Object error, [StackTrace? stack]) {
    if (error is UnauthorizedException) {
      return UnauthorizedFailure(message: error.message, cause: error);
    }
    if (error is ForbiddenException) {
      return ForbiddenFailure(message: error.message, cause: error);
    }
    if (error is NotFoundException) {
      return NotFoundFailure(message: error.message, cause: error);
    }
    if (error is ValidationException) {
      return ValidationFailure(
        message: error.message,
        fieldErrors: error.fieldErrors,
        cause: error,
      );
    }
    if (error is ServerException) {
      return ServerFailure(
        statusCode: error.statusCode,
        message: error.message,
        cause: error,
      );
    }
    if (error is NetworkException) {
      return NetworkFailure(message: error.message, cause: error);
    }
    if (error is CacheException) {
      return CacheFailure(message: error.message, cause: error);
    }
    return UnknownFailure(message: error.toString(), cause: error);
  }

  static String? _extractApiMessage(Object? data) {
    if (data is Map<String, Object?>) {
      final error = data['error'];
      if (error is Map<String, Object?> && error['message'] is String) {
        return error['message']! as String;
      }
      if (data['message'] is String) {
        return data['message']! as String;
      }
    }
    return null;
  }
}
