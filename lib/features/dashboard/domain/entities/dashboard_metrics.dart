import 'package:equatable/equatable.dart';

/// Snapshot des indicateurs commerciaux pour la page d'accueil.
///
/// Calculé à partir du cache local Drift — affichage offline-friendly,
/// pas d'appel réseau direct.
final class DashboardMetrics extends Equatable {
  const DashboardMetrics({
    this.caMois = 0,
    this.facturesMoisCount = 0,
    this.clientsMoisCount = 0,
    this.versementAttenduMontant = 0,
    this.versementAttenduCount = 0,
    this.devisEnAttenteCount = 0,
    this.facturesImpayeesCount = 0,
    this.facturesImpayeesMontant = 0,
  });

  /// Chiffre d'affaires TTC déjà facturé sur le mois en cours
  /// (factures validées + payées, datées dans le mois).
  final double caMois;

  /// Nombre de factures émises sur le mois en cours.
  final int facturesMoisCount;

  /// Nombre de clients distincts facturés sur le mois en cours.
  final int clientsMoisCount;

  /// Montant TTC attendu d'ici la fin du mois en cours, basé sur les
  /// dates d'échéance des factures validées non payées tombant entre
  /// le 1er et le dernier jour du mois courant.
  final double versementAttenduMontant;

  /// Nombre de factures concernées par [versementAttenduMontant].
  final int versementAttenduCount;

  /// Nombre de devis avec statut `validated` (en attente de signature).
  final int devisEnAttenteCount;

  /// Nombre de factures non payées + non abandonnées.
  final int facturesImpayeesCount;

  /// Somme TTC des factures impayées.
  final double facturesImpayeesMontant;

  @override
  List<Object?> get props => [
        caMois,
        facturesMoisCount,
        clientsMoisCount,
        versementAttenduMontant,
        versementAttenduCount,
        devisEnAttenteCount,
        facturesImpayeesCount,
        facturesImpayeesMontant,
      ];
}

/// Activité récente : dernières entités modifiées localement.
final class RecentActivityItem extends Equatable {
  const RecentActivityItem({
    required this.entityType,
    required this.localId,
    required this.label,
    required this.updatedAt,
    this.subtitle,
  });

  /// `thirdparty`, `contact`, `project`, `task`, `invoice`, `proposal`.
  final String entityType;
  final int localId;
  final String label;
  final String? subtitle;
  final DateTime updatedAt;

  @override
  List<Object?> get props =>
      [entityType, localId, label, subtitle, updatedAt];
}
