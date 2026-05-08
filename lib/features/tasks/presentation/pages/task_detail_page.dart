import 'package:dolibarr_mobile/core/routing/route_paths.dart';
import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/features/projects/presentation/providers/project_providers.dart';
import 'package:dolibarr_mobile/features/tasks/domain/entities/task.dart';
import 'package:dolibarr_mobile/features/tasks/presentation/providers/task_providers.dart';
import 'package:dolibarr_mobile/shared/widgets/confirm_dialog.dart';
import 'package:dolibarr_mobile/shared/widgets/error_state.dart';
import 'package:dolibarr_mobile/shared/widgets/loading_skeleton.dart';
import 'package:dolibarr_mobile/shared/widgets/sync_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TaskDetailPage extends ConsumerWidget {
  const TaskDetailPage({required this.localId, super.key});

  final int localId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(taskByIdProvider(localId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tâche'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.edit),
            tooltip: 'Modifier',
            onPressed: () => context.go(RoutePaths.taskEditFor(localId)),
          ),
          IconButton(
            icon: const Icon(LucideIcons.trash2),
            tooltip: 'Supprimer',
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: async.when(
        data: (t) => t == null
            ? const ErrorState(
                title: 'Tâche introuvable',
                description: "Cette fiche n'existe plus dans le cache.",
              )
            : _Body(task: t),
        loading: () => Center(child: LoadingSkeleton.card()),
        error: (e, _) => ErrorState(
          title: 'Impossible de charger la tâche',
          description: '$e',
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await ConfirmDialog.showDestructive(
      context,
      title: 'Supprimer cette tâche ?',
      message:
          'La suppression sera synchronisée au prochain passage en ligne.',
    );
    if (ok != true || !context.mounted) return;
    final result =
        await ref.read(taskRepositoryProvider).deleteLocal(localId);
    if (!context.mounted) return;
    result.fold(
      onSuccess: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Suppression enregistrée.')),
        );
        // Pas de liste racine pour les tâches : retour au projet parent.
        context.pop();
      },
      onFailure: (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec : $f')),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.task});
  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final t = task;
    return RefreshIndicator(
      onRefresh: () async {
        if (t.remoteId == null) return;
        await ref.read(taskRepositoryProvider).refreshById(t.remoteId!);
      },
      child: ListView(
        padding: const EdgeInsets.all(AppTokens.spaceMd),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  t.displayLabel,
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              SyncStatusBadge(status: t.syncStatus),
            ],
          ),
          const SizedBox(height: AppTokens.spaceMd),
          _ProjectLink(task: t),
          if (t.progress > 0) ...[
            const SizedBox(height: AppTokens.spaceMd),
            Text(
              'Avancement : ${t.progress} %',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppTokens.spaceXs),
            LinearProgressIndicator(
              value: (t.progress / 100).clamp(0, 1),
            ),
          ],
          if (t.description != null && t.description!.isNotEmpty) ...[
            const SizedBox(height: AppTokens.spaceLg),
            Text('Description', style: theme.textTheme.titleSmall),
            const SizedBox(height: AppTokens.spaceXs),
            Text(t.description!),
          ],
          if (t.dateStart != null || t.dateEnd != null) ...[
            const SizedBox(height: AppTokens.spaceLg),
            Text('Dates', style: theme.textTheme.titleSmall),
            const SizedBox(height: AppTokens.spaceXs),
            if (t.dateStart != null)
              Text('Début : ${_fmt(t.dateStart!)}'),
            if (t.dateEnd != null) Text('Fin : ${_fmt(t.dateEnd!)}'),
          ],
        ],
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _ProjectLink extends ConsumerWidget {
  const _ProjectLink({required this.task});
  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = task;
    if (t.projectLocal != null) {
      final async = ref.watch(projectByIdProvider(t.projectLocal!));
      return async.maybeWhen(
        data: (p) {
          if (p == null) return const SizedBox.shrink();
          return Card(
            child: ListTile(
              leading: const Icon(LucideIcons.folderOpen),
              title: Text(p.displayLabel),
              subtitle: const Text('Projet parent'),
              trailing: const Icon(LucideIcons.chevronRight),
              onTap: () =>
                  context.go(RoutePaths.projectDetailFor(p.localId)),
            ),
          );
        },
        orElse: () => const SizedBox.shrink(),
      );
    }
    if (t.projectRemote != null) {
      return Card(
        child: ListTile(
          leading: const Icon(LucideIcons.folderOpen),
          title: Text('Projet #${t.projectRemote}'),
          subtitle: const Text('Projet parent'),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
