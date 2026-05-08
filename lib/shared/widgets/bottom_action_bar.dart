import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:flutter/material.dart';

/// Barre d'actions persistante en bas d'une fiche détail / formulaire.
///
/// Garantit le respect du SafeArea iOS et un padding cohérent. Accepte
/// 1 ou 2 boutons (cancel + primary) — au-delà préférer un menu.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({
    required this.primary,
    this.secondary,
    super.key,
  });

  final Widget primary;
  final Widget? secondary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      elevation: AppTokens.elevationCard,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.spaceMd),
          child: Row(
            children: [
              if (secondary != null) ...[
                Expanded(child: secondary!),
                const SizedBox(width: AppTokens.spaceMd),
              ],
              Expanded(flex: 2, child: primary),
            ],
          ),
        ),
      ),
    );
  }
}
