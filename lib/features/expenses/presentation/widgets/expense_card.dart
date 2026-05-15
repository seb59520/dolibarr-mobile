import 'package:dolibarr_mobile/core/preferences/tweaks.dart';
import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/core/utils/formatters.dart';
import 'package:dolibarr_mobile/features/expenses/domain/entities/expense_report.dart';
import 'package:dolibarr_mobile/features/expenses/presentation/providers/expense_providers.dart';
import 'package:dolibarr_mobile/shared/widgets/app_card.dart';
import 'package:dolibarr_mobile/shared/widgets/colored_avatar.dart';
import 'package:dolibarr_mobile/shared/widgets/dolimob_chip.dart';
import 'package:dolibarr_mobile/shared/widgets/sync_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Carte d'une note de frais en liste.
///
/// Affichage paramétré par `Tweaks.expenseFields` : `date`/`totalTtc`/
/// `status` sont actifs par défaut ; `period` et `lineCount` sont des
/// options exposées dans la page Tweaks.
class ExpenseCard extends ConsumerWidget {
  const ExpenseCard({
    required this.expense,
    this.onTap,
    this.offline = false,
    super.key,
  });

  final ExpenseReport expense;
  final VoidCallback? onTap;
  final bool offline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final e = expense;
    final fields =
        ref.watch(tweaksProvider.select((t) => t.expenseFields));
    final density = ref.watch(tweaksProvider.select((t) => t.density));

    final showDate = fields.contains(ExpenseCardField.date) &&
        (e.dateDebut != null || e.dateFin != null);
    final showTotal =
        fields.contains(ExpenseCardField.totalTtc) && e.totalTtc != null;
    final showStatus = fields.contains(ExpenseCardField.status);
    final showPeriod = fields.contains(ExpenseCardField.period) &&
        e.dateDebut != null &&
        e.dateFin != null;
    final showLineCount = fields.contains(ExpenseCardField.lineCount);

    final title = _titleFor(e);

    return AppCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ColoredAvatar(name: title, size: density.avatarSize),
          const SizedBox(width: AppTokens.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    SyncStatusBadge(
                      status: e.syncStatus,
                      compact: true,
                      offline: offline,
                    ),
                  ],
                ),
                if (showDate) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(LucideIcons.calendar, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        _fmt(e.dateDebut ?? e.dateFin!),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
                if (showPeriod) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(LucideIcons.clock, size: 12),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Période ${_fmt(e.dateDebut!)} → '
                          '${_fmt(e.dateFin!)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
                if (showLineCount)
                  _LineCountRow(reportLocalId: e.localId),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (showTotal)
                      Text(
                        '${formatMoney(e.totalTtc)} TTC',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    if (showTotal && showStatus)
                      const SizedBox(width: AppTokens.spaceXs),
                    if (showStatus)
                      DoliMobChip(
                        label: statusLabel(e.status),
                        tone: statusTone(e.status),
                        compact: true,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _titleFor(ExpenseReport e) {
    final ref = e.ref;
    if (ref != null && ref.trim().isNotEmpty) return ref;
    return 'Brouillon #${e.localId}';
  }

  static String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';
}

/// Libellé court de statut affiché dans le chip (français).
String statusLabel(ExpenseReportStatus s) => switch (s) {
      ExpenseReportStatus.draft => 'Brouillon',
      ExpenseReportStatus.validated => 'Validé',
      ExpenseReportStatus.approved => 'Approuvé',
      ExpenseReportStatus.paid => 'Payé',
      ExpenseReportStatus.refused => 'Refusé',
    };

/// Mapping statut → tone DoliMob. `paid` réutilise `info` (accent) pour
/// rester aligné avec le DS (l'accent teal porte la notion "payé").
ChipTone statusTone(ExpenseReportStatus s) => switch (s) {
      ExpenseReportStatus.draft => ChipTone.warning,
      ExpenseReportStatus.validated => ChipTone.info,
      ExpenseReportStatus.approved => ChipTone.success,
      ExpenseReportStatus.paid => ChipTone.info,
      ExpenseReportStatus.refused => ChipTone.danger,
    };

class _LineCountRow extends ConsumerWidget {
  const _LineCountRow({required this.reportLocalId});

  final int reportLocalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final linesAsync =
        ref.watch(expenseLinesByReportLocalProvider(reportLocalId));
    final count = linesAsync.maybeWhen(
      data: (lines) => lines.length,
      orElse: () => null,
    );
    if (count == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          const Icon(LucideIcons.list, size: 12),
          const SizedBox(width: 4),
          Text(
            '$count ligne${count > 1 ? 's' : ''}',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
