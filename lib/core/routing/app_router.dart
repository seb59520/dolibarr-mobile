import 'package:dolibarr_mobile/core/routing/route_paths.dart';
import 'package:dolibarr_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:dolibarr_mobile/features/auth/presentation/pages/onboarding_page.dart';
import 'package:dolibarr_mobile/features/auth/presentation/pages/settings_page.dart';
import 'package:dolibarr_mobile/features/auth/presentation/pages/shell_page.dart';
import 'package:dolibarr_mobile/features/auth/presentation/pages/splash_page.dart';
import 'package:dolibarr_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:dolibarr_mobile/features/contacts/presentation/pages/contact_detail_page.dart';
import 'package:dolibarr_mobile/features/contacts/presentation/pages/contact_form_page.dart';
import 'package:dolibarr_mobile/features/contacts/presentation/pages/contacts_list_page.dart';
import 'package:dolibarr_mobile/features/projects/presentation/pages/project_detail_page.dart';
import 'package:dolibarr_mobile/features/projects/presentation/pages/project_form_page.dart';
import 'package:dolibarr_mobile/features/projects/presentation/pages/projects_list_page.dart';
import 'package:dolibarr_mobile/features/sync/presentation/pages/pending_operations_page.dart';
import 'package:dolibarr_mobile/features/thirdparties/presentation/pages/third_party_detail_page.dart';
import 'package:dolibarr_mobile/features/thirdparties/presentation/pages/third_party_form_page.dart';
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
              // Déclaré avant `:id` pour éviter que "new" ne soit
              // capturé par le wildcard.
              GoRoute(
                path: 'new',
                builder: (_, __) => const ThirdPartyFormPage(),
              ),
              GoRoute(
                path: ':id',
                builder: (_, state) => ThirdPartyDetailPage(
                  localId: int.parse(state.pathParameters['id']!),
                ),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (_, state) => ThirdPartyFormPage(
                      existingLocalId:
                          int.parse(state.pathParameters['id']!),
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: RoutePaths.contacts,
            builder: (_, __) => const ContactsListPage(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (_, state) {
                  final parent = state.uri.queryParameters['parent'];
                  return ContactFormPage(
                    parentLocalId: parent == null ? null : int.tryParse(parent),
                  );
                },
              ),
              GoRoute(
                path: ':id',
                builder: (_, state) => ContactDetailPage(
                  localId: int.parse(state.pathParameters['id']!),
                ),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (_, state) => ContactFormPage(
                      existingLocalId:
                          int.parse(state.pathParameters['id']!),
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: RoutePaths.projects,
            builder: (_, __) => const ProjectsListPage(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (_, state) {
                  final parent = state.uri.queryParameters['parent'];
                  return ProjectFormPage(
                    parentLocalId:
                        parent == null ? null : int.tryParse(parent),
                  );
                },
              ),
              GoRoute(
                path: ':id',
                builder: (_, state) => ProjectDetailPage(
                  localId: int.parse(state.pathParameters['id']!),
                ),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (_, state) => ProjectFormPage(
                      existingLocalId:
                          int.parse(state.pathParameters['id']!),
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: RoutePaths.settings,
            builder: (_, __) => const SettingsPage(),
          ),
          GoRoute(
            path: RoutePaths.pendingOperations,
            builder: (_, __) => const PendingOperationsPage(),
          ),
        ],
      ),
    ],
  );
});
