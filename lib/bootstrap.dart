import 'dart:async';

import 'package:dolibarr_mobile/core/di/providers.dart';
import 'package:dolibarr_mobile/core/preferences/tweaks.dart';
import 'package:dolibarr_mobile/core/storage/app_database.dart';
import 'package:dolibarr_mobile/core/storage/secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Initialisation asynchrone exécutée AVANT `runApp`.
///
/// Initialise la base Drift (singleton) et SharedPreferences, et les
/// passe au `ProviderScope` via override. Wrappé dans
/// `runZonedGuarded` pour qu'une exception au boot n'aboutisse pas à
/// un écran blanc — on affiche un message d'erreur exploitable.
void bootstrap(Widget Function() builder) {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      if (kDebugMode) {
        // ignore: avoid_print
        print('FlutterError.onError: ${details.exceptionAsString()}');
        // ignore: avoid_print
        print(details.stack);
      }
    };

    final db = AppDatabase();
    final prefs = await SharedPreferences.getInstance();

    // Lit la baseUrl persistée AVANT runApp pour que le `dioProvider`
    // partagé soit construit avec la bonne instance dès le cold start
    // (avant ce fix, on retombait sur `dolibarr.invalid` à chaque
    // reload web et toutes les requêtes tiers/factures échouaient).
    // On partage cette même instance de SecureStorage avec l'app pour
    // éviter deux singletons concurrents (Keychain/IndexedDB) et on lui
    // injecte les SharedPreferences pour son fallback web.
    final secureStorage = SecureStorageImpl(webPrefs: prefs);
    final storedBaseUrl = await secureStorage.readBaseUrl();

    runApp(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          sharedPreferencesProvider.overrideWithValue(prefs),
          secureStorageProvider.overrideWithValue(secureStorage),
          if (storedBaseUrl != null && storedBaseUrl.isNotEmpty)
            initialBaseUrlProvider.overrideWithValue(storedBaseUrl),
        ],
        child: builder(),
      ),
    );
  }, (error, stack) {
    runApp(_BootErrorApp(error: error, stack: stack));
  });
}

class _BootErrorApp extends StatelessWidget {
  const _BootErrorApp({required this.error, required this.stack});
  final Object error;
  final StackTrace stack;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF6F5F1),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Échec du démarrage de l'app",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFC0271C),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    error.toString(),
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 16),
                  SelectableText(
                    stack.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: Color(0xFF14171F),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
