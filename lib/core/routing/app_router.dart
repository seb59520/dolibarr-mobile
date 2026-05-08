import 'package:dolibarr_mobile/core/routing/route_paths.dart';
import 'package:dolibarr_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:dolibarr_mobile/features/auth/presentation/pages/onboarding_page.dart';
import 'package:dolibarr_mobile/features/auth/presentation/pages/placeholder_pages.dart';
import 'package:dolibarr_mobile/features/auth/presentation/pages/shell_page.dart';
import 'package:dolibarr_mobile/features/auth/presentation/pages/splash_page.dart';
import 'package:dolibarr_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:dolibarr_mobile/features/thirdparties/presentation/pages/third_party_detail_page.dart';
import 'package:dolibarr_mobile/features/thirdparties/presentation/pages/thirdparties_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Provider du `GoRouter` racine. La SplashPage pilote la décision de
/// navigation initiale (auth + onboarding). Le `redirect` ici ne sert
/// QU'À protéger les routes `/app/*` contre les accès non authentifiés.
final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0)..addListener(() {});
  ref
    ..listen(authNotifierProvider, (_, __) => refresh.value++)
    ..onDispose(refresh.dispose);

  final shellKey = GlobalKey<NavigatorState>();

  return GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authNotifierProvider);
      final loc = state.matchedLocation;
      final isProtected = loc.startsWith(RoutePaths.shell);

      if (!isProtected) return null;
      if (auth is AuthAuthenticated) return null;
      // Route protégée + non authentifié → /login en préservant la cible.
      final next = Uri.encodeComponent(loc);
      return '${RoutePaths.login}?next=$next';
    },
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        builder: (_, __) => const SplashPage(),
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        builder: (_, __) => const OnboardingPage(),
      ),
      GoRoute(
        path: RoutePaths.login,
        builder: (_, __) => const LoginPage(),
      ),
      ShellRoute(
        navigatorKey: shellKey,
        builder: (_, __, child) => ShellPage(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.thirdparties,
            builder: (_, __) => const ThirdPartiesListPage(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) => ThirdPartyDetailPage(
                  localId: int.parse(state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: RoutePaths.contacts,
            builder: (_, __) => const ContactsPlaceholderPage(),
          ),
          GoRoute(
            path: RoutePaths.settings,
            builder: (_, __) => const SettingsPlaceholderPage(),
          ),
        ],
      ),
    ],
  );
});
