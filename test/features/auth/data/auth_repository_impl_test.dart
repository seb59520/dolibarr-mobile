import 'package:dolibarr_mobile/core/errors/exceptions.dart';
import 'package:dolibarr_mobile/core/errors/failure.dart';
import 'package:dolibarr_mobile/core/storage/secure_storage.dart';
import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:dolibarr_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:dolibarr_mobile/features/auth/domain/entities/credentials.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements AuthRemoteDataSource {}

class _MockStorage extends Mock implements SecureStorage {}

const _userInfo = DolibarrUserInfo(
  id: 7,
  login: 'jdoe',
  firstname: 'Jeanne',
  lastname: 'Doe',
  email: 'j@doe.fr',
);

void main() {
  late _MockRemote remote;
  late _MockStorage storage;
  late AuthRepositoryImpl repo;

  setUp(() {
    remote = _MockRemote();
    storage = _MockStorage();
    repo = AuthRepositoryImpl(remote: remote, storage: storage);
    when(() => storage.writeApiKey(any())).thenAnswer((_) async {});
    when(() => storage.writeBaseUrl(any())).thenAnswer((_) async {});
    when(() => storage.deleteApiKey()).thenAnswer((_) async {});
  });

  group('login (mode apiKeyDirect)', () {
    test('persiste la clé et retourne la session enrichie', () async {
      when(
        () => remote.getUserInfo(
          baseUrl: any(named: 'baseUrl'),
          apiKey: any(named: 'apiKey'),
        ),
      ).thenAnswer((_) async => _userInfo);

      final result = await repo.login(
        Credentials.apiKey(baseUrl: 'https://erp', apiKey: 'k1'),
      );

      expect(result.isSuccess, isTrue);
      verify(() => storage.writeApiKey('k1')).called(1);
      verify(() => storage.writeBaseUrl('https://erp')).called(1);
    });

    test('renvoie UnauthorizedFailure si la clé est invalide', () async {
      when(
        () => remote.getUserInfo(
          baseUrl: any(named: 'baseUrl'),
          apiKey: any(named: 'apiKey'),
        ),
      ).thenThrow(const UnauthorizedException('clé invalide'));

      final result = await repo.login(
        Credentials.apiKey(baseUrl: 'https://erp', apiKey: 'bad'),
      );
      expect(
        (result as FailureResult).failure,
        isA<UnauthorizedFailure>(),
      );
      verifyNever(() => storage.writeApiKey(any()));
    });
  });

  group('login (mode loginPassword)', () {
    test('appelle remote.login puis getUserInfo avec le token', () async {
      when(
        () => remote.login(
          baseUrl: any(named: 'baseUrl'),
          login: any(named: 'login'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => const DolibarrLoginResponse(token: 'tok-xyz'),
      );
      when(
        () => remote.getUserInfo(
          baseUrl: 'https://erp',
          apiKey: 'tok-xyz',
        ),
      ).thenAnswer((_) async => _userInfo);

      final result = await repo.login(
        Credentials.loginPassword(
          baseUrl: 'https://erp',
          login: 'jdoe',
          password: 'secret',
        ),
      );
      expect(result.isSuccess, isTrue);
      verify(() => storage.writeApiKey('tok-xyz')).called(1);
    });
  });

  group('restoreSession', () {
    test('retourne null si pas de clé persistée', () async {
      when(() => storage.readApiKey()).thenAnswer((_) async => null);
      when(() => storage.readBaseUrl()).thenAnswer((_) async => null);

      final result = await repo.restoreSession();
      expect((result as Success).value, isNull);
    });

    test('valide la clé via getUserInfo et retourne la session', () async {
      when(() => storage.readApiKey()).thenAnswer((_) async => 'k1');
      when(() => storage.readBaseUrl())
          .thenAnswer((_) async => 'https://erp');
      when(
        () => remote.getUserInfo(
          baseUrl: 'https://erp',
          apiKey: 'k1',
        ),
      ).thenAnswer((_) async => _userInfo);

      final result = await repo.restoreSession();
      expect(result.isSuccess, isTrue);
    });
  });

  group('logout', () {
    test('purge la clé API mais garde la baseUrl', () async {
      final result = await repo.logout();
      expect(result.isSuccess, isTrue);
      verify(() => storage.deleteApiKey()).called(1);
      verifyNever(() => storage.writeBaseUrl(any()));
    });
  });
}
