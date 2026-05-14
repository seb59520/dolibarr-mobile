import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Clé partagée du `Scaffold` de la shell en layout phone. Permet aux
/// pages top-level d'ouvrir le drawer principal via leur AppBar `leading`
/// sans passer par un overlay (qui se confond avec le fond de l'AppBar).
final shellScaffoldKeyProvider = Provider<GlobalKey<ScaffoldState>>(
  (ref) => GlobalKey<ScaffoldState>(debugLabel: 'shell-scaffold'),
);

/// Bouton menu à utiliser en `AppBar.leading` sur les pages top-level.
///
/// Ne s'affiche que sur les viewports < 600px (layout phone) — sur
/// tablette/desktop, la `NavigationRail` de la shell remplit ce rôle et
/// le bouton se masque automatiquement pour libérer l'espace du titre.
class ShellMenuButton extends ConsumerWidget {
  const ShellMenuButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPhone = MediaQuery.sizeOf(context).width < 600;
    if (!isPhone) return const SizedBox.shrink();
    final key = ref.watch(shellScaffoldKeyProvider);
    return IconButton(
      icon: const Icon(LucideIcons.menu),
      tooltip: 'Ouvrir le menu',
      onPressed: () => key.currentState?.openDrawer(),
    );
  }
}
