import 'package:dolibarr_mobile/core/config/env.dart';
import 'package:dolibarr_mobile/core/di/providers.dart';
import 'package:dolibarr_mobile/core/i18n/generated/app_localizations.dart';
import 'package:dolibarr_mobile/core/routing/route_paths.dart';
import 'package:dolibarr_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Écran d'accueil : déclenche `restoreSession`, vérifie l'onboarding,
/// puis pousse vers la bonne route selon l'état.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final start = DateTime.now();
    final notifier = ref.read(authNotifierProvider.notifier);
    final storage = ref.read(secureStorageProvider);

    await Future.wait<Object?>([
      notifier.restore(),
      storage.readOnboardingCompleted(),
    ]);

    final auth = ref.read(authNotifierProvider);
    final onboardingDone = await storage.readOnboardingCompleted();

    final elapsed = DateTime.now().difference(start).inMilliseconds;
    final remaining = Env.splashDelayMs - elapsed;
    if (remaining > 0) {
      await Future<void>.delayed(Duration(milliseconds: remaining));
    }
    if (!mounted) return;

    if (auth is AuthAuthenticated) {
      context.go(RoutePaths.thirdparties);
    } else if (!onboardingDone) {
      context.go(RoutePaths.onboarding);
    } else {
      context.go(RoutePaths.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_center_outlined,
              size: 96,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(l10n.appTitle, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 32),
            const SizedBox(
              width: 200,
              child: LinearProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}
