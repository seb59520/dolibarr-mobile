import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Placeholder en shimmer pendant les chargements de listes.
///
/// `LoadingSkeleton.card` produit une card squelette (équivalent visuel
/// d'une `AppCard` peuplée). `LoadingSkeleton.line` rend une ligne de
/// texte simulée.
class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({
    required this.height,
    this.width,
    this.borderRadius = 8,
    super.key,
  });

  /// Card squelette : avatar + 2 lignes — utilisé en placeholder de liste.
  static Widget card() => const _CardSkeleton();

  /// Ligne de texte : 16px de haut, largeur paramétrable.
  static Widget line({double width = 200}) =>
      LoadingSkeleton(height: 16, width: width);

  final double height;
  final double? width;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(
          duration: 1200.ms,
          color: base.withValues(alpha: 0.4),
        );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.spaceMd,
        vertical: AppTokens.spaceXs,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppTokens.spaceMd),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        ),
        child: Row(
          children: [
            const LoadingSkeleton(
              height: 40,
              width: 40,
              borderRadius: 20,
            ),
            const SizedBox(width: AppTokens.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LoadingSkeleton.line(width: 160),
                  const SizedBox(height: AppTokens.spaceXs),
                  LoadingSkeleton.line(width: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
