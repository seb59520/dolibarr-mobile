import 'package:dolibarr_mobile/core/preferences/tweaks.dart';
import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/core/utils/formatters.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice.dart';
import 'package:dolibarr_mobile/features/thirdparties/presentation/providers/third_party_providers.dart';
import 'package:dolibarr_mobile/shared/widgets/app_card.dart';
import 'package:dolibarr_mobile/shared/widgets/sync_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class InvoiceCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final i = invoice;
    final statusColor = _statusColor(i);
    final fields = ref.watch(
      tweaksProvider.select((t) => t.invoiceFields),
    );
    final showClient =
        fields.contains(InvoiceCardField.client) && i.socidLocal != null;
    final clientName = showClient
        ? ref
            .watch(thirdPartyByIdProvider(i.socidLocal!))
            .maybeWhen(data: (tp) => tp?.name, orElse: () => null)
        : null;
    final showDueDate =
        fields.contains(InvoiceCardField.dueDate) && i.dateDue != null;
    final showHt =
        fields.contains(InvoiceCardField.totalHt) && i.totalHt != null;

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
                if (clientName != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(LucideIcons.briefcase, size: 12),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          clientName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
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
                if (showDueDate) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.clock,
                        size: 12,
                        color: i.isOverdue ? AppTokens.syncConflict : null,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Échéance ${_fmt(i.dateDue!)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: i.isOverdue ? AppTokens.syncConflict : null,
                          fontWeight:
                              i.isOverdue ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
                if (i.totalTtc != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${formatMoney(i.totalTtc)} TTC',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (showHt) ...[
                        const SizedBox(width: 8),
                        Text(
                          '(${formatMoney(i.totalHt)} HT)',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ],
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
