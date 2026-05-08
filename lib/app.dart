import 'package:dolibarr_mobile/core/i18n/generated/app_localizations.dart';
import 'package:dolibarr_mobile/core/routing/app_router.dart';
import 'package:dolibarr_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget racine de l'application Dolibarr Mobile.
///
/// Branche le `GoRouter`, le thème (clair + sombre suivant le système) et
/// les délégués de localisation. Ne contient aucune logique métier.
class DolibarrMobileApp extends ConsumerWidget {
  const DolibarrMobileApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
    );
  }
}
