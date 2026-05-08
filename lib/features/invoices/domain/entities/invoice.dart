import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:equatable/equatable.dart';

/// Statut Dolibarr d'une facture (`fk_statut` côté `llx_facture`).
enum InvoiceStatus {
  draft,
  validated,
  paid,
  abandoned;

  static InvoiceStatus fromInt(int statut, {int paye = 0}) {
    if (statut == 0) return InvoiceStatus.draft;
    if (statut == 3) return InvoiceStatus.abandoned;
    if (paye == 1) return InvoiceStatus.paid;
    return InvoiceStatus.validated;
  }

  int get apiValue => switch (this) {
        InvoiceStatus.draft => 0,
        InvoiceStatus.validated => 1,
        InvoiceStatus.paid => 2,
        InvoiceStatus.abandoned => 3,
      };
}

/// Type de facture Dolibarr (`type` côté `llx_facture`).
enum InvoiceType {
  standard,
  replacement,
  creditNote,
  deposit,
  proforma,
  situation;

  static InvoiceType fromInt(int v) => switch (v) {
        1 => InvoiceType.replacement,
        2 => InvoiceType.creditNote,
        3 => InvoiceType.deposit,
        4 => InvoiceType.proforma,
        5 => InvoiceType.situation,
        _ => InvoiceType.standard,
      };

  int get apiValue => switch (this) {
        InvoiceType.standard => 0,
        InvoiceType.replacement => 1,
        InvoiceType.creditNote => 2,
        InvoiceType.deposit => 3,
        InvoiceType.proforma => 4,
        InvoiceType.situation => 5,
      };
}

/// Facture Dolibarr (`llx_facture`), rattachée à un tiers (client).
final class Invoice extends Equatable {
  const Invoice({
    required this.localId,
    required this.localUpdatedAt,
    this.remoteId,
    this.socidRemote,
    this.socidLocal,
    this.ref,
    this.refClient,
    this.type = InvoiceType.standard,
    this.status = InvoiceStatus.draft,
    this.paye = 0,
    this.dateInvoice,
    this.dateDue,
    this.totalHt,
    this.totalTva,
    this.totalTtc,
    this.fkModeReglement,
    this.fkCondReglement,
    this.notePublic,
    this.notePrivate,
    this.extrafields = const {},
    this.tms,
    this.syncStatus = SyncStatus.synced,
  });

  final int localId;
  final int? remoteId;

  final int? socidRemote;
  final int? socidLocal;

  final String? ref;
  final String? refClient;

  final InvoiceType type;
  final InvoiceStatus status;
  final int paye;

  final DateTime? dateInvoice;
  final DateTime? dateDue;

  final String? totalHt;
  final String? totalTva;
  final String? totalTtc;

  final int? fkModeReglement;
  final int? fkCondReglement;

  final String? notePublic;
  final String? notePrivate;

  final Map<String, Object?> extrafields;

  final DateTime? tms;
  final DateTime localUpdatedAt;
  final SyncStatus syncStatus;

  bool get isDraft => status == InvoiceStatus.draft;
  bool get isPaid => status == InvoiceStatus.paid;
  bool get isOverdue {
    if (dateDue == null) return false;
    if (isPaid) return false;
    return DateTime.now().isAfter(dateDue!);
  }

  String get displayLabel {
    if (ref != null && ref!.trim().isNotEmpty) return ref!;
    return '(brouillon facture)';
  }

  Invoice copyWithSync(SyncStatus next) => Invoice(
        localId: localId,
        remoteId: remoteId,
        socidRemote: socidRemote,
        socidLocal: socidLocal,
        ref: ref,
        refClient: refClient,
        type: type,
        status: status,
        paye: paye,
        dateInvoice: dateInvoice,
        dateDue: dateDue,
        totalHt: totalHt,
        totalTva: totalTva,
        totalTtc: totalTtc,
        fkModeReglement: fkModeReglement,
        fkCondReglement: fkCondReglement,
        notePublic: notePublic,
        notePrivate: notePrivate,
        extrafields: extrafields,
        tms: tms,
        localUpdatedAt: localUpdatedAt,
        syncStatus: next,
      );

  @override
  List<Object?> get props => [
        localId,
        remoteId,
        socidRemote,
        socidLocal,
        ref,
        refClient,
        type,
        status,
        paye,
        dateInvoice,
        dateDue,
        totalHt,
        totalTva,
        totalTtc,
        fkModeReglement,
        fkCondReglement,
        notePublic,
        notePrivate,
        extrafields,
        tms,
        localUpdatedAt,
        syncStatus,
      ];
}
