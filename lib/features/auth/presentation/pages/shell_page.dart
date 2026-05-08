import 'package:dolibarr_mobile/core/routing/route_paths.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Shell principal après connexion : 3 onglets (Tiers / Contacts / Paramètres).
///
/// Pour l'Étape 3 les pages internes sont des placeholders. Elles seront
/// remplacées par les features réelles aux Étapes 6 / 8.
class ShellPage extends StatelessWidget {
  const ShellPage({required this.child, super.key});
  final Widget child;

  static const _tabs = [
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
      path: RoutePaths.settings,
      label: 'Paramètres',
      icon: LucideIcons.settings,
    ),
  ];

  int _activeIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    final i = _tabs.indexWhere((t) => loc.startsWith(t.path));
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    final active = _activeIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: active,
        onDestinationSelected: (i) => context.go(_tabs[i].path),
        destinations: [
          for (final t in _tabs)
            NavigationDestination(
              icon: Icon(t.icon),
              label: t.label,
            ),
        ],
      ),
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
