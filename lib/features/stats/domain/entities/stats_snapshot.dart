import 'package:dolibarr_mobile/features/stats/domain/entities/monthly_stat.dart';
import 'package:dolibarr_mobile/features/stats/domain/entities/yearly_stat.dart';
import 'package:equatable/equatable.dart';

/// Snapshot complet exposé à la couche présentation.
///
/// `monthly` est ordonné chronologiquement (du plus ancien au plus
/// récent). Sa longueur correspond à la fenêtre demandée au
/// repository (12 mois par défaut), incluant le mois courant.
final class StatsSnapshot extends Equatable {
  const StatsSnapshot({
    required this.monthly,
    required this.currentYear,
    required this.previousYear,
    this.lastPaymentSync,
  });

  factory StatsSnapshot.empty() => StatsSnapshot(
        monthly: const [],
        currentYear: YearlyStat(year: DateTime.now().year),
        previousYear: YearlyStat(year: DateTime.now().year - 1),
      );

  final List<MonthlyStat> monthly;
  final YearlyStat currentYear;
  final YearlyStat previousYear;
  final DateTime? lastPaymentSync;

  double get maxMonthlyValue {
    var max = 0.0;
    for (final m in monthly) {
      if (m.factureTtc > max) max = m.factureTtc;
      if (m.percu > max) max = m.percu;
    }
    return max;
  }

  @override
  List<Object?> get props => [
        monthly,
        currentYear,
        previousYear,
        lastPaymentSync,
      ];
}
