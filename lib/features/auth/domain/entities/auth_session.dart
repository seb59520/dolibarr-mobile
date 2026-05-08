import 'package:equatable/equatable.dart';

/// Session utilisateur courante après login réussi.
///
/// Construite à partir de la réponse `GET /users/info` enrichie avec
/// l'URL de l'instance et la clé API utilisée. Persiste tant que la
/// clé API est valide côté serveur ; un 401 émis par l'`ErrorInterceptor`
/// déclenche la purge.
final class AuthSession extends Equatable {
  const AuthSession({
    required this.baseUrl,
    required this.apiKey,
    required this.userId,
    required this.userLogin,
    required this.firstname,
    required this.lastname,
    this.email,
    this.admin = false,
  });

  final String baseUrl;

  /// Clé API (token retourné par /login OU clé personnelle saisie).
  /// JAMAIS exposée en UI ; uniquement transmise via DOLAPIKEY.
  final String apiKey;

  /// `rowid` de l'utilisateur Dolibarr connecté.
  final int userId;

  final String userLogin;
  final String firstname;
  final String lastname;
  final String? email;
  final bool admin;

  String get fullName {
    final f = firstname.trim();
    final l = lastname.trim();
    if (f.isEmpty && l.isEmpty) return userLogin;
    return [f, l].where((s) => s.isNotEmpty).join(' ');
  }

  @override
  List<Object?> get props => [
        baseUrl,
        apiKey,
        userId,
        userLogin,
        firstname,
        lastname,
        email,
        admin,
      ];
}
