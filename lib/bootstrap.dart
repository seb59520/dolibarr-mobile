import 'dart:async';

import 'package:dolibarr_mobile/core/di/providers.dart';
import 'package:dolibarr_mobile/core/storage/app_database.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Initialisation asynchrone exécutée AVANT `runApp`.
///
/// Initialise la base Drift (singleton) et la passe au `ProviderScope`
/// via override. Toute autre init asynchrone ajoute ses overrides ici
/// pour rester en un point central.
Future<void> bootstrap(Widget Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();

  runApp(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: builder(),
    ),
  );
}
