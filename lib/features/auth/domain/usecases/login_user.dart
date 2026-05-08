import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:dolibarr_mobile/features/auth/domain/entities/credentials.dart';
import 'package:dolibarr_mobile/features/auth/domain/repositories/auth_repository.dart';

/// Use-case de connexion. Persiste la session si succès.
final class LoginUser {
  const LoginUser(this._repo);
  final AuthRepository _repo;

  Future<Result<AuthSession>> call(Credentials credentials) =>
      _repo.login(credentials);
}
