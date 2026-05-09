import 'dart:io';

import 'package:dolibarr_mobile/core/routing/route_paths.dart';
import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/features/proposals/domain/entities/proposal.dart';
import 'package:dolibarr_mobile/features/proposals/domain/entities/proposal_line.dart';
import 'package:dolibarr_mobile/features/proposals/presentation/providers/proposal_providers.dart';
import 'package:dolibarr_mobile/features/proposals/presentation/widgets/proposal_line_edit_dialog.dart';
import 'package:dolibarr_mobile/features/thirdparties/presentation/providers/third_party_providers.dart';
import 'package:dolibarr_mobile/shared/widgets/confirm_dialog.dart';
import 'package:dolibarr_mobile/shared/widgets/error_state.dart';
import 'package:dolibarr_mobile/shared/widgets/loading_skeleton.dart';
import 'package:dolibarr_mobile/shared/widgets/sync_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ProposalDetailPage extends ConsumerWidget {
  const ProposalDetailPage({required this.localId, super.key});

  final int localId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(proposalByIdProvider(localId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devis'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.edit),
            tooltip: 'Modifier',
            onPressed: () =>
                context.go(RoutePaths.proposalEditFor(localId)),
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
                title: 'Devis introuvable',
                description: "Cette fiche n'existe plus dans le cache.",
              )
            : _Body(proposal: p),
        loading: () => Center(child: LoadingSkeleton.card()),
        error: (e, _) => ErrorState(
          title: 'Impossible de charger le devis',
          description: '$e',
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await ConfirmDialog.showDestructive(
      context,
      title: 'Supprimer ce devis ?',
      message:
          'La suppression sera synchronisée au prochain passage en ligne.',
    );
    if (ok != true || !context.mounted) return;
    final result =
        await ref.read(proposalRepositoryProvider).deleteLocal(localId);
    if (!context.mounted) return;
    result.fold(
      onSuccess: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Suppression enregistrée.')),
        );
        context.go(RoutePaths.proposals);
      },
      onFailure: (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec : $f')),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.proposal});
  final Proposal proposal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final p = proposal;
    final linesAsync =
        ref.watch(proposalLinesByProposalLocalProvider(p.localId));

    return RefreshIndicator(
      onRefresh: () async {
        if (p.remoteId == null) return;
        await ref.read(proposalRepositoryProvider).refreshById(p.remoteId!);
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
          _StatusBanner(proposal: p),
          const SizedBox(height: AppTokens.spaceMd),
          _WorkflowActions(proposal: p),
          _ParentLink(proposal: p),
          _DatesSection(proposal: p),
          _LinesSection(proposal: p, linesAsync: linesAsync),
          _TotalsSection(proposal: p),
          if (p.notePublic != null || p.notePrivate != null)
            _NotesSection(proposal: p),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.proposal});
  final Proposal proposal;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final p = proposal;
    final (label, color) = _resolve(p);
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

  (String, Color) _resolve(Proposal p) {
    if (p.isExpired && !p.isSigned && !p.isRefused) {
      return ('Expiré', AppTokens.syncConflict);
    }
    return switch (p.status) {
      ProposalStatus.draft => ('Brouillon', AppTokens.syncOffline),
      ProposalStatus.validated => ('Validé', AppTokens.syncPending),
      ProposalStatus.signed => ('Signé', AppTokens.syncSynced),
      ProposalStatus.refused => ('Refusé', AppTokens.syncConflict),
    };
  }
}

class _ParentLink extends ConsumerWidget {
  const _ParentLink({required this.proposal});
  final Proposal proposal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = proposal;
    if (p.socidLocal != null) {
      final async = ref.watch(thirdPartyByIdProvider(p.socidLocal!));
      return async.maybeWhen(
        data: (tp) {
          if (tp == null) return const SizedBox.shrink();
          return Card(
            child: ListTile(
              leading: const Icon(LucideIcons.briefcase),
              title: Text(tp.name),
              subtitle: const Text('Client'),
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
          title: Text('Client #${p.socidRemote}'),
          subtitle: const Text('Client'),
        ),
      );
    }
    return const SizedBox.shrink();
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

class _DatesSection extends StatelessWidget {
  const _DatesSection({required this.proposal});
  final Proposal proposal;

  @override
  Widget build(BuildContext context) {
    String fmt(DateTime? d) => d == null
        ? '—'
        : '${d.day.toString().padLeft(2, '0')}/'
            '${d.month.toString().padLeft(2, '0')}/${d.year}';
    return _Section(
      title: 'Dates',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Field(label: 'Émission', value: fmt(proposal.dateProposal)),
          _Field(label: 'Fin validité', value: fmt(proposal.dateEnd)),
          if (proposal.refClient != null && proposal.refClient!.isNotEmpty)
            _Field(label: 'Réf. client', value: proposal.refClient!),
        ],
      ),
    );
  }
}

class _LinesSection extends ConsumerWidget {
  const _LinesSection({required this.proposal, required this.linesAsync});
  final Proposal proposal;
  final AsyncValue<List<ProposalLine>> linesAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final editable = proposal.isDraft;
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
                  child: Text('Lignes', style: theme.textTheme.titleMedium),
                ),
                if (editable)
                  TextButton.icon(
                    onPressed: () => _addLine(context, ref),
                    icon: const Icon(LucideIcons.plus, size: 16),
                    label: const Text('Ajouter'),
                  ),
              ],
            ),
            if (!editable)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Devis validé — édition des lignes désactivée.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            const SizedBox(height: AppTokens.spaceXs),
            linesAsync.when(
              data: (lines) {
                if (lines.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Aucune ligne.'),
                  );
                }
                return Column(
                  children: [
                    for (final l in lines)
                      _LineTile(
                        line: l,
                        editable: editable,
                        onEdit: () => _editLine(context, ref, l),
                        onDelete: () => _deleteLine(context, ref, l),
                      ),
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

  Future<void> _addLine(BuildContext context, WidgetRef ref) async {
    final line = await ProposalLineEditDialog.show(
      context,
      proposalLocalId: proposal.localId,
      proposalRemoteId: proposal.remoteId,
    );
    if (line == null || !context.mounted) return;
    final result =
        await ref.read(proposalRepositoryProvider).createLocalLine(line);
    if (!context.mounted) return;
    result.fold(
      onSuccess: (_) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ligne ajoutée.')),
      ),
      onFailure: (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec : $f')),
      ),
    );
  }

  Future<void> _editLine(
    BuildContext context,
    WidgetRef ref,
    ProposalLine line,
  ) async {
    final updated = await ProposalLineEditDialog.show(
      context,
      proposalLocalId: proposal.localId,
      proposalRemoteId: proposal.remoteId,
      existing: line,
    );
    if (updated == null || !context.mounted) return;
    final result =
        await ref.read(proposalRepositoryProvider).updateLocalLine(updated);
    if (!context.mounted) return;
    result.fold(
      onSuccess: (_) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ligne modifiée.')),
      ),
      onFailure: (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec : $f')),
      ),
    );
  }

  Future<void> _deleteLine(
    BuildContext context,
    WidgetRef ref,
    ProposalLine line,
  ) async {
    final ok = await ConfirmDialog.showDestructive(
      context,
      title: 'Supprimer cette ligne ?',
      message: line.displayLabel,
    );
    if (ok != true || !context.mounted) return;
    final result = await ref
        .read(proposalRepositoryProvider)
        .deleteLocalLine(line.localId);
    if (!context.mounted) return;
    result.fold(
      onSuccess: (_) {},
      onFailure: (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec : $f')),
      ),
    );
  }
}

