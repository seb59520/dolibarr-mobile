import 'package:dolibarr_mobile/core/di/providers.dart';
import 'package:dolibarr_mobile/core/preferences/tweaks.dart';
import 'package:dolibarr_mobile/core/storage/secure_storage.dart';
import 'package:dolibarr_mobile/core/theme/app_theme.dart';
import 'package:dolibarr_mobile/features/expenses/presentation/pages/expense_scan_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeStorage implements SecureStorage {
  _FakeStorage({this.endpoint, this.bearer});
  final String? endpoint;
  final String? bearer;

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
  Future<String?> readOcrEndpoint() async => endpoint;
  @override
  Future<void> writeOcrBearer(String token) async {}
  @override
  Future<String?> readOcrBearer() async => bearer;
  @override
  Future<void> deleteOcrBearer() async {}
  @override
  Future<void> clear() async {}
}

Widget _wrap({
  required SharedPreferences prefs,
  required SecureStorage storage,
}) {
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      secureStorageProvider.overrideWithValue(storage),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(const Tweaks()),
      home: const ExpenseScanPage(),
    ),
  );
}

void main() {
  late SharedPreferences prefs;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    AppTheme.useSystemFontInsteadOfGoogleFonts = true;
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  testWidgets(
    'affiche le bloc "OCR non configuré" quand le bearer est absent',
    (tester) async {
      await tester.pumpWidget(
        _wrap(prefs: prefs, storage: _FakeStorage()),
      );
      // Laisse les FutureProviders se résoudre.
      await tester.pumpAndSettle();

      expect(find.text('OCR non configuré'), findsOneWidget);
      expect(find.text('Ouvrir Paramètres'), findsOneWidget);
      // Et donc PAS de boutons de capture.
      expect(find.text('Prendre une photo'), findsNothing);
    },
  );

  testWidgets(
    'affiche les 3 boutons de source quand l’OCR est configuré',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          prefs: prefs,
          storage: _FakeStorage(
            endpoint: 'https://ocr.example',
            bearer: 'sk-42',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Prendre une photo'), findsOneWidget);
      expect(find.text('Choisir dans la galerie'), findsOneWidget);
      expect(find.text('Saisir manuellement'), findsOneWidget);
      expect(find.text('OCR non configuré'), findsNothing);
    },
  );
}
