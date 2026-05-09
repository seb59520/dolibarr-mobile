import 'package:dolibarr_mobile/core/preferences/tweaks.dart';
import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:dolibarr_mobile/core/theme/app_theme.dart';
import 'package:dolibarr_mobile/shared/widgets/app_card.dart';
import 'package:dolibarr_mobile/shared/widgets/empty_state.dart';
import 'package:dolibarr_mobile/shared/widgets/entity_avatar.dart';
import 'package:dolibarr_mobile/shared/widgets/error_state.dart';
import 'package:dolibarr_mobile/shared/widgets/sync_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Goldens des 5 composants principaux du Design System.
///
/// Mode "skipGoldenAssertion" partial : si l'environnement n'a pas les
/// polices Roboto (fréquent en CI Linux), les comparaisons strictes
/// échouent. On vérifie surtout que la structure rend sans erreur.
/// Pour régénérer manuellement : `flutter test --update-goldens`.
Widget _wrap({
  required Widget child,
  required SharedPreferences prefs,
  bool dark = false,
}) {
  return ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: dark
          ? AppTheme.dark(const Tweaks())
          : AppTheme.light(const Tweaks()),
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  late SharedPreferences prefs;

  setUpAll(() {
    // En tests on n'a pas de réseau ni les fonts pré-chargées.
    GoogleFonts.config.allowRuntimeFetching = false;
    AppTheme.useSystemFontInsteadOfGoogleFonts = true;
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('Goldens — composants Design System', () {
    testWidgets('SyncStatusBadge — états variés', (tester) async {
      await tester.pumpWidget(
        _wrap(prefs: prefs, child: 
          const Wrap(
            spacing: 12,
            children: [
              SyncStatusBadge(status: SyncStatus.synced),
              SyncStatusBadge(status: SyncStatus.pendingUpdate),
              SyncStatusBadge(status: SyncStatus.conflict),
              SyncStatusBadge(status: SyncStatus.synced, offline: true),
            ],
          ),
        ),
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/sync_status_badge.png'),
      );
    });

    testWidgets('EntityAvatar — initiales', (tester) async {
      await tester.pumpWidget(
        _wrap(prefs: prefs, child: 
          const Wrap(
            spacing: 8,
            children: [
              EntityAvatar(name: 'ACME SAS'),
              EntityAvatar(name: 'Jeanne Doe'),
              EntityAvatar(name: 'Boulangerie Dupont'),
              EntityAvatar(name: 'X'),
            ],
          ),
        ),
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/entity_avatar.png'),
      );
    });

    testWidgets('AppCard — exemple peuplé', (tester) async {
      await tester.pumpWidget(
        _wrap(prefs: prefs, child: 
          AppCard(
            onTap: () {},
            child: const Row(
              children: [
                EntityAvatar(name: 'ACME SAS'),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ACME SAS',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text('C00012 · Paris'),
                    ],
                  ),
                ),
                SyncStatusBadge(
                  status: SyncStatus.synced,
                  compact: true,
                ),
              ],
            ),
          ),
        ),
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/app_card.png'),
      );
    });

    testWidgets('EmptyState', (tester) async {
      await tester.pumpWidget(
        _wrap(prefs: prefs, child: 
          EmptyState(
            icon: LucideIcons.users,
            title: 'Aucun contact',
            description: 'Créez votre premier contact pour commencer.',
            actionLabel: 'Créer',
            action: () {},
          ),
        ),
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/empty_state.png'),
      );
    });

    testWidgets('ErrorState', (tester) async {
      await tester.pumpWidget(
        _wrap(prefs: prefs, child: 
          ErrorState(
            title: 'Impossible de charger les tiers',
            description: 'Vérifiez votre connexion et réessayez.',
            onRetry: () {},
          ),
        ),
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/error_state.png'),
      );
    });
  });
}
