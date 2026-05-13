import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/core/utils/formatters.dart';
import 'package:dolibarr_mobile/features/stats/domain/entities/monthly_stat.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Bar chart « Facturé vs Perçu » sur la fenêtre mensuelle fournie.
///
/// Chaque mois affiche deux barres collées (groupées). L'axe Y est en
/// euros TTC, formaté en `K€` au-delà du millier. Le tooltip live
/// affiche les deux montants détaillés.
class StatsBarChart extends StatelessWidget {
  const StatsBarChart({
    required this.monthly,
    required this.maxValue,
    super.key,
  });

  final List<MonthlyStat> monthly;
  final double maxValue;

  @override
  Widget build(BuildContext context) {
    final c = DoliMobColors.of(context);
    final theme = Theme.of(context);
    if (monthly.isEmpty) {
      return SizedBox(
        height: 220,
        child: Center(
          child: Text(
            'Pas encore de données',
            style: theme.textTheme.bodySmall,
          ),
        ),
      );
    }

    // Sécurité : si tout est à zéro, on évite un range nul fl_chart.
    final upper = maxValue <= 0 ? 100.0 : (maxValue * 1.15);
    final interval = _niceInterval(upper);

    return SizedBox(
      height: 240,
      child: BarChart(
        BarChartData(
          maxY: upper,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => c.ink.withValues(alpha: 0.92),
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
              getTooltipItem: (group, gIdx, rod, rIdx) {
                final m = monthly[group.x];
                final label = '${_monthLabel(m.month)} ${m.year}';
                return BarTooltipItem(
                  '$label\n'
                  'Facturé : ${formatMoney(m.factureTtc)}\n'
                  'Perçu   : ${formatMoney(m.percu)}',
                  TextStyle(
                    color: c.surface,
                    fontSize: 11,
                    height: 1.4,
                  ),
                );
              },
            ),
          ),
          gridData: FlGridData(
            horizontalInterval: interval,
            getDrawingHorizontalLine: (_) => FlLine(
              color: c.hairline,
              strokeWidth: 1,
              dashArray: const [3, 3],
            ),
            drawVerticalLine: false,
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                interval: interval,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      _short(value),
                      style: TextStyle(color: c.ink3, fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 26,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= monthly.length) {
                    return const SizedBox.shrink();
                  }
                  final m = monthly[idx];
                  final isJanOrFirst = m.month == 1 || idx == 0;
                  final txt = isJanOrFirst
                      ? "${_monthLabel(m.month)} '${m.year % 100}"
                      : _monthLabel(m.month);
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      txt,
                      style: TextStyle(color: c.ink3, fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            for (var i = 0; i < monthly.length; i++)
              BarChartGroupData(
                x: i,
                barsSpace: 3,
                barRods: [
                  BarChartRodData(
                    toY: monthly[i].factureTtc,
                    color: c.accent,
                    width: 7,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(2),
                    ),
                  ),
                  BarChartRodData(
                    toY: monthly[i].percu,
                    color: c.success,
                    width: 7,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(2),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  static String _monthLabel(int m) => switch (m) {
        1 => 'janv.',
        2 => 'févr.',
        3 => 'mars',
        4 => 'avr.',
        5 => 'mai',
        6 => 'juin',
        7 => 'juil.',
        8 => 'août',
        9 => 'sept.',
        10 => 'oct.',
        11 => 'nov.',
        12 => 'déc.',
        _ => '?',
      };

  static String _short(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}k';
    return v.toStringAsFixed(0);
  }

  /// Cherche un pas raisonnable (1, 2, 5, 10 × 10^n) pour graduer l'axe.
  static double _niceInterval(double upper) {
    if (upper <= 0) return 25;
    final pow10 = _pow10(upper / 4);
    final candidates = [1.0, 2.0, 2.5, 5.0, 10.0];
    for (final c in candidates) {
      final step = c * pow10;
      if (upper / step <= 6) return step;
    }
    return 10 * pow10;
  }

  static double _pow10(double v) {
    var p = 1.0;
    while (p * 10 <= v) {
      p *= 10;
    }
    return p;
  }
}
