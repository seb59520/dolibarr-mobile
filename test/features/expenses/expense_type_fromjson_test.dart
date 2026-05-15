import 'package:dolibarr_mobile/features/expenses/domain/entities/expense_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExpenseType.fromJson', () {
    test('parse réponse Dolibarr /setup/dictionary/expensereport_types', () {
      final t = ExpenseType.fromJson(const {
        'id': '3',
        'code': 'TF_LUNCH',
        'label': 'Lunch',
        'accountancy_code': null,
        'active': '1',
      });
      expect(t.code, 'TF_LUNCH');
      expect(t.remoteId, 3);
      expect(t.label, 'Lunch');
      expect(t.accountancyCode, isNull);
      expect(t.active, isTrue);
    });

    test('type désactivé → active=false', () {
      final t = ExpenseType.fromJson(const {
        'id': 11,
        'code': 'EX_OBSOLETE',
        'label': 'Obsolete',
        'active': '0',
      });
      expect(t.active, isFalse);
    });

    test('fetchedAt injectable, sinon now', () {
      final ref = DateTime(2026, 5, 15, 10);
      final t = ExpenseType.fromJson(
        const {'id': 1, 'code': 'TF_OTHER', 'label': 'Other'},
        fetchedAt: ref,
      );
      expect(t.fetchedAt, ref);
    });

    test('label fallback sur code si absent', () {
      final t = ExpenseType.fromJson(const {
        'id': 5,
        'code': 'EX_HOT',
      });
      expect(t.label, 'EX_HOT');
    });
  });
}
