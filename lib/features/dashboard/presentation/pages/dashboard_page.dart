import 'package:dolibarr_mobile/core/routing/route_paths.dart';
import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/features/dashboard/domain/entities/dashboard_metrics.dart';
import 'package:dolibarr_mobile/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:dolibarr_mobile/features/dashboard/presentation/widgets/kpi_card.dart';
import 'package:dolibarr_mobile/shared/widgets/network_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final metricsAsync = ref.watch(dashboardMetricsProvider);
    final activityAsync = ref.watch(dashboardRecentActivityProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref
            ..invalidate(dashboardMetricsProvider)
            ..invalidate(dashboardRecentActivityProvider);
          await Future<void>.delayed(const Duration(milliseconds: 200));
        },
        child: ListView(
          padding: const EdgeInsets.all(AppTokens.spaceMd),
          children: [
            const NetworkBanner(),
            const SizedBox(height: AppTokens.spaceMd),
            metricsAsync.when(
              data: (m) => _MetricsGrid(metrics: m),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text(
                'Indicateurs indisponibles : $e',
                style: theme.textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: AppTokens.spaceLg),
            Text(
              'Actions rapides',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppTokens.spaceXs),
            const _QuickActions(),
            const SizedBox(height: AppTokens.spaceLg),
            Text(
              'Activité récente',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppTokens.spaceXs),
            activityAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(AppTokens.spaceMd),
                    child: Text(
                      'Aucune activité — commence par synchroniser '
                      'tes tiers ou créer un devis.',
                      style: theme.textTheme.bodySmall,
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final item in items) _ActivityTile(item: item),
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: LinearProgressIndicator(),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.metrics});
  final DashboardMetrics metrics;

  @override
  Widget build(BuildContext context) {
    String fmtMontant(double v) =>
        '${v.toStringAsFixed(2).replaceAll('.', ',')} €';
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: AppTokens.spaceXs,
      crossAxisSpacing: AppTokens.spaceXs,
      childAspectRatio: 1.6,
      children: [
        KpiCard(
          title: 'CA mois en cours',
          value: fmtMontant(metrics.caMois),
          icon: LucideIcons.trendingUp,
          color: AppTokens.syncSynced,
          onTap: () => GoRouter.of(context).go(RoutePaths.invoices),
        ),
        KpiCard(
          title: 'Devis en attente',
          value: '${metrics.devisEnAttenteCount}',
          subtitle: 'à signer',
          icon: LucideIcons.fileText,
          color: AppTokens.syncPending,
          onTap: () => GoRouter.of(context).go(RoutePaths.proposals),
        ),
        KpiCard(
          title: 'Factures impayées',
          value: '${metrics.facturesImpayeesCount}',
          subtitle: fmtMontant(metrics.facturesImpayeesMontant),
          icon: LucideIcons.alertTriangle,
          color: AppTokens.syncConflict,
          onTap: () => GoRouter.of(context).go(RoutePaths.invoices),
        ),
        KpiCard(
          title: 'Clients',
          value: '—',
          subtitle: 'voir la liste',
          icon: LucideIcons.briefcase,
          onTap: () => GoRouter.of(context).go(RoutePaths.thirdparties),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppTokens.spaceXs,
      runSpacing: AppTokens.spaceXs,
      children: [
        FilledButton.icon(
          onPressed: () => context.go(RoutePaths.thirdpartyNew),
          icon: const Icon(LucideIcons.userPlus, size: 16),
          label: const Text('Tiers'),
        ),
        FilledButton.tonalIcon(
          onPressed: () => context.go(RoutePaths.proposalNew),
          icon: const Icon(LucideIcons.fileText, size: 16),
          label: const Text('Devis'),
        ),
        FilledButton.tonalIcon(
          onPressed: () => context.go(RoutePaths.invoiceNew),
          icon: const Icon(LucideIcons.receipt, size: 16),
          label: const Text('Facture'),
        ),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.item});
  final RecentActivityItem item;

  @override
  Widget build(BuildContext context) {
    final (icon, route) = _resolveTarget(item);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        leading: Icon(icon),
        title: Text(item.label),
        subtitle: Text(
          [
            if (item.subtitle != null) item.subtitle!,
            _relativeTime(item.updatedAt),
          ].join(' · '),
        ),
        trailing: const Icon(LucideIcons.chevronRight),
        onTap: route == null ? null : () => context.go(route),
      ),
    );
  }

  static (IconData, String?) _resolveTarget(RecentActivityItem i) {
    return switch (i.entityType) {
      'thirdparty' => (
          LucideIcons.briefcase,
          RoutePaths.thirdpartyDetailFor(i.localId),
        ),
      'contact' => (
          LucideIcons.user,
          RoutePaths.contactDetailFor(i.localId),
        ),
      'project' => (
          LucideIcons.folderOpen,
          RoutePaths.projectDetailFor(i.localId),
        ),
      'task' => (
          LucideIcons.listChecks,
          RoutePaths.taskDetailFor(i.localId),
        ),
      'invoice' => (
          LucideIcons.receipt,
          RoutePaths.invoiceDetailFor(i.localId),
        ),
      'proposal' => (
          LucideIcons.fileText,
          RoutePaths.proposalDetailFor(i.localId),
        ),
      _ => (LucideIcons.fileQuestion, null),
    };
  }

  String _relativeTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return "à l'instant";
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
    if (diff.inDays < 30) return 'il y a ${diff.inDays} j';
    return '${t.day.toString().padLeft(2, '0')}/'
        '${t.month.toString().padLeft(2, '0')}/${t.year}';
  }
}
