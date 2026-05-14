import 'package:dolibarr_mobile/features/dashboard/domain/entities/dashboard_details.dart';
import 'package:dolibarr_mobile/features/dashboard/domain/entities/dashboard_metrics.dart';

abstract interface class DashboardRepository {
  /// Stream réactif des KPIs commerciaux. Recalculé à chaque mutation
  /// via les watchers Drift en aval.
  Stream<DashboardMetrics> watchMetrics();

  /// Stream des données détaillées pour les bottom-sheets d'accueil
  /// (listes de factures + comparaisons + répartition hebdomadaire).
  Stream<DashboardDetails> watchDetails();

  /// Stream des N entités les plus récemment modifiées localement.
  Stream<List<RecentActivityItem>> watchRecentActivity({int limit = 10});
}
