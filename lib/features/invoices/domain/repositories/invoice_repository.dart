import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice_filters.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice_line.dart';

/// Accès aux factures (lecture pour l'Étape 14).
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
}
