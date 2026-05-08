import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:equatable/equatable.dart';

/// Statut Dolibarr d'un devis (`fk_statut` côté `llx_propal`).
enum ProposalStatus {
  draft,
  validated,
  signed,
  refused;

  static ProposalStatus fromInt(int v) => switch (v) {
        0 => ProposalStatus.draft,
        2 => ProposalStatus.signed,
        -1 => ProposalStatus.refused,
        _ => ProposalStatus.validated,
      };

  int get apiValue => switch (this) {
        ProposalStatus.draft => 0,
        ProposalStatus.validated => 1,
        ProposalStatus.signed => 2,
        ProposalStatus.refused => -1,
      };
}

/// Devis Dolibarr (`llx_propal`), rattaché à un tiers (client).
final class Proposal extends Equatable {
  const Proposal({
    required this.localId,
    required this.localUpdatedAt,
    this.remoteId,
    this.socidRemote,
    this.socidLocal,
    this.ref,
    this.refClient,
    this.status = ProposalStatus.draft,
    this.dateProposal,
    this.dateEnd,
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

  final ProposalStatus status;

  final DateTime? dateProposal;
  final DateTime? dateEnd;

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

  bool get isDraft => status == ProposalStatus.draft;
  bool get isSigned => status == ProposalStatus.signed;
  bool get isRefused => status == ProposalStatus.refused;
  bool get isExpired {
    if (dateEnd == null) return false;
    if (isSigned || isRefused) return false;
    return DateTime.now().isAfter(dateEnd!);
  }

  String get displayLabel {
    if (ref != null && ref!.trim().isNotEmpty) return ref!;
    return '(brouillon devis)';
  }

  Proposal copyWithSync(SyncStatus next) => Proposal(
        localId: localId,
        remoteId: remoteId,
        socidRemote: socidRemote,
        socidLocal: socidLocal,
        ref: ref,
        refClient: refClient,
        status: status,
        dateProposal: dateProposal,
        dateEnd: dateEnd,
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
        status,
        dateProposal,
        dateEnd,
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
