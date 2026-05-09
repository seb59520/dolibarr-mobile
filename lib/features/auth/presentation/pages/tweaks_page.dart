import 'package:dolibarr_mobile/core/preferences/tweaks.dart';
import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Panneau de réglages visuels DoliMob (cf. design canvas).
///
/// Persistés en SharedPreferences via `tweaksProvider`. Tout l'app
/// reactif aux changements (theme, density, accent, etc.).
class TweaksPage extends ConsumerWidget {
  const TweaksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = DoliMobColors.of(context);
    final tweaks = ref.watch(tweaksProvider);
    final notifier = ref.read(tweaksProvider.notifier);

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        title: const Text('Personnalisation'),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          const _SectionHeader(text: 'Thème'),
          _SwitchRow(
            label: 'Mode sombre',
            value: tweaks.dark,
            onChanged: (v) => notifier.setDark(value: v),
          ),
          const SizedBox(height: 18),
          const _SectionHeader(text: "Couleur d'accent"),
          _AccentRow(
            value: tweaks.accent,
            onChanged: notifier.setAccent,
          ),
          const SizedBox(height: 18),
          const _SectionHeader(text: 'Typographie'),
          _RadioRow<FontFamilyChoice>(
            value: tweaks.font,
            options: FontFamilyChoice.values,
            labelOf: (f) => f.cssName,
            onChanged: notifier.setFont,
          ),
          const SizedBox(height: 18),
          const _SectionHeader(text: 'Densité'),
          _RadioRow<DensityChoice>(
            value: tweaks.density,
            options: DensityChoice.values,
            labelOf: (d) => switch (d) {
              DensityChoice.compact => 'Compact',
              DensityChoice.regular => 'Standard',
              DensityChoice.comfy => 'Aéré',
            },
            onChanged: notifier.setDensity,
          ),
          const SizedBox(height: 18),
          const _SectionHeader(text: 'Style des cartes'),
          _RadioRow<CardStyleChoice>(
            value: tweaks.cardStyle,
            options: CardStyleChoice.values,
            labelOf: (s) => switch (s) {
              CardStyleChoice.flat => 'Plat',
              CardStyleChoice.border => 'Bordure',
              CardStyleChoice.elevated => 'Élevé',
            },
            onChanged: notifier.setCardStyle,
          ),
          const SizedBox(height: 18),
          const _SectionHeader(text: 'Position du bouton +'),
          _RadioRow<FabPosition>(
            value: tweaks.fabPosition,
            options: FabPosition.values,
            labelOf: (p) => switch (p) {
              FabPosition.left => 'Gauche',
              FabPosition.center => 'Centre',
              FabPosition.right => 'Droite',
            },
            onChanged: notifier.setFabPosition,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final c = DoliMobColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: c.ink3,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = DoliMobColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusCardLg),
        border: Border.all(color: c.hairline, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: c.ink, fontSize: 15),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: c.accent,
          ),
        ],
      ),
    );
  }
}

class _AccentRow extends StatelessWidget {
  const _AccentRow({required this.value, required this.onChanged});
  final Color value;
  final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = DoliMobColors.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusCardLg),
        border: Border.all(color: c.hairline, width: 0.5),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final color in AppTokens.accentChoices)
            GestureDetector(
              onTap: () => onChanged(color),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: value.toARGB32() == color.toARGB32()
                        ? c.ink
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RadioRow<T> extends StatelessWidget {
  const _RadioRow({
    required this.value,
    required this.options,
    required this.labelOf,
    required this.onChanged,
  });
  final T value;
  final List<T> options;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = DoliMobColors.of(context);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusCardLg),
        border: Border.all(color: c.hairline, width: 0.5),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final opt in options)
            GestureDetector(
              onTap: () => onChanged(opt),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: opt == value ? c.accentSoft : c.fill,
                  border: Border.all(
                    color: opt == value ? c.accent : Colors.transparent,
                  ),
                  borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                ),
                child: Text(
                  labelOf(opt),
                  style: TextStyle(
                    color: opt == value ? c.accent : c.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
