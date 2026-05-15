import 'package:dolibarr_mobile/core/routing/route_paths.dart';
import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/core/utils/formatters.dart';
import 'package:dolibarr_mobile/features/dashboard/domain/entities/dashboard_details.dart';
import 'package:dolibarr_mobile/features/dashboard/domain/entities/dashboard_metrics.dart';
import 'package:dolibarr_mobile/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice.dart';
import 'package:dolibarr_mobile/features/thirdparties/presentation/providers/third_party_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

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

String _fmtDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/'
    '${d.month.toString().padLeft(2, '0')}/${d.year}';

Future<void> showMonthRevenueDetailSheet(
  BuildContext context, {
  required DashboardMetrics metrics,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (ctx) => _sheetFrame(
      ctx,
      child: MonthRevenueDetailSheet(metrics: metrics),
    ),
  );
}

Future<void> showMonthDueDetailSheet(
  BuildContext context, {
  required DashboardMetrics metrics,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (ctx) => _sheetFrame(
      ctx,
      child: MonthDueDetailSheet(metrics: metrics),
    ),
  );
}

Future<void> showOverdueDetailSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (ctx) => _sheetFrame(
      ctx,
      child: const OverdueDetailSheet(),
    ),
  );
}

/// Conteneur à hauteur fixe (88% écran) pour les bottom-sheets, avec
/// padding clavier — donne au ListView interne une hauteur bornée donc
/// scrollable de manière prévisible.
Widget _sheetFrame(BuildContext ctx, {required Widget child}) {
  final size = MediaQuery.of(ctx).size;
  final keyboard = MediaQuery.of(ctx).viewInsets.bottom;
  return Padding(
    padding: EdgeInsets.only(bottom: keyboard),
    child: SizedBox(
      height: size.height * 0.88,
      child: child,
    ),
  );
}

