import 'package:dolibarr_mobile/core/errors/failure.dart';
import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:dolibarr_mobile/features/auth/domain/entities/credentials.dart';
import 'package:dolibarr_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:dolibarr_mobile/features/auth/domain/usecases/login_user.dart';
import 'package:dolibarr_mobile/features/auth/domain/usecases/logout_user.dart';
import 'package:dolibarr_mobile/features/auth/domain/usecases/restore_session.dart';
import 'package:dolibarr_mobile/features/auth/domain/usecases/test_connection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      Credentials.apiKey(baseUrl: 'https://fallback', apiKey: 'k'),
    );
  });

  late _MockAuthRepository repo;

  setUp(() => repo = _MockAuthRepository());

  group('Credentials', () {
    test('isFilled exige baseUrl + login + password en mode loginPassword', () {
      final c = Credentials.loginPassword(
        baseUrl: 'https://erp.example.com',
        login: 'jdoe',
        password: 'secret',
      );
      expect(c.isFilled, isTrue);

      const empty =
          Credentials(baseUrl: '', mode: AuthMode.loginPassword);
      expect(empty.isFilled, isFalse);
    });

    test('isFilled exige baseUrl + apiKey en mode apiKeyDirect', () {
      final c = Credentials.apiKey(
        baseUrl: 'https://erp.example.com',
        apiKey: 'abc',
      );
      expect(c.isFilled, isTrue);

      final missing = Credentials.apiKey(
        baseUrl: 'https://erp.example.com',
        apiKey: '',
      );
      expect(missing.isFilled, isFalse);
    });
  });

  group('AuthSession', () {
    test('fullName fallback sur userLogin si pas de prénom/nom', () {
      const s = AuthSession(
        baseUrl: 'https://erp',
        apiKey: 'k',
        userId: 1,
        userLogin: 'jdoe',
        firstname: '',
        lastname: '',
      );
      expect(s.fullName, 'jdoe');
    });

    test('fullName concatène firstname et lastname', () {
      const s = AuthSession(
        baseUrl: 'https://erp',
        apiKey: 'k',
        userId: 1,
        userLogin: 'jdoe',
        firstname: 'Jeanne',
        lastname: 'Doe',
      );
      expect(s.fullName, 'Jeanne Doe');
    });
  });

  group('TestConnection usecase', () {
    test('délègue au repository', () async {
      const success = Success<String>('jdoe');
      when(() => repo.testConnection(any())).thenAnswer((_) async => success);
      final usecase = TestConnection(repo);
      final result = await usecase(
        Credentials.apiKey(baseUrl: 'https://erp', apiKey: 'k'),
      );
      expect(result, success);
    });
  });

  group('LoginUser usecase', () {
    test('propage le succès', () async {
      const session = AuthSession(
        baseUrl: 'https://erp',
        apiKey: 'k',
        userId: 1,
        userLogin: 'jdoe',
        firstname: 'Jeanne',
        lastname: 'Doe',
      );
      when(() => repo.login(any()))
          .thenAnswer((_) async => const Success<AuthSession>(session));
      final result = await LoginUser(repo)(
        Credentials.apiKey(baseUrl: 'https://erp', apiKey: 'k'),
      );
      expect(result, isA<Success<AuthSession>>());
    });

    test('propage l’échec', () async {
      when(() => repo.login(any())).thenAnswer(
        (_) async => const FailureResult<AuthSession>(UnauthorizedFailure()),
      );
      final result = await LoginUser(repo)(
        Credentials.apiKey(baseUrl: 'https://erp', apiKey: 'k'),
      );
      expect(result, isA<FailureResult<AuthSession>>());
    });
  });

  group('RestoreSession usecase', () {
    test('retourne null en cas de pas de session mémorisée', () async {
      when(() => repo.restoreSession())
          .thenAnswer((_) async => const Success<AuthSession?>(null));
      final result = await RestoreSession(repo)();
      expect((result as Success<AuthSession?>).value, isNull);
    });
  });

  group('LogoutUser usecase', () {
    test('appelle repo.logout', () async {
      when(() => repo.logout())
          .thenAnswer((_) async => const Success<void>(null));
      final result = await LogoutUser(repo)();
      expect(result.isSuccess, isTrue);
      verify(() => repo.logout()).called(1);
    });
  });
}
