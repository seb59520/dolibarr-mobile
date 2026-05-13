import 'package:dolibarr_mobile/core/routing/route_paths.dart';
import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/core/utils/formatters.dart';
import 'package:dolibarr_mobile/features/proposals/domain/entities/proposal.dart';
import 'package:dolibarr_mobile/features/proposals/presentation/providers/proposal_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ThirdPartyProposalsSection extends ConsumerWidget {
  const ThirdPartyProposalsSection({
    required this.thirdPartyLocalId,
    super.key,
  });

  final int thirdPartyLocalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final async = ref.watch(
      proposalsByThirdPartyLocalProvider(thirdPartyLocalId),
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
                  child: Text(
                    'Devis',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => context.go(
                    RoutePaths.proposalNewForParent(thirdPartyLocalId),
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
                      'Aucun devis.',
                      style: theme.textTheme.bodySmall,
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final p in items) _ProposalTile(proposal: p),
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: LinearProgressIndicator(),
              ),
              error: (_, __) => Text(
                'Devis indisponibles.',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProposalTile extends StatelessWidget {
  const _ProposalTile({required this.proposal});
  final Proposal proposal;

  @override
  Widget build(BuildContext context) {
    final p = proposal;
    final color = p.isSigned
        ? AppTokens.syncSynced
        : (p.isRefused || p.isExpired
            ? AppTokens.syncConflict
            : AppTokens.syncPending);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(LucideIcons.fileText, color: color),
      title: Text(p.displayLabel),
      subtitle: Text(
        '${p.totalTtc != null ? '${formatMoney(p.totalTtc)} · ' : ''}'
        '${_label(p)}'
            .trim(),
      ),
      trailing: const Icon(LucideIcons.chevronRight),
      onTap: () => context.go(RoutePaths.proposalDetailFor(p.localId)),
    );
  }

  static String _label(Proposal p) {
    if (p.isExpired && !p.isSigned && !p.isRefused) return 'Expiré';
    return switch (p.status) {
      ProposalStatus.draft => 'Brouillon',
      ProposalStatus.validated => 'Validé',
      ProposalStatus.signed => 'Signé',
      ProposalStatus.refused => 'Refusé',
    };
  }
}
