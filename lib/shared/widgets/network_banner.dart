import 'package:dolibarr_mobile/core/di/providers.dart';
import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Bandeau persistant affiché en haut quand l'app est offline.
///
/// Doit être posé en haut d'un Scaffold body. Disparaît automatiquement
/// quand le réseau revient (animé via `AnimatedSwitcher`).
class NetworkBanner extends ConsumerStatefulWidget {
  const NetworkBanner({super.key});

  @override
  ConsumerState<NetworkBanner> createState() => _NetworkBannerState();
}

class _NetworkBannerState extends ConsumerState<NetworkBanner> {
  bool _online = true;

  @override
  void initState() {
    super.initState();
    final info = ref.read(networkInfoProvider);
    _online = info.isOnline;
    info.refresh().then((v) {
      if (mounted) setState(() => _online = v);
    });
    info.onStatusChange.listen((v) {
      if (mounted) setState(() => _online = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppTokens.animDefault,
      child: _online ? const SizedBox.shrink() : const _OfflineBanner(),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.errorContainer,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.spaceMd,
            vertical: AppTokens.spaceXs,
          ),
          child: Row(
            children: [
              Icon(LucideIcons.wifiOff, color: scheme.onErrorContainer),
              const SizedBox(width: AppTokens.spaceXs),
              Expanded(
                child: Text(
                  'Mode hors-ligne — vos modifications seront '
                  'synchronisées au retour réseau.',
                  style: TextStyle(color: scheme.onErrorContainer),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
