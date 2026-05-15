import 'package:dolibarr_mobile/core/routing/route_paths.dart';
import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/core/utils/formatters.dart';
import 'package:dolibarr_mobile/features/dashboard/domain/entities/dashboard_metrics.dart';
import 'package:dolibarr_mobile/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:dolibarr_mobile/features/dashboard/presentation/widgets/dashboard_detail_sheets.dart';
import 'package:dolibarr_mobile/features/dashboard/presentation/widgets/trend_combo_chart.dart';
import 'package:dolibarr_mobile/features/stats/domain/entities/stats_snapshot.dart';
import 'package:dolibarr_mobile/features/stats/domain/entities/yearly_stat.dart';
import 'package:dolibarr_mobile/features/stats/domain/repositories/stats_repository.dart';
import 'package:dolibarr_mobile/features/stats/presentation/providers/stats_providers.dart';
import 'package:dolibarr_mobile/shared/widgets/app_card.dart';
import 'package:dolibarr_mobile/shared/widgets/network_banner.dart';
import 'package:dolibarr_mobile/shared/widgets/shell_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    // Première ouverture : on tente de pré-charger les paiements
    // depuis Dolibarr pour que la courbe « perçu » se peuple sans
    // que l'utilisateur ait à tirer pour rafraîchir.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncPayments(silent: true);
    });
  }

  Future<void> _syncPayments({bool silent = false}) async {
    if (_syncing) return;
    setState(() => _syncing = true);
    try {
      final res = await ref.read(paymentSyncServiceProvider).syncRecent();
      if (!mounted) return;
      ref
        ..invalidate(dashboardMetricsProvider)
        ..invalidate(dashboardRecentActivityProvider)
        ..invalidate(statsSnapshotForPeriodProvider);
      if (!silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 3),
            content: Text(
              res.hasErrors
                  ? '${res.paymentsUpserted} paiements synchronisés — '
                      '${res.errors.first}'
                  : '${res.paymentsUpserted} paiements synchronisés sur '
                      '${res.invoicesScanned} factures',
            ),
          ),
        );
      }
    } on Exception catch (e) {
      if (!mounted || silent) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec sync paiements : $e')),
      );
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const ShellMenuButton(),
        title: const Text(
          'Pilotage',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Synchroniser les paiements Dolibarr',
            onPressed: _syncing ? null : _syncPayments,
            icon: _syncing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(LucideIcons.refreshCcw, size: 18),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _syncPayments(),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppTokens.spaceMd),
          children: const [
            NetworkBanner(),
            SizedBox(height: AppTokens.spaceXs),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppTokens.spaceMd),
              child: _PilotageCard(),
            ),
            SizedBox(height: AppTokens.spaceLg),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppTokens.spaceMd),
              child: _QuickActionsSection(),
            ),
            SizedBox(height: AppTokens.spaceLg),
            _RecentActivitySection(),
            SizedBox(height: AppTokens.spaceLg),
          ],
        ),
      ),
    );
  }
}

const List<String> _kFrenchMonths = [
  'janvier',
  'février',
  'mars',
  'avril',
  'mai',
  'juin',
  'juillet',
  'août',
  'septembre',
  'octobre',
  'novembre',
  'décembre',
];

String _monthLabel(DateTime now) =>
    '${_kFrenchMonths[now.month - 1]} ${now.year}';

String _activityCountLabel(int n) {
  if (n == 0) return 'aucun mouvement';
  return '$n ${n > 1 ? "éléments" : "élément"}';
}

/// Carte hero « Pilotage » :
/// - sélecteur de période (12 mois / année civile / complet)
/// - courbe combo facturé+perçu
/// - 4 KPIs sur la période
/// - 2 rangs temps réel : CA du mois en cours + versement attendu
class _PilotageCard extends ConsumerWidget {
  const _PilotageCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = DoliMobColors.of(context);
    final period = ref.watch(dashboardPilotagePeriodProvider);
    final snapshotAsync = ref.watch(dashboardPilotageSnapshotProvider);
    final metricsAsync = ref.watch(dashboardMetricsProvider);

