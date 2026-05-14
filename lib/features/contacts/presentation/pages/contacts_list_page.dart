import 'package:dolibarr_mobile/core/routing/route_paths.dart';
import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/features/contacts/domain/entities/contact.dart';
import 'package:dolibarr_mobile/features/contacts/presentation/providers/contact_providers.dart';
import 'package:dolibarr_mobile/features/contacts/presentation/widgets/contact_card.dart';
import 'package:dolibarr_mobile/shared/widgets/empty_state.dart';
import 'package:dolibarr_mobile/shared/widgets/error_state.dart';
import 'package:dolibarr_mobile/shared/widgets/loading_skeleton.dart';
import 'package:dolibarr_mobile/shared/widgets/network_banner.dart';
import 'package:dolibarr_mobile/shared/widgets/search_field.dart';
import 'package:dolibarr_mobile/shared/widgets/shell_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ContactsListPage extends ConsumerStatefulWidget {
  const ContactsListPage({super.key});

  @override
  ConsumerState<ContactsListPage> createState() => _ContactsListPageState();
}

class _ContactsListPageState extends ConsumerState<ContactsListPage> {
  final _scroll = ScrollController();
  int _page = 0;
  bool _loadingMore = false;
  bool _exhausted = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _exhausted) return;
    final filters = ref.read(contactFiltersProvider);
    setState(() => _loadingMore = true);
    final result = await ref.read(contactRepositoryProvider).refreshPage(
          filters: filters,
          page: _page + 1,
        );
    if (!mounted) return;
    result.fold(
      onSuccess: (count) {
        setState(() {
          _loadingMore = false;
          if (count == 0) {
            _exhausted = true;
          } else {
            _page++;
          }
        });
      },
      onFailure: (_) => setState(() => _loadingMore = false),
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _page = 0;
      _exhausted = false;
    });
    final filters = ref.read(contactFiltersProvider);
    await ref.read(contactRepositoryProvider).refreshPage(
          filters: filters,
          page: 0,
        );
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(contactFiltersProvider);
    final notifier = ref.read(contactFiltersProvider.notifier);
    final listAsync = ref.watch(contactsListProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const ShellMenuButton(),
        title: const Text('Contacts'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: filters.hasEmail || filters.hasPhone,
              child: const Icon(LucideIcons.slidersHorizontal),
            ),
            onPressed: () => _showFilters(context),
            tooltip: 'Filtres',
          ),
        ],
      ),
      body: Column(
        children: [
          const NetworkBanner(),
          Padding(
            padding: const EdgeInsets.all(AppTokens.spaceMd),
            child: SearchField(
              onChanged: notifier.setSearch,
              hintText: 'Rechercher (nom, email, ville)',
              initialValue: filters.search,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: listAsync.when(
                data: _buildList,
                error: (e, _) => ErrorState(
                  title: 'Impossible de charger les contacts',
                  description: '$e',
                  onRetry: _refresh,
                ),
                loading: () => ListView(
                  children:
                      List.generate(6, (_) => LoadingSkeleton.card()),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(RoutePaths.contactNew),
        icon: const Icon(LucideIcons.plus),
        label: const Text('Nouveau'),
      ),
    );
  }

  Widget _buildList(List<Contact> items) {
    if (items.isEmpty) {
      return EmptyState(
        icon: LucideIcons.users,
        title: 'Aucun contact',
        description: ref.read(contactFiltersProvider).search.isEmpty
            ? 'Aucun contact visible avec les filtres courants.'
            : 'Aucun résultat pour cette recherche.',
        actionLabel: 'Réinitialiser les filtres',
        action: () => ref.read(contactFiltersProvider.notifier).reset(),
      );
    }
    return ListView.builder(
      controller: _scroll,
      itemCount: items.length + (_loadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= items.length) {
          return Padding(
            padding: const EdgeInsets.all(AppTokens.spaceMd),
            child: LoadingSkeleton.card(),
          );
        }
        final c = items[index];
        return ContactCard(
          contact: c,
          onTap: () => context.go(RoutePaths.contactDetailFor(c.localId)),
        );
      },
    );
  }

  void _showFilters(BuildContext context) {
    final notifier = ref.read(contactFiltersProvider.notifier);
    final filters = ref.read(contactFiltersProvider);
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: StatefulBuilder(
          builder: (ctx, setSheetState) => Padding(
            padding: const EdgeInsets.all(AppTokens.spaceMd),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Filtres',
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
                const SizedBox(height: AppTokens.spaceMd),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Avec email'),
                  value: filters.hasEmail,
                  onChanged: (v) {
                    notifier.setHasEmail(value: v);
                    setSheetState(() {});
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Avec téléphone'),
                  value: filters.hasPhone,
                  onChanged: (v) {
                    notifier.setHasPhone(value: v);
                    setSheetState(() {});
                  },
                ),
                const SizedBox(height: AppTokens.spaceMd),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          notifier.reset();
                          setSheetState(() {});
                        },
                        child: const Text('Réinitialiser'),
                      ),
                    ),
                    const SizedBox(width: AppTokens.spaceMd),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Appliquer'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
