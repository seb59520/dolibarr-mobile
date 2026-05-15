import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/core/utils/formatters.dart';
import 'package:dolibarr_mobile/features/expenses/domain/entities/expense_line.dart';
import 'package:dolibarr_mobile/features/expenses/domain/entities/expense_report.dart';
import 'package:dolibarr_mobile/features/expenses/domain/entities/expense_type.dart';
import 'package:dolibarr_mobile/features/expenses/presentation/providers/expense_providers.dart';
import 'package:dolibarr_mobile/features/expenses/presentation/widgets/expense_card.dart';
import 'package:dolibarr_mobile/shared/widgets/dolimob_chip.dart';
import 'package:dolibarr_mobile/shared/widgets/error_state.dart';
import 'package:dolibarr_mobile/shared/widgets/loading_skeleton.dart';
import 'package:dolibarr_mobile/shared/widgets/sync_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Fiche d'une note de frais — lecture seule (étape 27).
///
/// Pas d'action d'édition ni de workflow (valider/approuver). L'écriture
/// arrive à l'étape 29. Affiche : header (statut + ref + période),
/// lignes (date / libellé / type / TVA / TTC), totaux HT/TVA/TTC, et
/// un encart "Lecture seule" en haut.
class ExpenseDetailPage extends ConsumerWidget {
  const ExpenseDetailPage({required this.localId, super.key});

  final int localId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(expenseDetailProvider(localId));
    return Scaffold(
      appBar: AppBar(title: const Text('Note de frais')),
      body: async.when(
        data: (e) => e == null
            ? const ErrorState(
                title: 'Note de frais introuvable',
                description: "Cette fiche n'existe plus dans le cache.",
              )
            : _Body(report: e),
        loading: () => Center(child: LoadingSkeleton.card()),
        error: (e, _) => ErrorState(
          title: 'Impossible de charger la note de frais',
          description: '$e',
        ),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.report});
  final ExpenseReport report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final e = report;
    final linesAsync =
        ref.watch(expenseLinesByReportLocalProvider(e.localId));
    final typesAsync = ref.watch(expenseTypesProvider);

    return RefreshIndicator(
      onRefresh: () async {
        if (e.remoteId == null) return;
        await ref.read(expenseRepositoryProvider).refreshById(e.remoteId!);
      },
      child: ListView(
        padding: const EdgeInsets.all(AppTokens.spaceMd),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.displayLabel,
                      style: theme.textTheme.headlineSmall,
                    ),
                    if (e.dateDebut != null || e.dateFin != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          _periodLabel(e),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SyncStatusBadge(status: e.syncStatus),
            ],
          ),
          const SizedBox(height: AppTokens.spaceMd),
          Row(
            children: [
              DoliMobChip(
                label: statusLabel(e.status),
                tone: statusTone(e.status),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.spaceMd),
          const _ReadOnlyBanner(),
          const SizedBox(height: AppTokens.spaceMd),
          _LinesSection(
            report: e,
            linesAsync: linesAsync,
            typesAsync: typesAsync,
          ),
          _TotalsSection(report: e),
          if ((e.notePublic != null && e.notePublic!.isNotEmpty) ||
              (e.notePrivate != null && e.notePrivate!.isNotEmpty))
            _NotesSection(report: e),
        ],
      ),
    );
  }

  String _periodLabel(ExpenseReport e) {
    String fmt(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year}';
    if (e.dateDebut != null && e.dateFin != null) {
      return 'Période ${fmt(e.dateDebut!)} → ${fmt(e.dateFin!)}';
    }
    return fmt(e.dateDebut ?? e.dateFin!);
  }
}

/// Bannière "lecture seule" rappelant que l'édition arrive plus tard.
class _ReadOnlyBanner extends StatelessWidget {
  const _ReadOnlyBanner();

