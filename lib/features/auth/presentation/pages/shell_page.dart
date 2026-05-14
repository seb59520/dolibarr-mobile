import 'package:dolibarr_mobile/core/routing/route_paths.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ShellPage extends StatefulWidget {
  const ShellPage({required this.child, super.key});
  final Widget child;

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  static const _tabs = [
    _TabRoute(
      path: RoutePaths.dashboard,
      label: 'Accueil',
      icon: LucideIcons.home,
    ),
    _TabRoute(
      path: RoutePaths.thirdparties,
      label: 'Tiers',
      icon: LucideIcons.briefcase,
    ),
    _TabRoute(
      path: RoutePaths.contacts,
      label: 'Contacts',
      icon: LucideIcons.users,
    ),
    _TabRoute(
      path: RoutePaths.projects,
      label: 'Projets',
      icon: LucideIcons.folderOpen,
    ),
    _TabRoute(
      path: RoutePaths.proposals,
      label: 'Devis',
      icon: LucideIcons.fileText,
    ),
    _TabRoute(
      path: RoutePaths.invoices,
      label: 'Factures',
      icon: LucideIcons.receipt,
    ),
    _TabRoute(
      path: RoutePaths.settings,
      label: 'Paramètres',
      icon: LucideIcons.settings,
    ),
  ];

  bool? _userExtended;

  int _activeIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    final i = _tabs.indexWhere((t) => loc.startsWith(t.path));
    return i < 0 ? 0 : i;
  }

  bool _isTopLevel(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    return _tabs.any((t) => t.path == loc);
  }

  @override
  Widget build(BuildContext context) {
    final active = _activeIndex(context);
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final w = constraints.maxWidth;
        final isPhone = w < 600;
        final autoExtended = w >= 1000;
        final extended = _userExtended ?? autoExtended;

        if (isPhone) {
          return _buildPhoneLayout(active);
        }
        return _buildWideLayout(active, extended: extended);
      },
    );
  }

  Widget _buildPhoneLayout(int active) {
    final showHamburger = _isTopLevel(context);
    return Scaffold(
      drawer: _AppDrawer(
        tabs: _tabs,
        selectedIndex: active,
        onSelected: (i) => context.go(_tabs[i].path),
      ),
      body: Stack(
        children: [
          widget.child,
          if (showHamburger)
            Positioned(
              top: 0,
              left: 0,
              child: SafeArea(
                child: Builder(
                  builder: (innerCtx) => Padding(
                    padding: const EdgeInsets.all(4),
                    child: Material(
                      color: Theme.of(innerCtx).colorScheme.surface,
                      shape: const CircleBorder(),
                      elevation: 2,
                      child: IconButton(
                        icon: const Icon(LucideIcons.menu),
                        tooltip: 'Ouvrir le menu',
                        onPressed: () => Scaffold.of(innerCtx).openDrawer(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWideLayout(int active, {required bool extended}) {
    final compact = !extended;
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: extended,
            minWidth: compact ? 72 : 72,
            minExtendedWidth: 220,
            labelType: extended
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            selectedIndex: active,
            onDestinationSelected: (i) => context.go(_tabs[i].path),
            leading: IconButton(
              icon: Icon(extended ? LucideIcons.chevronLeft : LucideIcons.menu),
              tooltip: extended ? 'Réduire le menu' : 'Étendre le menu',
              onPressed: () => setState(() => _userExtended = !extended),
            ),
            destinations: [
              for (final t in _tabs)
                NavigationRailDestination(
                  icon: Icon(t.icon),
                  label: Text(t.label),
                ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<_TabRoute> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return NavigationDrawer(
      selectedIndex: selectedIndex,
      onDestinationSelected: (i) {
        Navigator.of(context).pop();
        onSelected(i);
      },
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 8),
          child: Text(
            'Dolibarr Mobile',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 0, 28, 16),
          child: Divider(height: 1),
        ),
        for (final t in tabs)
          NavigationDrawerDestination(icon: Icon(t.icon), label: Text(t.label)),
      ],
    );
  }
}

class _TabRoute {
  const _TabRoute({
    required this.path,
    required this.label,
    required this.icon,
  });
  final String path;
  final String label;
  final IconData icon;
}
