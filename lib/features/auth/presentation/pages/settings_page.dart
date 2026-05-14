import 'package:dolibarr_mobile/core/routing/route_paths.dart';
import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:dolibarr_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:dolibarr_mobile/features/sync/presentation/providers/sync_providers.dart';
import 'package:dolibarr_mobile/shared/widgets/shell_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authNotifierProvider);
    final session = state is AuthAuthenticated ? state.session : null;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: const ShellMenuButton(),
        title: const Text('Paramètres'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTokens.spaceMd),
        children: [
          if (session != null) _SessionCard(session: session),
          const SizedBox(height: AppTokens.spaceLg),
          const _PendingOperationsTile(),
          const SizedBox(height: AppTokens.spaceXs),
          const _TweaksTile(),
          const SizedBox(height: AppTokens.spaceLg),
          FilledButton.tonalIcon(
            onPressed: () => _confirmLogout(context, ref),
            icon: const Icon(LucideIcons.logOut),
            label: const Text('Se déconnecter'),
            style: FilledButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text(
          'Votre clé API sera supprimée. Le cache local est conservé '
          'pour votre prochaine connexion.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref.read(authNotifierProvider.notifier).logout();
    }
  }
}


class _TweaksTile extends StatelessWidget {
  const _TweaksTile();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(LucideIcons.palette),
        title: const Text('Personnalisation visuelle'),
        subtitle: const Text(
          'Mode sombre, accent, police, densité, position du bouton +.',
        ),
        trailing: const Icon(LucideIcons.chevronRight),
        onTap: () => context.go(RoutePaths.tweaks),
      ),
    );
  }
}

class _PendingOperationsTile extends ConsumerWidget {
  const _PendingOperationsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(pendingOperationsCountProvider);
    final value = count.maybeWhen(data: (c) => c, orElse: () => 0);
    return Card(
      child: ListTile(
        leading: Badge(
          isLabelVisible: value > 0,
          label: Text('$value'),
          child: const Icon(LucideIcons.refreshCw),
        ),
        title: const Text('Opérations en attente'),
        subtitle: Text(
          value == 0
              ? 'Toutes les modifications sont synchronisées.'
              : 'Vos modifications seront poussées au retour réseau.',
        ),
        trailing: const Icon(LucideIcons.chevronRight),
        onTap: () => context.go(RoutePaths.pendingOperations),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});
  final AuthSession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Compte', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppTokens.spaceXs),
            Text(session.fullName),
            Text(
              session.userLogin,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppTokens.spaceMd),
            Text('Instance', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppTokens.spaceXs),
            Text(session.baseUrl),
          ],
        ),
      ),
    );
  }
}