  @override
  Widget build(BuildContext context) {
    final c = DoliMobColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.spaceMd,
        vertical: AppTokens.spaceXs,
      ),
      decoration: BoxDecoration(
        color: c.fill,
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        border: Border.all(color: c.hairline),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.info, size: 16, color: c.ink2),
          const SizedBox(width: AppTokens.spaceXs),
          Expanded(
            child: Text(
              'Lecture seule — pour ajouter une ligne, scanne un ticket depuis l’onglet Frais.',
              style: TextStyle(color: c.ink2, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppTokens.spaceXs),
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppTokens.spaceXs),
            child,
          ],
        ),
      ),
    );
  }
}

class _LinesSection extends StatelessWidget {
  const _LinesSection({
    required this.report,
    required this.linesAsync,
    required this.typesAsync,
  });

  final ExpenseReport report;
  final AsyncValue<List<ExpenseLine>> linesAsync;
  final AsyncValue<List<ExpenseType>> typesAsync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppTokens.spaceXs),
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lignes', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppTokens.spaceXs),
            linesAsync.when(
              data: (lines) {
                if (lines.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Aucune ligne.'),
                  );
                }
                final types = typesAsync.maybeWhen(
                  data: (t) => t,
                  orElse: () => const <ExpenseType>[],
                );
                return Column(
                  children: [
                    for (final l in lines)
                      ExpenseLineTile(line: l, types: types),
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: LinearProgressIndicator(),
              ),
              error: (_, __) => const Text('Lignes indisponibles.'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ligne unique d'une note de frais.
class ExpenseLineTile extends StatelessWidget {
  const ExpenseLineTile({
    required this.line,
    required this.types,
    super.key,
  });

  final ExpenseLine line;
  final List<ExpenseType> types;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = DoliMobColors.of(context);
    final typeLabel = _resolveTypeLabel();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  line.displayLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (line.totalTtc != null)
                Text(
                  '${formatMoney(line.totalTtc)} TTC',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              if (line.date != null) ...[
                Icon(LucideIcons.calendar, size: 12, color: c.ink3),
                const SizedBox(width: 4),
                Text(_fmt(line.date!), style: theme.textTheme.bodySmall),
                const SizedBox(width: 8),
              ],
              if (typeLabel != null) ...[
                Icon(LucideIcons.tag, size: 12, color: c.ink3),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    typeLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (line.tvaTx != null) ...[
                Icon(LucideIcons.percent, size: 12, color: c.ink3),
                const SizedBox(width: 4),
                Text(
                  'TVA ${formatPercent(line.tvaTx)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String? _resolveTypeLabel() {
    // Préférence : id numérique (fk_c_type_fees). Fallback sur le code
    // textuel quand l'id n'est pas peuplé localement.
    if (line.fkCTypeFees != null) {
      for (final t in types) {
        if (t.remoteId == line.fkCTypeFees) return t.label;
      }
    }
    if (line.codeCTypeFees != null && line.codeCTypeFees!.isNotEmpty) {
      for (final t in types) {
        if (t.code == line.codeCTypeFees) return t.label;
      }
      return line.codeCTypeFees;
    }
    return null;
  }

  static String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _TotalsSection extends StatelessWidget {
  const _TotalsSection({required this.report});
  final ExpenseReport report;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Totaux',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Field(label: 'Total HT', value: formatMoney(report.totalHt)),
          _Field(label: 'TVA', value: formatMoney(report.totalTva)),
          _Field(label: 'Total TTC', value: formatMoney(report.totalTtc)),
        ],
      ),
    );
  }
}

class _NotesSection extends StatelessWidget {
  const _NotesSection({required this.report});
  final ExpenseReport report;

  @override
  Widget build(BuildContext context) {
    final e = report;
    return _Section(
      title: 'Notes',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (e.notePublic != null && e.notePublic!.isNotEmpty) ...[
            const Text(
              'Publique',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(e.notePublic!),
          ],
          if (e.notePrivate != null && e.notePrivate!.isNotEmpty) ...[
            const SizedBox(height: AppTokens.spaceXs),
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
            Text(e.notePrivate!),
          ],
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
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
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
