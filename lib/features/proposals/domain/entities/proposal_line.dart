import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:equatable/equatable.dart';

enum ProposalLineProductType {
  product,
  service;

  static ProposalLineProductType fromInt(int v) => v == 1
      ? ProposalLineProductType.service
      : ProposalLineProductType.product;

  int get apiValue => switch (this) {
        ProposalLineProductType.product => 0,
        ProposalLineProductType.service => 1,
      };
}

/// Ligne d'un devis (`llx_propaldet`).
final class ProposalLine extends Equatable {
  const ProposalLine({
    required this.localId,
    required this.localUpdatedAt,
    this.remoteId,
    this.proposalRemote,
    this.proposalLocal,
    this.fkProduct,
    this.label,
    this.description,
    this.productType = ProposalLineProductType.service,
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

  final int? proposalRemote;
  final int? proposalLocal;

  final int? fkProduct;

  final String? label;
  final String? description;

  final ProposalLineProductType productType;

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

  ProposalLine copyWithSync(SyncStatus next) => ProposalLine(
        localId: localId,
        remoteId: remoteId,
        proposalRemote: proposalRemote,
        proposalLocal: proposalLocal,
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
        proposalRemote,
        proposalLocal,
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
