import 'package:dolibarr_mobile/core/preferences/tweaks.dart';
import 'package:dolibarr_mobile/core/theme/app_theme.dart';
import 'package:dolibarr_mobile/features/stats/domain/entities/monthly_stat.dart';
import 'package:dolibarr_mobile/features/stats/domain/entities/stats_snapshot.dart';
import 'package:dolibarr_mobile/features/stats/domain/entities/yearly_stat.dart';
import 'package:dolibarr_mobile/features/stats/domain/repositories/stats_repository.dart';
import 'package:dolibarr_mobile/features/stats/presentation/pages/stats_page.dart';
import 'package:dolibarr_mobile/features/stats/presentation/providers/stats_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeRepo implements StatsRepository {
  _FakeRepo(this.snapshot);
  final StatsSnapshot snapshot;
  @override
  Stream<StatsSnapshot> watchSnapshot({
    StatsPeriod period = StatsPeriod.rolling12,
  }) =>
      Stream.value(snapshot);
}

void main() {
  late SharedPreferences prefs;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    AppTheme.useSystemFontInsteadOfGoogleFonts = true;
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  testWidgets('StatsPage rend les KPIs et la liste mensuelle', (tester) async {
    final snapshot = StatsSnapshot(
      monthly: List.generate(
        12,
        (i) => MonthlyStat(
          year: i < 7 ? 2025 : 2026,
          month: i < 7 ? i + 6 : i - 6,
          factureTtc: (i + 1) * 100.0,
          factureHt: (i + 1) * 83.0,
          percu: i * 50.0,
        ),
      ),
      currentYear: const YearlyStat(
        year: 2026,
        factureTtc: 5000,
        factureHt: 4166,
        percu: 3200,
      ),
      previousYear: const YearlyStat(
        year: 2025,
        factureTtc: 9000,
        percu: 8800,
      ),
    );

    await tester.binding.setSurfaceSize(const Size(600, 2400));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          statsRepositoryProvider.overrideWithValue(_FakeRepo(snapshot)),
        ],
        child: MaterialApp(
          theme: AppTheme.light(const Tweaks()),
          home: const StatsPage(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Statistiques'), findsOneWidget);
    expect(find.text('Année 2026'), findsOneWidget);
    expect(find.text('Année 2025'), findsOneWidget);
    expect(find.text('12 derniers mois'), findsOneWidget);
    expect(find.text('Détail par mois'), findsOneWidget);
    expect(find.text('FACTURÉ TTC'), findsNWidgets(2));
    expect(find.text('PERÇU'), findsNWidgets(2));
    expect(find.text('TAUX DE RECOUVREMENT'), findsNWidgets(2));

    addTearDown(() => tester.binding.setSurfaceSize(null));
  });
}
