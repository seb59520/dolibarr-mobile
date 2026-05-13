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

  @override
  Widget build(BuildContext context) {
    final active = _activeIndex(context);
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final w = constraints.maxWidth;
        final autoExtended = w >= 1000;
        final extended = _userExtended ?? autoExtended;
        final compact = w < 600 && !extended;

        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                extended: extended,
                minWidth: compact ? 56 : 72,
                minExtendedWidth: 220,
                labelType: extended
                    ? NavigationRailLabelType.none
                    : (compact
                        ? NavigationRailLabelType.selected
                        : NavigationRailLabelType.all),
                selectedIndex: active,
                onDestinationSelected: (i) => context.go(_tabs[i].path),
                leading: IconButton(
                  icon: Icon(
                    extended ? LucideIcons.chevronLeft : LucideIcons.menu,
                  ),
                  tooltip: extended ? 'Réduire le menu' : 'Étendre le menu',
                  onPressed: () =>
                      setState(() => _userExtended = !extended),
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
      },
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
