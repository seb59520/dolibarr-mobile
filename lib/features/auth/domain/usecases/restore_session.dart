import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:dolibarr_mobile/features/auth/domain/repositories/auth_repository.dart';

/// Use-case appelé par le splash : tente de restaurer la session
/// depuis `SecureStorage` + `GET /users/info` pour valider la clé.
final class RestoreSession {
  const RestoreSession(this._repo);
  final AuthRepository _repo;

  Future<Result<AuthSession?>> call() => _repo.restoreSession();
}
