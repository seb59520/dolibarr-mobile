import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:dolibarr_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Placeholders pour les onglets non encore implémentés.
class ThirdPartiesPlaceholderPage extends StatelessWidget {
  const ThirdPartiesPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) => const _ComingSoon(
        title: 'Tiers',
        description: 'Liste, recherche et fiche tiers — Étape 6.',
        icon: LucideIcons.briefcase,
      );
}

class SettingsPlaceholderPage extends ConsumerWidget {
  const SettingsPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authNotifierProvider);
    final session = state is AuthAuthenticated ? state.session : null;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        padding: const EdgeInsets.all(AppTokens.spaceMd),
        children: [
          if (session != null) _SessionCard(session: session),
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

class _ComingSoon extends StatelessWidget {
  const _ComingSoon({
    required this.title,
    required this.description,
    required this.icon,
  });
  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.spaceLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 96, color: theme.colorScheme.primary),
              const SizedBox(height: AppTokens.spaceLg),
              Text(title, style: theme.textTheme.headlineSmall),
              const SizedBox(height: AppTokens.spaceSm),
              Text(
                description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
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
