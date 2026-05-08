import 'package:flutter/material.dart';

/// Tokens du Design System Dolibarr Mobile (Direction B — Moderne coloré).
///
/// Toutes les valeurs visuelles partagées de l'app vivent ici. Aucune
/// couleur, espacement ou rayon ne doit être codé en dur ailleurs.
abstract final class AppTokens {
  // ----- Couleurs primaires / accents -----
  /// Bleu primaire Dolibarr Mobile, sert de seed à `ColorScheme.fromSeed`.
  static const Color primarySeed = Color(0xFF1E5AA8);

  /// Ambre secondaire, utilisé pour les CTAs principaux.
  static const Color secondarySeed = Color(0xFFE89B2C);

  // ----- Couleurs sémantiques (sync / état) -----
  static const Color syncSynced = Color(0xFF2E8B57);
  static const Color syncPending = Color(0xFFE89B2C);
  static const Color syncConflict = Color(0xFFD64545);
  static const Color syncOffline = Color(0xFF9AA0A6);

  // ----- Espacements (multiples de 4) -----
  static const double spaceXxs = 4;
  static const double spaceXs = 8;
  static const double spaceSm = 12;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;

  // ----- Rayons -----
  static const double radiusChip = 8;
  static const double radiusCard = 12;
  static const double radiusSheet = 16;
  static const double radiusFab = 24;

  // ----- Élévations -----
  static const double elevationFlat = 0;
  static const double elevationCard = 1;
  static const double elevationFab = 4;
  static const double elevationModal = 8;

  // ----- Cibles tactiles -----
  static const double minTapTarget = 48;

  // ----- Animations -----
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animDefault = Duration(milliseconds: 200);
  static const Duration animSlow = Duration(milliseconds: 350);
}
