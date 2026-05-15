import 'package:dolibarr_mobile/features/expenses/domain/entities/expense_report.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExpenseReportStatus.fromInt — mapping Dolibarr non contigu', () {
    test('0 → draft', () {
      expect(ExpenseReportStatus.fromInt(0), ExpenseReportStatus.draft);
    });
    test('2 → validated', () {
      expect(
        ExpenseReportStatus.fromInt(2),
        ExpenseReportStatus.validated,
      );
    });
    test('4 → approved', () {
      expect(
        ExpenseReportStatus.fromInt(4),
        ExpenseReportStatus.approved,
      );
    });
    test('6 → paid', () {
      expect(ExpenseReportStatus.fromInt(6), ExpenseReportStatus.paid);
    });
    test('99 → refused', () {
      expect(
        ExpenseReportStatus.fromInt(99),
        ExpenseReportStatus.refused,
      );
    });
    test('valeurs inattendues → draft (sécuritaire)', () {
      expect(ExpenseReportStatus.fromInt(7), ExpenseReportStatus.draft);
      expect(ExpenseReportStatus.fromInt(-1), ExpenseReportStatus.draft);
    });
  });

  group('apiValue — round-trip', () {
    test('toutes les valeurs roundtrip', () {
      for (final s in ExpenseReportStatus.values) {
        expect(ExpenseReportStatus.fromInt(s.apiValue), s);
      }
    });
  });
}
