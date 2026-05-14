// ignore_for_file: one_member_abstracts

import 'package:dolibarr_mobile/features/stats/domain/entities/stats_snapshot.dart';

/// Période d'analyse exposée par le repo statistiques.
///
/// `rolling12` : mois courant + 11 mois antérieurs (vue Stats par défaut).
/// `currentYear` : 1er janvier de l'année courante → mois courant inclus.
/// `allHistory` : du premier mois ayant un mouvement (facture ou paiement)
///   jusqu'au mois courant.
enum StatsPeriod { rolling12, currentYear, allHistory }

abstract interface class StatsRepository {
  /// Stream du snapshot complet, recalculé à chaque mutation locale
  /// des factures ou des paiements.
  Stream<StatsSnapshot> watchSnapshot({
    StatsPeriod period = StatsPeriod.rolling12,
  });
}
