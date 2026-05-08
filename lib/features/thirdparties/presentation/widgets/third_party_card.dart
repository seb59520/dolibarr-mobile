import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/features/thirdparties/domain/entities/third_party.dart';
import 'package:dolibarr_mobile/shared/widgets/app_card.dart';
import 'package:dolibarr_mobile/shared/widgets/entity_avatar.dart';
import 'package:dolibarr_mobile/shared/widgets/sync_status_badge.dart';
import 'package:flutter/material.dart';

class ThirdPartyCard extends StatelessWidget {
  const ThirdPartyCard({
    required this.thirdParty,
    this.onTap,
    this.offline = false,
    super.key,
  });

  final ThirdParty thirdParty;
  final VoidCallback? onTap;
  final bool offline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = thirdParty;
    final chips = <Widget>[];
    if (t.isCustomer) chips.add(const _Tag('Client'));
    if (t.isProspect) chips.add(const _Tag('Prospect'));
    if (t.isSupplier) chips.add(const _Tag('Fournisseur'));

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          EntityAvatar(name: t.name),
          const SizedBox(width: AppTokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        t.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    SyncStatusBadge(
                      status: t.syncStatus,
                      compact: true,
                      offline: offline,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  [t.codeClient, t.cityLine]
                      .where((s) => s != null && s.isNotEmpty)
                      .join(' · '),
                  style: theme.textTheme.bodySmall,
                ),
                if (chips.isNotEmpty) ...[
                  const SizedBox(height: AppTokens.spaceXs),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: chips,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label);
  final String label;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppTokens.radiusChip),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: scheme.onPrimaryContainer,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
