import 'package:dolibarr_mobile/core/routing/route_paths.dart';
import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/features/projects/presentation/providers/project_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Section "Projets" rendue sur la fiche d'un tiers : liste les projets
/// rattachés au tiers (par PK locale).
class ThirdPartyProjectsSection extends ConsumerWidget {
  const ThirdPartyProjectsSection({
    required this.thirdPartyLocalId,
    super.key,
  });

  final int thirdPartyLocalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final async = ref.watch(
      projectsByThirdPartyLocalProvider(thirdPartyLocalId),
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
                  child:
                      Text('Projets', style: theme.textTheme.titleMedium),
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
                      'Aucun projet rattaché.',
                      style: theme.textTheme.bodySmall,
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final p in items)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(LucideIcons.folderOpen),
                        title: Text(p.displayLabel),
                        subtitle: p.dateStart != null
                            ? Text(_formatDate(p.dateStart!))
                            : null,
                        trailing: const Icon(LucideIcons.chevronRight),
                        onTap: () => context.go(
                          RoutePaths.projectDetailFor(p.localId),
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
                'Projets indisponibles.',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';
}
