import 'package:dolibarr_mobile/core/preferences/tweaks.dart';
import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/features/thirdparties/domain/entities/third_party.dart';
import 'package:dolibarr_mobile/shared/widgets/colored_avatar.dart';
import 'package:dolibarr_mobile/shared/widgets/dolimob_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ligne de tier au pattern DoliMob (refonte Étape 23).
///
/// Pattern : avatar coloré · nom + statut sync à droite ; sous-titre
/// chip de type (client/prospect/fournisseur) + ville/contact ; pas de
/// bordure individuelle (les rangs vivent dans une `Card` regroupante,
/// séparés par une hairline 0.5px).
///
/// Densité (compact/regular/comfy) lue depuis les Tweaks.
class ThirdPartyCard extends ConsumerWidget {
  const ThirdPartyCard({
    required this.thirdParty,
    this.onTap,
    this.offline = false,
    this.last = false,
    super.key,
  });

  final ThirdParty thirdParty;
  final VoidCallback? onTap;
  final bool offline;
  final bool last;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = DoliMobColors.of(context);
    final density = ref.watch(tweaksProvider).density;
    final t = thirdParty;

    final ChipTone tone;
    final String typeLabel;
    if (t.isProspect) {
      tone = ChipTone.info;
      typeLabel = 'Prospect';
    } else if (t.isSupplier) {
      tone = ChipTone.warning;
      typeLabel = 'Fournisseur';
    } else {
      tone = ChipTone.success;
      typeLabel = 'Client';
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 18,
          vertical: density.listRowVertical,
        ),
        decoration: BoxDecoration(
          border: last
              ? null
              : Border(
                  bottom: BorderSide(color: c.hairline2, width: 0.5),
                ),
        ),
        child: Row(
          children: [
            ColoredAvatar(name: t.name, size: density.avatarSize),
            const SizedBox(width: AppTokens.spaceSm),
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
                          style: TextStyle(
                            color: c.ink,
                            fontSize: density == DensityChoice.compact
                                ? 14.5
                                : 15.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _SyncDot(status: t.syncStatus, offline: offline),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      DoliMobChip(label: typeLabel, tone: tone, compact: true),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          [t.cityLine, t.codeClient]
                              .where((s) => s != null && s.isNotEmpty)
                              .join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: c.ink2,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SyncDot extends StatelessWidget {
  const _SyncDot({required this.status, this.offline = false});
  final SyncStatus status;
  final bool offline;

  @override
  Widget build(BuildContext context) {
    final c = DoliMobColors.of(context);
    Color color;
    switch (status) {
      case SyncStatus.synced:
        if (offline) {
          color = c.ink3;
        } else {
          return const SizedBox.shrink();
        }
      case SyncStatus.pendingCreate:
      case SyncStatus.pendingUpdate:
      case SyncStatus.pendingDelete:
        color = c.warning;
      case SyncStatus.conflict:
        color = c.danger;
    }
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.only(left: 6),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
