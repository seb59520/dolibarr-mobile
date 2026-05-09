import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:flutter/material.dart';

class KpiCard extends StatelessWidget {
  const KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.color,
    this.onTap,
    super.key,
  });

  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = color ?? theme.colorScheme.primary;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.spaceMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius:
                          BorderRadius.circular(AppTokens.radiusChip),
                    ),
                    child: Icon(icon, size: 18, color: accent),
                  ),
                  const SizedBox(width: AppTokens.spaceXs),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.spaceXs),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
