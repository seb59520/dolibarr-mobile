import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/auth/domain/entities/credentials.dart';
import 'package:dolibarr_mobile/features/auth/domain/repositories/auth_repository.dart';

/// Use-case « Tester la connexion » de l'écran de login.
///
/// Encapsule l'appel au repository pour rester homogène avec les autres
/// usecases (et faciliter le mock en test de l'AuthNotifier).
final class TestConnection {
  const TestConnection(this._repo);
  final AuthRepository _repo;

  Future<Result<String>> call(Credentials credentials) =>
      _repo.testConnection(credentials);
}
