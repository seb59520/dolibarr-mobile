import 'package:dolibarr_mobile/core/routing/route_paths.dart';
import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/features/proposals/domain/entities/proposal.dart';
import 'package:dolibarr_mobile/features/proposals/domain/entities/proposal_filters.dart';
import 'package:dolibarr_mobile/features/proposals/presentation/providers/proposal_providers.dart';
import 'package:dolibarr_mobile/features/proposals/presentation/widgets/proposal_card.dart';
import 'package:dolibarr_mobile/shared/widgets/empty_state.dart';
import 'package:dolibarr_mobile/shared/widgets/error_state.dart';
import 'package:dolibarr_mobile/shared/widgets/loading_skeleton.dart';
import 'package:dolibarr_mobile/shared/widgets/network_banner.dart';
import 'package:dolibarr_mobile/shared/widgets/search_field.dart';
import 'package:dolibarr_mobile/shared/widgets/shell_menu_button.dart';
import 'package:dolibarr_mobile/shared/widgets/sort_chips_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProposalsListPage extends ConsumerStatefulWidget {
  const ProposalsListPage({super.key});

  @override
  ConsumerState<ProposalsListPage> createState() =>
      _ProposalsListPageState();
}

class _ProposalsListPageState extends ConsumerState<ProposalsListPage> {
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
    final filters = ref.read(proposalFiltersProvider);
    setState(() => _loadingMore = true);
    final result = await ref.read(proposalRepositoryProvider).refreshPage(
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
    final filters = ref.read(proposalFiltersProvider);
    await ref.read(proposalRepositoryProvider).refreshPage(
          filters: filters,
          page: 0,
        );
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(proposalFiltersProvider);
    final notifier = ref.read(proposalFiltersProvider.notifier);
    final listAsync = ref.watch(proposalsListProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const ShellMenuButton(),
        title: const Text('Devis'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: filters.statuses.length !=
                      ProposalStatus.values.length ||
                  filters.dateFrom != null ||
                  filters.dateTo != null,
              child: const Icon(LucideIcons.slidersHorizontal),
            ),
            onPressed: () => _showFilters(context),
            tooltip: 'Filtres',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(RoutePaths.proposalNew),
        icon: const Icon(LucideIcons.plus),
        label: const Text('Nouveau'),
      ),
      body: Column(
        children: [
          const NetworkBanner(),
          Padding(
            padding: const EdgeInsets.all(AppTokens.spaceMd),
            child: SearchField(
              onChanged: notifier.setSearch,
              hintText: 'Rechercher (référence, ref. client)',
              initialValue: filters.search,
            ),
          ),
          SortChipsRow<ProposalSortBy>(
            options: ProposalSortBy.values,
            active: filters.sortBy,
            descending: filters.sortDescending,
            labelOf: (s) => s.label,
            onSelected: notifier.setSort,
          ),
          const SizedBox(height: AppTokens.spaceXs),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: listAsync.when(
                data: _buildList,
                error: (e, _) => ErrorState(
                  title: 'Impossible de charger les devis',
                  description: '$e',
                  onRetry: _refresh,
                ),
                loading: () => ListView(
                  children: List.generate(
                    6,
                    (_) => LoadingSkeleton.card(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<Proposal> items) {
    if (items.isEmpty) {
      return EmptyState(
        icon: LucideIcons.fileText,
        title: 'Aucun devis',
        description: ref.read(proposalFiltersProvider).search.isEmpty
            ? 'Aucun devis visible avec les filtres courants.'
            : 'Aucun résultat pour cette recherche.',
        actionLabel: 'Réinitialiser les filtres',
        action: () => ref.read(proposalFiltersProvider.notifier).reset(),
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
        final p = items[index];
        return ProposalCard(
          proposal: p,
          onTap: () => context.go(RoutePaths.proposalDetailFor(p.localId)),
        );
      },
    );
  }

  void _showFilters(BuildContext context) {
    final notifier = ref.read(proposalFiltersProvider.notifier);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: StatefulBuilder(
          builder: (ctx, setSheetState) {
            final filters = ref.read(proposalFiltersProvider);
            return Padding(
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
                  Text(
                    'Statut',
                    style: Theme.of(ctx).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppTokens.spaceXs),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final s in ProposalStatus.values)
                        FilterChip(
                          label: Text(_statusLabel(s)),
                          selected: filters.statuses.contains(s),
                          onSelected: (_) {
                            notifier.toggleStatus(s);
                            setSheetState(() {});
                          },
                        ),
                    ],
                  ),
                  const Divider(height: AppTokens.spaceLg * 2),
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
            );
          },
        ),
      ),
    );
  }

  String _statusLabel(ProposalStatus s) => switch (s) {
        ProposalStatus.draft => 'Brouillon',
        ProposalStatus.validated => 'Validé',
        ProposalStatus.signed => 'Signé',
        ProposalStatus.refused => 'Refusé',
      };
}
