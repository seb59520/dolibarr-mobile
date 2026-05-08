import 'package:dolibarr_mobile/core/errors/error_mapper.dart';
import 'package:dolibarr_mobile/core/storage/secure_storage.dart';
import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:dolibarr_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:dolibarr_mobile/features/auth/domain/entities/credentials.dart';
import 'package:dolibarr_mobile/features/auth/domain/repositories/auth_repository.dart';

/// Implémentation par défaut de `AuthRepository`. Coordonne le datasource
/// distant et le `SecureStorage` ; ne touche pas à Drift (la purge du
/// cache local est faite par le SyncEngine, pas l'auth — Étape 9).
final class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required SecureStorage storage,
  })  : _remote = remote,
        _storage = storage;

  final AuthRemoteDataSource _remote;
  final SecureStorage _storage;

  @override
  Future<Result<String>> testConnection(Credentials credentials) async {
    try {
      final apiKey = await _resolveApiKey(credentials);
      final info = await _remote.getUserInfo(
        baseUrl: credentials.baseUrl,
        apiKey: apiKey,
      );
      return Success(info.login);
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }

  @override
  Future<Result<AuthSession>> login(Credentials credentials) async {
    try {
      final apiKey = await _resolveApiKey(credentials);
      final info = await _remote.getUserInfo(
        baseUrl: credentials.baseUrl,
        apiKey: apiKey,
      );
      // Persistance : on stocke uniquement la clé API et l'URL.
      await _storage.writeBaseUrl(credentials.baseUrl);
      await _storage.writeApiKey(apiKey);

      return Success(
        AuthSession(
          baseUrl: credentials.baseUrl,
          apiKey: apiKey,
          userId: info.id,
          userLogin: info.login,
          firstname: info.firstname,
          lastname: info.lastname,
          email: info.email,
          admin: info.admin,
        ),
      );
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }

  @override
  Future<Result<AuthSession?>> restoreSession() async {
    try {
      final baseUrl = await _storage.readBaseUrl();
      final apiKey = await _storage.readApiKey();
      if (baseUrl == null ||
          baseUrl.isEmpty ||
          apiKey == null ||
          apiKey.isEmpty) {
        return const Success<AuthSession?>(null);
      }
      final info = await _remote.getUserInfo(
        baseUrl: baseUrl,
        apiKey: apiKey,
      );
      return Success(
        AuthSession(
          baseUrl: baseUrl,
          apiKey: apiKey,
          userId: info.id,
          userLogin: info.login,
          firstname: info.firstname,
          lastname: info.lastname,
          email: info.email,
          admin: info.admin,
        ),
      );
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _storage.deleteApiKey();
      // baseUrl est gardée pour pré-remplir la prochaine connexion.
      return const Success<void>(null);
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }

  /// Résout la clé API à utiliser pour la requête : soit la clé directe
  /// fournie par l'utilisateur, soit le token obtenu via `POST /login`.
  Future<String> _resolveApiKey(Credentials c) async {
    return switch (c.mode) {
      AuthMode.apiKeyDirect => c.apiKey ?? '',
      AuthMode.loginPassword => (await _remote.login(
          baseUrl: c.baseUrl,
          login: c.login ?? '',
          password: c.password ?? '',
        ))
            .token,
    };
  }
}
