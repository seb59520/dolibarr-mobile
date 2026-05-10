import 'package:dolibarr_mobile/core/preferences/tweaks.dart';
import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Carte cliquable du Design System DoliMob.
///
/// Honore le réglage `Tweaks.cardStyle` :
///   - `flat`     : surface + hairline 0.5px
///   - `border`   : surface + hairline 1px (plus marqué)
///   - `elevated` : ombre douce (1+6px)
///
/// Border-radius depuis `AppTokens.radiusCardLg` (14px).
class AppCard extends ConsumerWidget {
  const AppCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppTokens.spaceMd),
    this.margin,
    this.borderRadius,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = DoliMobColors.of(context);
    final style = ref.watch(tweaksProvider).cardStyle;
    final radius = BorderRadius.circular(
      borderRadius ?? AppTokens.radiusCardLg,
    );

    BoxBorder? border;
    List<BoxShadow>? shadow;
    if (style == CardStyleChoice.flat) {
      border = Border.all(color: c.hairline, width: 0.5);
    } else if (style == CardStyleChoice.border) {
      border = Border.all(color: c.hairline);
    } else {
      shadow = [
        BoxShadow(
          color: Colors.black.withValues(alpha: c.dark ? 0.40 : 0.04),
          blurRadius: 2,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: c.dark ? 0.20 : 0.10),
          blurRadius: 18,
          spreadRadius: -8,
          offset: const Offset(0, 6),
        ),
      ];
    }

    return Padding(
      padding: margin ??
          const EdgeInsets.symmetric(
            horizontal: AppTokens.spaceMd,
            vertical: AppTokens.spaceXs,
          ),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: radius,
            border: border,
            boxShadow: shadow,
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}
