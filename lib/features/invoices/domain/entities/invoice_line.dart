import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:equatable/equatable.dart';

/// Type de ligne facture (`product_type` Dolibarr).
enum InvoiceLineProductType {
  product,
  service;

  static InvoiceLineProductType fromInt(int v) =>
      v == 1 ? InvoiceLineProductType.service : InvoiceLineProductType.product;

  int get apiValue => switch (this) {
        InvoiceLineProductType.product => 0,
        InvoiceLineProductType.service => 1,
      };
}

/// Ligne d'une facture (`llx_facturedet`).
final class InvoiceLine extends Equatable {
  const InvoiceLine({
    required this.localId,
    required this.localUpdatedAt,
    this.remoteId,
    this.invoiceRemote,
    this.invoiceLocal,
    this.fkProduct,
    this.label,
    this.description,
    this.productType = InvoiceLineProductType.service,
    this.qty = '1',
    this.subprice,
    this.tvaTx,
    this.remisePercent,
    this.totalHt,
    this.totalTva,
    this.totalTtc,
    this.rang = 0,
    this.extrafields = const {},
    this.tms,
    this.syncStatus = SyncStatus.synced,
  });

  final int localId;
  final int? remoteId;

  final int? invoiceRemote;
  final int? invoiceLocal;

  final int? fkProduct;

  final String? label;
  final String? description;

  final InvoiceLineProductType productType;

  final String qty;
  final String? subprice;
  final String? tvaTx;
  final String? remisePercent;

  final String? totalHt;
  final String? totalTva;
  final String? totalTtc;

  final int rang;

  final Map<String, Object?> extrafields;

  final DateTime? tms;
  final DateTime localUpdatedAt;
  final SyncStatus syncStatus;

  String get displayLabel {
    if (label != null && label!.trim().isNotEmpty) return label!;
    if (description != null && description!.trim().isNotEmpty) {
      return description!;
    }
    return '(ligne sans intitulé)';
  }

  InvoiceLine copyWithSync(SyncStatus next) => InvoiceLine(
        localId: localId,
        remoteId: remoteId,
        invoiceRemote: invoiceRemote,
        invoiceLocal: invoiceLocal,
        fkProduct: fkProduct,
        label: label,
        description: description,
        productType: productType,
        qty: qty,
        subprice: subprice,
        tvaTx: tvaTx,
        remisePercent: remisePercent,
        totalHt: totalHt,
        totalTva: totalTva,
        totalTtc: totalTtc,
        rang: rang,
        extrafields: extrafields,
        tms: tms,
        localUpdatedAt: localUpdatedAt,
        syncStatus: next,
      );

  @override
  List<Object?> get props => [
        localId,
        remoteId,
        invoiceRemote,
        invoiceLocal,
        fkProduct,
        label,
        description,
        productType,
        qty,
        subprice,
        tvaTx,
        remisePercent,
        totalHt,
        totalTva,
        totalTtc,
        rang,
        extrafields,
        tms,
        localUpdatedAt,
        syncStatus,
      ];
}
