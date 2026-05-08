import 'package:dolibarr_mobile/core/routing/route_paths.dart';
import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/features/projects/domain/entities/project.dart';
import 'package:dolibarr_mobile/features/projects/presentation/providers/project_providers.dart';
import 'package:dolibarr_mobile/features/tasks/presentation/widgets/project_tasks_section.dart';
import 'package:dolibarr_mobile/features/thirdparties/presentation/providers/third_party_providers.dart';
import 'package:dolibarr_mobile/shared/widgets/confirm_dialog.dart';
import 'package:dolibarr_mobile/shared/widgets/error_state.dart';
import 'package:dolibarr_mobile/shared/widgets/loading_skeleton.dart';
import 'package:dolibarr_mobile/shared/widgets/sync_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProjectDetailPage extends ConsumerWidget {
  const ProjectDetailPage({required this.localId, super.key});

  final int localId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(projectByIdProvider(localId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projet'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.edit),
            tooltip: 'Modifier',
            onPressed: () =>
                context.go(RoutePaths.projectEditFor(localId)),
          ),
          IconButton(
            icon: const Icon(LucideIcons.trash2),
            tooltip: 'Supprimer',
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: async.when(
        data: (p) => p == null
            ? const ErrorState(
                title: 'Projet introuvable',
                description: "Cette fiche n'existe plus dans le cache.",
              )
            : _DetailBody(project: p),
        loading: () => Center(child: LoadingSkeleton.card()),
        error: (e, _) => ErrorState(
          title: 'Impossible de charger le projet',
          description: '$e',
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await ConfirmDialog.showDestructive(
      context,
      title: 'Supprimer ce projet ?',
      message:
          'La suppression sera synchronisée au prochain passage en ligne.',
    );
    if (ok != true || !context.mounted) return;
    final result =
        await ref.read(projectRepositoryProvider).deleteLocal(localId);
    if (!context.mounted) return;
    result.fold(
      onSuccess: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Suppression enregistrée.')),
        );
        context.go(RoutePaths.projects);
      },
      onFailure: (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec : $f')),
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.project});
  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final p = project;
    return RefreshIndicator(
      onRefresh: () async {
        if (p.remoteId == null) return;
        await ref.read(projectRepositoryProvider).refreshById(p.remoteId!);
      },
      child: ListView(
        padding: const EdgeInsets.all(AppTokens.spaceMd),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  p.displayLabel,
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              SyncStatusBadge(status: p.syncStatus),
            ],
          ),
          const SizedBox(height: AppTokens.spaceMd),
          _StatusBanner(status: p.status),
          const SizedBox(height: AppTokens.spaceMd),
          _ParentLink(project: p),
          _DatesSection(project: p),
          if (p.description != null && p.description!.isNotEmpty)
            _DescriptionSection(project: p),
          if (p.budgetAmount != null ||
              p.oppAmount != null ||
              p.oppPercent != null)
            _FinancialSection(project: p),
          ProjectTasksSection(projectLocalId: p.localId),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.status});
  final ProjectStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (label, color) = switch (status) {
      ProjectStatus.draft => ('Brouillon', AppTokens.syncPending),
      ProjectStatus.opened => ('Ouvert', AppTokens.syncSynced),
      ProjectStatus.closed => ('Fermé', AppTokens.syncOffline),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.spaceMd,
        vertical: AppTokens.spaceXs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTokens.radiusChip),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppTokens.spaceXs),
          Text(
            label,
            style: TextStyle(color: scheme.onSurface),
          ),
        ],
      ),
    );
  }
}

class _ParentLink extends ConsumerWidget {
  const _ParentLink({required this.project});
  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = project;
    if (p.socidLocal != null) {
      final async = ref.watch(thirdPartyByIdProvider(p.socidLocal!));
      return async.maybeWhen(
        data: (tp) {
          if (tp == null) return const SizedBox.shrink();
          return Card(
            child: ListTile(
              leading: const Icon(LucideIcons.briefcase),
              title: Text(tp.name),
              subtitle: const Text('Tiers parent'),
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
    if (p.socidRemote != null) {
      return Card(
        child: ListTile(
          leading: const Icon(LucideIcons.briefcase),
          title: Text('Tiers #${p.socidRemote}'),
          subtitle: const Text('Tiers parent'),
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

class _DatesSection extends StatelessWidget {
  const _DatesSection({required this.project});
  final Project project;

  @override
  Widget build(BuildContext context) {
    final p = project;
    String? fmt(DateTime? d) {
      if (d == null) return null;
      return '${d.day.toString().padLeft(2, '0')}/'
          '${d.month.toString().padLeft(2, '0')}/${d.year}';
    }

    return _Section(
      title: 'Période',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Field(label: 'Début', value: fmt(p.dateStart)),
          _Field(label: 'Fin', value: fmt(p.dateEnd)),
        ],
      ),
    );
  }
}

class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection({required this.project});
  final Project project;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Description',
      child: Text(project.description ?? ''),
    );
  }
}

class _FinancialSection extends StatelessWidget {
  const _FinancialSection({required this.project});
  final Project project;

  @override
  Widget build(BuildContext context) {
    final p = project;
    return _Section(
      title: 'Financier',
      initiallyExpanded: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Field(label: 'Budget', value: p.budgetAmount),
          _Field(label: 'Opportunité', value: p.oppAmount),
          _Field(
            label: '% gain',
            value: p.oppPercent == null ? null : '${p.oppPercent} %',
          ),
        ],
      ),
    );
  }
}
