import 'package:dolibarr_mobile/core/routing/route_paths.dart';
import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/features/expenses/presentation/controllers/expense_scan_controller.dart';
import 'package:dolibarr_mobile/features/expenses/presentation/providers/ocr_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Page de sélection de la source du ticket + déclenchement de l'OCR.
///
/// L'écran enchaîne plusieurs phases :
///   1. `idle` → 2 boutons "Caméra" et "Galerie" + 1 bouton "Saisir
///      manuellement" qui by-pass l'OCR.
///   2. `capturing` → spinner pendant la sélection système.
///   3. `extracting` → spinner avec message rassurant (≤ 2 min) car le
///      modèle Qwen2.5-VL CPU est lent au premier appel.
///   4. `editing` / `done` → navigation automatique vers le formulaire.
///   5. `error` → bloc d'erreur + boutons Réessayer / Saisir manuellement.
class ExpenseScanPage extends ConsumerStatefulWidget {
  const ExpenseScanPage({super.key});

  @override
  ConsumerState<ExpenseScanPage> createState() => _ExpenseScanPageState();
}

class _ExpenseScanPageState extends ConsumerState<ExpenseScanPage> {
  @override
  void initState() {
    super.initState();
    // Re-clear l'état à chaque entrée pour ne pas afficher un vieux résultat.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(expenseScanControllerProvider.notifier).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(expenseScanControllerProvider);
    final configured = ref.watch(ocrConfiguredProvider);

    // Quand on bascule en phase `editing`, on route vers le formulaire.
    ref.listen<ExpenseScanState>(expenseScanControllerProvider, (prev, next) {
      if (prev?.phase != next.phase &&
          next.phase == ExpenseScanPhase.editing) {
        if (!mounted) return;
        context.go(RoutePaths.expenseScanEdit);
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => context.go(RoutePaths.expenses),
        ),
        title: const Text('Scanner un ticket'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.spaceLg),
          child: _buildBody(context, state, configured: configured),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ExpenseScanState state, {
    required bool configured,
  }) {
    if (!configured) {
      return _ConfigMissing(
        onOpenSettings: () => context.go(RoutePaths.settings),
      );
    }
    switch (state.phase) {
      case ExpenseScanPhase.capturing:
        return const _BusyView(label: 'Préparation de l’image…');
      case ExpenseScanPhase.extracting:
        return const _ExtractingView();
      case ExpenseScanPhase.pushing:
        return const _BusyView(label: 'Envoi à Dolibarr…');
      case ExpenseScanPhase.error:
        return _ErrorView(
          message: state.failure?.toString() ?? 'Erreur inconnue.',
          onRetry: () => ref
              .read(expenseScanControllerProvider.notifier)
              .reset(),
          onManual: () => ref
              .read(expenseScanControllerProvider.notifier)
              .startManual(),
        );
      case ExpenseScanPhase.idle:
      case ExpenseScanPhase.editing:
      case ExpenseScanPhase.done:
        return _SourcePickerView(
          onCamera: () => ref
              .read(expenseScanControllerProvider.notifier)
              .pickAndExtract(ImageSource.camera),
          onGallery: () => ref
              .read(expenseScanControllerProvider.notifier)
              .pickAndExtract(ImageSource.gallery),
          onManual: () => ref
              .read(expenseScanControllerProvider.notifier)
              .startManual(),
        );
    }
  }
}

class _SourcePickerView extends StatelessWidget {
  const _SourcePickerView({
    required this.onCamera,
    required this.onGallery,
    required this.onManual,
  });

  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onManual;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppTokens.spaceLg),
        Icon(
          LucideIcons.receipt,
          size: 96,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: AppTokens.spaceLg),
        Text(
          'Comment veux-tu importer ton ticket ?',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppTokens.spaceSm),
        Text(
          'L’app envoie l’image au moteur OCR puis pré-remplit '
          'le formulaire de note de frais. Tout reste éditable avant '
          'l’enregistrement.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppTokens.spaceXl),
        FilledButton.icon(
          onPressed: onCamera,
          icon: const Icon(LucideIcons.camera),
          label: const Text('Prendre une photo'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        const SizedBox(height: AppTokens.spaceSm),
        FilledButton.tonalIcon(
          onPressed: onGallery,
          icon: const Icon(LucideIcons.imagePlus),
          label: const Text('Choisir dans la galerie'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        const SizedBox(height: AppTokens.spaceXl),
        TextButton.icon(
          onPressed: onManual,
          icon: const Icon(LucideIcons.pencil),
          label: const Text('Saisir manuellement'),
        ),
      ],
    );
  }
}

class _ExtractingView extends StatelessWidget {
  const _ExtractingView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(strokeWidth: 4),
          ),
          const SizedBox(height: AppTokens.spaceLg),
          Text(
            'Analyse du ticket en cours…',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppTokens.spaceSm),
          Text(
            'Le modèle Qwen2.5-VL tourne sur CPU.\n'
            'Comptez jusqu’à 2 minutes au premier appel.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppTokens.spaceLg),
          const SizedBox(
            width: 220,
            child: LinearProgressIndicator(),
          ),
        ],
      ),
    );
  }
}

class _BusyView extends StatelessWidget {
  const _BusyView({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppTokens.spaceMd),
          Text(label, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.onManual,
  });
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onManual;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.alertTriangle, size: 56, color: scheme.error),
          const SizedBox(height: AppTokens.spaceMd),
          Text(
            'Échec de l’analyse',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppTokens.spaceXs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppTokens.spaceLg),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(LucideIcons.rotateCcw),
            label: const Text('Réessayer'),
          ),
          const SizedBox(height: AppTokens.spaceXs),
          TextButton.icon(
            onPressed: onManual,
            icon: const Icon(LucideIcons.pencil),
            label: const Text('Saisir manuellement'),
          ),
        ],
      ),
    );
  }
}

class _ConfigMissing extends StatelessWidget {
  const _ConfigMissing({required this.onOpenSettings});
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.settings,
            size: 56,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: AppTokens.spaceMd),
          Text('OCR non configuré', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppTokens.spaceXs),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppTokens.spaceLg),
            child: Text(
              'Renseigne l’endpoint OCR et le jeton Bearer dans '
              'Paramètres → OCR Tickets pour activer le scan.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: AppTokens.spaceLg),
          FilledButton.icon(
            onPressed: onOpenSettings,
            icon: const Icon(LucideIcons.arrowRight),
            label: const Text('Ouvrir Paramètres'),
          ),
        ],
      ),
    );
  }
}
