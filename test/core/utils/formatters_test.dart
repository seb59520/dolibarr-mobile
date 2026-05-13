import 'package:dolibarr_mobile/core/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatMoney', () {
    test('arrondit toujours à 2 décimales et utilise la virgule', () {
      expect(formatMoney('100.00000000'), '100,00 €');
      expect(formatMoney('1234.5'), '1234,50 €');
      expect(formatMoney('1234.567'), '1234,57 €');
      expect(formatMoney(42), '42,00 €');
      expect(formatMoney(42.1), '42,10 €');
    });

    test('null/invalid → fallback', () {
      expect(formatMoney(null), '— €');
      expect(formatMoney(''), '— €');
      expect(formatMoney('abc'), '— €');
      expect(formatMoney(null, fallback: '?'), '? €');
    });

    test('accepte une virgule en entrée (saisie FR)', () {
      expect(formatMoney('1234,5'), '1234,50 €');
    });
  });

  group('formatPercent', () {
    test('strip trailing zeros', () {
      expect(formatPercent('20.00000000'), '20 %');
      expect(formatPercent('20.5'), '20,5 %');
      expect(formatPercent('20.55'), '20,55 %');
      expect(formatPercent(20), '20 %');
    });

    test('null → fallback', () {
      expect(formatPercent(null), '— %');
    });
  });

  group('formatQty', () {
    test('strip trailing zeros, pas de symbole', () {
      expect(formatQty('1.00000000'), '1');
      expect(formatQty('1.5'), '1,5');
      expect(formatQty('1.25'), '1,25');
      expect(formatQty(10), '10');
    });

    test('null → fallback', () {
      expect(formatQty(null), '—');
    });
  });
}
