import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/auth/domain/repositories/auth_repository.dart';

/// Use-case de déconnexion : purge la clé API, l'URL persistée et
/// le cache local. Le router redirige ensuite vers `/login`.
final class LogoutUser {
  const LogoutUser(this._repo);
  final AuthRepository _repo;

  Future<Result<void>> call() => _repo.logout();
}
