import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice_filters.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice_line.dart';

/// Accès aux factures, avec écritures offline-first.
abstract interface class InvoiceRepository {
  Stream<List<Invoice>> watchList(InvoiceFilters filters);

  Stream<Invoice?> watchById(int localId);

  /// Stream des factures d'un tiers (par PK locale du tiers).
  Stream<List<Invoice>> watchByThirdPartyLocal(int thirdPartyLocalId);

  /// Stream des lignes d'une facture (par PK locale de la facture).
  Stream<List<InvoiceLine>> watchLinesByInvoiceLocal(int invoiceLocalId);

  Future<Result<int>> refreshPage({
    required InvoiceFilters filters,
    required int page,
    int limit = 100,
  });

  /// Refetch un détail. Le payload Dolibarr inclut les lignes dans
  /// `lines`, qui sont upsertées en local également.
  Future<Result<Invoice>> refreshById(int remoteId);

  // -------- Écritures header (Outbox + Optimistic UI) --------------

  Future<Result<int>> createLocal(Invoice draft);
  Future<Result<void>> updateLocal(Invoice entity);
  Future<Result<void>> deleteLocal(int localId);

  // -------- Écritures lignes (cascade interne facture→ligne) -------

  Future<Result<int>> createLocalLine(InvoiceLine draft);
  Future<Result<void>> updateLocalLine(InvoiceLine entity);
  Future<Result<void>> deleteLocalLine(int lineLocalId);

  // ----------------------- Brouillons -------------------------------

  Stream<Map<String, Object?>?> watchDraft({int? refLocalId});
  Future<void> saveDraft({
    required Map<String, Object?> fields,
    int? refLocalId,
  });
  Future<void> discardDraft({int? refLocalId});
}
