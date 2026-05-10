import 'package:dolibarr_mobile/core/di/providers.dart';
import 'package:dolibarr_mobile/core/routing/route_paths.dart';
import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/features/contacts/presentation/widgets/third_party_contacts_section.dart';
import 'package:dolibarr_mobile/features/invoices/presentation/widgets/third_party_invoices_section.dart';
import 'package:dolibarr_mobile/features/projects/presentation/widgets/third_party_projects_section.dart';
import 'package:dolibarr_mobile/features/proposals/presentation/widgets/third_party_proposals_section.dart';
import 'package:dolibarr_mobile/features/thirdparties/domain/entities/third_party.dart';
import 'package:dolibarr_mobile/features/thirdparties/presentation/providers/third_party_providers.dart';
import 'package:dolibarr_mobile/shared/widgets/colored_avatar.dart';
import 'package:dolibarr_mobile/shared/widgets/confirm_dialog.dart';
import 'package:dolibarr_mobile/shared/widgets/dolimob_chip.dart';
import 'package:dolibarr_mobile/shared/widgets/error_state.dart';
import 'package:dolibarr_mobile/shared/widgets/loading_skeleton.dart';
import 'package:dolibarr_mobile/shared/widgets/quick_action_chip.dart';
import 'package:dolibarr_mobile/shared/widgets/sync_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class ThirdPartyDetailPage extends ConsumerWidget {
  const ThirdPartyDetailPage({required this.localId, super.key});

  final int localId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(thirdPartyByIdProvider(localId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiers'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.edit),
            tooltip: 'Modifier',
            onPressed: () =>
                context.go(RoutePaths.thirdpartyEditFor(localId)),
          ),
          IconButton(
            icon: const Icon(LucideIcons.trash2),
            tooltip: 'Supprimer',
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: async.when(
        data: (tp) => tp == null
            ? const ErrorState(
                title: 'Tiers introuvable',
                description: 'Cette fiche n’existe plus dans le cache.',
              )
            : _DetailBody(thirdParty: tp),
        loading: () => Center(child: LoadingSkeleton.card()),
        error: (e, _) => ErrorState(
          title: 'Impossible de charger la fiche',
          description: '$e',
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await ConfirmDialog.showDestructive(
      context,
      title: 'Supprimer ce tiers ?',
      message:
          'La suppression sera synchronisée au prochain passage en ligne. '
          'Les contacts liés non poussés seront aussi supprimés.',
    );
    if (ok != true || !context.mounted) return;
    final result =
        await ref.read(thirdPartyRepositoryProvider).deleteLocal(localId);
    if (!context.mounted) return;
    result.fold(
      onSuccess: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Suppression enregistrée.')),
        );
        context.go(RoutePaths.thirdparties);
      },
      onFailure: (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec : $f')),
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.thirdParty});
  final ThirdParty thirdParty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = thirdParty;

    return RefreshIndicator(
      onRefresh: () async {
        if (t.remoteId == null) return;
        await ref.read(thirdPartyRepositoryProvider).refreshById(t.remoteId!);
      },
      child: ListView(
        padding: const EdgeInsets.all(AppTokens.spaceMd),
        children: [
          _HeaderCard(thirdParty: t),
          const SizedBox(height: AppTokens.spaceMd),
          _ActionsRow(thirdParty: t),
          const SizedBox(height: AppTokens.spaceMd),
          _InfosSection(thirdParty: t),
          if ((t.address ?? t.zip ?? t.town) != null)
            _AddressSection(thirdParty: t),
          _ContactSection(thirdParty: t),
          _IdsSection(thirdParty: t),
          ThirdPartyContactsSection(thirdPartyLocalId: t.localId),
          ThirdPartyProjectsSection(thirdPartyLocalId: t.localId),
          ThirdPartyProposalsSection(thirdPartyLocalId: t.localId),
          ThirdPartyInvoicesSection(thirdPartyLocalId: t.localId),
          if (t.notePublic != null || t.notePrivate != null)
            _NotesSection(thirdParty: t),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.thirdParty});
  final ThirdParty thirdParty;

  @override
  Widget build(BuildContext context) {
    final c = DoliMobColors.of(context);
    final t = thirdParty;
    final ChipTone tone;
    final String typeLabel;
    if (t.isProspect) {
      tone = ChipTone.info;
      typeLabel = 'Prospect';
    } else if (t.isSupplier) {
      tone = ChipTone.warning;
      typeLabel = 'Fournisseur';
    } else {
      tone = ChipTone.success;
      typeLabel = 'Client';
    }
    return Row(
      children: [
        ColoredAvatar(name: t.name, size: 56),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.name,
                style: TextStyle(
                  color: c.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  DoliMobChip(label: typeLabel, tone: tone),
                  if (t.codeClient != null && t.codeClient!.isNotEmpty)
                    DoliMobChip(label: t.codeClient!),
                ],
              ),
            ],
          ),
        ),
        SyncStatusBadge(status: t.syncStatus),
      ],
    );
  }
}

