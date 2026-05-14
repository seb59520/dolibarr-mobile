import 'package:dolibarr_mobile/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice.dart';
import 'package:dolibarr_mobile/features/proposals/domain/entities/proposal.dart';
import 'package:flutter_test/flutter_test.dart';

Invoice _inv(
  int localId, {
  required InvoiceStatus status,
  required String totalTtc,
  DateTime? dateInvoice,
  DateTime? dateDue,
  int paye = 0,
  int? socidLocal,
  int? socidRemote,
}) =>
    Invoice(
      localId: localId,
      localUpdatedAt: dateInvoice ?? DateTime(2026, 5),
      status: status,
      paye: paye,
      dateInvoice: dateInvoice,
      dateDue: dateDue,
      totalTtc: totalTtc,
      socidLocal: socidLocal,
      socidRemote: socidRemote,
    );

Proposal _prop(int localId, ProposalStatus status) => Proposal(
      localId: localId,
      localUpdatedAt: DateTime(2026, 5),
      status: status,
    );

void main() {
  // Référence : 14 mai 2026 — mois courant = mai 2026.
  final now = DateTime(2026, 5, 14);

  group('DashboardRepositoryImpl.compute — CA du mois', () {
    test('snapshot vide produit zéros partout', () {
      final m = DashboardRepositoryImpl.compute(
        invoices: const [],
        proposals: const [],
        now: now,
      );
      expect(m.caMois, 0);
      expect(m.facturesMoisCount, 0);
      expect(m.clientsMoisCount, 0);
      expect(m.versementAttenduMontant, 0);
      expect(m.versementAttenduCount, 0);
      expect(m.facturesImpayeesCount, 0);
    });

    test('agrège CA + factures + clients distincts du mois', () {
      final m = DashboardRepositoryImpl.compute(
        invoices: [
          _inv(
            1,
            status: InvoiceStatus.validated,
            dateInvoice: DateTime(2026, 5, 3),
            totalTtc: '1000.00',
            socidLocal: 10,
          ),
          _inv(
            2,
            status: InvoiceStatus.paid,
            paye: 1,
            dateInvoice: DateTime(2026, 5, 10),
            totalTtc: '500.50',
            socidLocal: 10,
          ),
          _inv(
            3,
            status: InvoiceStatus.validated,
            dateInvoice: DateTime(2026, 5, 12),
            totalTtc: '250.00',
            socidLocal: 11,
          ),
          // Brouillon dans le mois → ignoré.
          _inv(
            4,
            status: InvoiceStatus.draft,
            dateInvoice: DateTime(2026, 5, 5),
            totalTtc: '999.00',
            socidLocal: 12,
          ),
          // Mois précédent → ignoré.
          _inv(
            5,
            status: InvoiceStatus.validated,
            dateInvoice: DateTime(2026, 4, 30),
            totalTtc: '700.00',
            socidLocal: 13,
          ),
        ],
        proposals: const [],
        now: now,
      );
      expect(m.caMois, closeTo(1750.50, 0.001));
      expect(m.facturesMoisCount, 3);
      // 2 clients distincts (10 apparaît 2x, 11 une fois).
      expect(m.clientsMoisCount, 2);
    });

    test('clients comptés via socidRemote si socidLocal absent', () {
      final m = DashboardRepositoryImpl.compute(
        invoices: [
          _inv(
            1,
            status: InvoiceStatus.validated,
            dateInvoice: DateTime(2026, 5, 3),
            totalTtc: '100',
            socidRemote: 42,
          ),
          _inv(
            2,
            status: InvoiceStatus.validated,
            dateInvoice: DateTime(2026, 5, 4),
            totalTtc: '100',
            socidRemote: 42,
          ),
          _inv(
            3,
            status: InvoiceStatus.validated,
            dateInvoice: DateTime(2026, 5, 5),
            totalTtc: '100',
            socidLocal: 7,
          ),
        ],
        proposals: const [],
        now: now,
      );
      expect(m.facturesMoisCount, 3);
      expect(m.clientsMoisCount, 2);
    });

    test('borne haute exclusive : 1er du mois suivant exclu', () {
      final m = DashboardRepositoryImpl.compute(
        invoices: [
          _inv(
            1,
            status: InvoiceStatus.validated,
            dateInvoice: DateTime(2026, 6),
            totalTtc: '100',
            socidLocal: 1,
          ),
        ],
        proposals: const [],
        now: now,
      );
      expect(m.caMois, 0);
      expect(m.facturesMoisCount, 0);
    });
  });

  group('DashboardRepositoryImpl.compute — versement attendu fin de mois',
      () {
    test('somme uniquement validated + paye=0 + dateDue dans le mois', () {
      final m = DashboardRepositoryImpl.compute(
        invoices: [
          // Échéance dans le mois courant → inclus.
          _inv(
            1,
            status: InvoiceStatus.validated,
            dateInvoice: DateTime(2026, 4, 15),
            dateDue: DateTime(2026, 5, 20),
            totalTtc: '500.00',
            socidLocal: 1,
          ),
          // Échéance dans le mois courant → inclus.
          _inv(
            2,
            status: InvoiceStatus.validated,
            dateInvoice: DateTime(2026, 5),
            dateDue: DateTime(2026, 5, 31),
            totalTtc: '300.00',
            socidLocal: 2,
          ),
          // Échéance le mois suivant → exclus.
          _inv(
            3,
            status: InvoiceStatus.validated,
            dateInvoice: DateTime(2026, 5),
            dateDue: DateTime(2026, 6, 5),
            totalTtc: '999.00',
            socidLocal: 3,
          ),
          // Échéance dans le mois mais déjà payée → exclus.
          _inv(
            4,
            status: InvoiceStatus.paid,
            paye: 1,
            dateInvoice: DateTime(2026, 4, 15),
            dateDue: DateTime(2026, 5, 10),
            totalTtc: '200.00',
            socidLocal: 4,
          ),
          // Échéance mois antérieur (retard) → exclus.
          _inv(
            5,
            status: InvoiceStatus.validated,
            dateInvoice: DateTime(2026, 3),
            dateDue: DateTime(2026, 4),
            totalTtc: '700.00',
            socidLocal: 5,
          ),
          // Brouillon → exclus.
          _inv(
            6,
            status: InvoiceStatus.draft,
            dateDue: DateTime(2026, 5, 15),
            totalTtc: '999.00',
            socidLocal: 6,
          ),
        ],
        proposals: const [],
        now: now,
      );
      expect(m.versementAttenduMontant, closeTo(800.00, 0.001));
      expect(m.versementAttenduCount, 2);
    });

    test('dateDue null → exclus', () {
      final m = DashboardRepositoryImpl.compute(
        invoices: [
          _inv(
            1,
            status: InvoiceStatus.validated,
            dateInvoice: DateTime(2026, 5),
            totalTtc: '500.00',
          ),
        ],
        proposals: const [],
        now: now,
      );
      expect(m.versementAttenduMontant, 0);
      expect(m.versementAttenduCount, 0);
    });
  });

  group('DashboardRepositoryImpl.computeDetails', () {
    test('comparaison mois précédent : agrège uniquement avril 2026', () {
      final d = DashboardRepositoryImpl.computeDetails(
        invoices: [
          // Mois courant (mai) → ne doit PAS contribuer à caMoisPrev.
          _inv(
            1,
            status: InvoiceStatus.validated,
            dateInvoice: DateTime(2026, 5),
            totalTtc: '100',
          ),
          // Mois précédent (avril).
          _inv(
            2,
            status: InvoiceStatus.validated,
            dateInvoice: DateTime(2026, 4, 10),
            totalTtc: '300.50',
          ),
          _inv(
            3,
            status: InvoiceStatus.paid,
            paye: 1,
            dateInvoice: DateTime(2026, 4, 25),
            totalTtc: '200.00',
          ),
          // Mars → ignoré.
          _inv(
            4,
            status: InvoiceStatus.validated,
            dateInvoice: DateTime(2026, 3, 15),
            totalTtc: '999.00',
          ),
        ],
        now: now,
      );
      expect(d.caMoisPrev, closeTo(500.50, 0.001));
      expect(d.facturesMoisPrevCount, 2);
    });

    test('invoicesMois triées par dateInvoice décroissante', () {
      final d = DashboardRepositoryImpl.computeDetails(
        invoices: [
          _inv(
            1,
            status: InvoiceStatus.validated,
            dateInvoice: DateTime(2026, 5, 3),
            totalTtc: '100',
          ),
          _inv(
            2,
            status: InvoiceStatus.validated,
            dateInvoice: DateTime(2026, 5, 12),
            totalTtc: '200',
          ),
          _inv(
            3,
            status: InvoiceStatus.validated,
            dateInvoice: DateTime(2026, 5, 7),
            totalTtc: '150',
          ),
        ],
        now: now,
      );
      expect(d.invoicesMois.map((i) => i.localId).toList(), [2, 3, 1]);
    });

    test('factures en retard : dateDue strictement < firstOfMonth', () {
      final d = DashboardRepositoryImpl.computeDetails(
        invoices: [
          // Échéance avril → en retard.
          _inv(
            1,
            status: InvoiceStatus.validated,
            dateInvoice: DateTime(2026, 3),
            dateDue: DateTime(2026, 4, 20),
            totalTtc: '500',
          ),
          // Échéance 30 avril → en retard.
          _inv(
            2,
            status: InvoiceStatus.validated,
            dateInvoice: DateTime(2026, 3),
            dateDue: DateTime(2026, 4, 30),
            totalTtc: '700',
          ),
          // Échéance 1er mai → c'est dans le mois courant → pas un retard.
          _inv(
            3,
            status: InvoiceStatus.validated,
            dateInvoice: DateTime(2026, 4),
            dateDue: DateTime(2026, 5),
            totalTtc: '999',
          ),
          // Payée → ignorée.
          _inv(
            4,
            status: InvoiceStatus.paid,
            paye: 1,
            dateInvoice: DateTime(2026, 3),
            dateDue: DateTime(2026, 4, 10),
            totalTtc: '999',
          ),
        ],
        now: now,
      );
      expect(d.facturesEnRetardCount, 2);
      expect(d.facturesEnRetardMontant, closeTo(1200, 0.001));
      expect(d.invoicesEnRetard.map((i) => i.localId).toList(), [1, 2]);
    });

    test('weekly buckets : 1-7 / 8-14 / 15-21 / 22-fin', () {
      final d = DashboardRepositoryImpl.computeDetails(
        invoices: [
          _inv(
            1,
            status: InvoiceStatus.validated,
            dateInvoice: DateTime(2026, 5),
            dateDue: DateTime(2026, 5, 3),
            totalTtc: '100',
          ),
          _inv(
            2,
            status: InvoiceStatus.validated,
            dateInvoice: DateTime(2026, 5),
            dateDue: DateTime(2026, 5, 7),
            totalTtc: '50',
          ),
          _inv(
            3,
            status: InvoiceStatus.validated,
            dateInvoice: DateTime(2026, 5),
            dateDue: DateTime(2026, 5, 8),
            totalTtc: '200',
          ),
          _inv(
            4,
            status: InvoiceStatus.validated,
            dateInvoice: DateTime(2026, 5),
            dateDue: DateTime(2026, 5, 21),
            totalTtc: '300',
          ),
          _inv(
            5,
            status: InvoiceStatus.validated,
            dateInvoice: DateTime(2026, 5),
            dateDue: DateTime(2026, 5, 30),
            totalTtc: '400',
          ),
        ],
        now: now,
      );
      expect(d.weeklyDueMontant, [150.0, 200.0, 300.0, 400.0]);
      expect(d.weeklyDueCount, [2, 1, 1, 1]);
    });

    test('invoicesDueMois triées par dateDue croissante', () {
      final d = DashboardRepositoryImpl.computeDetails(
        invoices: [
          _inv(
            1,
            status: InvoiceStatus.validated,
            dateInvoice: DateTime(2026, 5),
            dateDue: DateTime(2026, 5, 25),
            totalTtc: '100',
          ),
          _inv(
            2,
            status: InvoiceStatus.validated,
            dateInvoice: DateTime(2026, 5),
            dateDue: DateTime(2026, 5, 10),
            totalTtc: '100',
          ),
        ],
        now: now,
      );
      expect(d.invoicesDueMois.map((i) => i.localId).toList(), [2, 1]);
    });
  });

  test('devisEnAttenteCount = nb propositions validated', () {
    final m = DashboardRepositoryImpl.compute(
      invoices: const [],
      proposals: [
        _prop(1, ProposalStatus.validated),
        _prop(2, ProposalStatus.validated),
        _prop(3, ProposalStatus.draft),
      ],
      now: now,
    );
    expect(m.devisEnAttenteCount, 2);
  });
}
