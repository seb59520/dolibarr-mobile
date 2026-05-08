import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:equatable/equatable.dart';

/// Statut Dolibarr d'un projet.
enum ProjectStatus {
  draft,
  opened,
  closed;

  static ProjectStatus fromInt(int v) => switch (v) {
        0 => ProjectStatus.draft,
        2 => ProjectStatus.closed,
        _ => ProjectStatus.opened,
      };

  int get apiValue => switch (this) {
        ProjectStatus.draft => 0,
        ProjectStatus.opened => 1,
        ProjectStatus.closed => 2,
      };
}

/// Projet Dolibarr (`llx_projet`), rattaché à un tiers.
///
/// Le rattachement au tiers est dual (comme pour les contacts) :
/// - `socidRemote` : `socid` côté Dolibarr ;
/// - `socidLocal` : PK locale du tiers parent quand celui-ci est encore
///   en `pendingCreate` (cascade Outbox via `dependsOnLocalId`).
final class Project extends Equatable {
  const Project({
    required this.localId,
    required this.localUpdatedAt,
    this.remoteId,
    this.socidRemote,
    this.socidLocal,
    this.ref,
    this.title = '',
    this.description,
    this.status = ProjectStatus.draft,
    this.publicLevel = 0,
    this.fkUserResp,
    this.dateStart,
    this.dateEnd,
    this.budgetAmount,
    this.oppStatus,
    this.oppAmount,
    this.oppPercent,
    this.extrafields = const {},
    this.tms,
    this.syncStatus = SyncStatus.synced,
  });

  final int localId;
  final int? remoteId;

  final int? socidRemote;
  final int? socidLocal;

  final String? ref;
  final String title;
  final String? description;

  final ProjectStatus status;

  final int publicLevel;
  final int? fkUserResp;

  final DateTime? dateStart;
  final DateTime? dateEnd;

  final String? budgetAmount;

  final int? oppStatus;
  final String? oppAmount;
  final double? oppPercent;

  final Map<String, Object?> extrafields;

  final DateTime? tms;
  final DateTime localUpdatedAt;
  final SyncStatus syncStatus;

  bool get isOpened => status == ProjectStatus.opened;
  bool get isPublic => publicLevel == 1;

  /// Libellé d'affichage : "REF - title" ou "title" si pas de ref.
  String get displayLabel {
    if (ref != null && ref!.trim().isNotEmpty) {
      return '$ref — $title';
    }
    return title.trim().isEmpty ? '(sans titre)' : title;
  }

  Project copyWithSync(SyncStatus next) => Project(
        localId: localId,
        remoteId: remoteId,
        socidRemote: socidRemote,
        socidLocal: socidLocal,
        ref: ref,
        title: title,
        description: description,
        status: status,
        publicLevel: publicLevel,
        fkUserResp: fkUserResp,
        dateStart: dateStart,
        dateEnd: dateEnd,
        budgetAmount: budgetAmount,
        oppStatus: oppStatus,
        oppAmount: oppAmount,
        oppPercent: oppPercent,
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
        title,
        description,
        status,
        publicLevel,
        fkUserResp,
        dateStart,
        dateEnd,
        budgetAmount,
        oppStatus,
        oppAmount,
        oppPercent,
        extrafields,
        tms,
        localUpdatedAt,
        syncStatus,
      ];
}
