import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice_payment.dart';
import 'package:dolibarr_mobile/features/stats/data/repositories/stats_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

Invoice _inv({
  required InvoiceStatus status,
  required DateTime date,
  required String totalTtc,
  String? totalHt,
  int paye = 0,
  int localId = 1,
}) =>
    Invoice(
      localId: localId,
      dateInvoice: date,
      localUpdatedAt: date,
      status: status,
      paye: paye,
      totalTtc: totalTtc,
      totalHt: totalHt,
    );

InvoicePayment _pay({
  required DateTime date,
  required String amount,
  int remoteId = 1,
}) =>
    InvoicePayment(remoteId: remoteId, date: date, amount: amount);

void main() {
  // Référence temporelle figée pour les tests (mai 2026).
  final now = DateTime(2026, 5, 13);

  group('StatsRepositoryImpl.compute — fenêtre mensuelle', () {
    test('snapshot vide produit 12 mois zéro', () {
      final s = StatsRepositoryImpl.compute(
        invoices: const [],
        payments: const [],
        monthWindow: 12,
        now: now,
      );
      expect(s.monthly.length, 12);
      expect(s.currentYear.year, 2026);
      expect(s.previousYear.year, 2025);
      expect(s.currentYear.factureTtc, 0);
      expect(s.previousYear.percu, 0);
      expect(s.maxMonthlyValue, 0);
    });

    test('mois courant = dernier élément, 11 mois antérieurs avant', () {
      final s = StatsRepositoryImpl.compute(
        invoices: const [],
        payments: const [],
        monthWindow: 12,
        now: now,
      );
      expect(s.monthly.last.year, 2026);
      expect(s.monthly.last.month, 5);
      expect(s.monthly.first.year, 2025);
      expect(s.monthly.first.month, 6);
    });

    test(
      "facture validée dans la fenêtre s'ajoute au mois correspondant",
      () {
        final s = StatsRepositoryImpl.compute(
          invoices: [
            _inv(
              status: InvoiceStatus.validated,
              date: DateTime(2026, 3, 15),
              totalTtc: '1200.00',
              totalHt: '1000.00',
            ),
          ],
          payments: const [],
          monthWindow: 12,
          now: now,
        );
        final mars = s.monthly.firstWhere((m) => m.month == 3);
        expect(mars.factureTtc, 1200);
        expect(mars.factureHt, 1000);
        expect(mars.percu, 0);
      },
    );

    test('factures draft ou abandoned sont ignorées', () {
      final s = StatsRepositoryImpl.compute(
        invoices: [
          _inv(
            status: InvoiceStatus.draft,
            date: DateTime(2026, 5),
            totalTtc: '999.00',
          ),
          _inv(
            status: InvoiceStatus.abandoned,
            date: DateTime(2026, 5),
            totalTtc: '999.00',
          ),
        ],
        payments: const [],
        monthWindow: 12,
        now: now,
      );
      expect(s.monthly.last.factureTtc, 0);
      expect(s.currentYear.factureTtc, 0);
    });

    test('facture payée compte dans facturé ET le paiement compte dans perçu',
        () {
      final s = StatsRepositoryImpl.compute(
        invoices: [
          _inv(
            status: InvoiceStatus.paid,
            date: DateTime(2026, 4),
            totalTtc: '500',
            paye: 1,
          ),
        ],
        payments: [
          _pay(date: DateTime(2026, 5, 2), amount: '500'),
        ],
        monthWindow: 12,
        now: now,
      );
      final avril = s.monthly.firstWhere((m) => m.month == 4);
      final mai = s.monthly.firstWhere((m) => m.month == 5);
      expect(avril.factureTtc, 500);
      expect(mai.percu, 500);
      // Le paiement n'inflate PAS le facturé du mois de paiement.
      expect(mai.factureTtc, 0);
    });

    test(
        "facture hors fenêtre n'est pas dans monthly mais peut alimenter "
        'currentYear si même année', () {
      final s = StatsRepositoryImpl.compute(
        invoices: [
          // janv. 2026 — hors fenêtre 12 mois si now=mai 2026
          // (fenêtre = juin 2025 → mai 2026). janvier 2026 EST dans la
          // fenêtre. On teste avec mai 2025 qui doit être DANS la fenêtre
          // (le premier mois). On utilise donc avril 2025 = hors fenêtre.
          _inv(
            status: InvoiceStatus.validated,
            date: DateTime(2025, 4),
            totalTtc: '999',
          ),
        ],
        payments: const [],
        monthWindow: 12,
        now: now,
      );
      // Aucun mois ne devrait porter ce montant.
      for (final m in s.monthly) {
        expect(m.factureTtc, 0);
      }
      // previousYear (2025) doit cumuler le montant.
      expect(s.previousYear.factureTtc, 999);
    });

    test('montants formatés avec virgule décimale sont parsés correctement',
        () {
      final s = StatsRepositoryImpl.compute(
        invoices: [
          _inv(
            status: InvoiceStatus.validated,
            date: DateTime(2026, 5),
            totalTtc: '1234,56',
          ),
        ],
        payments: const [],
        monthWindow: 12,
        now: now,
      );
      expect(s.currentYear.factureTtc, closeTo(1234.56, 0.001));
    });

    test('maxMonthlyValue prend le max entre facturé et perçu sur la fenêtre',
        () {
      final s = StatsRepositoryImpl.compute(
        invoices: [
          _inv(
            status: InvoiceStatus.validated,
            date: DateTime(2026, 4),
            totalTtc: '1000',
          ),
        ],
        payments: [
          _pay(date: DateTime(2026, 5), amount: '2500'),
        ],
        monthWindow: 12,
        now: now,
      );
      expect(s.maxMonthlyValue, 2500);
    });

    test('paiement N-1 cumule sur previousYear sans toucher currentYear', () {
      final s = StatsRepositoryImpl.compute(
        invoices: const [],
        payments: [
          _pay(date: DateTime(2025, 8), amount: '750'),
        ],
        monthWindow: 12,
        now: now,
      );
      expect(s.previousYear.percu, 750);
      expect(s.currentYear.percu, 0);
    });

    test('fenêtre 6 mois — première entrée = now − 5 mois', () {
      final s = StatsRepositoryImpl.compute(
        invoices: const [],
        payments: const [],
        monthWindow: 6,
        now: now,
      );
      expect(s.monthly.length, 6);
      expect(s.monthly.first.month, 12);
      expect(s.monthly.first.year, 2025);
      expect(s.monthly.last.month, 5);
      expect(s.monthly.last.year, 2026);
    });
  });
}
