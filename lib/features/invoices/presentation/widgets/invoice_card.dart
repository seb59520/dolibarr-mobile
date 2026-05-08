import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice.dart';
import 'package:dolibarr_mobile/shared/widgets/app_card.dart';
import 'package:dolibarr_mobile/shared/widgets/sync_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class InvoiceCard extends StatelessWidget {
  const InvoiceCard({
    required this.invoice,
    this.onTap,
    this.offline = false,
    super.key,
  });

  final Invoice invoice;
  final VoidCallback? onTap;
  final bool offline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i = invoice;
    final statusColor = _statusColor(i);
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
                        i.displayLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    SyncStatusBadge(
                      status: i.syncStatus,
                      compact: true,
                      offline: offline,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (i.dateInvoice != null) ...[
                      const Icon(LucideIcons.calendar, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        _fmt(i.dateInvoice!),
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      _statusLabel(i),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (i.totalTtc != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${i.totalTtc} € TTC',
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

  static Color _statusColor(Invoice i) {
    if (i.isPaid) return AppTokens.syncSynced;
    if (i.isOverdue) return AppTokens.syncConflict;
    if (i.status == InvoiceStatus.draft) return AppTokens.syncOffline;
    return AppTokens.syncPending;
  }

  static String _statusLabel(Invoice i) {
    if (i.isPaid) return 'Payée';
    if (i.isOverdue) return 'En retard';
    return switch (i.status) {
      InvoiceStatus.draft => 'Brouillon',
      InvoiceStatus.validated => 'Validée',
      InvoiceStatus.paid => 'Payée',
      InvoiceStatus.abandoned => 'Abandonnée',
    };
  }

  static String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';
}
