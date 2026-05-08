import 'package:dolibarr_mobile/core/routing/route_paths.dart';
import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/features/tasks/domain/entities/task.dart';
import 'package:dolibarr_mobile/features/tasks/presentation/providers/task_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Section "Tâches" rendue sur la fiche d'un projet : liste les tâches
/// du projet et propose un bouton "Ajouter".
class ProjectTasksSection extends ConsumerWidget {
  const ProjectTasksSection({
    required this.projectLocalId,
    super.key,
  });

  final int projectLocalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final async = ref.watch(tasksByProjectLocalProvider(projectLocalId));
    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppTokens.spaceXs),
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child:
                      Text('Tâches', style: theme.textTheme.titleMedium),
                ),
                TextButton.icon(
                  onPressed: () => context.go(
                    RoutePaths.taskNewForProject(projectLocalId),
                  ),
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('Ajouter'),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.spaceXs),
            async.when(
              data: (items) {
                if (items.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Aucune tâche.',
                      style: theme.textTheme.bodySmall,
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final t in items) _TaskTile(task: t),
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: LinearProgressIndicator(),
              ),
              error: (_, __) => Text(
                'Tâches indisponibles.',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task});
  final Task task;

  @override
  Widget build(BuildContext context) {
    final t = task;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        t.isClosed ? LucideIcons.checkCircle : LucideIcons.circle,
        size: 20,
        color: t.isClosed
            ? AppTokens.syncSynced
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Text(
        t.displayLabel,
        style: t.isClosed
            ? const TextStyle(decoration: TextDecoration.lineThrough)
            : null,
      ),
      subtitle: t.progress > 0
          ? LinearProgressIndicator(
              value: (t.progress / 100).clamp(0, 1),
              minHeight: 4,
            )
          : null,
      trailing: const Icon(LucideIcons.chevronRight),
      onTap: () =>
          context.go(RoutePaths.taskDetailFor(t.localId)),
    );
  }
}
