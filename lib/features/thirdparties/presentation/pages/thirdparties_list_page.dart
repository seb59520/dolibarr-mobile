import 'package:dolibarr_mobile/core/preferences/tweaks.dart';
import 'package:dolibarr_mobile/core/routing/route_paths.dart';
import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:dolibarr_mobile/features/thirdparties/domain/entities/third_party.dart';
import 'package:dolibarr_mobile/features/thirdparties/domain/entities/third_party_filters.dart';
import 'package:dolibarr_mobile/features/thirdparties/presentation/providers/third_party_providers.dart';
import 'package:dolibarr_mobile/features/thirdparties/presentation/widgets/filters_bottom_sheet.dart';
import 'package:dolibarr_mobile/features/thirdparties/presentation/widgets/third_party_card.dart';
import 'package:dolibarr_mobile/shared/widgets/app_card.dart';
import 'package:dolibarr_mobile/shared/widgets/empty_state.dart';
import 'package:dolibarr_mobile/shared/widgets/error_state.dart';
import 'package:dolibarr_mobile/shared/widgets/loading_skeleton.dart';
import 'package:dolibarr_mobile/shared/widgets/network_banner.dart';
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
  final _searchCtrl = TextEditingController();
  int _page = 0;
  bool _loadingMore = false;
  bool _exhausted = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    final initial = ref.read(thirdPartyFiltersProvider).search;
    _searchCtrl.text = initial;
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    _searchCtrl.dispose();
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
    final c = DoliMobColors.of(context);
    final fabPos = ref.watch(tweaksProvider).fabPosition;

    return Scaffold(
      backgroundColor: c.bg,
      floatingActionButtonLocation: switch (fabPos) {
        FabPosition.left => FloatingActionButtonLocation.startFloat,
        FabPosition.center => FloatingActionButtonLocation.centerFloat,
        FabPosition.right => FloatingActionButtonLocation.endFloat,
      },
      floatingActionButton: _DoliMobFab(
        label: 'Nouveau',
        onPressed: () => context.go(RoutePaths.thirdpartyNew),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const NetworkBanner(),
            _LargeTopBar(
              title: 'Tiers',
              subtitle: listAsync.maybeWhen(
                data: (items) => '${items.length} fiche'
                    '${items.length > 1 ? 's' : ''}',
                orElse: () => null,
              ),
              trailing: IconButton(
                icon: Badge(
                  isLabelVisible: _hasActiveFilters(filters),
                  child: const Icon(LucideIcons.slidersHorizontal),
                ),
                onPressed: () => FiltersBottomSheet.show(context),
                tooltip: 'Filtres',
              ),
            ),
            _SearchRow(
              controller: _searchCtrl,
              onChanged: filtersNotifier.setSearch,
            ),
            _QuickChipsRow(filters: filters),
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
                        List.generate(6, (_) => LoadingSkeleton.card()),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasActiveFilters(ThirdPartyFilters f) {
    return f.kinds.isNotEmpty ||
        f.categoryIds.isNotEmpty ||
        !f.activeOnly ||
        f.myOnly;
  }

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
    return ListView(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 100),
      children: [
        AppCard(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++)
                ThirdPartyCard(
                  thirdParty: items[i],
                  last: i == items.length - 1,
                  onTap: () => context.go(
                    RoutePaths.thirdpartyDetailFor(items[i].localId),
                  ),
                ),
            ],
          ),
        ),
        if (_loadingMore)
          Padding(
            padding: const EdgeInsets.all(AppTokens.spaceMd),
            child: LoadingSkeleton.card(),
          ),
      ],
    );
  }
}

class _LargeTopBar extends StatelessWidget {
  const _LargeTopBar({
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = DoliMobColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (trailing != null)
            Align(
              alignment: Alignment.centerRight,
              child: trailing,
            ),
          Text(
            title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
              color: c.ink,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(fontSize: 13, color: c.ink2),
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = DoliMobColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: c.fill,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.search, size: 18, color: c.ink3),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: TextStyle(color: c.ink, fontSize: 15),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: 'Rechercher (nom, code, ville…)',
                  hintStyle: TextStyle(color: c.ink3),
                ),
              ),
            ),
            if (controller.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  controller.clear();
                  onChanged('');
                },
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: c.ink3,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    LucideIcons.x,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _QuickChipsRow extends ConsumerWidget {
  const _QuickChipsRow({required this.filters});
  final ThirdPartyFilters filters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = DoliMobColors.of(context);
    final notifier = ref.read(thirdPartyFiltersProvider.notifier);

    final chips = <_QuickChipDef>[
      _QuickChipDef(
        label: 'Tous',
        active: filters.kinds.isEmpty,
        onTap: () => notifier.toggleKinds(const {}),
      ),
      _QuickChipDef(
        label: 'Clients',
        active: filters.kinds.length == 1 &&
            filters.kinds.contains(ThirdPartyKind.customer),
        onTap: () => notifier.toggleKinds({ThirdPartyKind.customer}),
      ),
      _QuickChipDef(
        label: 'Prospects',
        active: filters.kinds.length == 1 &&
            filters.kinds.contains(ThirdPartyKind.prospect),
        onTap: () => notifier.toggleKinds({ThirdPartyKind.prospect}),
      ),
      _QuickChipDef(
        label: 'Fournisseurs',
        active: filters.kinds.length == 1 &&
            filters.kinds.contains(ThirdPartyKind.supplier),
        onTap: () => notifier.toggleKinds({ThirdPartyKind.supplier}),
      ),
    ];
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        children: [
          for (final chip in chips) ...[
            _QuickChip(c: c, def: chip),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _QuickChipDef {
  const _QuickChipDef({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.c, required this.def});
  final DoliMobColors c;
  final _QuickChipDef def;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: def.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: def.active ? c.ink : c.surface,
          border: Border.all(color: def.active ? c.ink : c.hairline),
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.center,
        child: Text(
          def.label,
          style: TextStyle(
            color: def.active ? (c.dark ? c.bg : Colors.white) : c.ink,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _DoliMobFab extends StatelessWidget {
  const _DoliMobFab({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = DoliMobColors.of(context);
    return Material(
      color: c.ink,
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.plus,
                size: 20,
                color: c.dark ? c.bg : Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: c.dark ? c.bg : Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