class _LineTile extends StatelessWidget {
  const _LineTile({
    required this.line,
    required this.editable,
    required this.onEdit,
    required this.onDelete,
  });
  final ProposalLine line;
  final bool editable;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final body = Padding(
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
              if (line.totalHt != null)
                Text(
                  '${line.totalHt} €',
                  style: theme.textTheme.bodyMedium,
                ),
              if (editable)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(LucideIcons.trash2, size: 16),
                  onPressed: onDelete,
                ),
            ],
          ),
          if (line.description != null &&
              line.description!.isNotEmpty &&
              line.label != null) ...[
            const SizedBox(height: 2),
            Text(line.description!, style: theme.textTheme.bodySmall),
          ],
          const SizedBox(height: 2),
          Text(
            'Qté ${line.qty}'
            '${line.subprice != null ? ' × ${line.subprice} €' : ''}'
            '${line.tvaTx != null ? ' · TVA ${line.tvaTx} %' : ''}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
    if (!editable) return body;
    return InkWell(onTap: onEdit, child: body);
  }
}

class _TotalsSection extends StatelessWidget {
  const _TotalsSection({required this.proposal});
  final Proposal proposal;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Totaux',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Field(label: 'Total HT', value: '${proposal.totalHt ?? '—'} €'),
          _Field(label: 'TVA', value: '${proposal.totalTva ?? '—'} €'),
          _Field(label: 'Total TTC', value: '${proposal.totalTtc ?? '—'} €'),
        ],
      ),
    );
  }
}

class _NotesSection extends StatelessWidget {
  const _NotesSection({required this.proposal});
  final Proposal proposal;

