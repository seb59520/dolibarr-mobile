import 'package:dolibarr_mobile/core/storage/app_database.dart';
import 'package:dolibarr_mobile/core/storage/collections/invoice_payments.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice_payment.dart';
import 'package:drift/drift.dart';

part 'invoice_payment_local_dao.g.dart';

@DriftAccessor(tables: [InvoicePayments])
class InvoicePaymentLocalDao extends DatabaseAccessor<AppDatabase>
    with _$InvoicePaymentLocalDaoMixin {
  InvoicePaymentLocalDao(super.attachedDatabase);

  Stream<List<InvoicePayment>> watchAll() {
    final q = select(invoicePayments)
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);
    return q.watch().map((rows) => rows.map(_fromRow).toList());
  }

  Stream<List<InvoicePayment>> watchSince(DateTime since) {
    final q = select(invoicePayments)
      ..where((t) => t.date.isBiggerOrEqualValue(since))
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);
    return q.watch().map((rows) => rows.map(_fromRow).toList());
  }

  Future<List<InvoicePayment>> getByInvoiceRemoteId(int invoiceRemoteId) async {
    final rows = await (select(invoicePayments)
          ..where((t) => t.invoiceRemoteId.equals(invoiceRemoteId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
    return rows.map(_fromRow).toList();
  }

  /// Upsert idempotent par `remoteId`. Si la ligne existe, on met à jour
  /// les champs ; sinon on insère.
  Future<void> upsertFromRemote({
    required int remoteId,
    required int invoiceRemoteId,
    DateTime? date,
    String? amount,
    String? type,
    String? num,
    String? ref,
  }) async {
    final now = DateTime.now();
    await into(invoicePayments).insert(
      InvoicePaymentsCompanion.insert(
        remoteId: remoteId,
        invoiceRemoteId: invoiceRemoteId,
        date: Value(date),
        amount: Value(amount),
        type: Value(type),
        num: Value(num),
        ref: Value(ref),
        localUpdatedAt: now,
      ),
      mode: InsertMode.insertOrReplace,
      onConflict: DoUpdate(
        (_) => InvoicePaymentsCompanion(
          invoiceRemoteId: Value(invoiceRemoteId),
          date: Value(date),
          amount: Value(amount),
          type: Value(type),
          num: Value(num),
          ref: Value(ref),
          localUpdatedAt: Value(now),
        ),
        target: [invoicePayments.remoteId],
      ),
    );
  }

  /// Remplace l'ensemble des paiements connus pour une facture donnée.
  /// Utilisé après un `fetchPayments` réussi pour propager les
  /// suppressions serveur.
  Future<void> replaceForInvoice(
    int invoiceRemoteId,
    List<InvoicePayment> payments,
  ) async {
    await transaction(() async {
      await (delete(invoicePayments)
            ..where((t) => t.invoiceRemoteId.equals(invoiceRemoteId)))
          .go();
      for (final p in payments) {
        if (p.remoteId == 0) continue;
        await upsertFromRemote(
          remoteId: p.remoteId,
          invoiceRemoteId: invoiceRemoteId,
          date: p.date,
          amount: p.amount,
          type: p.type,
          num: p.num,
          ref: p.ref,
        );
      }
    });
  }

  Future<int> count() async {
    final exp = invoicePayments.id.count();
    final query = selectOnly(invoicePayments)..addColumns([exp]);
    final row = await query.getSingle();
    return row.read(exp) ?? 0;
  }

  InvoicePayment _fromRow(InvoicePaymentRow r) => InvoicePayment(
        remoteId: r.remoteId,
        date: r.date,
        amount: r.amount,
        type: r.type,
        num: r.num,
        ref: r.ref,
      );
}
