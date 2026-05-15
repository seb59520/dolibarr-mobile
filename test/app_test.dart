import 'package:dolibarr_mobile/app.dart';
import 'package:dolibarr_mobile/core/di/providers.dart';
import 'package:dolibarr_mobile/core/preferences/tweaks.dart';
import 'package:dolibarr_mobile/core/storage/secure_storage.dart';
import 'package:dolibarr_mobile/core/sync/sync_providers.dart';
import 'package:dolibarr_mobile/core/theme/app_theme.dart';
import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:dolibarr_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:dolibarr_mobile/features/auth/domain/entities/credentials.dart';
import 'package:dolibarr_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:dolibarr_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _NoopStorage implements SecureStorage {
  @override
  Future<void> writeApiKey(String apiKey) async {}
  @override
  Future<String?> readApiKey() async => null;
  @override
  Future<void> deleteApiKey() async {}
  @override
  Future<void> writeBaseUrl(String url) async {}
  @override
  Future<String?> readBaseUrl() async => null;
  @override
  Future<void> writeOnboardingCompleted() async {}
  @override
  Future<bool> readOnboardingCompleted() async => true;
  @override
  Future<void> writeOcrEndpoint(String url) async {}
  @override
  Future<String?> readOcrEndpoint() async => null;
  @override
  Future<void> writeOcrBearer(String token) async {}
  @override
  Future<String?> readOcrBearer() async => null;
  @override
  Future<void> deleteOcrBearer() async {}
  @override
  Future<void> clear() async {}
}

class _StubAuthRepository implements AuthRepository {
  @override
  Future<Result<String>> testConnection(Credentials c) async =>
      const Success('jdoe');
  @override
  Future<Result<AuthSession>> login(Credentials c) async =>
      const Success(_session);
  @override
  Future<Result<AuthSession?>> restoreSession() async =>
      const Success<AuthSession?>(null);
  @override
  Future<Result<void>> logout() async => const Success<void>(null);

  static const _session = AuthSession(
    baseUrl: 'https://erp',
    apiKey: 'k',
    userId: 1,
    userLogin: 'jdoe',
    firstname: 'Jeanne',
    lastname: 'Doe',
  );
}

class _NoopRemote implements AuthRemoteDataSource {
  @override
  Future<DolibarrLoginResponse> login({
    required String baseUrl,
    required String login,
    required String password,
  }) async =>
      const DolibarrLoginResponse(token: '');
  @override
  Future<DolibarrUserInfo> getUserInfo({
    required String baseUrl,
    required String apiKey,
  }) async =>
      const DolibarrUserInfo(
        id: 0,
        login: '',
        firstname: '',
        lastname: '',
      );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    AppTheme.useSystemFontInsteadOfGoogleFonts = true;
  });

  testWidgets('DolibarrMobileApp démarre sur le Splash', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_StubAuthRepository()),
          authRemoteDataSourceProvider.overrideWithValue(_NoopRemote()),
          secureStorageProvider.overrideWithValue(_NoopStorage()),
          sharedPreferencesProvider.overrideWithValue(prefs),
          // Court-circuite l'engine sync (besoin de la base Drift sinon).
          syncBootstrapProvider.overrideWith((_) {}),
        ],
        child: const DolibarrMobileApp(),
      ),
    );
    // Premier frame : le splash s'affiche.
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byIcon(Icons.business_center_outlined), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    // Laisse les timers du splash se résoudre (delay configuré + restore).
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Onboarding terminé + non authentifié → redirige vers Login.
    expect(find.text('Connexion à votre instance'), findsOneWidget);
  });
}
