import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/core/utils/formatters.dart';
import 'package:dolibarr_mobile/features/stats/domain/entities/monthly_stat.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Combo chart « Facturé vs Perçu » :
/// - barres pour le facturé TTC mensuel
/// - ligne lissée superposée pour le perçu
///
/// L'interaction tactile (tooltip) reste portée par la couche
/// [BarChart] de fl_chart. La ligne « perçu » est dessinée par un
/// [CustomPaint] en overlay, en recalculant les positions à l'identique
/// (alignement `spaceAround`, slots équirépartis).
class TrendComboChart extends StatelessWidget {
  const TrendComboChart({
    required this.monthly,
    required this.maxValue,
    super.key,
  });

  final List<MonthlyStat> monthly;
  final double maxValue;

  static const double _leftReserved = 42;
  static const double _bottomReserved = 26;

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

    final upper = maxValue <= 0 ? 100.0 : (maxValue * 1.15);
    final interval = _niceInterval(upper);
    final n = monthly.length;
    final barW = (200 / n).clamp(2.5, 10.0);
    final labelStep = n <= 8 ? 1 : (n / 8).ceil();

    return SizedBox(
      height: 240,
      child: Stack(
        children: [
          BarChart(
            BarChartData(
              maxY: upper,
              minY: 0,
              alignment: BarChartAlignment.spaceAround,
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
                    return BarTooltipItem(
                      '${_monthLabel(m.month)} ${m.year}\n'
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
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: c.hairline,
                  strokeWidth: 1,
                  dashArray: const [3, 3],
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: _leftReserved,
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
                    reservedSize: _bottomReserved,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= n) return const SizedBox.shrink();
                      if (idx % labelStep != 0 && idx != n - 1) {
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
                for (var i = 0; i < n; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: monthly[i].factureTtc,
                        color: c.accent,
                        width: barW,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(2),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: _leftReserved,
                  bottom: _bottomReserved,
                ),
                child: CustomPaint(
                  painter: _PercuLinePainter(
                    monthly: monthly,
                    maxY: upper,
                    color: c.revenue,
                  ),
                ),
              ),
            ),
          ),
        ],
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

  static double _niceInterval(double upper) {
    if (upper <= 0) return 25;
    final pow10 = _pow10(upper / 4);
    const candidates = [1.0, 2.0, 2.5, 5.0, 10.0];
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

/// Peint la courbe « perçu » lissée par-dessus la zone de tracé de la
/// BarChart. L'alignement `spaceAround` de fl_chart répartit n slots
/// identiques, donc le centre du slot i est à (i + 0.5) · width / n.
class _PercuLinePainter extends CustomPainter {
  _PercuLinePainter({
    required this.monthly,
    required this.maxY,
    required this.color,
  });

  final List<MonthlyStat> monthly;
  final double maxY;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (monthly.isEmpty || maxY <= 0) return;
    final n = monthly.length;
    final w = size.width;
    final h = size.height;
    final points = <Offset>[
      for (var i = 0; i < n; i++)
        Offset(
          (i + 0.5) * w / n,
          h - (monthly[i].percu.clamp(0, maxY) / maxY) * h,
        ),
    ];

    final path = _smoothPath(points);

    // Halo doux sous la ligne
    final halo = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(path, halo);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, stroke);

    // Dots aux mois ayant une valeur > 0
    final dot = Paint()..color = color;
    final dotRing = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (var i = 0; i < n; i++) {
      if (monthly[i].percu <= 0) continue;
      canvas
        ..drawCircle(points[i], 3, dot)
        ..drawCircle(points[i], 3, dotRing);
    }
  }

  /// Courbe Catmull-Rom convertie en cubiques Bézier — lissage doux
  /// sans dépendre des splines internes de fl_chart.
  Path _smoothPath(List<Offset> pts) {
    final path = Path();
    if (pts.isEmpty) return path;
    path.moveTo(pts.first.dx, pts.first.dy);
    if (pts.length == 1) return path;
    if (pts.length == 2) {
      path.lineTo(pts[1].dx, pts[1].dy);
      return path;
    }
    for (var i = 0; i < pts.length - 1; i++) {
      final p0 = i == 0 ? pts[i] : pts[i - 1];
      final p1 = pts[i];
      final p2 = pts[i + 1];
      final p3 = i + 2 < pts.length ? pts[i + 2] : pts[i + 1];
      final cp1 = Offset(
        p1.dx + (p2.dx - p0.dx) / 6,
        p1.dy + (p2.dy - p0.dy) / 6,
      );
      final cp2 = Offset(
        p2.dx - (p3.dx - p1.dx) / 6,
        p2.dy - (p3.dy - p1.dy) / 6,
      );
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant _PercuLinePainter old) =>
      old.monthly != monthly || old.maxY != maxY || old.color != color;
}
