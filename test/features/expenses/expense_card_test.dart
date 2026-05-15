import 'package:dolibarr_mobile/core/preferences/tweaks.dart';
import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:dolibarr_mobile/core/theme/app_theme.dart';
import 'package:dolibarr_mobile/features/expenses/domain/entities/expense_report.dart';
import 'package:dolibarr_mobile/features/expenses/presentation/widgets/expense_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _wrap({
  required Widget child,
  required SharedPreferences prefs,
}) {
  return ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(const Tweaks()),
      home: Scaffold(body: ListView(children: [child])),
    ),
  );
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

  group('ExpenseCard', () {
    testWidgets('affiche la réf, le montant TTC et le chip de statut',
        (tester) async {
      final report = ExpenseReport(
        localId: 7,
        remoteId: 42,
        ref: 'NDF2026-007',
        status: ExpenseReportStatus.validated,
        totalHt: '120.00',
        totalTva: '24.00',
        totalTtc: '144.00',
        dateDebut: DateTime(2026, 5, 2),
        dateFin: DateTime(2026, 5, 15),
        localUpdatedAt: DateTime(2026, 5, 15),
      );

      await tester.pumpWidget(
        _wrap(prefs: prefs, child: ExpenseCard(expense: report)),
      );
      await tester.pump();

      expect(find.text('NDF2026-007'), findsOneWidget);
      expect(find.text('144,00 € TTC'), findsOneWidget);
      expect(find.text('Validé'), findsOneWidget);
    });

    testWidgets('fallback "Brouillon #id" quand la réf est nulle',
        (tester) async {
      final report = ExpenseReport(
        localId: 11,
        totalTtc: '50.00',
        localUpdatedAt: DateTime(2026, 5, 15),
        syncStatus: SyncStatus.pendingCreate,
      );

      await tester.pumpWidget(
        _wrap(prefs: prefs, child: ExpenseCard(expense: report)),
      );
      await tester.pump();

      expect(find.text('Brouillon #11'), findsOneWidget);
      expect(find.text('50,00 € TTC'), findsOneWidget);
      expect(find.text('Brouillon'), findsOneWidget);
    });
  });
}
