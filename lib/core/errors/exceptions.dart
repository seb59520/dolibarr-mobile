// Exceptions internes à la couche `data`.
//
// Elles ne traversent JAMAIS la frontière `data → domain` : le
// repository les capture et retourne un `Result.FailureResult(Failure…)`
// approprié.

/// Soulevée par les datasources lors d'une 401 — déclenche le flux de
/// re-login global piloté par l'auth_guard.
final class UnauthorizedException implements Exception {
  const UnauthorizedException([this.message]);
  final String? message;
  @override
  String toString() => 'UnauthorizedException: $message';
}

/// Soulevée par les datasources lors d'une 403.
final class ForbiddenException implements Exception {
  const ForbiddenException([this.message]);
  final String? message;
  @override
  String toString() => 'ForbiddenException: $message';
}

/// Soulevée par les datasources lors d'une 404.
final class NotFoundException implements Exception {
  const NotFoundException([this.message]);
  final String? message;
  @override
  String toString() => 'NotFoundException: $message';
}

/// Erreur HTTP non triviale après les retries (5xx, 4xx imprévue).
final class ServerException implements Exception {
  const ServerException({required this.statusCode, this.message});
  final int statusCode;
  final String? message;
  @override
  String toString() => 'ServerException($statusCode): $message';
}

/// Erreur de validation côté API (typiquement 400 avec corps détaillé).
final class ValidationException implements Exception {
  const ValidationException({this.message, this.fieldErrors = const {}});
  final String? message;
  final Map<String, String> fieldErrors;
  @override
  String toString() => 'ValidationException: $message ($fieldErrors)';
}

/// Pas de réseau ou timeout côté client.
final class NetworkException implements Exception {
  const NetworkException([this.message]);
  final String? message;
  @override
  String toString() => 'NetworkException: $message';
}

/// Échec d'opération sur le cache local.
final class CacheException implements Exception {
  const CacheException([this.message]);
  final String? message;
  @override
  String toString() => 'CacheException: $message';
}
