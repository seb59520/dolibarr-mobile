import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:dolibarr_mobile/features/auth/domain/entities/credentials.dart';

/// Contrat d'accès à l'authentification Dolibarr.
///
/// Toutes les méthodes retournent un `Result<T>` — aucune exception
/// ne traverse cette frontière. La couche `presentation` pattern-matche
/// le `Result.fold(...)`.
abstract interface class AuthRepository {
  /// Vérifie que l'instance répond et que les credentials fournis sont
  /// valides, sans persister de session. Utilisé par le bouton
  /// "Tester la connexion" avant le submit.
  ///
  /// Retourne le `userLogin` côté Dolibarr en cas de succès.
  Future<Result<String>> testConnection(Credentials credentials);

  /// Login complet : valide les credentials, persiste la clé API et
  /// l'URL dans `SecureStorage`, retourne la session enrichie.
  Future<Result<AuthSession>> login(Credentials credentials);

  /// Restaure la session depuis le stockage sécurisé au démarrage.
  /// Retourne `null` côté succès si aucune session n'est mémorisée.
  Future<Result<AuthSession?>> restoreSession();

  /// Purge la session locale (clé API, URL, cache) et émet le logout.
  Future<Result<void>> logout();
}
