import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/features/projects/domain/entities/project.dart';
import 'package:dolibarr_mobile/shared/widgets/app_card.dart';
import 'package:dolibarr_mobile/shared/widgets/sync_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({
    required this.project,
    this.onTap,
    this.offline = false,
    super.key,
  });

  final Project project;
  final VoidCallback? onTap;
  final bool offline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = project;
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          _StatusDot(status: p.status),
          const SizedBox(width: AppTokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        p.displayLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    SyncStatusBadge(
                      status: p.syncStatus,
                      compact: true,
                      offline: offline,
                    ),
                  ],
                ),
                if (p.description != null && p.description!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    p.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
                if (p.dateStart != null || p.dateEnd != null) ...[
                  const SizedBox(height: AppTokens.spaceXs),
                  Row(
                    children: [
                      const Icon(LucideIcons.calendar, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateRange(p.dateStart, p.dateEnd),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDateRange(DateTime? start, DateTime? end) {
    String fmt(DateTime d) => '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year}';
    if (start != null && end != null) return '${fmt(start)} → ${fmt(end)}';
    if (start != null) return 'Depuis ${fmt(start)}';
    if (end != null) return "Jusqu'au ${fmt(end)}";
    return '';
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.status});
  final ProjectStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      ProjectStatus.draft => AppTokens.syncPending,
      ProjectStatus.opened => AppTokens.syncSynced,
      ProjectStatus.closed => AppTokens.syncOffline,
    };
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
