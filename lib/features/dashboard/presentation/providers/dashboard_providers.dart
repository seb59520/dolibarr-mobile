import 'package:dolibarr_mobile/features/contacts/presentation/providers/contact_providers.dart';
import 'package:dolibarr_mobile/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:dolibarr_mobile/features/dashboard/domain/entities/dashboard_details.dart';
import 'package:dolibarr_mobile/features/dashboard/domain/entities/dashboard_metrics.dart';
import 'package:dolibarr_mobile/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:dolibarr_mobile/features/invoices/presentation/providers/invoice_providers.dart';
import 'package:dolibarr_mobile/features/projects/presentation/providers/project_providers.dart';
import 'package:dolibarr_mobile/features/proposals/presentation/providers/proposal_providers.dart';
import 'package:dolibarr_mobile/features/stats/domain/entities/stats_snapshot.dart';
import 'package:dolibarr_mobile/features/stats/domain/repositories/stats_repository.dart';
import 'package:dolibarr_mobile/features/stats/presentation/providers/stats_providers.dart';
import 'package:dolibarr_mobile/features/tasks/presentation/providers/task_providers.dart';
import 'package:dolibarr_mobile/features/thirdparties/presentation/providers/third_party_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(
    invoiceDao: ref.watch(invoiceLocalDaoProvider),
    proposalDao: ref.watch(proposalLocalDaoProvider),
    thirdPartyDao: ref.watch(thirdPartyLocalDaoProvider),
    contactDao: ref.watch(contactLocalDaoProvider),
    projectDao: ref.watch(projectLocalDaoProvider),
    taskDao: ref.watch(taskLocalDaoProvider),
  );
});

final dashboardMetricsProvider =
    StreamProvider.autoDispose<DashboardMetrics>((ref) {
  return ref.watch(dashboardRepositoryProvider).watchMetrics();
});

final dashboardDetailsProvider =
    StreamProvider.autoDispose<DashboardDetails>((ref) {
  return ref.watch(dashboardRepositoryProvider).watchDetails();
});

final dashboardRecentActivityProvider =
    StreamProvider.autoDispose<List<RecentActivityItem>>((ref) {
  return ref.watch(dashboardRepositoryProvider).watchRecentActivity();
});

/// Période active de la carte Pilotage (persistée tant que la page vit).
final dashboardPilotagePeriodProvider =
    StateProvider<StatsPeriod>((ref) => StatsPeriod.rolling12);

/// Snapshot agrégé sur la période sélectionnée par l'utilisateur dans
/// la carte Pilotage du dashboard. On suit la valeur du family
/// provider correspondant — la valeur initiale (loading) est propagée
/// telle quelle pour que l'UI affiche l'état approprié.
final dashboardPilotageSnapshotProvider =
    Provider.autoDispose<AsyncValue<StatsSnapshot>>((ref) {
  final period = ref.watch(dashboardPilotagePeriodProvider);
  return ref.watch(statsSnapshotForPeriodProvider(period));
});
