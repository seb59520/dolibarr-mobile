import 'dart:typed_data';

import 'package:dolibarr_mobile/core/preferences/tweaks.dart';
import 'package:dolibarr_mobile/core/routing/route_paths.dart';
import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/core/utils/formatters.dart';
import 'package:dolibarr_mobile/core/utils/pdf_share.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice_line.dart';
import 'package:dolibarr_mobile/features/invoices/presentation/providers/invoice_providers.dart';
import 'package:dolibarr_mobile/features/invoices/presentation/widgets/invoice_line_edit_dialog.dart';
import 'package:dolibarr_mobile/features/thirdparties/presentation/providers/third_party_providers.dart';
import 'package:dolibarr_mobile/shared/widgets/confirm_dialog.dart';
import 'package:dolibarr_mobile/shared/widgets/error_state.dart';
import 'package:dolibarr_mobile/shared/widgets/loading_skeleton.dart';
import 'package:dolibarr_mobile/shared/widgets/sync_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Compte bancaire SCINNOVA (Shine) — seul compte actif côté Dolibarr.
/// Exigé par /invoices/{id}/payments quand le module Banque est actif.
/// Si plusieurs comptes existent un jour, exposer un sélecteur dans la
/// sheet d'encaissement.
const int _kDefaultBankAccountId = 1;

class InvoiceDetailPage extends ConsumerWidget {
  const InvoiceDetailPage({required this.localId, super.key});

  final int localId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(invoiceByIdProvider(localId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Facture'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.edit),
            tooltip: 'Modifier',
            onPressed: () =>
                context.go(RoutePaths.invoiceEditFor(localId)),
          ),
          IconButton(
            icon: const Icon(LucideIcons.trash2),
            tooltip: 'Supprimer',
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: async.when(
        data: (i) => i == null
            ? const ErrorState(
                title: 'Facture introuvable',
                description: "Cette fiche n'existe plus dans le cache.",
              )
            : _Body(invoice: i),
        loading: () => Center(child: LoadingSkeleton.card()),
        error: (e, _) => ErrorState(
          title: 'Impossible de charger la facture',
          description: '$e',
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await ConfirmDialog.showDestructive(
      context,
      title: 'Supprimer cette facture ?',
      message:
          'La suppression sera synchronisée au prochain passage en ligne.',
    );
    if (ok != true || !context.mounted) return;
    final result =
        await ref.read(invoiceRepositoryProvider).deleteLocal(localId);
    if (!context.mounted) return;
    result.fold(
      onSuccess: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Suppression enregistrée.')),
        );
        context.go(RoutePaths.invoices);
      },
      onFailure: (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec : $f')),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.invoice});
  final Invoice invoice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final i = invoice;
    final linesAsync =
        ref.watch(invoiceLinesByInvoiceLocalProvider(i.localId));

    final fields =
        ref.watch(tweaksProvider.select((t) => t.invoiceFields));
    final showClient = fields.contains(InvoiceCardField.client) &&
        (i.socidLocal != null || i.socidRemote != null);
    String? clientName;
    if (showClient) {
      if (i.socidLocal != null) {
        clientName = ref
            .watch(thirdPartyByIdProvider(i.socidLocal!))
            .maybeWhen(data: (tp) => tp?.name, orElse: () => null);
      } else if (i.socidRemote != null) {
        clientName = ref
            .watch(thirdPartyByRemoteIdProvider(i.socidRemote!))
            .maybeWhen(data: (tp) => tp?.name, orElse: () => null);
      }
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (i.remoteId == null) return;
        await ref.read(invoiceRepositoryProvider).refreshById(i.remoteId!);
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
                      i.displayLabel,
                      style: theme.textTheme.headlineSmall,
                    ),
                    if (clientName != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          clientName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SyncStatusBadge(status: i.syncStatus),
            ],
          ),
          const SizedBox(height: AppTokens.spaceMd),
          _StatusBanner(invoice: i),
          const SizedBox(height: AppTokens.spaceMd),
          _WorkflowActions(invoice: i),
          _ParentLink(invoice: i),
          _DatesSection(invoice: i),
          _LinesSection(invoice: i, linesAsync: linesAsync),
          _TotalsSection(invoice: i),
          _PaymentsSection(invoice: i),
          if (i.notePublic != null || i.notePrivate != null)
            _NotesSection(invoice: i),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.invoice});
  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final i = invoice;
    final (label, color) = _resolve(i);
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

  (String, Color) _resolve(Invoice i) {
    if (i.isPaid) return ('Payée', AppTokens.syncSynced);
    if (i.isOverdue) return ('En retard', AppTokens.syncConflict);
    return switch (i.status) {
      InvoiceStatus.draft => ('Brouillon', AppTokens.syncOffline),
      InvoiceStatus.validated => ('Validée', AppTokens.syncPending),
      InvoiceStatus.paid => ('Payée', AppTokens.syncSynced),
      InvoiceStatus.abandoned => ('Abandonnée', AppTokens.syncOffline),
    };
  }
}

class _ParentLink extends ConsumerWidget {
  const _ParentLink({required this.invoice});
  final Invoice invoice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i = invoice;
    if (i.socidLocal != null) {
      final async = ref.watch(thirdPartyByIdProvider(i.socidLocal!));
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
    if (i.socidRemote != null) {
      final async = ref.watch(thirdPartyByRemoteIdProvider(i.socidRemote!));
      return async.maybeWhen(
        data: (tp) {
          if (tp != null) {
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
          }
          // Tiers pas encore en cache local : on garde l'affichage
          // identifiant remote en attendant une sync des tiers.
          return Card(
            child: ListTile(
              leading: const Icon(LucideIcons.briefcase),
              title: Text('Client #${i.socidRemote}'),
              subtitle: const Text('Client'),
            ),
          );
        },
        orElse: () => const SizedBox.shrink(),
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
  const _DatesSection({required this.invoice});
  final Invoice invoice;

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
          _Field(label: 'Émission', value: fmt(invoice.dateInvoice)),
          _Field(label: 'Échéance', value: fmt(invoice.dateDue)),
          if (invoice.refClient != null && invoice.refClient!.isNotEmpty)
            _Field(label: 'Réf. client', value: invoice.refClient!),
        ],
      ),
    );
  }
}

