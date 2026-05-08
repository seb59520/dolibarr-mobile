import 'package:equatable/equatable.dart';

/// Mode de saisie des identifiants à l'écran de connexion.
enum AuthMode {
  /// Login + mot de passe : on appelle `POST /login`, le serveur retourne
  /// un token qui sera persisté comme `DOLAPIKEY`. Le mot de passe ne
  /// transite jamais en stockage local.
  loginPassword,

  /// Clé API directe créée dans le profil utilisateur Dolibarr.
  /// Recommandée pour la sécurité (révocable, scopée, persistante).
  apiKeyDirect,
}

/// Saisie utilisateur de l'écran de login.
final class Credentials extends Equatable {
  const Credentials({
    required this.baseUrl,
    required this.mode,
    this.login,
    this.password,
    this.apiKey,
  });

  factory Credentials.loginPassword({
    required String baseUrl,
    required String login,
    required String password,
  }) =>
      Credentials(
        baseUrl: baseUrl,
        mode: AuthMode.loginPassword,
        login: login,
        password: password,
      );

  factory Credentials.apiKey({
    required String baseUrl,
    required String apiKey,
  }) =>
      Credentials(
        baseUrl: baseUrl,
        mode: AuthMode.apiKeyDirect,
        apiKey: apiKey,
      );

  final String baseUrl;
  final AuthMode mode;
  final String? login;
  final String? password;
  final String? apiKey;

  /// Vérifie que la saisie est non-vide pour le mode courant.
  bool get isFilled {
    if (baseUrl.trim().isEmpty) return false;
    return switch (mode) {
      AuthMode.loginPassword =>
        (login?.isNotEmpty ?? false) && (password?.isNotEmpty ?? false),
      AuthMode.apiKeyDirect => apiKey?.isNotEmpty ?? false,
    };
  }

  @override
  List<Object?> get props => [baseUrl, mode, login, password, apiKey];
}
