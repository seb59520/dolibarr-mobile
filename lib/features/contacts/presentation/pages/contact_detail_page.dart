import 'package:dolibarr_mobile/core/routing/route_paths.dart';
import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/features/contacts/domain/entities/contact.dart';
import 'package:dolibarr_mobile/features/contacts/presentation/providers/contact_providers.dart';
import 'package:dolibarr_mobile/features/thirdparties/presentation/providers/third_party_providers.dart';
import 'package:dolibarr_mobile/shared/widgets/confirm_dialog.dart';
import 'package:dolibarr_mobile/shared/widgets/error_state.dart';
import 'package:dolibarr_mobile/shared/widgets/loading_skeleton.dart';
import 'package:dolibarr_mobile/shared/widgets/quick_action_chip.dart';
import 'package:dolibarr_mobile/shared/widgets/sync_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactDetailPage extends ConsumerWidget {
  const ContactDetailPage({required this.localId, super.key});

  final int localId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(contactByIdProvider(localId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.edit),
            tooltip: 'Modifier',
            onPressed: () =>
                context.go(RoutePaths.contactEditFor(localId)),
          ),
          IconButton(
            icon: const Icon(LucideIcons.trash2),
            tooltip: 'Supprimer',
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: async.when(
        data: (c) => c == null
            ? const ErrorState(
                title: 'Contact introuvable',
                description: 'Cette fiche n’existe plus dans le cache.',
              )
            : _DetailBody(contact: c),
        loading: () => Center(child: LoadingSkeleton.card()),
        error: (e, _) => ErrorState(
          title: 'Impossible de charger le contact',
          description: '$e',
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await ConfirmDialog.showDestructive(
      context,
      title: 'Supprimer ce contact ?',
      message:
          'La suppression sera synchronisée au prochain passage en ligne.',
    );
    if (ok != true || !context.mounted) return;
    final result =
        await ref.read(contactRepositoryProvider).deleteLocal(localId);
    if (!context.mounted) return;
    result.fold(
      onSuccess: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Suppression enregistrée.')),
        );
        context.go(RoutePaths.contacts);
      },
      onFailure: (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec : $f')),
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.contact});
  final Contact contact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final c = contact;
    return RefreshIndicator(
      onRefresh: () async {
        if (c.remoteId == null) return;
        await ref.read(contactRepositoryProvider).refreshById(c.remoteId!);
      },
      child: ListView(
        padding: const EdgeInsets.all(AppTokens.spaceMd),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  c.displayName,
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              SyncStatusBadge(status: c.syncStatus),
            ],
          ),
          if (c.poste != null && c.poste!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                c.poste!,
                style: theme.textTheme.bodySmall,
              ),
            ),
          const SizedBox(height: AppTokens.spaceMd),
          _ActionsRow(contact: c),
          const SizedBox(height: AppTokens.spaceMd),
          _ParentLink(contact: c),
          _ContactSection(contact: c),
          if (c.fullAddress.isNotEmpty) _AddressSection(contact: c),
        ],
      ),
    );
  }
}

class _ActionsRow extends StatelessWidget {
  const _ActionsRow({required this.contact});
  final Contact contact;

  Future<void> _open(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = contact;
    final actions = <Widget>[];
    final phone =
        (c.phoneMobile?.isNotEmpty ?? false) ? c.phoneMobile : c.phonePro;
    if (phone != null && phone.isNotEmpty) {
      actions.add(QuickActionChip(
        icon: LucideIcons.phone,
        label: 'Appeler',
        onPressed: () => _open(Uri(scheme: 'tel', path: phone)),
      ));
    }
    if (c.email != null && c.email!.isNotEmpty) {
      actions.add(QuickActionChip(
        icon: LucideIcons.mail,
        label: 'Email',
        onPressed: () => _open(Uri(scheme: 'mailto', path: c.email)),
      ));
    }
    if (actions.isEmpty) return const SizedBox.shrink();
    return Wrap(spacing: 8, runSpacing: 8, children: actions);
  }
}

class _ParentLink extends ConsumerWidget {
  const _ParentLink({required this.contact});
  final Contact contact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = contact;
    final theme = Theme.of(context);

    // On regarde d'abord le tiers via socidLocal (cas pendingCreate),
    // sinon par remoteId via la liste — pour l'Étape 8 on se contente
    // d'afficher le label brut "Tiers #<id>" si on n'a pas encore le
    // tiers en cache.
    if (c.socidLocal != null) {
      final async = ref.watch(thirdPartyByIdProvider(c.socidLocal!));
      return async.maybeWhen(
        data: (tp) {
          if (tp == null) return const SizedBox.shrink();
          return Card(
            child: ListTile(
              leading: const Icon(LucideIcons.briefcase),
              title: Text(tp.name),
              subtitle: Text(
                'Tiers parent',
                style: theme.textTheme.bodySmall,
              ),
              trailing: const Icon(LucideIcons.chevronRight),
              onTap: () => context.go(
                RoutePaths.thirdpartyDetailFor(tp.localId),
              ),
            ),
          );
        },
        orElse: () => const SizedBox.shrink(),
      );
    }
    if (c.socidRemote != null) {
      return Card(
        child: ListTile(
          leading: const Icon(LucideIcons.briefcase),
          title: Text('Tiers #${c.socidRemote}'),
          subtitle: Text(
            'Tiers parent',
            style: theme.textTheme.bodySmall,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _Section extends StatefulWidget {
  const _Section({
    required this.title,
    required this.child,
    this.initiallyExpanded = true,
  });
  final String title;
  final Widget child;
  final bool initiallyExpanded;

  @override
  State<_Section> createState() => _SectionState();
}

class _SectionState extends State<_Section> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppTokens.spaceXs),
      child: Column(
        children: [
          ListTile(
            title: Text(widget.title, style: theme.textTheme.titleMedium),
            trailing: Icon(
              _expanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
            ),
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.spaceMd,
                0,
                AppTokens.spaceMd,
                AppTokens.spaceMd,
              ),
              child: widget.child,
            ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value!)),
        ],
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection({required this.contact});
  final Contact contact;
  @override
  Widget build(BuildContext context) {
    final c = contact;
    return _Section(
      title: 'Coordonnées',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Field(label: 'Tél. pro', value: c.phonePro),
          _Field(label: 'Tél. mobile', value: c.phoneMobile),
          _Field(label: 'Email', value: c.email),
        ],
      ),
    );
  }
}

class _AddressSection extends StatelessWidget {
  const _AddressSection({required this.contact});
  final Contact contact;
  @override
  Widget build(BuildContext context) {
    final c = contact;
    return _Section(
      title: 'Adresse',
      initiallyExpanded: false,
      child: Text(c.fullAddress),
    );
  }
}