class _LinesSection extends ConsumerWidget {
  const _LinesSection({required this.invoice, required this.linesAsync});
  final Invoice invoice;
  final AsyncValue<List<InvoiceLine>> linesAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final editable = invoice.isDraft;
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
                  'Facture validée — édition des lignes désactivée.',
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
    final line = await InvoiceLineEditDialog.show(
      context,
      invoiceLocalId: invoice.localId,
      invoiceRemoteId: invoice.remoteId,
    );
    if (line == null || !context.mounted) return;
    final result =
        await ref.read(invoiceRepositoryProvider).createLocalLine(line);
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
    InvoiceLine line,
  ) async {
    final updated = await InvoiceLineEditDialog.show(
      context,
      invoiceLocalId: invoice.localId,
      invoiceRemoteId: invoice.remoteId,
      existing: line,
    );
    if (updated == null || !context.mounted) return;
    final result =
        await ref.read(invoiceRepositoryProvider).updateLocalLine(updated);
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
    InvoiceLine line,
  ) async {
    final ok = await ConfirmDialog.showDestructive(
      context,
      title: 'Supprimer cette ligne ?',
      message: line.displayLabel,
    );
    if (ok != true || !context.mounted) return;
    final result = await ref
        .read(invoiceRepositoryProvider)
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
  final InvoiceLine line;
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
                  formatMoney(line.totalHt),
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
            [
              'Qté ${formatQty(line.qty)}',
              if (line.subprice != null) '× ${formatMoney(line.subprice)}',
              if (line.tvaTx != null) 'TVA ${formatPercent(line.tvaTx)}',
            ].join(' · '),
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
  const _TotalsSection({required this.invoice});
  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Totaux',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Field(label: 'Total HT', value: formatMoney(invoice.totalHt)),
          _Field(label: 'TVA', value: formatMoney(invoice.totalTva)),
          _Field(label: 'Total TTC', value: formatMoney(invoice.totalTtc)),
        ],
      ),
    );
  }
}

