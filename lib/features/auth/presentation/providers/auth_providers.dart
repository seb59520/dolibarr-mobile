import 'package:dolibarr_mobile/core/di/providers.dart';
import 'package:dolibarr_mobile/core/errors/failure.dart';
import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:dolibarr_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:dolibarr_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:dolibarr_mobile/features/auth/domain/entities/credentials.dart';
import 'package:dolibarr_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:dolibarr_mobile/features/auth/domain/usecases/login_user.dart';
import 'package:dolibarr_mobile/features/auth/domain/usecases/logout_user.dart';
import 'package:dolibarr_mobile/features/auth/domain/usecases/restore_session.dart';
import 'package:dolibarr_mobile/features/auth/domain/usecases/test_connection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Providers Riverpod de la feature `auth`.
///
/// `authNotifierProvider` est le state racine consommé par le router
/// (auth_guard) et l'UI. Il commence en `restoring` puis bascule vers
/// `authenticated` ou `unauthenticated`.

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remote: ref.watch(authRemoteDataSourceProvider),
    storage: ref.watch(secureStorageProvider),
  );
});

final testConnectionProvider = Provider<TestConnection>(
  (ref) => TestConnection(ref.watch(authRepositoryProvider)),
);
final loginUserProvider = Provider<LoginUser>(
  (ref) => LoginUser(ref.watch(authRepositoryProvider)),
);
final logoutUserProvider = Provider<LogoutUser>(
  (ref) => LogoutUser(ref.watch(authRepositoryProvider)),
);
final restoreSessionProvider = Provider<RestoreSession>(
  (ref) => RestoreSession(ref.watch(authRepositoryProvider)),
);

/// État racine de l'auth.
sealed class AuthState {
  const AuthState();
}

final class AuthRestoring extends AuthState {
  const AuthRestoring();
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated({this.lastBaseUrl});
  final String? lastBaseUrl;
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.session);
  final AuthSession session;
}

final class AuthError extends AuthState {
  const AuthError(this.failure);
  final Failure failure;
}

/// Notifier de session — branché sur le bus `SessionExpired` au démarrage.
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Écoute le bus pour basculer en unauthenticated dès qu'un 401 fuit.
    final bus = ref.watch(networkEventBusProvider);
    final sub = bus.onSessionExpired.listen((_) => _onSessionExpired());
    ref.onDispose(sub.cancel);
    return const AuthRestoring();
  }

  /// À appeler par le splash : tente de restaurer la session.
  Future<void> restore() async {
    state = const AuthRestoring();
    final result = await ref.read(restoreSessionProvider)();
    state = result.fold(
      onSuccess: (s) =>
          s == null ? const AuthUnauthenticated() : AuthAuthenticated(s),
      onFailure: (f) {
        // Si le serveur dit 401 : la clé est invalide, on purge.
        if (f is UnauthorizedFailure) {
          // Ne pas attendre — fire & forget.
          ref.read(logoutUserProvider)();
          return const AuthUnauthenticated();
        }
        // Erreur réseau : on garde la session locale (mode dégradé).
        return AuthError(f);
      },
    );
  }

  Future<Result<String>> testConnection(Credentials c) =>
      ref.read(testConnectionProvider)(c);

  Future<Result<AuthSession>> login(Credentials c) async {
    final result = await ref.read(loginUserProvider)(c);
    // Propage la baseUrl au `appConfigProvider` pour que le `dioProvider`
    // partagé (consommé par tiers/factures/etc.) se reconstruise avec la
    // bonne instance Dolibarr — sinon il reste figé sur la valeur lue au
    // boot et toutes les requêtes data tapent sur le placeholder.
    if (result is Success<AuthSession>) {
      ref.read(appConfigProvider.notifier).setBaseUrl(c.baseUrl);
    }
    state = result.fold(
      onSuccess: AuthAuthenticated.new,
      onFailure: AuthError.new,
    );
    return result;
  }

  Future<void> logout() async {
    await ref.read(logoutUserProvider)();
    state = const AuthUnauthenticated();
  }

  void _onSessionExpired() {
    state = const AuthUnauthenticated();
    // Fire & forget purge.
    ref.read(logoutUserProvider)();
  }
}

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
