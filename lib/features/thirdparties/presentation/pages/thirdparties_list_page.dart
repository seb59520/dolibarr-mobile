import 'package:dolibarr_mobile/core/routing/route_paths.dart';
import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:dolibarr_mobile/features/thirdparties/domain/entities/third_party.dart';
import 'package:dolibarr_mobile/features/thirdparties/presentation/providers/third_party_providers.dart';
import 'package:dolibarr_mobile/features/thirdparties/presentation/widgets/filters_bottom_sheet.dart';
import 'package:dolibarr_mobile/features/thirdparties/presentation/widgets/third_party_card.dart';
import 'package:dolibarr_mobile/shared/widgets/empty_state.dart';
import 'package:dolibarr_mobile/shared/widgets/error_state.dart';
import 'package:dolibarr_mobile/shared/widgets/loading_skeleton.dart';
import 'package:dolibarr_mobile/shared/widgets/network_banner.dart';
import 'package:dolibarr_mobile/shared/widgets/search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ThirdPartiesListPage extends ConsumerStatefulWidget {
  const ThirdPartiesListPage({super.key});

  @override
  ConsumerState<ThirdPartiesListPage> createState() =>
      _ThirdPartiesListPageState();
}

class _ThirdPartiesListPageState extends ConsumerState<ThirdPartiesListPage> {
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
    final filters = ref.read(thirdPartyFiltersProvider);
    final auth = ref.read(authNotifierProvider);
    final userId = auth is AuthAuthenticated ? auth.session.userId : null;
    setState(() => _loadingMore = true);
    final result =
        await ref.read(thirdPartyRepositoryProvider).refreshPage(
              filters: filters,
              page: _page + 1,
              userId: userId,
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
    final filters = ref.read(thirdPartyFiltersProvider);
    final auth = ref.read(authNotifierProvider);
    final userId = auth is AuthAuthenticated ? auth.session.userId : null;
    await ref.read(thirdPartyRepositoryProvider).refreshPage(
          filters: filters,
          page: 0,
          userId: userId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(thirdPartyFiltersProvider);
    final filtersNotifier = ref.read(thirdPartyFiltersProvider.notifier);
    final listAsync = ref.watch(thirdPartiesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiers'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: filters.kinds.isNotEmpty ||
                  filters.categoryIds.isNotEmpty ||
                  !filters.activeOnly ||
                  !filters.myOnly,
              child: const Icon(LucideIcons.slidersHorizontal),
            ),
            onPressed: () => FiltersBottomSheet.show(context),
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
              onChanged: filtersNotifier.setSearch,
              hintText: 'Rechercher (nom, code, ville)',
              initialValue: filters.search,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: listAsync.when(
                data: _buildList,
                error: (e, _) => ErrorState(
                  title: 'Impossible de charger les tiers',
                  description: '$e',
                  onRetry: _refresh,
                ),
                loading: () => ListView(
                  children:
                      List.generate(6, (_) => _skeletonCard()),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(RoutePaths.thirdpartyNew),
        icon: const Icon(LucideIcons.plus),
        label: const Text('Nouveau'),
      ),
    );
  }

  Widget _skeletonCard() => LoadingSkeleton.card();

  Widget _buildList(List<ThirdParty> items) {
    if (items.isEmpty) {
      return EmptyState(
        icon: LucideIcons.briefcase,
        title: 'Aucun tiers',
        description: ref.read(thirdPartyFiltersProvider).search.isEmpty
            ? 'Aucun tiers visible avec les filtres courants.'
            : 'Aucun résultat pour cette recherche.',
        actionLabel: 'Réinitialiser les filtres',
        action: () =>
            ref.read(thirdPartyFiltersProvider.notifier).reset(),
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
        final tp = items[index];
        return ThirdPartyCard(
          thirdParty: tp,
          onTap: () => context.go(
            RoutePaths.thirdpartyDetailFor(tp.localId),
          ),
        );
      },
    );
  }
}
