import 'package:dolibarr_mobile/core/routing/route_paths.dart';
import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:dolibarr_mobile/features/projects/domain/entities/project.dart';
import 'package:dolibarr_mobile/features/projects/presentation/providers/project_providers.dart';
import 'package:dolibarr_mobile/features/projects/presentation/widgets/project_card.dart';
import 'package:dolibarr_mobile/shared/widgets/empty_state.dart';
import 'package:dolibarr_mobile/shared/widgets/error_state.dart';
import 'package:dolibarr_mobile/shared/widgets/loading_skeleton.dart';
import 'package:dolibarr_mobile/shared/widgets/network_banner.dart';
import 'package:dolibarr_mobile/shared/widgets/search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProjectsListPage extends ConsumerStatefulWidget {
  const ProjectsListPage({super.key});

  @override
  ConsumerState<ProjectsListPage> createState() =>
      _ProjectsListPageState();
}

class _ProjectsListPageState extends ConsumerState<ProjectsListPage> {
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
    final filters = ref.read(projectFiltersProvider);
    final auth = ref.read(authNotifierProvider);
    final userId = auth is AuthAuthenticated ? auth.session.userId : null;
    setState(() => _loadingMore = true);
    final result = await ref.read(projectRepositoryProvider).refreshPage(
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
    final filters = ref.read(projectFiltersProvider);
    final auth = ref.read(authNotifierProvider);
    final userId = auth is AuthAuthenticated ? auth.session.userId : null;
    await ref.read(projectRepositoryProvider).refreshPage(
          filters: filters,
          page: 0,
          userId: userId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(projectFiltersProvider);
    final notifier = ref.read(projectFiltersProvider.notifier);
    final listAsync = ref.watch(projectsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projets'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: filters.statuses.length !=
                  ProjectStatus.values.length ||
                  filters.mineOnly,
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
              hintText: 'Rechercher (référence, titre)',
              initialValue: filters.search,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: listAsync.when(
                data: _buildList,
                error: (e, _) => ErrorState(
                  title: 'Impossible de charger les projets',
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
    );
  }

  Widget _buildList(List<Project> items) {
    if (items.isEmpty) {
      return EmptyState(
        icon: LucideIcons.folderOpen,
        title: 'Aucun projet',
        description: ref.read(projectFiltersProvider).search.isEmpty
            ? 'Aucun projet visible avec les filtres courants.'
            : 'Aucun résultat pour cette recherche.',
        actionLabel: 'Réinitialiser les filtres',
        action: () => ref.read(projectFiltersProvider.notifier).reset(),
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
        return ProjectCard(
          project: p,
          onTap: () =>
              context.go(RoutePaths.projectDetailFor(p.localId)),
        );
      },
    );
  }

  void _showFilters(BuildContext context) {
    final notifier = ref.read(projectFiltersProvider.notifier);
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: StatefulBuilder(
          builder: (ctx, setSheetState) {
            final filters = ref.read(projectFiltersProvider);
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
                      for (final s in ProjectStatus.values)
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
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Mes projets uniquement'),
                    subtitle: const Text(
                      'Filtrés par responsable connecté côté API',
                    ),
                    value: filters.mineOnly,
                    onChanged: (v) {
                      notifier.setMineOnly(value: v);
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
            );
          },
        ),
      ),
    );
  }

  String _statusLabel(ProjectStatus s) => switch (s) {
        ProjectStatus.draft => 'Brouillon',
        ProjectStatus.opened => 'Ouvert',
        ProjectStatus.closed => 'Fermé',
      };
}
