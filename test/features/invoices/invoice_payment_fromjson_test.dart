import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice_payment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InvoicePayment.fromJson — date', () {
    test('parse timestamp Unix (entier) → DateTime correct', () {
      final p = InvoicePayment.fromJson(const {
        'id': 42,
        'date': 1743379200, // 2025-03-31 00:00:00 UTC
        'amount': '500.00',
      });
      expect(p.date, isNotNull);
      expect(p.date!.year, 2025);
      expect(p.date!.month, 3);
      expect(p.date!.day, 31);
    });

    test(
      'parse chaîne SQL YYYY-MM-DD HH:MM:SS (format /invoices/id/payments)',
      () {
        final p = InvoicePayment.fromJson(const {
          'fk_bank_line': '69',
          'date': '2026-03-31 00:00:00',
          'amount': '600.00000000',
        });
        expect(p.date, isNotNull);
        expect(p.date!.year, 2026);
        expect(p.date!.month, 3);
        expect(p.date!.day, 31);
      },
    );

    test('fallback sur datep si date absent', () {
      final p = InvoicePayment.fromJson(const {
        'id': 1,
        'datep': 1743379200,
        'amount': '100',
      });
      expect(p.date, isNotNull);
      expect(p.date!.year, 2025);
    });

    test('null/empty → null', () {
      expect(InvoicePayment.fromJson(const {'id': 1}).date, isNull);
      expect(
        InvoicePayment.fromJson(const {'id': 1, 'date': ''}).date,
        isNull,
      );
      expect(
        InvoicePayment.fromJson(const {'id': 1, 'date': 'null'}).date,
        isNull,
      );
    });
  });

  group('InvoicePayment.fromJson — remoteId', () {
    test('utilise id quand présent', () {
      final p = InvoicePayment.fromJson(const {'id': 42, 'amount': '1'});
      expect(p.remoteId, 42);
    });

    test('fallback sur rowid', () {
      final p = InvoicePayment.fromJson(const {'rowid': 99, 'amount': '1'});
      expect(p.remoteId, 99);
    });

    test('fallback sur fk_bank_line (cas /invoices/id/payments)', () {
      final p = InvoicePayment.fromJson(const {
        'fk_bank_line': '69',
        'date': '2026-03-31 00:00:00',
        'amount': '600',
      });
      expect(p.remoteId, 69);
    });

    test(
      'deux paiements sur la même facture sans id → '
      'remoteId distincts via le hash de fingerprint',
      () {
        final a = InvoicePayment.fromJson(const {
          'date': '2026-03-31 00:00:00',
          'amount': '300',
          'ref': 'PAY-A',
        });
        final b = InvoicePayment.fromJson(const {
          'date': '2026-04-15 00:00:00',
          'amount': '300',
          'ref': 'PAY-B',
        });
        expect(a.remoteId, isNot(b.remoteId));
        expect(a.remoteId, greaterThan(0));
        expect(b.remoteId, greaterThan(0));
      },
    );
  });

  test('amount lu depuis amount puis amount_ttc', () {
    final p1 = InvoicePayment.fromJson(
      const {'id': 1, 'amount': '600.00000000'},
    );
    expect(p1.amount, '600.00000000');
    final p2 = InvoicePayment.fromJson(const {'id': 2, 'amount_ttc': '120'});
    expect(p2.amount, '120');
  });

  test('type lu depuis type_code puis type (cas réel Dolibarr)', () {
    final p1 = InvoicePayment.fromJson(const {
      'id': 1,
      'type_code': 'VIR',
    });
    expect(p1.type, 'VIR');
    final p2 = InvoicePayment.fromJson(const {
      'id': 2,
      'type': 'VIR',
    });
    expect(p2.type, 'VIR');
  });
}
