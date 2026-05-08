import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// État d'erreur affiché à la place d'une liste / fiche en cas d'échec.
class ErrorState extends StatelessWidget {
  const ErrorState({
    required this.title,
    this.description,
    this.onRetry,
    this.icon = LucideIcons.alertCircle,
    super.key,
  });

  final String title;
  final String? description;
  final VoidCallback? onRetry;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: scheme.error),
            const SizedBox(height: AppTokens.spaceMd),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: scheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: AppTokens.spaceXs),
              Text(
                description!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: AppTokens.spaceMd),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(LucideIcons.rotateCcw),
                label: const Text('Réessayer'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
