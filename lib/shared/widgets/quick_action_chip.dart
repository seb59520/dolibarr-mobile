import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:flutter/material.dart';

/// Chip d'action rapide (icone + label optionnel) utilisé dans les
/// fiches détail (appeler, envoyer un mail, ouvrir Maps).
class QuickActionChip extends StatelessWidget {
  const QuickActionChip({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.tonal = true,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  /// Si vrai, fond tonal (recommandé). Sinon, transparent + bordure.
  final bool tonal;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final disabled = onPressed == null;
    return Material(
      color: tonal && !disabled
          ? scheme.primaryContainer.withValues(alpha: 0.6)
          : Colors.transparent,
      shape: RoundedRectangleBorder(
        side: tonal
            ? BorderSide.none
            : BorderSide(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(AppTokens.radiusChip),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppTokens.radiusChip),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.spaceMd,
            vertical: AppTokens.spaceXs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: disabled ? scheme.onSurfaceVariant : scheme.primary,
              ),
              const SizedBox(width: AppTokens.spaceXs),
              Text(
                label,
                style: TextStyle(
                  color: disabled ? scheme.onSurfaceVariant : scheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
