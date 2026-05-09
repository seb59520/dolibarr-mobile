import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/features/products/domain/entities/product.dart';
import 'package:dolibarr_mobile/features/products/presentation/providers/product_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Bottom-sheet de sélection d'un produit du catalogue. Retourne le
/// `Product` choisi ou `null` si annulé.
///
/// Le contenu est watché via Drift : pull-to-refresh recharge depuis
/// l'API. Une recherche locale filtre `ref + label + description`.
class ProductPickerSheet extends ConsumerStatefulWidget {
  const ProductPickerSheet({super.key});

  static Future<Product?> show(BuildContext context) {
    return showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const ProductPickerSheet(),
    );
  }

  @override
  ConsumerState<ProductPickerSheet> createState() =>
      _ProductPickerSheetState();
}

class _ProductPickerSheetState extends ConsumerState<ProductPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final listAsync = ref.watch(productsListProvider(_query));
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (context, scroll) => Padding(
        padding: const EdgeInsets.all(AppTokens.spaceMd),
        child: Column(
          children: [
            Text(
              'Choisir un produit / service',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppTokens.spaceMd),
            TextField(
              autofocus: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(LucideIcons.search),
                hintText: 'Rechercher (ref, libellé, description)',
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: AppTokens.spaceMd),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () =>
                    ref.read(productRepositoryProvider).refresh(),
                child: listAsync.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return ListView(
                        controller: scroll,
                        children: [
                          const SizedBox(height: AppTokens.spaceLg),
                          Center(
                            child: Text(
                              _query.trim().isEmpty
                                  ? 'Aucun produit en cache. Tirez pour '
                                      'rafraîchir.'
                                  : 'Aucun résultat pour "$_query".',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      );
                    }
                    return ListView.builder(
                      controller: scroll,
                      itemCount: items.length,
                      itemBuilder: (_, i) {
                        final p = items[i];
                        return _ProductTile(product: p);
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('$e')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = product;
    return ListTile(
      leading: Icon(
        p.type == ProductType.service
            ? LucideIcons.wrench
            : LucideIcons.package,
        color: theme.colorScheme.primary,
      ),
      title: Text(p.displayLabel),
      subtitle: Text(
        [
          p.ref,
          if (p.price != null) '${p.price} € HT',
          if (p.tvaTx != null) 'TVA ${p.tvaTx} %',
        ].join(' · '),
        style: theme.textTheme.bodySmall,
      ),
      onTap: () => Navigator.of(context).pop(p),
    );
  }
}
