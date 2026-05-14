import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/core/utils/formatters.dart';
import 'package:dolibarr_mobile/features/stats/domain/entities/monthly_stat.dart';
import 'package:dolibarr_mobile/features/stats/domain/entities/stats_snapshot.dart';
import 'package:dolibarr_mobile/features/stats/domain/entities/yearly_stat.dart';
import 'package:dolibarr_mobile/features/stats/presentation/providers/stats_providers.dart';
import 'package:dolibarr_mobile/features/stats/presentation/widgets/stats_bar_chart.dart';
import 'package:dolibarr_mobile/shared/widgets/app_card.dart';
import 'package:dolibarr_mobile/shared/widgets/kpi_card.dart';
import 'package:dolibarr_mobile/shared/widgets/network_banner.dart';
import 'package:dolibarr_mobile/shared/widgets/shell_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class StatsPage extends ConsumerStatefulWidget {
  const StatsPage({super.key});

  @override
  ConsumerState<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends ConsumerState<StatsPage> {
  bool _syncing = false;

  Future<void> _refresh() async {
    if (_syncing) return;
    setState(() => _syncing = true);
    try {
      final svc = ref.read(paymentSyncServiceProvider);
      final res = await svc.syncRecent();
      if (!mounted) return;
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
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec sync paiements : $e')),
      );
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshotAsync = ref.watch(statsSnapshotProvider);
    final c = DoliMobColors.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: const ShellMenuButton(),
        title: const Text('Statistiques'),
        actions: [
          IconButton(
            tooltip: 'Rafraîchir les paiements',
            onPressed: _syncing ? null : _refresh,
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
        onRefresh: _refresh,
        child: snapshotAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ListView(
            padding: const EdgeInsets.all(AppTokens.spaceMd),
            children: [
              const NetworkBanner(),
              const SizedBox(height: AppTokens.spaceMd),
              Text(
                'Impossible de charger les statistiques : $e',
                style: TextStyle(color: c.danger),
              ),
            ],
          ),
          data: (snapshot) => _StatsBody(snapshot: snapshot),
        ),
      ),
    );
  }
}

class _StatsBody extends StatelessWidget {
  const _StatsBody({required this.snapshot});

  final StatsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final c = DoliMobColors.of(context);
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppTokens.spaceMd),
      children: [
        const NetworkBanner(),
        const SizedBox(height: AppTokens.spaceMd),

        // Bloc Année courante
        Text(
          'Année ${snapshot.currentYear.year}',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppTokens.spaceXs),
        _YearKpis(stat: snapshot.currentYear, accentTone: KpiTone.accent),

        const SizedBox(height: AppTokens.spaceLg),

        // Graphe 12 mois
        Text(
          '12 derniers mois',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppTokens.spaceXxs),
        _Legend(accent: c.accent, success: c.success),
        const SizedBox(height: AppTokens.spaceXs),
        AppCard(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.fromLTRB(8, 14, 14, 10),
          child: StatsBarChart(
            monthly: snapshot.monthly,
            maxValue: snapshot.maxMonthlyValue,
          ),
        ),

        const SizedBox(height: AppTokens.spaceLg),

        // Bloc Année précédente (compaction)
        Text(
          'Année ${snapshot.previousYear.year}',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppTokens.spaceXs),
        _YearKpis(stat: snapshot.previousYear, accentTone: KpiTone.neutral),

        const SizedBox(height: AppTokens.spaceLg),

        // Détail par mois
        Text(
          'Détail par mois',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppTokens.spaceXs),
        AppCard(
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = snapshot.monthly.length - 1; i >= 0; i--)
                _MonthRow(
                  stat: snapshot.monthly[i],
                  isLast: i == 0,
                ),
            ],
          ),
        ),
        const SizedBox(height: AppTokens.spaceLg),
        Text(
          'Le « facturé » agrège les factures validées et payées par '
          'date de facture. Le « perçu » est la somme des paiements '
          'rattachés, par date de règlement. Tire pour rafraîchir les '
          'paiements depuis Dolibarr.',
          style: theme.textTheme.bodySmall?.copyWith(color: c.ink2),
        ),
      ],
    );
  }
}

class _YearKpis extends StatelessWidget {
  const _YearKpis({required this.stat, required this.accentTone});
  final YearlyStat stat;
  final KpiTone accentTone;

  @override
  Widget build(BuildContext context) {
    final solde = stat.factureTtc - stat.percu;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: AppTokens.spaceXs,
      crossAxisSpacing: AppTokens.spaceXs,
      childAspectRatio: 1.45,
      children: [
        KpiCard(
          label: 'Facturé TTC',
          value: formatMoney(stat.factureTtc),
          hint: 'HT : ${formatMoney(stat.factureHt)}',
          icon: LucideIcons.receipt,
          tone: accentTone,
        ),
        KpiCard(
          label: 'Perçu',
          value: formatMoney(stat.percu),
          icon: LucideIcons.banknote,
          tone: KpiTone.success,
        ),
        KpiCard(
          label: 'Reste à encaisser',
          value: formatMoney(solde),
          icon: LucideIcons.alertTriangle,
          tone: solde > 0 ? KpiTone.danger : KpiTone.neutral,
        ),
        KpiCard(
          label: 'Taux de recouvrement',
          value: stat.factureTtc <= 0
              ? '—'
              : '${(stat.percu / stat.factureTtc * 100).toStringAsFixed(0)} %',
          icon: LucideIcons.percent,
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.accent, required this.success});
  final Color accent;
  final Color success;

  @override
  Widget build(BuildContext context) {
    final c = DoliMobColors.of(context);
    return Row(
      children: [
        _LegendDot(color: accent, label: 'Facturé', textColor: c.ink2),
        const SizedBox(width: 12),
        _LegendDot(color: success, label: 'Perçu', textColor: c.ink2),
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

class _MonthRow extends StatelessWidget {
  const _MonthRow({required this.stat, required this.isLast});
  final MonthlyStat stat;
  final bool isLast;

  static const _names = [
    'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
    'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
  ];

  @override
  Widget build(BuildContext context) {
    final c = DoliMobColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: c.hairline2)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Text(
              '${_names[stat.month - 1]} ${stat.year}',
              style: TextStyle(color: c.ink2, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              formatMoney(stat.factureTtc),
              textAlign: TextAlign.end,
              style: TextStyle(
                color: c.accent,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              formatMoney(stat.percu),
              textAlign: TextAlign.end,
              style: TextStyle(
                color: c.success,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
