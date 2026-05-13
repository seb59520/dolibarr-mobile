// ignore_for_file: one_member_abstracts

import 'package:dolibarr_mobile/features/stats/domain/entities/stats_snapshot.dart';

abstract interface class StatsRepository {
  /// Stream du snapshot complet, recalculé à chaque mutation locale
  /// des factures ou des paiements.
  ///
  /// [monthWindow] = nombre de mois inclus dans `monthly`. 12 par
  /// défaut (mois courant + 11 mois antérieurs).
  Stream<StatsSnapshot> watchSnapshot({int monthWindow = 12});
}