    return AppCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Icon(LucideIcons.gauge, size: 18, color: c.accent),
                const SizedBox(width: 8),
                Text(
                  'PILOTAGE',
                  style: TextStyle(
                    color: c.ink3,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: _PeriodChips(active: period),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
            child: _Legend(accent: c.accent, percu: c.revenue),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 14, 10),
            child: snapshotAsync.when(
              loading: () => const SizedBox(
                height: 240,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SizedBox(
                height: 240,
                child: Center(
                  child: Text(
                    'Indicateurs indisponibles',
                    style: TextStyle(color: c.ink2, fontSize: 12),
                  ),
                ),
              ),
              data: (snap) => TrendComboChart(
                monthly: snap.monthly,
                maxValue: snap.maxMonthlyValue,
              ),
            ),
          ),
          Container(height: 1, color: c.hairline2),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: snapshotAsync.when(
              loading: () => const SizedBox(
                height: 96,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const SizedBox(height: 8),
              data: (snap) {
                final agg = _aggregateForPeriod(snap, period);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _KpiRow(
                      stat: agg,
                      periodLabel: _periodSubtitle(period, snap),
                    ),
                    if (agg.factureTtc > 0 && agg.percu == 0) ...[
                      const SizedBox(height: 10),
                      _PercuHint(),
                    ],
                  ],
                );
              },
            ),
          ),
          Container(height: 1, color: c.hairline2),
          metricsAsync.when(
            data: (m) => _RealtimeRows(metrics: m),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  static YearlyStat _aggregateForPeriod(
    StatsSnapshot snap,
    StatsPeriod period,
  ) {
    if (period == StatsPeriod.currentYear) return snap.currentYear;
    var ht = 0.0;
    var ttc = 0.0;
    var percu = 0.0;
    for (final m in snap.monthly) {
      ht += m.factureHt;
      ttc += m.factureTtc;
      percu += m.percu;
    }
    return YearlyStat(
      year: DateTime.now().year,
      factureHt: ht,
      factureTtc: ttc,
      percu: percu,
    );
  }

  static String _periodSubtitle(StatsPeriod p, StatsSnapshot snap) {
    switch (p) {
      case StatsPeriod.rolling12:
        return '12 derniers mois';
      case StatsPeriod.currentYear:
        return 'Année ${snap.currentYear.year}';
      case StatsPeriod.allHistory:
        if (snap.monthly.isEmpty) return 'Depuis le début';
        final first = snap.monthly.first;
        return 'Depuis ${_kFrenchMonths[first.month - 1]} ${first.year}';
    }
  }
}

class _PeriodChips extends ConsumerWidget {
  const _PeriodChips({required this.active});
  final StatsPeriod active;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: _Chip(
            label: '12 mois',
            selected: active == StatsPeriod.rolling12,
            onTap: () => ref
                .read(dashboardPilotagePeriodProvider.notifier)
                .state = StatsPeriod.rolling12,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _Chip(
            label: 'Année',
            selected: active == StatsPeriod.currentYear,
            onTap: () => ref
                .read(dashboardPilotagePeriodProvider.notifier)
                .state = StatsPeriod.currentYear,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _Chip(
            label: 'Complet',
            selected: active == StatsPeriod.allHistory,
            onTap: () => ref
                .read(dashboardPilotagePeriodProvider.notifier)
                .state = StatsPeriod.allHistory,
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = DoliMobColors.of(context);
    return Material(
      color: selected ? c.accent : c.fill,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : c.ink2,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.accent, required this.percu});
  final Color accent;
  final Color percu;

  @override
  Widget build(BuildContext context) {
    final c = DoliMobColors.of(context);
    return Row(
      children: [
        _LegendDot(color: accent, label: 'Facturé', textColor: c.ink2),
        const SizedBox(width: 12),
        _LegendDot(color: percu, label: 'Perçu', textColor: c.ink2),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
    required this.textColor,
  });
  final Color color;
  final String label;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(color: textColor, fontSize: 12)),
      ],
    );
  }
}

