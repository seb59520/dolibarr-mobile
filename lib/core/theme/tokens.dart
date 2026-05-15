import 'package:flutter/material.dart';

/// Tokens du Design System DoliMob (refonte Étape 23 — direction B2B
/// clean, fond off-white chaud, accent teal, hairlines plutôt
/// qu'élévation par défaut).
///
/// Toutes les valeurs visuelles partagées de l'app vivent ici. Les
/// sémantiques contextuelles (ink, ink2, hairline, accentSoft…)
/// passent par l'extension `DoliMobColors` sur `ThemeData` car elles
/// dépendent du mode sombre et de l'accent courant choisi par
/// l'utilisateur.
abstract final class AppTokens {
  // ----- Accents proposés (5 options Tweaks) -----
  static const Color accentTeal = Color(0xFF0E7C66);
  static const Color accentBlue = Color(0xFF2A55D6);
  static const Color accentPurple = Color(0xFF7C3AED);
  static const Color accentAmber = Color(0xFFB4530A);
  static const Color accentRed = Color(0xFFC0271C);

  /// Liste ordonnée pour la page Tweaks.
  static const List<Color> accentChoices = [
    accentTeal,
    accentBlue,
    accentPurple,
    accentAmber,
    accentRed,
  ];

  /// Accent par défaut (Direction B DoliMob).
  static const Color primarySeed = accentTeal;

  /// Conservé pour compat — utilisé par les anciens écrans en attendant
  /// leur refonte. Cible le même teal pour rester cohérent.
  static const Color secondarySeed = accentTeal;

  // ----- Couleurs sémantiques (état de sync, héritées) -----
  static const Color syncSynced = Color(0xFF0E7C66);
  static const Color syncPending = Color(0xFFB4530A);
  static const Color syncConflict = Color(0xFFC0271C);
  static const Color syncOffline = Color(0xFF9AA0A6);

  // ----- Espacements (multiples de 4) -----
  static const double spaceXxs = 4;
  static const double spaceXs = 8;
  static const double spaceSm = 12;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;

  // ----- Rayons (legacy compat — utilisés un peu partout dans l'app) -----
  static const double radiusChip = 8;
  static const double radiusCard = 12;
  static const double radiusSheet = 16;
  static const double radiusFab = 24;

  // ----- Rayons DoliMob (refonte v23) -----
  static const double radiusPill = 999;
  static const double radiusCardLg = 14;
  static const double radiusSheetLg = 22;

  // ----- Élévations (legacy compat) -----
  static const double elevationFlat = 0;
  static const double elevationCard = 1;
  static const double elevationFab = 4;
  static const double elevationModal = 8;

  // ----- Cibles tactiles -----
  static const double minTapTarget = 48;

  // ----- Animations -----
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animDefault = Duration(milliseconds: 240);
  static const Duration animSlow = Duration(milliseconds: 350);
}

/// Extension de thème exposant les sémantiques DoliMob (ink/hairline/
/// accent…) en plus des couleurs Material 3 standard.
///
/// Lecture : `DoliMobColors.of(context)` ou
/// `Theme.of(context).extension<DoliMobColors>()!`.
@immutable
class DoliMobColors extends ThemeExtension<DoliMobColors> {
  const DoliMobColors({
    required this.bg,
    required this.surface,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.hairline,
    required this.hairline2,
    required this.fill,
    required this.accent,
    required this.accentSoft,
    required this.accentSofter,
    required this.success,
    required this.info,
    required this.warning,
    required this.danger,
    required this.revenue,
    required this.dark,
  });

  /// Palette claire avec un accent paramétré.
  factory DoliMobColors.light(Color accent) => DoliMobColors(
        bg: const Color(0xFFF6F5F1),
        surface: const Color(0xFFFFFFFF),
        ink: const Color(0xFF14171F),
        ink2: const Color(0xFF14171F).withValues(alpha: 0.62),
        ink3: const Color(0xFF14171F).withValues(alpha: 0.42),
        hairline: const Color(0xFF14171F).withValues(alpha: 0.08),
        hairline2: const Color(0xFF14171F).withValues(alpha: 0.05),
        fill: const Color(0xFF14171F).withValues(alpha: 0.05),
        accent: accent,
        accentSoft: accent.withValues(alpha: 0.08),
        accentSofter: accent.withValues(alpha: 0.04),
        success: const Color(0xFF0E7C66),
        info: const Color(0xFF2563EB),
        warning: const Color(0xFFB4530A),
        danger: const Color(0xFFC0271C),
        // Vert distinct de l'accent teal : utilisé pour différencier les
        // séries « perçu » (cf. chart pilotage) du facturé (couleur accent).
        revenue: const Color(0xFF10B981),
        dark: false,
      );