class _NotesSection extends StatelessWidget {
  const _NotesSection({required this.invoice});
  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    final i = invoice;
    return _Section(
      title: 'Notes',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (i.notePublic != null && i.notePublic!.isNotEmpty) ...[
            const Text('Publique',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(i.notePublic!),
          ],
          if (i.notePrivate != null && i.notePrivate!.isNotEmpty) ...[
            const SizedBox(height: AppTokens.spaceXs),
            const Row(
              children: [
                Icon(LucideIcons.lock, size: 14),
                SizedBox(width: 4),
                Text('Privée',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 4),
            Text(i.notePrivate!),
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
  const _WorkflowActions({required this.invoice});
  final Invoice invoice;

  @override
  ConsumerState<_WorkflowActions> createState() => _WorkflowActionsState();
}

class _WorkflowActionsState extends ConsumerState<_WorkflowActions> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final i = widget.invoice;
    final actions = <Widget>[];
    final canValidate = i.isDraft && i.remoteId != null;
    final canAddPayment = !i.isDraft && i.paye == 0 && i.remoteId != null;
    final canDownloadPdf = !i.isDraft && i.remoteId != null;

    if (canValidate) {
      actions.add(
        FilledButton.icon(
          onPressed: _busy ? null : _validate,
          icon: const Icon(LucideIcons.checkCircle, size: 16),
          label: const Text('Valider'),
        ),
      );
    }
    if (canAddPayment) {
      actions.add(
        FilledButton.tonalIcon(
          onPressed: _busy ? null : _addPayment,
          icon: const Icon(LucideIcons.banknote, size: 16),
          label: const Text('Encaisser'),
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
        .read(invoiceRepositoryProvider)
        .validate(widget.invoice.localId);
    if (!mounted) return;
    setState(() => _busy = false);
    r.fold(
      onSuccess: (_) => _toast('Facture validée.'),
      onFailure: (f) => _toast('Échec : $f'),
    );
  }

  Future<void> _addPayment() async {
    final entry = await _PaymentEntryDialog.show(
      context,
      invoiceTotal: widget.invoice.totalTtc,
    );
    if (entry == null || !mounted) return;
    setState(() => _busy = true);
    final r = await ref.read(invoiceRepositoryProvider).createPayment(
          localId: widget.invoice.localId,
          date: entry.date,
          accountId: _kDefaultBankAccountId,
          paymentTypeCode: entry.typeCode,
          num: entry.num,
          note: entry.note,
        );
    if (!mounted) return;
    setState(() => _busy = false);
    r.fold(
      onSuccess: (_) => _toast('Paiement enregistré.'),
      onFailure: (f) => _toast('Échec : $f'),
    );
  }

  Future<void> _downloadPdf() async {
    setState(() => _busy = true);
    final r = await ref
        .read(invoiceRepositoryProvider)
        .downloadPdf(widget.invoice.localId);
    if (!mounted) return;
    setState(() => _busy = false);
    await r.fold(
      onSuccess: (data) async {
        try {
          await sharePdfBytes(
            Uint8List.fromList(data.bytes),
            data.filename,
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

class _PaymentEntry {
  const _PaymentEntry({
    required this.date,
    this.typeCode,
    this.num,
    this.note,
  });
  final DateTime date;
  final String? typeCode;
  final String? num;
  final String? note;
}

class _PaymentEntryDialog extends StatefulWidget {
  const _PaymentEntryDialog({this.invoiceTotal});
  final String? invoiceTotal;

  static Future<_PaymentEntry?> show(
    BuildContext context, {
    String? invoiceTotal,
  }) {
    return showDialog<_PaymentEntry>(
      context: context,
      builder: (_) => _PaymentEntryDialog(invoiceTotal: invoiceTotal),
    );
  }

  @override
  State<_PaymentEntryDialog> createState() => _PaymentEntryDialogState();
}

/// Modes de paiement connus de Dolibarr (codes `c_paiement`).
/// Le mapping vers les IDs int Dolibarr est fait côté repository.
const Map<String, String> _kPaymentModes = {
  'VIR': 'Virement',
  'CB': 'Carte bancaire',
  'CHQ': 'Chèque',
  'LIQ': 'Espèces',
  'PRE': 'Prélèvement',
};

class _PaymentEntryDialogState extends State<_PaymentEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  String _typeCode = 'VIR';
  final _numCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _numCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fmt = '${_date.day.toString().padLeft(2, '0')}/'
        '${_date.month.toString().padLeft(2, '0')}/${_date.year}';
    final totalLabel = widget.invoiceTotal != null
        ? formatMoney(widget.invoiceTotal)
        : null;
    return AlertDialog(
      title: const Text('Encaisser le solde'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (totalLabel != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.banknote,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Montant facture : $totalLabel',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              if (totalLabel != null)
                const SizedBox(height: AppTokens.spaceXs),
              Text(
                'Dolibarr encaisse le solde restant. Pour un paiement '
                'partiel, passe par l’interface web.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppTokens.spaceMd),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Date'),
                  child: Text(fmt),
                ),
              ),
              const SizedBox(height: AppTokens.spaceMd),
              DropdownButtonFormField<String>(
                initialValue: _typeCode,
                decoration: const InputDecoration(labelText: 'Mode'),
                items: [
                  for (final e in _kPaymentModes.entries)
                    DropdownMenuItem(
                      value: e.key,
                      child: Text('${e.value} (${e.key})'),
                    ),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _typeCode = v);
                },
              ),
              const SizedBox(height: AppTokens.spaceMd),
              TextFormField(
                controller: _numCtrl,
                decoration: const InputDecoration(
                  labelText: 'Numéro (chèque/transaction)',
                ),
              ),
              const SizedBox(height: AppTokens.spaceMd),
              TextFormField(
                controller: _noteCtrl,
                decoration: const InputDecoration(labelText: 'Commentaire'),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            String? notEmpty(String s) =>
                s.trim().isEmpty ? null : s.trim();
            Navigator.of(context).pop(
              _PaymentEntry(
                date: _date,
                typeCode: _typeCode,
                num: notEmpty(_numCtrl.text),
                note: notEmpty(_noteCtrl.text),
              ),
            );
          },
          child: const Text('Encaisser'),
        ),
      ],
    );
  }
}

class _PaymentsSection extends ConsumerWidget {
  const _PaymentsSection({required this.invoice});
  final Invoice invoice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (invoice.isDraft || invoice.remoteId == null) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppTokens.spaceXs),
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Paiements', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppTokens.spaceXs),
            FutureBuilder(
              future: ref
                  .read(invoiceRepositoryProvider)
                  .fetchPayments(invoice.localId),
              builder: (_, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: LinearProgressIndicator(),
                  );
                }
                final result = snapshot.data!;
                return result.fold(
                  onSuccess: (payments) {
                    if (payments.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Aucun paiement enregistré.',
                          style: theme.textTheme.bodySmall,
                        ),
                      );
                    }
                    return Column(
                      children: [
                        for (final p in payments)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(LucideIcons.banknote),
                            title: Text(
                              '${formatMoney(p.amount, fallback: '?')}'
                              '${p.type != null ? ' · ${p.type}' : ''}',
                            ),
                            subtitle: Text(
                              p.date == null
                                  ? '—'
                                  : '${p.date!.day.toString().padLeft(2, '0')}/'
                                      '${p.date!.month.toString().padLeft(2, '0')}/'
                                      '${p.date!.year}'
                                      '${p.num != null ? ' · ${p.num}' : ''}',
                            ),
                          ),
                      ],
                    );
                  },
                  onFailure: (f) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Paiements indisponibles : $f',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