/// Bandeau d'aide quand le perçu reste à zéro alors qu'il y a du
/// facturé : invite à tirer pour synchroniser les paiements depuis
/// Dolibarr (la sync se déclenche dans le RefreshIndicator).
class _PercuHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = DoliMobColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: c.warning.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.warning.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.refreshCw, size: 14, color: c.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Perçu à 0 — appuie sur ⟳ en haut pour synchroniser '
              'les paiements depuis Dolibarr.',
              style: TextStyle(color: c.ink2, fontSize: 11.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiRow extends StatelessWidget {
  const _KpiRow({required this.stat, required this.periodLabel});
  final YearlyStat stat;
  final String periodLabel;

  @override
  Widget build(BuildContext context) {
    final c = DoliMobColors.of(context);
    final solde = stat.factureTtc - stat.percu;
    final taux = stat.factureTtc <= 0
        ? '—'
        : '${(stat.percu / stat.factureTtc * 100).toStringAsFixed(0)} %';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          periodLabel.toUpperCase(),
          style: TextStyle(
            color: c.ink3,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _KpiCell(
                label: 'Facturé',
                value: formatMoney(stat.factureTtc),
                tone: c.accent,
                icon: LucideIcons.receipt,
              ),
            ),
            Container(width: 1, height: 36, color: c.hairline2),
            Expanded(
              child: _KpiCell(
                label: 'Perçu',
                value: formatMoney(stat.percu),
                tone: c.revenue,
                icon: LucideIcons.banknote,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _KpiCell(
                label: 'Reste',
                value: formatMoney(solde),
                tone: solde > 0 ? c.danger : c.ink2,
                icon: LucideIcons.alertTriangle,
              ),
            ),
            Container(width: 1, height: 36, color: c.hairline2),
            Expanded(
              child: _KpiCell(
                label: 'Recouvrement',
                value: taux,
                tone: c.ink,
                icon: LucideIcons.percent,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _KpiCell extends StatelessWidget {
  const _KpiCell({
    required this.label,
    required this.value,
    required this.tone,
    required this.icon,
  });
  final String label;
  final String value;
  final Color tone;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final c = DoliMobColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: tone),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(color: c.ink2, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: tone,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// Trois lignes temps réel : CA du mois courant + versement attendu fin
/// de mois + factures en retard. Tap → bottom sheet détail.
class _RealtimeRows extends ConsumerWidget {
  const _RealtimeRows({required this.metrics});
  final DashboardMetrics metrics;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = DoliMobColors.of(context);
    final now = DateTime.now();
    final hasPending = metrics.versementAttenduCount > 0;
    final pendingColor = hasPending ? c.accent : c.ink3;
    final detailsAsync = ref.watch(dashboardDetailsProvider);
    final overdueCount = detailsAsync.maybeWhen(
      data: (d) => d.facturesEnRetardCount,
      orElse: () => 0,
    );
    final overdueMontant = detailsAsync.maybeWhen(
      data: (d) => d.facturesEnRetardMontant,
      orElse: () => 0.0,
    );
    final hasOverdue = overdueCount > 0;
    final overdueColor = hasOverdue ? c.danger : c.ink3;

    return Column(
      children: [
        _RealtimeRow(
          icon: LucideIcons.trendingUp,
          tone: c.accent,
          title: 'CA ${_monthLabel(now)}',
          subtitle: _facturesLabel(metrics),
          value: formatMoney(metrics.caMois),
          onTap: () => showMonthRevenueDetailSheet(context, metrics: metrics),
        ),
        Container(height: 1, color: c.hairline2),
        _RealtimeRow(
          icon: LucideIcons.calendarClock,
          tone: pendingColor,
          title: 'Versement attendu fin ${_kFrenchMonths[now.month - 1]}',
          subtitle: hasPending
              ? _pendingLabel(metrics.versementAttenduCount)
              : 'aucune échéance ce mois',
          value: hasPending
              ? formatMoney(metrics.versementAttenduMontant)
              : '—',
          onTap: () => showMonthDueDetailSheet(context, metrics: metrics),
        ),
        Container(height: 1, color: c.hairline2),
        _RealtimeRow(
          icon: LucideIcons.alertTriangle,
          tone: overdueColor,
          title: 'Factures en retard',
          subtitle: hasOverdue
              ? _overdueLabel(overdueCount)
              : 'aucun impayé en retard',
          value: hasOverdue ? formatMoney(overdueMontant) : '—',
          onTap: () => showOverdueDetailSheet(context),
        ),
      ],
    );
  }

  String _facturesLabel(DashboardMetrics m) {
    final f = m.facturesMoisCount;
    final cli = m.clientsMoisCount;
    final factures = '$f ${f > 1 ? "factures" : "facture"}';
    final clients = '$cli ${cli > 1 ? "clients" : "client"}';
    return '$factures · $clients';
  }

  String _pendingLabel(int count) {
    final noun = count > 1 ? 'factures' : 'facture';
    return '$count $noun à échéance';
  }

  String _overdueLabel(int count) {
    final noun = count > 1 ? 'factures échues' : 'facture échue';
    return '$count $noun';
  }
}

class _RealtimeRow extends StatelessWidget {
  const _RealtimeRow({
    required this.icon,
    required this.tone,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onTap,
  });
  final IconData icon;
  final Color tone;
  final String title;
  final String subtitle;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = DoliMobColors.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: tone.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 18, color: tone),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: c.ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: c.ink2, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                color: tone,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            Icon(LucideIcons.chevronRight, size: 16, color: c.ink3),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Actions rapides', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppTokens.spaceXs),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => context.go(RoutePaths.thirdpartyNew),
                icon: const Icon(LucideIcons.userPlus, size: 16),
                label: const Text('Tiers'),
              ),
            ),
            const SizedBox(width: AppTokens.spaceXs),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: () => context.go(RoutePaths.proposalNew),
                icon: const Icon(LucideIcons.fileText, size: 16),
                label: const Text('Devis'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTokens.spaceXs),
        Row(
          children: [
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: () => context.go(RoutePaths.invoiceNew),
                icon: const Icon(LucideIcons.receipt, size: 16),
                label: const Text('Facture'),
              ),
            ),
            const SizedBox(width: AppTokens.spaceXs),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: () => context.go(RoutePaths.projectNew),
                icon: const Icon(LucideIcons.folderPlus, size: 16),
                label: const Text('Projet'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RecentActivitySection extends ConsumerWidget {
  const _RecentActivitySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(dashboardRecentActivityProvider);
    final c = DoliMobColors.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.spaceMd),
      child: AppCard(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        child: Theme(
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.fromLTRB(16, 4, 12, 4),
            childrenPadding: EdgeInsets.zero,
            leading: Icon(LucideIcons.history, size: 18, color: c.ink2),
            title: Text(
              'Activité récente',
              style: theme.textTheme.titleSmall,
            ),
            subtitle: activityAsync.maybeWhen(
              data: (items) => Text(
                _activityCountLabel(items.length),
                style: TextStyle(color: c.ink3, fontSize: 11),
              ),
              orElse: () => null,
            ),
            children: [
              activityAsync.when(
                data: (items) {
                  if (items.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      child: Text(
                        'Aucune activité — commence par synchroniser '
                        'tes tiers ou créer un devis.',
                        style: theme.textTheme.bodySmall,
                      ),
                    );
                  }
                  return Column(
                    children: [
                      for (var i = 0; i < items.length; i++)
                        _ActivityRow(
                          item: items[i],
                          isLast: i == items.length - 1,
                        ),
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
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.item, required this.isLast});
  final RecentActivityItem item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final c = DoliMobColors.of(context);
    final (icon, route) = _resolveTarget(item);
    return InkWell(
      onTap: route == null ? null : () => context.go(route),
      child: Container(
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(bottom: BorderSide(color: c.hairline2)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: c.ink2),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.label,
                    style: TextStyle(
                      color: c.ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    [
                      if (item.subtitle != null) item.subtitle!,
                      _relativeTime(item.updatedAt),
                    ].join(' · '),
                    style: TextStyle(color: c.ink3, fontSize: 11),
                  ),
                ],
              ),
            ),
            if (route != null)
              Icon(LucideIcons.chevronRight, size: 16, color: c.ink3),
          ],
        ),
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
