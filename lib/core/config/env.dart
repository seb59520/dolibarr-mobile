import 'package:flutter/foundation.dart';

/// Lecture des variables d'environnement injectées au build.
///
/// Sur Flutter on n'a pas de fichier `.env` chargé au runtime — on passe
/// par `--dart-define=KEY=value` ou `--dart-define-from-file=.env`. Ce
/// helper centralise la lecture pour exposer une API typée.
abstract final class Env {
  static const String defaultDolibarrUrl = String.fromEnvironment(
    'DEFAULT_DOLIBARR_URL',
  );

  static const String defaultMapTileUrl = String.fromEnvironment(
    'DEFAULT_MAP_TILE_URL',
    defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  );

  static const String defaultMapAttribution = String.fromEnvironment(
    'DEFAULT_MAP_ATTRIBUTION',
    defaultValue: '© OpenStreetMap contributors',
  );

  static const int splashDelayMs = int.fromEnvironment(
    'SPLASH_DELAY_MS',
    defaultValue: 800,
  );

  /// Force `false` en build release, sinon `true` en debug par défaut.
  /// Toggle additionnel via `--dart-define=DEBUG_MODE=false` pour tester
  /// le comportement release sur un build debug.
  static bool get debugMode {
    if (!kDebugMode) return false;
    return const bool.fromEnvironment('DEBUG_MODE', defaultValue: true);
  }
}
