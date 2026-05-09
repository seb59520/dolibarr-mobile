import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:flutter/material.dart';

/// Tone (intention) d'un chip DoliMob.
enum ChipTone { neutral, info, success, warning, danger }

/// Chip pilule avec fond pâle + texte de la même teinte (B2B clean).
///
/// Différent du Material `Chip` standard : pas de border par défaut,
/// padding plus serré, font weight 600. Aligne sur le pattern du design
/// DoliMob (3px 9px, fontSize 11.5).
class DoliMobChip extends StatelessWidget {
  const DoliMobChip({
    required this.label,
    this.tone = ChipTone.neutral,
    this.compact = false,
    super.key,
  });

  final String label;
  final ChipTone tone;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = DoliMobColors.of(context);
    final (bg, fg) = _resolve(c, tone);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 9,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: compact ? 11 : 11.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          height: 1.2,
        ),
      ),
    );
  }

  static (Color, Color) _resolve(DoliMobColors c, ChipTone tone) {
    if (c.dark) {
      return switch (tone) {
        ChipTone.neutral => (c.fill, c.ink2),
        ChipTone.info => (c.accentSoft, c.accent),
        ChipTone.success =>
          (const Color(0xFF3DDC97).withValues(alpha: 0.15), c.success),
        ChipTone.warning =>
          (const Color(0xFFF2B36B).withValues(alpha: 0.18), c.warning),
        ChipTone.danger =>
          (const Color(0xFFF47A6E).withValues(alpha: 0.18), c.danger),
      };
    }
    return switch (tone) {
      ChipTone.neutral => (c.fill, c.ink2),
      ChipTone.info => (c.accentSoft, c.accent),
      ChipTone.success => (const Color(0xFFE8F4EF), const Color(0xFF0E5C4D)),
      ChipTone.warning => (const Color(0xFFFBEFD9), const Color(0xFF7A3B07)),
      ChipTone.danger => (const Color(0xFFFAE5E2), const Color(0xFF8C1B12)),
    };
  }
}
