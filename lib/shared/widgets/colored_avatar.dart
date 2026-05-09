import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:flutter/material.dart';

/// Avatar à fond coloré dérivé d'un hash du nom (pattern DoliMob).
///
/// Pastille rectangulaire à coins arrondis, fond pâle, texte dans la
/// même teinte plus saturée. Hash stable pour garder la même couleur
/// entre rendus. Approximation OkLCH via HSL (chroma → saturation).
class ColoredAvatar extends StatelessWidget {
  const ColoredAvatar({
    required this.name,
    this.size = 42,
    super.key,
  });

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = DoliMobColors.of(context);
    final hue = _hashHue(name);
    final bg = _oklchLikeColor(
      l: c.dark ? 0.28 : 0.94,
      chroma: c.dark ? 0.06 : 0.04,
      hueDeg: hue,
    );
    final fg = _oklchLikeColor(
      l: c.dark ? 0.82 : 0.34,
      chroma: 0.10,
      hueDeg: hue,
    );
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials(name),
        style: TextStyle(
          color: fg,
          fontSize: size * 0.36,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

double _hashHue(String s) {
  if (s.isEmpty) return 0;
  var h = 0;
  for (final code in s.codeUnits) {
    h = (h * 31 + code) & 0x7fffffff;
  }
  return (h % 360).toDouble();
}

String _initials(String name) {
  final parts = name
      .split(RegExp(r'[\s&\-]+'))
      .where((p) => p.isNotEmpty)
      .take(2)
      .toList();
  if (parts.isEmpty) return '?';
  return parts
      .map((p) => String.fromCharCode(p.runes.first).toUpperCase())
      .join();
}

/// Approximation OkLCH → sRGB via HSL (chroma → saturation linéaire).
Color _oklchLikeColor({
  required double l,
  required double chroma,
  required double hueDeg,
}) {
  final sat = (chroma * 5.0).clamp(0.0, 0.85);
  return HSLColor.fromAHSL(1, hueDeg % 360, sat, l).toColor();
}