class _ActionsRow extends StatelessWidget {
  const _ActionsRow({required this.thirdParty});
  final ThirdParty thirdParty;

  Future<void> _open(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = thirdParty;
    final actions = <Widget>[];
    if (t.phone != null && t.phone!.isNotEmpty) {
      actions.add(QuickActionChip(
        icon: LucideIcons.phone,
        label: 'Appeler',
        onPressed: () => _open(Uri(scheme: 'tel', path: t.phone)),
      ));
    }
    if (t.email != null && t.email!.isNotEmpty) {
      actions.add(QuickActionChip(
        icon: LucideIcons.mail,
        label: 'Email',
        onPressed: () => _open(Uri(scheme: 'mailto', path: t.email)),
      ));
    }
    if (t.fullAddress.isNotEmpty) {
      actions.add(QuickActionChip(
        icon: LucideIcons.map,
        label: 'Itinéraire',
        onPressed: () => _open(
          Uri.parse(
            'https://www.openstreetmap.org/search?query='
            '${Uri.encodeQueryComponent(t.fullAddress)}',
          ),
        ),
      ));
    }
    if (actions.isEmpty) return const SizedBox.shrink();
    return Wrap(spacing: 8, runSpacing: 8, children: actions);
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

class _InfosSection extends StatelessWidget {
  const _InfosSection({required this.thirdParty});
  final ThirdParty thirdParty;
  @override
  Widget build(BuildContext context) {
    final t = thirdParty;
    final kinds = <String>[];
    if (t.isCustomer) kinds.add('Client');
    if (t.isProspect) kinds.add('Prospect');
    if (t.isSupplier) kinds.add('Fournisseur');
    return _Section(
      title: 'Informations générales',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Field(label: 'Type', value: kinds.join(', ')),
          _Field(label: 'Code client', value: t.codeClient),
          _Field(label: 'Code fourn.', value: t.codeFournisseur),
          _Field(
            label: 'Statut',
            value: t.isActive ? 'Actif' : 'Inactif',
          ),
        ],
      ),
    );
  }
}

class _AddressSection extends ConsumerWidget {
  const _AddressSection({required this.thirdParty});
  final ThirdParty thirdParty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = thirdParty;
    final config = ref.watch(appConfigProvider);
    return _Section(
      title: 'Adresse',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (t.fullAddress.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.spaceXs),
              child: Text(t.fullAddress),
            ),
          // Carte indicative non géocodée — la position réelle dépendrait
          // d'un géocodage qui sortirait du périmètre Étape 6.
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTokens.radiusCard),
            child: SizedBox(
              height: 160,
              child: FlutterMap(
                options: const MapOptions(
                  initialCenter: LatLng(46.603354, 1.888334),
                  initialZoom: 5,
                ),
                children: [
                  TileLayer(
                    urlTemplate: config.mapTileUrl,
                    userAgentPackageName: 'cloud.scinnova.dolibarr_mobile',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection({required this.thirdParty});
  final ThirdParty thirdParty;
  @override
  Widget build(BuildContext context) {
    final t = thirdParty;
    return _Section(
      title: 'Contact',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Field(label: 'Téléphone', value: t.phone),
          _Field(label: 'Email', value: t.email),
          _Field(label: 'Site web', value: t.url),
        ],
      ),
    );
  }
}

class _IdsSection extends StatelessWidget {
  const _IdsSection({required this.thirdParty});
  final ThirdParty thirdParty;
  @override
  Widget build(BuildContext context) {
    final t = thirdParty;
    if (t.siren == null && t.siret == null && t.tvaIntra == null) {
      return const SizedBox.shrink();
    }
    return _Section(
      title: 'Identifiants fiscaux',
      initiallyExpanded: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Field(label: 'SIREN', value: t.siren),
          _Field(label: 'SIRET', value: t.siret),
          _Field(label: 'TVA intra.', value: t.tvaIntra),
        ],
      ),
    );
  }
}

class _NotesSection extends StatelessWidget {
  const _NotesSection({required this.thirdParty});
  final ThirdParty thirdParty;
  @override
  Widget build(BuildContext context) {
    final t = thirdParty;
    return _Section(
      title: 'Notes',
      initiallyExpanded: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (t.notePublic != null && t.notePublic!.isNotEmpty) ...[
            const Text(
              'Publique',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(t.notePublic!),
            const SizedBox(height: AppTokens.spaceMd),
          ],
          if (t.notePrivate != null && t.notePrivate!.isNotEmpty) ...[
            const Row(
              children: [
                Icon(LucideIcons.lock, size: 14),
                SizedBox(width: 4),
                Text(
                  'Privée',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(t.notePrivate!),
          ],
        ],
      ),
    );
  }
}
