import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Initialisation asynchrone exécutée AVANT `runApp`.
///
/// Pour l'Étape 1, le bootstrap se contente de garantir le binding et de
/// démarrer l'app. Aux étapes suivantes il pilotera l'init Isar, le
/// chargement de `.env`, le warm-up du logger, etc.
Future<void> bootstrap(Widget Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(child: builder()));
}
