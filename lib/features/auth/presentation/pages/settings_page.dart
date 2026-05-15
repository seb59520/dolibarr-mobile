import 'package:dolibarr_mobile/core/routing/route_paths.dart';
import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:dolibarr_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:dolibarr_mobile/features/expenses/presentation/providers/ocr_providers.dart';
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
          const SizedBox(height: AppTokens.spaceXs),
          const _OcrSection(),
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


/// Section dédiée à la configuration du backend OCR pour le scan de tickets.
///
/// Source de vérité = `flutter_secure_storage` via [ocrEndpointProvider] /
/// [ocrBearerProvider]. Le bouton "Tester" appelle `GET /health` (no auth).
class _OcrSection extends ConsumerStatefulWidget {
  const _OcrSection();

  @override
  ConsumerState<_OcrSection> createState() => _OcrSectionState();
}

class _OcrSectionState extends ConsumerState<_OcrSection> {
  final _endpointCtrl = TextEditingController();
  final _bearerCtrl = TextEditingController();
  bool _bearerVisible = false;
  bool _hydrated = false;
  String? _testResult;
  bool _testing = false;

  @override
  void dispose() {
    _endpointCtrl.dispose();
    _bearerCtrl.dispose();
    super.dispose();
  }

  void _hydrate(String endpoint, String bearer) {
    if (_hydrated) return;
    _hydrated = true;
    _endpointCtrl.text = endpoint;
    _bearerCtrl.text = bearer;
  }

  Future<void> _saveEndpoint() async {
    await ref
        .read(ocrEndpointProvider.notifier)
        .set(_endpointCtrl.text);
  }

  Future<void> _saveBearer() async {
    await ref.read(ocrBearerProvider.notifier).set(_bearerCtrl.text);
  }

  Future<void> _test() async {
    setState(() {
      _testing = true;
      _testResult = null;
    });
    await _saveEndpoint();
    final ds = ref.read(ocrRemoteDataSourceProvider);
    final ok = await ds.healthCheck(endpoint: _endpointCtrl.text);
    if (!mounted) return;
    setState(() {
      _testing = false;
      _testResult = ok
          ? 'Backend OCR joignable.'
          : 'Backend OCR injoignable ou modèle indisponible.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final endpointAsync = ref.watch(ocrEndpointProvider);
    final bearerAsync = ref.watch(ocrBearerProvider);
    if (endpointAsync.hasValue && bearerAsync.hasValue) {
      _hydrate(endpointAsync.value!, bearerAsync.value!);
    }
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.scanLine),
                const SizedBox(width: AppTokens.spaceXs),
                Text(
                  'OCR Tickets',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: AppTokens.spaceXs),
            Text(
              'Backend qui transforme un ticket de caisse en ligne '
              'de note de frais pré-remplie.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppTokens.spaceMd),
            TextField(
              controller: _endpointCtrl,
              decoration: const InputDecoration(
                labelText: 'Endpoint OCR',
                hintText: 'https://ocr.lab.scinnova-academy.cloud',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _saveEndpoint(),
            ),
            const SizedBox(height: AppTokens.spaceXs),
            TextField(
              controller: _bearerCtrl,
              obscureText: !_bearerVisible,
              decoration: InputDecoration(
                labelText: 'Jeton Bearer',
                hintText: 'sk-xxxxxxxxxxxx',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _bearerVisible
                        ? LucideIcons.eyeOff
                        : LucideIcons.eye,
                  ),
                  onPressed: () => setState(
                    () => _bearerVisible = !_bearerVisible,
                  ),
                ),
              ),
              onSubmitted: (_) => _saveBearer(),
            ),
            const SizedBox(height: AppTokens.spaceXs),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    await _saveEndpoint();
                    await _saveBearer();
                    if (!mounted) return;
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Paramètres OCR enregistrés.'),
                      ),
                    );
                  },
                  icon: const Icon(LucideIcons.save),
                  label: const Text('Enregistrer'),
                ),
                const SizedBox(width: AppTokens.spaceXs),
                OutlinedButton.icon(
                  onPressed: _testing ? null : _test,
                  icon: _testing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(LucideIcons.activity),
                  label: const Text('Tester /health'),
                ),
              ],
            ),
            if (_testResult != null) ...[
              const SizedBox(height: AppTokens.spaceXs),
              Text(
                _testResult!,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
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
