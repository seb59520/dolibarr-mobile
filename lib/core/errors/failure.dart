import 'package:equatable/equatable.dart';

/// Représentation typée d'un échec, indépendante de la cause technique.
///
/// La couche `data` mappe toute exception (Dio, Drift, plateforme) vers
/// une variante `Failure` que la couche `domain`/`presentation` peut
/// pattern-matcher sans dépendre de Dio ou de Drift.
sealed class Failure extends Equatable {
  const Failure({this.message, this.cause});
  final String? message;
  final Object? cause;

  @override
  List<Object?> get props => [runtimeType, message];
}

/// Pas de réseau, ou requête timeoutée avant d'atteindre le serveur.
final class NetworkFailure extends Failure {
  const NetworkFailure({super.message, super.cause});
}

/// La session API est expirée ou la clé est invalide (HTTP 401).
final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.message, super.cause});
}

/// L'utilisateur n'a pas le droit d'effectuer l'opération (HTTP 403).
final class ForbiddenFailure extends Failure {
  const ForbiddenFailure({super.message, super.cause});
}

/// Ressource introuvable (HTTP 404). Souvent utilisée pour détecter les
/// suppressions concurrentes côté serveur.
final class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message, super.cause});
}

/// La ressource a été modifiée côté serveur depuis la lecture locale.
/// Détecté via comparaison `tms` lors d'une mise à jour.
final class ConflictFailure extends Failure {
  const ConflictFailure({
    required this.expectedTms,
    required this.serverTms,
    super.message,
    super.cause,
  });
  final DateTime expectedTms;
  final DateTime serverTms;

  @override
  List<Object?> get props => [...super.props, expectedTms, serverTms];
}

/// Erreur 4xx imputable à la requête (validation, payload invalide).
final class ValidationFailure extends Failure {
  const ValidationFailure({
    super.message,
    super.cause,
    this.fieldErrors = const {},
  });
  final Map<String, String> fieldErrors;

  @override
  List<Object?> get props => [...super.props, fieldErrors];
}

/// Erreur serveur 5xx, après épuisement des retries.
final class ServerFailure extends Failure {
  const ServerFailure({this.statusCode, super.message, super.cause});
  final int? statusCode;

  @override
  List<Object?> get props => [...super.props, statusCode];
}

/// Erreur de cache local (Drift, secure_storage…).
final class CacheFailure extends Failure {
  const CacheFailure({super.message, super.cause});
}

/// Erreur inconnue / non catégorisée. À éviter dans le code de production.
final class UnknownFailure extends Failure {
  const UnknownFailure({super.message, super.cause});
}
