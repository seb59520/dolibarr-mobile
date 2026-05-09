import 'package:dolibarr_mobile/core/i18n/generated/app_localizations.dart';
import 'package:dolibarr_mobile/core/preferences/tweaks.dart';
import 'package:dolibarr_mobile/core/routing/app_router.dart';
import 'package:dolibarr_mobile/core/sync/sync_providers.dart';
import 'package:dolibarr_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget racine de l'application Dolibarr Mobile.
///
/// Branche le `GoRouter`, le thème (clair/sombre paramétré via Tweaks)
/// et les délégués de localisation. Aucune logique métier.
class DolibarrMobileApp extends ConsumerWidget {
  const DolibarrMobileApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final tweaks = ref.watch(tweaksProvider);
    // Démarre/arrête le SyncEngine selon l'état d'auth (effet de bord
    // monté à l'éveil de la racine).
    ref.watch(syncBootstrapProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light(tweaks),
      darkTheme: AppTheme.dark(tweaks),
      themeMode: tweaks.dark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
    );
  }
}