  /// Palette sombre avec un accent paramétré.
  factory DoliMobColors.dark(Color accent) => DoliMobColors(
        bg: const Color(0xFF0E1014),
        surface: const Color(0xFF1A1D24),
        ink: const Color(0xFFF4F5F7),
        ink2: const Color(0xFFF4F5F7).withValues(alpha: 0.62),
        ink3: const Color(0xFFF4F5F7).withValues(alpha: 0.42),
        hairline: const Color(0xFFF4F5F7).withValues(alpha: 0.10),
        hairline2: const Color(0xFFF4F5F7).withValues(alpha: 0.06),
        fill: const Color(0xFFF4F5F7).withValues(alpha: 0.06),
        accent: accent,
        accentSoft: accent.withValues(alpha: 0.20),
        accentSofter: accent.withValues(alpha: 0.10),
        success: const Color(0xFF3DDC97),
        info: const Color(0xFF5C8DFA),
        warning: const Color(0xFFF2B36B),
        danger: const Color(0xFFF47A6E),
        revenue: const Color(0xFF34D399),
        dark: true,
      );

  final Color bg;
  final Color surface;
  final Color ink;
  final Color ink2;
  final Color ink3;
  final Color hairline;
  final Color hairline2;
  final Color fill;
  final Color accent;
  final Color accentSoft;
  final Color accentSofter;
  final Color success;
  final Color info;
  final Color warning;
  final Color danger;
  final Color revenue;
  final bool dark;

  /// Helper pour récupérer la palette depuis le contexte.
  static DoliMobColors of(BuildContext context) =>
      Theme.of(context).extension<DoliMobColors>()!;

  @override
  DoliMobColors copyWith({
    Color? bg,
    Color? surface,
    Color? ink,
    Color? ink2,
    Color? ink3,
    Color? hairline,
    Color? hairline2,
    Color? fill,
    Color? accent,
    Color? accentSoft,
    Color? accentSofter,
    Color? success,
    Color? info,
    Color? warning,
    Color? danger,
    Color? revenue,
    bool? dark,
  }) =>
      DoliMobColors(
        bg: bg ?? this.bg,
        surface: surface ?? this.surface,
        ink: ink ?? this.ink,
        ink2: ink2 ?? this.ink2,
        ink3: ink3 ?? this.ink3,
        hairline: hairline ?? this.hairline,
        hairline2: hairline2 ?? this.hairline2,
        fill: fill ?? this.fill,
        accent: accent ?? this.accent,
        accentSoft: accentSoft ?? this.accentSoft,
        accentSofter: accentSofter ?? this.accentSofter,
        success: success ?? this.success,
        info: info ?? this.info,
        warning: warning ?? this.warning,
        danger: danger ?? this.danger,
        revenue: revenue ?? this.revenue,
        dark: dark ?? this.dark,
      );

  @override
  DoliMobColors lerp(ThemeExtension<DoliMobColors>? other, double t) {
    if (other is! DoliMobColors) return this;
    return DoliMobColors(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      ink2: Color.lerp(ink2, other.ink2, t)!,
      ink3: Color.lerp(ink3, other.ink3, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      hairline2: Color.lerp(hairline2, other.hairline2, t)!,
      fill: Color.lerp(fill, other.fill, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      accentSofter: Color.lerp(accentSofter, other.accentSofter, t)!,
      success: Color.lerp(success, other.success, t)!,
      info: Color.lerp(info, other.info, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      revenue: Color.lerp(revenue, other.revenue, t)!,
      dark: t < 0.5 ? dark : other.dark,
    );
  }
}

/// Tokens de densité — sélectionnable dans la page Tweaks.
enum DensityChoice {
  compact,
  regular,
  comfy;

  double get listRowVertical => switch (this) {
        DensityChoice.compact => 10,
        DensityChoice.regular => 13,
        DensityChoice.comfy => 16,
      };

  double get avatarSize => switch (this) {
        DensityChoice.compact => 36,
        DensityChoice.regular => 42,
        DensityChoice.comfy => 48,
      };
}

/// Style de carte — sélectionnable dans la page Tweaks.
enum CardStyleChoice {
  flat,
  border,
  elevated;
}

/// Position du FAB — sélectionnable dans la page Tweaks.
enum FabPosition {
  left,
  center,
  right;
}

/// Choix de famille de police — sélectionnable dans la page Tweaks.
/// Les noms correspondent aux familles publiées par Google Fonts.
enum FontFamilyChoice {
  geist('Geist'),
  manrope('Manrope'),
  ibmPlex('IBM Plex Sans'),
  dmSans('DM Sans');

  const FontFamilyChoice(this.cssName);

  final String cssName;
}
