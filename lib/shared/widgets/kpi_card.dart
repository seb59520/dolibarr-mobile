import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';

/// Tone d'une `KpiCard` — colorise la valeur (ink/danger/success).
enum KpiTone { neutral, danger, success, accent }

/// Carte KPI au pattern DoliMob.
///
/// Layout :
///   - label tiny uppercase letterSpacing 0.04em
///   - valeur 22px tabular-nums + accent color selon `tone`
///   - hint optionnel ink2
///
/// Wrappé dans un [AppCard] pour suivre le style global (flat/border/
/// elevated). Tap optionnel pour navigation.
class KpiCard extends StatelessWidget {
  const KpiCard({
    required this.label,
    required this.value,
    this.hint,
    this.icon,
    this.tone = KpiTone.neutral,
    this.onTap,
    super.key,
  });

  final String label;
  final String value;
  final String? hint;
  final IconData? icon;
  final KpiTone tone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = DoliMobColors.of(context);
    final accentValue = switch (tone) {
      KpiTone.danger => c.danger,
      KpiTone.success => c.success,
      KpiTone.accent => c.accent,
      KpiTone.neutral => c.ink,
    };
    return AppCard(
      onTap: onTap,
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: c.accentSoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 16, color: c.accent),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: c.ink3,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: accentValue,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (hint != null) ...[
            const SizedBox(height: 2),
            Text(
              hint!,
              style: TextStyle(color: c.ink2, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
