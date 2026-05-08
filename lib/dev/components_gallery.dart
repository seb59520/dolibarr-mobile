import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:dolibarr_mobile/core/theme/app_theme.dart';
import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/shared/widgets/app_card.dart';
import 'package:dolibarr_mobile/shared/widgets/bottom_action_bar.dart';
import 'package:dolibarr_mobile/shared/widgets/confirm_dialog.dart';
import 'package:dolibarr_mobile/shared/widgets/empty_state.dart';
import 'package:dolibarr_mobile/shared/widgets/entity_avatar.dart';
import 'package:dolibarr_mobile/shared/widgets/error_state.dart';
import 'package:dolibarr_mobile/shared/widgets/loading_skeleton.dart';
import 'package:dolibarr_mobile/shared/widgets/quick_action_chip.dart';
import 'package:dolibarr_mobile/shared/widgets/search_field.dart';
import 'package:dolibarr_mobile/shared/widgets/sync_status_badge.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Galerie type Storybook : permet d'inspecter visuellement chaque
/// composant partagé en clair + sombre.
///
/// Activée via `--dart-define=DEV_GALLERY=true` ou en l'instanciant
/// depuis un menu caché des Paramètres en build debug.
class ComponentsGalleryApp extends StatelessWidget {
  const ComponentsGalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Components Gallery',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const ComponentsGalleryPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ComponentsGalleryPage extends StatelessWidget {
  const ComponentsGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _sections.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Components Gallery'),
          bottom: TabBar(
            isScrollable: true,
            tabs: [for (final s in _sections) Tab(text: s.title)],
          ),
        ),
        body: TabBarView(
          children: [for (final s in _sections) s.builder(context)],
        ),
      ),
    );
  }

  static const _sections = <_Section>[
    _Section('AppCard', _appCardSection),
    _Section('Avatars', _avatarsSection),
    _Section('Badges', _badgesSection),
    _Section('Chips', _chipsSection),
    _Section('Search', _searchSection),
    _Section('Empty/Error', _emptyErrorSection),
    _Section('Skeletons', _skeletonsSection),
    _Section('Bars/Dialogs', _barsDialogsSection),
  ];
}

class _Section {
  const _Section(this.title, this.builder);
  final String title;
  final Widget Function(BuildContext) builder;
}

Widget _appCardSection(BuildContext context) => ListView(
      children: [
        const SizedBox(height: AppTokens.spaceMd),
        AppCard(
          onTap: () {},
          child: const Row(
            children: [
              EntityAvatar(name: 'ACME SAS'),
              SizedBox(width: AppTokens.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACME SAS',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text('C00012 · Paris'),
                  ],
                ),
              ),
              SyncStatusBadge(status: SyncStatus.synced, compact: true),
            ],
          ),
        ),
        AppCard(
          onTap: () {},
          child: const Text(
            'Card simple sans avatar — exemple de fiche compacte.',
          ),
        ),
      ],
    );

Widget _avatarsSection(BuildContext context) => const Center(
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          EntityAvatar(name: 'ACME SAS'),
          EntityAvatar(name: 'Jeanne Doe'),
          EntityAvatar(name: 'Boulangerie Dupont'),
          EntityAvatar(name: 'Tech Industries'),
          EntityAvatar(name: 'X'),
          EntityAvatar(name: '', size: 56),
        ],
      ),
    );

Widget _badgesSection(BuildContext context) => const Center(
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          SyncStatusBadge(status: SyncStatus.synced),
          SyncStatusBadge(status: SyncStatus.pendingCreate),
          SyncStatusBadge(status: SyncStatus.pendingUpdate),
          SyncStatusBadge(status: SyncStatus.conflict),
          SyncStatusBadge(status: SyncStatus.synced, offline: true),
          SyncStatusBadge(status: SyncStatus.pendingUpdate, compact: true),
        ],
      ),
    );

Widget _chipsSection(BuildContext context) => Center(
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          QuickActionChip(
            icon: LucideIcons.phone,
            label: 'Appeler',
            onPressed: () {},
          ),
          QuickActionChip(
            icon: LucideIcons.mail,
            label: 'Email',
            onPressed: () {},
            tonal: false,
          ),
          QuickActionChip(
            icon: LucideIcons.map,
            label: 'Itinéraire',
            onPressed: () {},
          ),
          const QuickActionChip(
            icon: LucideIcons.phone,
            label: 'Désactivé',
            onPressed: null,
          ),
        ],
      ),
    );

Widget _searchSection(BuildContext context) => Padding(
      padding: const EdgeInsets.all(AppTokens.spaceMd),
      child: SearchField(
        onChanged: (v) {
          if (kDebugMode) debugPrint('search: $v');
        },
      ),
    );

Widget _emptyErrorSection(BuildContext context) => Column(
      children: [
        Expanded(
          child: EmptyState(
            icon: LucideIcons.users,
            title: 'Aucun tiers',
            description: 'Commencez par en créer un.',
            actionLabel: 'Créer un tiers',
            action: () {},
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ErrorState(
            title: 'Impossible de charger les tiers',
            description: 'Vérifiez votre connexion et réessayez.',
            onRetry: () {},
          ),
        ),
      ],
    );

Widget _skeletonsSection(BuildContext context) => ListView(
      children: [
        const SizedBox(height: AppTokens.spaceMd),
        LoadingSkeleton.card(),
        LoadingSkeleton.card(),
        LoadingSkeleton.card(),
        const SizedBox(height: AppTokens.spaceLg),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.spaceMd,
          ),
          child: LoadingSkeleton.line(width: 240),
        ),
      ],
    );

Widget _barsDialogsSection(BuildContext context) => Stack(
      children: [
        Center(
          child: FilledButton(
            onPressed: () => ConfirmDialog.show(
              context,
              title: 'Confirmer',
              message: 'Voulez-vous vraiment continuer ?',
            ),
            child: const Text('Confirm dialog'),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: BottomActionBar(
            primary: FilledButton(
              onPressed: () {},
              child: const Text('Enregistrer'),
            ),
            secondary: OutlinedButton(
              onPressed: () {},
              child: const Text('Annuler'),
            ),
          ),
        ),
      ],
    );
