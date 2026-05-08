import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Badge sémantique d'état de synchronisation d'une entité.
///
/// Couleurs et icônes alignées sur les tokens (`syncSynced`, `syncPending`,
/// `syncConflict`). En supplément, expose une variante "offline" quand
/// l'entité est synced mais l'app est offline.
class SyncStatusBadge extends StatelessWidget {
  const SyncStatusBadge({
    required this.status,
    this.compact = false,
    this.offline = false,
    super.key,
  });

  final SyncStatus status;
  final bool compact;
  final bool offline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, color, label) = _resolve();

    if (compact) {
      return Tooltip(
        message: label,
        child: Icon(icon, size: 16, color: color),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.spaceXs,
        vertical: AppTokens.spaceXxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTokens.radiusChip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AppTokens.spaceXxs),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  (IconData, Color, String) _resolve() {
    if (offline && status == SyncStatus.synced) {
      return (
        LucideIcons.cloudOff,
        AppTokens.syncOffline,
        'Hors-ligne',
      );
    }
    return switch (status) {
      SyncStatus.synced =>
        (LucideIcons.checkCircle, AppTokens.syncSynced, 'Synchronisé'),
      SyncStatus.pendingCreate ||
      SyncStatus.pendingUpdate ||
      SyncStatus.pendingDelete =>
        (LucideIcons.clock, AppTokens.syncPending, 'En attente'),
      SyncStatus.conflict =>
        (LucideIcons.alertTriangle, AppTokens.syncConflict, 'Conflit'),
    };
  }
}
