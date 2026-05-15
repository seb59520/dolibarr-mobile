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

  /// Libellé court et stable du type d'erreur (insensible au minify
  /// release web). Utilisé pour préfixer toString() — chaque sous-type
  /// l'override avec sa propre étiquette.
  String get kind;

  @override
  List<Object?> get props => [kind, message];

  @override
  String toString() {
    final m = message;
    if (m != null && m.isNotEmpty) return '$kind : $m';
    return kind;
  }
}

/// Pas de réseau, ou requête timeoutée avant d'atteindre le serveur.
final class NetworkFailure extends Failure {
  const NetworkFailure({super.message, super.cause});
  @override
  String get kind => 'Réseau indisponible';
}

/// La session API est expirée ou la clé est invalide (HTTP 401).
final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.message, super.cause});
  @override
  String get kind => 'Session expirée';
}

/// L'utilisateur n'a pas le droit d'effectuer l'opération (HTTP 403).
final class ForbiddenFailure extends Failure {
  const ForbiddenFailure({super.message, super.cause});
  @override
  String get kind => 'Droit refusé';
}

/// Ressource introuvable (HTTP 404). Souvent utilisée pour détecter les
/// suppressions concurrentes côté serveur.
final class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message, super.cause});
  @override
  String get kind => 'Introuvable';
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
  String get kind => 'Conflit de version';

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
  String get kind => 'Données invalides';

  @override
  String toString() {
    final base = super.toString();
    if (fieldErrors.isEmpty) return base;
    final details =
        fieldErrors.entries.map((e) => '${e.key}: ${e.value}').join(', ');
    return '$base ($details)';
  }

  @override
  List<Object?> get props => [...super.props, fieldErrors];
}

/// Erreur serveur 5xx, après épuisement des retries.
final class ServerFailure extends Failure {
  const ServerFailure({this.statusCode, super.message, super.cause});
  final int? statusCode;

  @override
  String get kind =>
      statusCode == null ? 'Erreur serveur' : 'Erreur serveur ($statusCode)';

  @override
  List<Object?> get props => [...super.props, statusCode];
}

/// Erreur de cache local (Drift, secure_storage…).
final class CacheFailure extends Failure {
  const CacheFailure({super.message, super.cause});
  @override
  String get kind => 'Cache local';
}

/// Erreur inconnue / non catégorisée. À éviter dans le code de production.
final class UnknownFailure extends Failure {
  const UnknownFailure({super.message, super.cause});
  @override
  String get kind => 'Erreur inattendue';
}
