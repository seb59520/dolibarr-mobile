import 'package:dolibarr_mobile/core/preferences/tweaks.dart';
import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Construit les ThemeData clair et sombre à partir des tokens DoliMob
/// et des préférences utilisateur (Tweaks : accent, police, densité).
///
/// Les sémantiques contextuelles (ink, hairline, accentSoft…) sont
/// exposées via `DoliMobColors` (extension de thème) — récupérables
/// avec `DoliMobColors.of(context)` dans les widgets.
abstract final class AppTheme {
  /// Quand `true`, `_build` skipe `GoogleFonts.getTextTheme` (utilisé
  /// par les tests pour éviter les Exceptions "font not found" quand
  /// les assets ne sont pas livrés). À laisser à `false` en runtime.
  static bool useSystemFontInsteadOfGoogleFonts = false;

  static ThemeData light(Tweaks tweaks) =>
      _build(Brightness.light, tweaks);

  static ThemeData dark(Tweaks tweaks) =>
      _build(Brightness.dark, tweaks);

  static ThemeData _build(Brightness brightness, Tweaks tweaks) {
    final isDark = brightness == Brightness.dark;
    final dolimob = isDark
        ? DoliMobColors.dark(tweaks.accent)
        : DoliMobColors.light(tweaks.accent);

    final scheme = ColorScheme.fromSeed(
      seedColor: tweaks.accent,
      brightness: brightness,
    ).copyWith(
      surface: dolimob.surface,
      onSurface: dolimob.ink,
      onSurfaceVariant: dolimob.ink2,
      outline: dolimob.hairline,
      outlineVariant: dolimob.hairline2,
      primary: tweaks.accent,
      error: dolimob.danger,
    );

    final baseTextTheme = isDark
        ? Typography.whiteCupertino
        : Typography.blackCupertino;

    // GoogleFonts.getTextTheme peut throw au boot web si le fetch échoue
    // (CORS, offline, CSP). On retombe gracieusement sur la font système.
    TextTheme tt;
    if (useSystemFontInsteadOfGoogleFonts) {
      tt = baseTextTheme;
    } else {
      try {
        tt = GoogleFonts.getTextTheme(tweaks.font.cssName, baseTextTheme);
      } catch (_) {
        tt = baseTextTheme;
      }
    }
    final textTheme = tt.apply(
      bodyColor: dolimob.ink,
      displayColor: dolimob.ink,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: dolimob.bg,
      canvasColor: dolimob.bg,
      textTheme: textTheme,
      extensions: [dolimob],
      appBarTheme: AppBarTheme(
        backgroundColor: dolimob.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: dolimob.ink,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: dolimob.ink,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: dolimob.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusCardLg),
          side: BorderSide(color: dolimob.hairline, width: 0.5),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppTokens.spaceMd,
          vertical: AppTokens.spaceXs,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: dolimob.fill,
        labelStyle: textTheme.bodySmall?.copyWith(
          color: dolimob.ink2,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide(color: dolimob.hairline, width: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusPill),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: dolimob.hairline,
        thickness: 0.5,
        space: 0.5,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: dolimob.ink,
        foregroundColor: dolimob.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppTokens.radiusPill),
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: dolimob.bg,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTokens.radiusSheetLg),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: dolimob.ink,
          foregroundColor: dolimob.surface,
          minimumSize: const Size(double.infinity, AppTokens.minTapTarget),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: dolimob.ink,
          side: BorderSide(color: dolimob.hairline),
          minimumSize: const Size(double.infinity, AppTokens.minTapTarget),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: dolimob.accent),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: dolimob.surface.withValues(alpha: 0.92),
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelSmall?.copyWith(
            color: states.contains(WidgetState.selected)
                ? dolimob.accent
                : dolimob.ink3,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? dolimob.accent
                : dolimob.ink3,
            size: 22,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dolimob.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: dolimob.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: dolimob.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: dolimob.accent),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTokens.spaceMd,
          vertical: AppTokens.spaceSm,
        ),
        labelStyle: TextStyle(color: dolimob.ink3),
      ),
      iconTheme: IconThemeData(color: dolimob.ink),
      listTileTheme: ListTileThemeData(
        iconColor: dolimob.ink2,
        textColor: dolimob.ink,
      ),
    );
  }
}