/// Bottom sheet du détail « CA du mois » — comparaison vs mois N-1 +
/// liste des factures émises sur le mois courant.
class MonthRevenueDetailSheet extends ConsumerWidget {
  const MonthRevenueDetailSheet({required this.metrics, super.key});
  final DashboardMetrics metrics;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = DoliMobColors.of(context);
    final theme = Theme.of(context);
    final now = DateTime.now();
    final monthName = _kFrenchMonths[now.month - 1];
    final prevMonthIndex = now.month - 2 < 0 ? 11 : now.month - 2;
    final prevMonthName = _kFrenchMonths[prevMonthIndex];
    final detailsAsync = ref.watch(dashboardDetailsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: c.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  LucideIcons.trendingUp,
                  size: 18,
                  color: c.success,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CA du mois',
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      '$monthName ${now.year}',
                      style: TextStyle(color: c.ink2, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: detailsAsync.when(
            data: (d) => ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _RevenueHeroBlock(metrics: metrics, details: d),
                const SizedBox(height: 16),
                _ComparisonBlock(
                  current: metrics.caMois,
                  currentCount: metrics.facturesMoisCount,
                  previous: d.caMoisPrev,
                  previousCount: d.facturesMoisPrevCount,
                  prevMonthName: prevMonthName,
                ),
                const SizedBox(height: 20),
                _SectionLabel(label: 'Factures du mois '
                    '(${d.invoicesMois.length})'),
                if (d.invoicesMois.isEmpty)
                  const _EmptyHint(text: 'Aucune facture émise ce mois.')
                else
                  for (final inv in d.invoicesMois)
                    _InvoiceRow(invoice: inv, mode: _RowMode.invoiceDate),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: FilledButton.tonalIcon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      GoRouter.of(context).go(RoutePaths.stats);
                    },
                    icon: const Icon(LucideIcons.barChart3, size: 16),
                    label: const Text('Voir les statistiques 12 mois'),
                  ),
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Détail indisponible : $e',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Bottom sheet du détail « Versement attendu » — retard + répartition
/// hebdomadaire + liste des factures à échéance dans le mois.
class MonthDueDetailSheet extends ConsumerWidget {
  const MonthDueDetailSheet({required this.metrics, super.key});
  final DashboardMetrics metrics;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = DoliMobColors.of(context);
    final theme = Theme.of(context);
    final now = DateTime.now();
    final monthName = _kFrenchMonths[now.month - 1];
    final detailsAsync = ref.watch(dashboardDetailsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: c.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  LucideIcons.calendarClock,
                  size: 18,
                  color: c.accent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Versement attendu',
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      "d'ici fin $monthName",
                      style: TextStyle(color: c.ink2, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: detailsAsync.when(
            data: (d) => ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _DueHeroBlock(metrics: metrics),
                const SizedBox(height: 12),
                if (d.facturesEnRetardCount > 0)
                  _OverdueBanner(
                    count: d.facturesEnRetardCount,
                    montant: d.facturesEnRetardMontant,
                    onTap: () {
                      Navigator.of(context).pop();
                      GoRouter.of(context).go(RoutePaths.invoices);
                    },
                  ),
                if (metrics.versementAttenduCount > 0) ...[
                  const SizedBox(height: 16),
                  const _SectionLabel(label: 'Répartition hebdomadaire'),
                  const SizedBox(height: 8),
                  _WeeklyBreakdown(
                    montants: d.weeklyDueMontant,
                    counts: d.weeklyDueCount,
                  ),
                ],
                const SizedBox(height: 20),
                _SectionLabel(
                  label: 'Factures à échéance ce mois '
                      '(${d.invoicesDueMois.length})',
                ),
                if (d.invoicesDueMois.isEmpty)
                  const _EmptyHint(
                    text: 'Aucune facture à échéance ce mois.',
                  )
                else
                  for (final inv in d.invoicesDueMois)
                    _InvoiceRow(invoice: inv, mode: _RowMode.dueDate),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: FilledButton.tonalIcon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      GoRouter.of(context).go(RoutePaths.invoices);
                    },
                    icon: const Icon(LucideIcons.receipt, size: 16),
                    label: const Text('Voir toutes les factures'),
                  ),
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Détail indisponible : $e',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Bottom sheet du détail « Factures en retard » — total impayé + liste
/// des factures dont l'échéance est strictement antérieure au 1er du mois.
class OverdueDetailSheet extends ConsumerWidget {
  const OverdueDetailSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = DoliMobColors.of(context);
    final theme = Theme.of(context);
    final detailsAsync = ref.watch(dashboardDetailsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: c.danger.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  LucideIcons.alertTriangle,
                  size: 18,
                  color: c.danger,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Factures en retard',
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      'échéances dépassées',
                      style: TextStyle(color: c.ink2, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: detailsAsync.when(
            data: (d) => ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _OverdueHeroBlock(
                  count: d.facturesEnRetardCount,
                  montant: d.facturesEnRetardMontant,
                ),
                const SizedBox(height: 20),
                _SectionLabel(
                  label: 'Factures échues (${d.invoicesEnRetard.length})',
                ),
                const SizedBox(height: 8),
                if (d.invoicesEnRetard.isEmpty)
                  const _EmptyHint(
                    text: 'Aucune facture en retard. Bravo !',
                  )
                else
                  for (final inv in d.invoicesEnRetard)
                    _InvoiceRow(invoice: inv, mode: _RowMode.dueDate),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: FilledButton.tonalIcon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      GoRouter.of(context).go(RoutePaths.invoices);
                    },
                    icon: const Icon(LucideIcons.receipt, size: 16),
                    label: const Text('Voir toutes les factures'),
                  ),
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Détail indisponible : $e',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OverdueHeroBlock extends StatelessWidget {
  const _OverdueHeroBlock({required this.count, required this.montant});
  final int count;
  final double montant;

  @override
  Widget build(BuildContext context) {
    final c = DoliMobColors.of(context);
    final hasOverdue = count > 0;
    return Container(
      decoration: BoxDecoration(
        color: hasOverdue ? c.danger.withValues(alpha: 0.06) : c.fill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasOverdue
              ? c.danger.withValues(alpha: 0.22)
              : c.hairline,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MONTANT EN RETARD',
            style: TextStyle(
              color: c.ink3,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hasOverdue ? formatMoney(montant) : '—',
            style: TextStyle(
              color: hasOverdue ? c.danger : c.ink3,
              fontSize: 30,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hasOverdue
                ? '$count ${count > 1 ? "factures échues" : "facture échue"} '
                    'avant ce mois'
                : 'aucun impayé en retard',
            style: TextStyle(color: c.ink2, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _RevenueHeroBlock extends StatelessWidget {
  const _RevenueHeroBlock({required this.metrics, required this.details});
  final DashboardMetrics metrics;
  final DashboardDetails details;

  @override
  Widget build(BuildContext context) {
    final c = DoliMobColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.success.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.success.withValues(alpha: 0.18)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DÉJÀ FACTURÉ',
            style: TextStyle(
              color: c.ink3,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formatMoney(metrics.caMois),
            style: TextStyle(
              color: c.success,
              fontSize: 30,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              _InlineStat(
                value: '${metrics.facturesMoisCount}',
                label: metrics.facturesMoisCount > 1 ? 'factures' : 'facture',
                color: c.info,
                icon: LucideIcons.receipt,
              ),
              _InlineStat(
                value: '${metrics.clientsMoisCount}',
                label: metrics.clientsMoisCount > 1 ? 'clients' : 'client',
                color: c.warning,
                icon: LucideIcons.users,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DueHeroBlock extends StatelessWidget {
  const _DueHeroBlock({required this.metrics});
  final DashboardMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final c = DoliMobColors.of(context);
    final hasPending = metrics.versementAttenduCount > 0;
    return Container(
      decoration: BoxDecoration(
        color: hasPending ? c.accent.withValues(alpha: 0.06) : c.fill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasPending
              ? c.accent.withValues(alpha: 0.18)
              : c.hairline,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MONTANT ATTENDU',
            style: TextStyle(
              color: c.ink3,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hasPending ? formatMoney(metrics.versementAttenduMontant) : '—',
            style: TextStyle(
              color: hasPending ? c.accent : c.ink3,
              fontSize: 30,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hasPending
                ? '${metrics.versementAttenduCount} '
                    '${metrics.versementAttenduCount > 1
                        ? "factures à échéance"
                        : "facture à échéance"} ce mois'
                : 'aucune échéance ce mois',
            style: TextStyle(color: c.ink2, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _OverdueBanner extends StatelessWidget {
  const _OverdueBanner({
    required this.count,
    required this.montant,
    required this.onTap,
  });

  final int count;
  final double montant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = DoliMobColors.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: c.danger.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.danger.withValues(alpha: 0.22)),
          ),
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          child: Row(
            children: [
              Icon(LucideIcons.alertTriangle, size: 18, color: c.danger),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$count ${count > 1 ? "factures" : "facture"} en retard',
                      style: TextStyle(
                        color: c.danger,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${formatMoney(montant)} échus avant ce mois',
                      style: TextStyle(color: c.ink2, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(LucideIcons.chevronRight, size: 16, color: c.danger),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComparisonBlock extends StatelessWidget {
  const _ComparisonBlock({
    required this.current,
    required this.currentCount,
    required this.previous,
    required this.previousCount,
    required this.prevMonthName,
  });

  final double current;
  final int currentCount;
  final double previous;
  final int previousCount;
  final String prevMonthName;

  @override
  Widget build(BuildContext context) {
    final c = DoliMobColors.of(context);
    final theme = Theme.of(context);
    final delta = current - previous;
    final hasPrev = previous > 0;
    final pct = hasPrev ? (delta / previous) * 100 : null;
    final goingUp = delta >= 0;
    final deltaColor = !hasPrev
        ? c.ink3
        : goingUp
            ? c.success
            : c.danger;
    final deltaIcon =
        goingUp ? LucideIcons.trendingUp : LucideIcons.trendingDown;

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.hairline),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.history, size: 14, color: c.ink2),
              const SizedBox(width: 6),
              Text(
                'vs $prevMonthName',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                formatMoney(previous),
                style: TextStyle(
                  color: c.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '($previousCount '
                '${previousCount > 1 ? "factures" : "facture"})',
                style: TextStyle(color: c.ink2, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(deltaIcon, size: 14, color: deltaColor),
              const SizedBox(width: 4),
              Text(
                hasPrev
                    ? '${goingUp ? "+" : ""}${formatMoney(delta)} '
                        '(${goingUp ? "+" : ""}${pct!.toStringAsFixed(1)} %)'
                    : 'pas de référence le mois dernier',
                style: TextStyle(
                  color: deltaColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeeklyBreakdown extends StatelessWidget {
  const _WeeklyBreakdown({required this.montants, required this.counts});
  final List<double> montants;
  final List<int> counts;

  @override
  Widget build(BuildContext context) {
    final c = DoliMobColors.of(context);
    final maxMontant = montants.fold<double>(0, (m, v) => v > m ? v : m);
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.hairline),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var idx = 0; idx < 4; idx++) ...[
            _WeekRow(
              label: 'S${idx + 1}',
              range: _weekRangeLabel(idx),
              montant: montants[idx],
              count: counts[idx],
              fraction: maxMontant == 0 ? 0 : montants[idx] / maxMontant,
              color: c.accent,
            ),
            if (idx < 3) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  static String _weekRangeLabel(int idx) {
    return switch (idx) {
      0 => '1-7',
      1 => '8-14',
      2 => '15-21',
      _ => '22-fin',
    };
  }
}

class _WeekRow extends StatelessWidget {
  const _WeekRow({
    required this.label,
    required this.range,
    required this.montant,
    required this.count,
    required this.fraction,
    required this.color,
  });

  final String label;
  final String range;
  final double montant;
  final int count;
  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = DoliMobColors.of(context);
    return Row(
      children: [
        SizedBox(
          width: 24,
          child: Text(
            label,
            style: TextStyle(
              color: c.ink2,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(
          width: 50,
          child: Text(
            range,
            style: TextStyle(color: c.ink3, fontSize: 11),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (ctx, cons) => Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: c.fill,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  height: 8,
                  width: cons.maxWidth * fraction.clamp(0.0, 1.0),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 100,
          child: Text(
            formatMoney(montant),
            textAlign: TextAlign.right,
            style: TextStyle(
              color: count == 0 ? c.ink3 : c.ink,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        SizedBox(
          width: 28,
          child: Text(
            count == 0 ? '' : '·$count',
            textAlign: TextAlign.right,
            style: TextStyle(color: c.ink3, fontSize: 11),
          ),
        ),
      ],
    );
  }
}

enum _RowMode { invoiceDate, dueDate }

class _InvoiceRow extends ConsumerWidget {
  const _InvoiceRow({required this.invoice, required this.mode});

  final Invoice invoice;
  final _RowMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = DoliMobColors.of(context);
    final i = invoice;
    String? clientName;
    if (i.socidLocal != null) {
      clientName = ref
          .watch(thirdPartyByIdProvider(i.socidLocal!))
          .maybeWhen(data: (tp) => tp?.name, orElse: () => null);
    } else if (i.socidRemote != null) {
      clientName = ref
          .watch(thirdPartyByRemoteIdProvider(i.socidRemote!))
          .maybeWhen(data: (tp) => tp?.name, orElse: () => null);
    }
    final date = switch (mode) {
      _RowMode.invoiceDate => i.dateInvoice,
      _RowMode.dueDate => i.dateDue,
    };
    final dateLabel = switch (mode) {
      _RowMode.invoiceDate => date == null ? '' : 'émise ${_fmtDate(date)}',
      _RowMode.dueDate =>
        date == null ? '' : 'échéance ${_fmtDate(date)}',
    };
    final statusColor = _statusColor(i, c);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).pop();
            GoRouter.of(context).go(RoutePaths.invoiceDetailFor(i.localId));
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: c.hairline2),
            ),
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 36,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        i.displayLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: c.ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          if (clientName != null && clientName.isNotEmpty)
                            clientName,
                          if (dateLabel.isNotEmpty) dateLabel,
                        ].join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: c.ink2, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formatMoney(i.totalTtc),
                  style: TextStyle(
                    color: c.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Color _statusColor(Invoice i, DoliMobColors c) {
    if (i.isPaid) return c.success;
    if (i.isOverdue) return c.danger;
    if (i.status == InvoiceStatus.draft) return c.ink3;
    return c.warning;
  }
}

class _InlineStat extends StatelessWidget {
  const _InlineStat({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  final String value;
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final c = DoliMobColors.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: c.ink2, fontSize: 12),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = DoliMobColors.of(context);
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: c.ink3,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = DoliMobColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: TextStyle(color: c.ink2, fontSize: 12),
      ),
    );
  }
}
