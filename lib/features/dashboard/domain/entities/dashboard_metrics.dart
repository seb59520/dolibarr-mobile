import 'package:equatable/equatable.dart';

/// Snapshot des indicateurs commerciaux pour la page d'accueil.
///
/// Calculé à partir du cache local Drift — affichage offline-friendly,
/// pas d'appel réseau direct.
final class DashboardMetrics extends Equatable {
  const DashboardMetrics({
    this.caMois = 0,
    this.devisEnAttenteCount = 0,
    this.facturesImpayeesCount = 0,
    this.facturesImpayeesMontant = 0,
  });

  /// Chiffre d'affaires TTC du mois en cours (factures validées).
  final double caMois;

  /// Nombre de devis avec statut `validated` (en attente de signature).
  final int devisEnAttenteCount;

  /// Nombre de factures non payées + non abandonnées.
  final int facturesImpayeesCount;

  /// Somme TTC des factures impayées.
  final double facturesImpayeesMontant;

  @override
  List<Object?> get props => [
        caMois,
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
