import 'package:dolibarr_mobile/core/routing/route_paths.dart';
import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice_line.dart';
import 'package:dolibarr_mobile/features/invoices/presentation/providers/invoice_providers.dart';
import 'package:dolibarr_mobile/features/thirdparties/presentation/providers/third_party_providers.dart';
import 'package:dolibarr_mobile/shared/widgets/error_state.dart';
import 'package:dolibarr_mobile/shared/widgets/loading_skeleton.dart';
import 'package:dolibarr_mobile/shared/widgets/sync_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class InvoiceDetailPage extends ConsumerWidget {
  const InvoiceDetailPage({required this.localId, super.key});

  final int localId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(invoiceByIdProvider(localId));
    return Scaffold(
      appBar: AppBar(title: const Text('Facture')),
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
                child: Text(
                  i.displayLabel,
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              SyncStatusBadge(status: i.syncStatus),
            ],
          ),
          const SizedBox(height: AppTokens.spaceMd),
          _StatusBanner(invoice: i),
          const SizedBox(height: AppTokens.spaceMd),
          _ParentLink(invoice: i),
          _DatesSection(invoice: i),
          _LinesSection(linesAsync: linesAsync),
          _TotalsSection(invoice: i),
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
      return Card(
        child: ListTile(
          leading: const Icon(LucideIcons.briefcase),
          title: Text('Client #${i.socidRemote}'),
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

class _LinesSection extends StatelessWidget {
  const _LinesSection({required this.linesAsync});
  final AsyncValue<List<InvoiceLine>> linesAsync;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Lignes',
      child: linesAsync.when(
        data: (lines) {
          if (lines.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Aucune ligne.'),
            );
          }
          return Column(
            children: [
              for (final l in lines) _LineTile(line: l),
            ],
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: LinearProgressIndicator(),
        ),
        error: (_, __) => const Text('Lignes indisponibles.'),
      ),
    );
  }
}

class _LineTile extends StatelessWidget {
  const _LineTile({required this.line});
  final InvoiceLine line;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
              if (line.totalHt != null)
                Text(
                  '${line.totalHt} €',
                  style: theme.textTheme.bodyMedium,
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
          _Field(label: 'Total HT', value: '${invoice.totalHt ?? '—'} €'),
          _Field(label: 'TVA', value: '${invoice.totalTva ?? '—'} €'),
          _Field(label: 'Total TTC', value: '${invoice.totalTtc ?? '—'} €'),
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
