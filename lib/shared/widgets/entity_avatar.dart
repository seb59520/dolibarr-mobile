import 'package:dolibarr_mobile/shared/widgets/colored_avatar.dart';
import 'package:flutter/material.dart';

/// Avatar pour entités du domaine. Alias historique de [ColoredAvatar]
/// — conservé pour compat avec les écrans qui ne sont pas encore
/// refactorés vers la nomenclature DoliMob.
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

  @override
  Widget build(BuildContext context) {
    return ColoredAvatar(name: name, size: size);
  }
}
