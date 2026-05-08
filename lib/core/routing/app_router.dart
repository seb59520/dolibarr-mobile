import 'package:dolibarr_mobile/core/i18n/generated/app_localizations.dart';
import 'package:dolibarr_mobile/core/routing/route_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Provider du `GoRouter` racine de l'application.
///
/// Pour l'Étape 1 le router est minimaliste et n'a qu'un placeholder.
/// L'auth guard et les routes complètes seront branchés à l'Étape 3.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RoutePaths.splash,
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        builder: (context, state) => const _PlaceholderHome(),
      ),
    ],
  );
});

class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_done_outlined,
                size: 96,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.helloWorld,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text('Étape 1 — Bootstrap', style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
