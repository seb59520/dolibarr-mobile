import 'package:dolibarr_mobile/core/storage/app_database.dart';
import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:dolibarr_mobile/core/sync/sync_providers.dart';
import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/features/sync/presentation/providers/sync_providers.dart';
import 'package:dolibarr_mobile/shared/widgets/confirm_dialog.dart';
import 'package:dolibarr_mobile/shared/widgets/empty_state.dart';
import 'package:dolibarr_mobile/shared/widgets/error_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Page "Opérations en attente" — visualise et résout les ops Outbox.
class PendingOperationsPage extends ConsumerWidget {
  const PendingOperationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(pendingOperationsAllProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Opérations en attente'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw),
            tooltip: 'Synchroniser maintenant',
            onPressed: () =>
                // ignore: unawaited_futures
                ref.read(syncEngineProvider).runOnce(),
          ),
        ],
      ),
      body: async.when(
        data: (ops) {
          if (ops.isEmpty) {
            return const EmptyState(
              icon: LucideIcons.checkCircle,
              title: 'Tout est synchronisé',
              description: 'Aucune opération en attente.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppTokens.spaceMd),
            itemCount: ops.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppTokens.spaceXs),
            itemBuilder: (_, i) => _OpCard(op: ops[i]),
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(
          title: 'Impossible de charger la file',
          description: '$e',
        ),
      ),
    );
  }
}

class _OpCard extends ConsumerWidget {
  const _OpCard({required this.op});
  final PendingOperationRow op;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final (icon, color, label) = _statusVisual(op.status, theme);
    final entity = switch (op.entityType) {
      PendingOpEntity.thirdparty => 'Tiers',
      PendingOpEntity.contact => 'Contact',
      PendingOpEntity.project => 'Projet',
    };
    final type = switch (op.opType) {
      PendingOpType.create => 'Création',
      PendingOpType.update => 'Mise à jour',
      PendingOpType.delete => 'Suppression',
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: AppTokens.spaceXs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$type — $entity',
                        style: theme.textTheme.titleSmall,
                      ),
                      Text(
                        label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '#${op.targetRemoteId ?? 'local-${op.targetLocalId}'}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            if (op.lastError != null) ...[
              const SizedBox(height: AppTokens.spaceXs),
              Container(
                padding: const EdgeInsets.all(AppTokens.spaceXs),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(
                    alpha: 0.6,
                  ),
                  borderRadius: BorderRadius.circular(AppTokens.radiusChip),
                ),
                child: Text(
                  op.lastError!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppTokens.spaceXs),
            Row(
              children: [
                Text(
                  'Tentatives : ${op.attempts}',
                  style: theme.textTheme.bodySmall,
                ),
                const Spacer(),
                if (op.dependsOnLocalId != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Tooltip(
                      message: "En attente d'une opération parente "
                          '(#${op.dependsOnLocalId})',
                      child: const Icon(LucideIcons.link, size: 16),
                    ),
                  ),
                if (op.status != PendingOpStatus.inProgress &&
                    op.status != PendingOpStatus.dead)
                  TextButton.icon(
                    onPressed: () =>
                        // ignore: unawaited_futures
                        ref.read(syncEngineProvider).retryNow(op.id),
                    icon: const Icon(LucideIcons.refreshCw, size: 16),
                    label: const Text('Réessayer'),
                  ),
                TextButton.icon(
                  onPressed: () => _confirmDiscard(context, ref),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                  icon: const Icon(LucideIcons.trash2, size: 16),
                  label: const Text('Discarder'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  (IconData, Color, String) _statusVisual(
    PendingOpStatus status,
    ThemeData theme,
  ) {
    return switch (status) {
      PendingOpStatus.queued =>
        (LucideIcons.clock, AppTokens.syncPending, 'En file'),
      PendingOpStatus.inProgress =>
        (LucideIcons.loader, AppTokens.syncPending, 'En cours'),
      PendingOpStatus.failed => (
          LucideIcons.alertCircle,
          AppTokens.syncPending,
          'Échec — sera retentée'
        ),
      PendingOpStatus.conflict => (
          LucideIcons.alertTriangle,
          AppTokens.syncConflict,
          'Conflit — résolution requise'
        ),
      PendingOpStatus.dead => (
          LucideIcons.xCircle,
          AppTokens.syncConflict,
          'Échec définitif'
        ),
    };
  }

  Future<void> _confirmDiscard(BuildContext context, WidgetRef ref) async {
    final isCreate = op.opType == PendingOpType.create;
    final confirmed = await ConfirmDialog.showDestructive(
      context,
      title: 'Discarder cette opération ?',
      message: isCreate
          ? "L'entité locale jamais poussée sera également supprimée."
          : 'Les modifications locales seront conservées mais ne seront '
              'pas envoyées au serveur.',
      confirmLabel: 'Discarder',
    );
    if (confirmed != true) return;
    await ref.read(syncEngineProvider).discard(
          op.id,
          alsoDeleteEntity: isCreate,
        );
  }
}
