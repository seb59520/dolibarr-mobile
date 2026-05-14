import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice.dart';
import 'package:equatable/equatable.dart';

/// Données détaillées affichées dans les bottom-sheets de l'accueil.
///
/// Complète [`DashboardMetrics`] : les tuiles gardent les KPI agrégés,
/// les sheets affichent les listes et la comparaison historique.
final class DashboardDetails extends Equatable {
  const DashboardDetails({
    this.caMoisPrev = 0,
    this.facturesMoisPrevCount = 0,
    this.invoicesMois = const [],
    this.invoicesDueMois = const [],
    this.invoicesEnRetard = const [],
    this.facturesEnRetardMontant = 0,
    this.weeklyDueMontant = const [0, 0, 0, 0],
    this.weeklyDueCount = const [0, 0, 0, 0],
  });

  /// CA TTC du mois précédent (factures validées + payées).
  final double caMoisPrev;

  /// Nombre de factures émises sur le mois précédent.
  final int facturesMoisPrevCount;

  /// Factures émises sur le mois courant (validées + payées), triées
  /// par `dateInvoice` décroissante.
  final List<Invoice> invoicesMois;

  /// Factures validées non payées dont l'échéance tombe dans le mois
  /// courant, triées par `dateDue` croissante.
  final List<Invoice> invoicesDueMois;

  /// Factures validées non payées dont l'échéance est strictement
  /// antérieure au 1er du mois courant — les retards.
  final List<Invoice> invoicesEnRetard;

  /// Somme TTC des factures en retard.
  final double facturesEnRetardMontant;

  /// Répartition hebdomadaire des échéances du mois (4 buckets) :
  ///   S1 = jours 1..7, S2 = 8..14, S3 = 15..21, S4 = 22..fin.
  /// Montants TTC.
  final List<double> weeklyDueMontant;

  /// Nombre de factures par bucket hebdomadaire (mêmes index).
  final List<int> weeklyDueCount;

  /// Nombre de factures en retard.
  int get facturesEnRetardCount => invoicesEnRetard.length;

  @override
  List<Object?> get props => [
        caMoisPrev,
        facturesMoisPrevCount,
        invoicesMois,
        invoicesDueMois,
        invoicesEnRetard,
        facturesEnRetardMontant,
        weeklyDueMontant,
        weeklyDueCount,
      ];
}