  @override
  Widget build(BuildContext context) {
    final p = proposal;
    return _Section(
      title: 'Notes',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (p.notePublic != null && p.notePublic!.isNotEmpty) ...[
            const Text(
              'Publique',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(p.notePublic!),
          ],
          if (p.notePrivate != null && p.notePrivate!.isNotEmpty) ...[
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
            Text(p.notePrivate!),
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

class _WorkflowActions extends ConsumerStatefulWidget {
  const _WorkflowActions({required this.proposal});
  final Proposal proposal;

  @override
  ConsumerState<_WorkflowActions> createState() => _WorkflowActionsState();
}

class _WorkflowActionsState extends ConsumerState<_WorkflowActions> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.proposal;
    final actions = <Widget>[];
    final canValidate = p.isDraft && p.remoteId != null;
    final canClose = p.status == ProposalStatus.validated &&
        p.remoteId != null;
    final canConvert = p.isSigned && p.remoteId != null;
    final canSetInvoiced = p.isSigned && p.remoteId != null;
    final canDownloadPdf = !p.isDraft && p.remoteId != null;

    if (canValidate) {
      actions.add(
        FilledButton.icon(
          onPressed: _busy ? null : _validate,
          icon: const Icon(LucideIcons.checkCircle, size: 16),
          label: const Text('Valider'),
        ),
      );
    }
    if (canClose) {
      actions
        ..add(
          FilledButton.tonalIcon(
            onPressed: _busy ? null : () => _close(ProposalStatus.signed),
            icon: const Icon(LucideIcons.thumbsUp, size: 16),
            label: const Text('Signé'),
          ),
        )
        ..add(
          OutlinedButton.icon(
            onPressed: _busy ? null : () => _close(ProposalStatus.refused),
            icon: const Icon(LucideIcons.thumbsDown, size: 16),
            label: const Text('Refusé'),
          ),
        );
    }
    if (canConvert) {
      actions.add(
        FilledButton.tonalIcon(
          onPressed: _busy ? null : _convertToInvoice,
          icon: const Icon(LucideIcons.fileOutput, size: 16),
          label: const Text('Créer facture'),
        ),
      );
    }
    if (canSetInvoiced) {
      actions.add(
        OutlinedButton.icon(
          onPressed: _busy ? null : _setInvoiced,
          icon: const Icon(LucideIcons.receipt, size: 16),
          label: const Text('Facturé'),
        ),
      );
    }
    if (canDownloadPdf) {
      actions.add(
        OutlinedButton.icon(
          onPressed: _busy ? null : _downloadPdf,
          icon: const Icon(LucideIcons.fileDown, size: 16),
          label: const Text('PDF'),
        ),
      );
    }

    if (actions.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.spaceXs),
      child: Wrap(spacing: 8, runSpacing: 8, children: actions),
    );
  }

  Future<void> _validate() async {
    setState(() => _busy = true);
    final r = await ref
        .read(proposalRepositoryProvider)
        .validate(widget.proposal.localId);
    if (!mounted) return;
    setState(() => _busy = false);
    r.fold(
      onSuccess: (_) => _toast('Devis validé.'),
      onFailure: (f) => _toast('Échec : $f'),
    );
  }

  Future<void> _close(ProposalStatus status) async {
    final ok = await ConfirmDialog.show(
      context,
      title: status == ProposalStatus.signed
          ? 'Marquer le devis signé ?'
          : 'Marquer le devis refusé ?',
      message: 'Cette action est irréversible côté Dolibarr.',
      confirmLabel: status == ProposalStatus.signed ? 'Signé' : 'Refusé',
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    final r = await ref
        .read(proposalRepositoryProvider)
        .close(widget.proposal.localId, status);
    if (!mounted) return;
    setState(() => _busy = false);
    r.fold(
      onSuccess: (_) => _toast(
        status == ProposalStatus.signed
            ? 'Devis marqué signé.'
            : 'Devis marqué refusé.',
      ),
      onFailure: (f) => _toast('Échec : $f'),
    );
  }

  Future<void> _convertToInvoice() async {
    final ok = await ConfirmDialog.show(
      context,
      title: 'Créer la facture à partir de ce devis ?',
      message: 'Une nouvelle facture brouillon sera créée avec '
          'les mêmes lignes. Le devis sera marqué facturé.',
      confirmLabel: 'Créer',
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    final r = await ref
        .read(proposalRepositoryProvider)
        .convertToInvoice(widget.proposal.localId);
    if (!mounted) return;
    setState(() => _busy = false);
    r.fold(
      onSuccess: (data) {
        _toast('Facture créée — ouverture…');
        context.go(RoutePaths.invoiceDetailFor(data.invoiceLocalId));
      },
      onFailure: (f) => _toast('Échec : $f'),
    );
  }

  Future<void> _setInvoiced() async {
    setState(() => _busy = true);
    final r = await ref
        .read(proposalRepositoryProvider)
        .setInvoiced(widget.proposal.localId);
    if (!mounted) return;
    setState(() => _busy = false);
    r.fold(
      onSuccess: (_) => _toast('Devis marqué facturé.'),
      onFailure: (f) => _toast('Échec : $f'),
    );
  }

  Future<void> _downloadPdf() async {
    setState(() => _busy = true);
    final r = await ref
        .read(proposalRepositoryProvider)
        .downloadPdf(widget.proposal.localId);
    if (!mounted) return;
    setState(() => _busy = false);
    await r.fold(
      onSuccess: (data) async {
        try {
          final dir = await getTemporaryDirectory();
          final file = File('${dir.path}/${data.filename}');
          await file.writeAsBytes(data.bytes);
          await Share.shareXFiles(
            [XFile(file.path, mimeType: 'application/pdf')],
            subject: data.filename,
          );
        } catch (e) {
          _toast("Impossible d'ouvrir le PDF : $e");
        }
      },
      onFailure: (f) async => _toast('Échec : $f'),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}
