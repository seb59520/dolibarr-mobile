import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:flutter/material.dart';

/// Carte cliquable standardisée du Design System.
///
/// Ergonomie : padding cohérent, ripple sur le tap, bordures arrondies
/// du token. Évite les `Card` directs dans les features pour garantir
/// l'homogénéité visuelle des listes.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppTokens.spaceMd),
    this.margin,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ??
          const EdgeInsets.symmetric(
            horizontal: AppTokens.spaceMd,
            vertical: AppTokens.spaceXs,
          ),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        elevation: AppTokens.elevationCard,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
