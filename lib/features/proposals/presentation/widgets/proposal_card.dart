import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/features/proposals/domain/entities/proposal.dart';
import 'package:dolibarr_mobile/shared/widgets/app_card.dart';
import 'package:dolibarr_mobile/shared/widgets/sync_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProposalCard extends StatelessWidget {
  const ProposalCard({
    required this.proposal,
    this.onTap,
    this.offline = false,
    super.key,
  });

  final Proposal proposal;
  final VoidCallback? onTap;
  final bool offline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = proposal;
    final statusColor = _statusColor(p);
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 4,
            height: 56,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppTokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        p.displayLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    SyncStatusBadge(
                      status: p.syncStatus,
                      compact: true,
                      offline: offline,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (p.dateProposal != null) ...[
                      const Icon(LucideIcons.calendar, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        _fmt(p.dateProposal!),
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      _statusLabel(p),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (p.totalTtc != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${p.totalTtc} € TTC',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Color _statusColor(Proposal p) {
    if (p.isSigned) return AppTokens.syncSynced;
    if (p.isRefused) return AppTokens.syncConflict;
    if (p.isExpired) return AppTokens.syncConflict;
    if (p.status == ProposalStatus.draft) return AppTokens.syncOffline;
    return AppTokens.syncPending;
  }

  static String _statusLabel(Proposal p) {
    if (p.isExpired && !p.isSigned && !p.isRefused) return 'Expiré';
    return switch (p.status) {
      ProposalStatus.draft => 'Brouillon',
      ProposalStatus.validated => 'Validé',
      ProposalStatus.signed => 'Signé',
      ProposalStatus.refused => 'Refusé',
    };
  }

  static String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';
}
