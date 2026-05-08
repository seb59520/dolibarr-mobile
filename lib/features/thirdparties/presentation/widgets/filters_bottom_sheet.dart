import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/features/categories/domain/entities/category.dart';
import 'package:dolibarr_mobile/features/categories/presentation/providers/category_providers.dart';
import 'package:dolibarr_mobile/features/thirdparties/domain/entities/third_party_filters.dart';
import 'package:dolibarr_mobile/features/thirdparties/presentation/providers/third_party_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bottom-sheet de filtres : kinds + activeOnly + myOnly + catégories.
class FiltersBottomSheet extends ConsumerWidget {
  const FiltersBottomSheet({super.key});

  static Future<void> show(BuildContext context) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => const FiltersBottomSheet(),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filters = ref.watch(thirdPartyFiltersProvider);
    final notifier = ref.read(thirdPartyFiltersProvider.notifier);
    final categoriesAsync =
        ref.watch(categoriesByTypeProvider(CategoryType.customer));

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scroll) => ListView(
        controller: scroll,
        padding: const EdgeInsets.all(AppTokens.spaceMd),
        children: [
          Text('Filtres', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppTokens.spaceMd),
          Text('Type', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppTokens.spaceXs),
          Wrap(
            spacing: 8,
            children: [
              for (final k in ThirdPartyKind.values)
                FilterChip(
                  label: Text(_kindLabel(k)),
                  selected: filters.kinds.contains(k),
                  onSelected: (_) => notifier.toggleKind(k),
                ),
            ],
          ),
          const Divider(height: AppTokens.spaceLg * 2),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Tiers actifs uniquement'),
            value: filters.activeOnly,
            onChanged: (v) => notifier.setActiveOnly(value: v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Mes tiers uniquement'),
            subtitle:
                const Text('Filtrés par commercial connecté côté API'),
            value: filters.myOnly,
            onChanged: (v) => notifier.setMyOnly(value: v),
          ),
          const Divider(height: AppTokens.spaceLg * 2),
          Text('Catégories', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppTokens.spaceXs),
          categoriesAsync.when(
            data: (cats) {
              if (cats.isEmpty) {
                return const Text(
                  'Aucune catégorie disponible.',
                  style: TextStyle(color: Colors.grey),
                );
              }
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in cats)
                    FilterChip(
                      label: Text(c.label),
                      selected: filters.categoryIds.contains(c.remoteId),
                      onSelected: (selected) {
                        final ids = {...filters.categoryIds};
                        if (selected) {
                          ids.add(c.remoteId);
                        } else {
                          ids.remove(c.remoteId);
                        }
                        notifier.setCategories(ids);
                      },
                    ),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: LinearProgressIndicator(),
            ),
            error: (_, __) => const Text(
              'Impossible de charger les catégories.',
              style: TextStyle(color: Colors.red),
            ),
          ),
          const SizedBox(height: AppTokens.spaceLg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: notifier.reset,
                  child: const Text('Réinitialiser'),
                ),
              ),
              const SizedBox(width: AppTokens.spaceMd),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Appliquer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _kindLabel(ThirdPartyKind k) => switch (k) {
        ThirdPartyKind.customer => 'Client',
        ThirdPartyKind.prospect => 'Prospect',
        ThirdPartyKind.supplier => 'Fournisseur',
      };
}
