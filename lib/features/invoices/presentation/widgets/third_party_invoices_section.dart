import 'package:dolibarr_mobile/core/routing/route_paths.dart';
import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/core/utils/formatters.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice.dart';
import 'package:dolibarr_mobile/features/invoices/presentation/providers/invoice_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ThirdPartyInvoicesSection extends ConsumerWidget {
  const ThirdPartyInvoicesSection({
    required this.thirdPartyLocalId,
    super.key,
  });

  final int thirdPartyLocalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final async = ref.watch(
      invoicesByThirdPartyLocalProvider(thirdPartyLocalId),
    );
    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppTokens.spaceXs),
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Factures',
                      style: theme.textTheme.titleMedium),
                ),
                TextButton.icon(
                  onPressed: () => context.go(
                    RoutePaths.invoiceNewForParent(thirdPartyLocalId),
                  ),
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('Ajouter'),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.spaceXs),
            async.when(
              data: (items) {
                if (items.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Aucune facture.',
                      style: theme.textTheme.bodySmall,
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final i in items) _InvoiceTile(invoice: i),
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: LinearProgressIndicator(),
              ),
              error: (_, __) => Text(
                'Factures indisponibles.',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvoiceTile extends StatelessWidget {
  const _InvoiceTile({required this.invoice});
  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    final i = invoice;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        LucideIcons.receipt,
        color: i.isPaid
            ? AppTokens.syncSynced
            : (i.isOverdue
                ? AppTokens.syncConflict
                : AppTokens.syncPending),
      ),
      title: Text(i.displayLabel),
      subtitle: Text(
        '${i.totalTtc != null ? '${formatMoney(i.totalTtc)} · ' : ''}'
        '${i.isPaid ? 'Payée' : (i.isOverdue ? 'En retard' : '')}'
            .trim(),
      ),
      trailing: const Icon(LucideIcons.chevronRight),
      onTap: () => context.go(RoutePaths.invoiceDetailFor(i.localId)),
    );
  }
}
