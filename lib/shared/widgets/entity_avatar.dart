import 'package:flutter/material.dart';

/// Avatar circulaire avec initiales, couleur dérivée du nom.
///
/// Utilisé pour les listes de tiers et de contacts. La couleur est
/// déterministe (hash du nom modulo palette) pour rester stable entre
/// les rendus et garder un effet de reconnaissance visuelle.
class EntityAvatar extends StatelessWidget {
  const EntityAvatar({
    required this.name,
    this.size = 40,
    this.imageUrl,
    super.key,
  });

  final String name;
  final double size;
  final String? imageUrl;

  static const _palette = <Color>[
    Color(0xFF1E5AA8),
    Color(0xFF2E8B57),
    Color(0xFFE89B2C),
    Color(0xFF6B5BD4),
    Color(0xFFD64545),
    Color(0xFF0E7C86),
  ];

  Color _colorFor(String s) {
    if (s.isEmpty) return _palette.first;
    final h = s.codeUnits.fold<int>(0, (a, c) => (a + c) & 0xfffff);
    return _palette[h % _palette.length];
  }

  String _initials(String s) {
    final parts =
        s.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(name);
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: color.withValues(alpha: 0.15),
      foregroundColor: color,
      child: Text(
        _initials(name),
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: size / 2.6,
        ),
      ),
    );
  }
}
