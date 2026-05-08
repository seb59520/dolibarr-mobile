import 'package:dolibarr_mobile/core/routing/route_paths.dart';
import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/features/contacts/presentation/providers/contact_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Section "Contacts" rendue sur la fiche d'un tiers : liste les contacts
/// rattachés au tiers (par PK locale) et expose un bouton "Ajouter".
class ThirdPartyContactsSection extends ConsumerWidget {
  const ThirdPartyContactsSection({
    required this.thirdPartyLocalId,
    super.key,
  });

  final int thirdPartyLocalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final async = ref.watch(
      contactsByThirdPartyLocalProvider(thirdPartyLocalId),
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
                  child: Text('Contacts', style: theme.textTheme.titleMedium),
                ),
                TextButton.icon(
                  onPressed: () => context.go(
                    RoutePaths.contactNewForParent(thirdPartyLocalId),
                  ),
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('Ajouter'),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.spaceXs),
            async.when(
              data: (contacts) {
                if (contacts.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Aucun contact rattaché.',
                      style: theme.textTheme.bodySmall,
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final c in contacts)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(LucideIcons.user),
                        title: Text(c.displayName),
                        subtitle: c.poste != null && c.poste!.isNotEmpty
                            ? Text(c.poste!)
                            : null,
                        trailing: const Icon(LucideIcons.chevronRight),
                        onTap: () => context.go(
                          RoutePaths.contactDetailFor(c.localId),
                        ),
                      ),
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: LinearProgressIndicator(),
              ),
              error: (_, __) => Text(
                'Contacts indisponibles.',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
