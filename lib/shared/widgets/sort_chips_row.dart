import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Ligne horizontale scrollable de chips de tri, pattern Linear/Gmail.
///
/// L'utilisateur tape sur un chip pour activer son critère ; tape une
/// 2ᵉ fois pour inverser le sens. L'état actif affiche l'accent + flèche.
class SortChipsRow<T extends Enum> extends StatelessWidget {
  const SortChipsRow({
    required this.options,
    required this.active,
    required this.descending,
    required this.labelOf,
    required this.onSelected,
    super.key,
  });

  /// Critères disponibles.
  final List<T> options;

  /// Critère actuellement actif.
  final T active;

  /// `true` = décroissant (flèche ↓).
  final bool descending;

  /// Libellé court à afficher pour chaque critère.
  final String Function(T) labelOf;

  /// Callback quand un chip est tapé. Le notifier doit :
  ///   - activer le critère si différent de `active`
  ///   - inverser `descending` si même critère
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTokens.spaceMd),
        itemCount: options.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (ctx, idx) {
          if (idx == 0) {
            return _LeadingLabel();
          }
          final option = options[idx - 1];
          final isActive = option == active;
          return _SortChip(
            label: labelOf(option),
            active: isActive,
            descending: descending,
            onTap: () => onSelected(option),
          );
        },
      ),
    );
  }
}

class _LeadingLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = DoliMobColors.of(context);
    return Center(
      child: Row(
        children: [
          Icon(LucideIcons.arrowUpDown, size: 13, color: c.ink3),
          const SizedBox(width: 4),
          Text(
            'Trier',
            style: TextStyle(
              color: c.ink3,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.active,
    required this.descending,
    required this.onTap,
  });

  final String label;
  final bool active;
  final bool descending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = DoliMobColors.of(context);
    final bg = active ? c.ink : Colors.transparent;
    final fg = active ? c.bg : c.ink2;
    final border = active ? c.ink : c.hairline;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
        child: Ink(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppTokens.radiusPill),
            border: Border.all(color: border),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: fg,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (active) ...[
                  const SizedBox(width: 4),
                  Icon(
                    descending
                        ? LucideIcons.arrowDown
                        : LucideIcons.arrowUp,
                    size: 13,
                    color: fg,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
