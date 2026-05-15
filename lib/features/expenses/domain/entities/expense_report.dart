import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:equatable/equatable.dart';

/// Statut Dolibarr d'une note de frais (`fk_statut` côté `llx_expensereport`,
/// constantes `ExpenseReport::STATUS_*`).
enum ExpenseReportStatus {
  draft,
  validated,
  approved,
  paid,
  refused;

  /// Le mapping Dolibarr est non contigu : 0/2/4/6/99 et non 0..4.
  static ExpenseReportStatus fromInt(int statut) {
    switch (statut) {
      case 2:
        return ExpenseReportStatus.validated;
      case 4:
        return ExpenseReportStatus.approved;
      case 6:
        return ExpenseReportStatus.paid;
      case 99:
        return ExpenseReportStatus.refused;
      case 0:
      default:
        return ExpenseReportStatus.draft;
    }
  }

  int get apiValue => switch (this) {
        ExpenseReportStatus.draft => 0,
        ExpenseReportStatus.validated => 2,
        ExpenseReportStatus.approved => 4,
        ExpenseReportStatus.paid => 6,
        ExpenseReportStatus.refused => 99,
      };
}

/// Note de frais Dolibarr (`llx_expensereport`).
final class ExpenseReport extends Equatable {
  const ExpenseReport({
    required this.localId,
    required this.localUpdatedAt,
    this.remoteId,
    this.ref,
    this.status = ExpenseReportStatus.draft,
    this.fkUserAuthor,
    this.fkUserValid,
    this.dateDebut,
    this.dateFin,
    this.totalHt,
    this.totalTva,
    this.totalTtc,
    this.notePublic,
    this.notePrivate,
    this.extrafields = const {},
    this.tms,
    this.syncStatus = SyncStatus.synced,
  });

  final int localId;
  final int? remoteId;

  final String? ref;

  final ExpenseReportStatus status;

  final int? fkUserAuthor;
  final int? fkUserValid;

  final DateTime? dateDebut;
  final DateTime? dateFin;

  final String? totalHt;
  final String? totalTva;
  final String? totalTtc;

  final String? notePublic;
  final String? notePrivate;

  final Map<String, Object?> extrafields;

  final DateTime? tms;
  final DateTime localUpdatedAt;
  final SyncStatus syncStatus;

  bool get isDraft => status == ExpenseReportStatus.draft;
  bool get isValidated => status == ExpenseReportStatus.validated;
  bool get isApproved => status == ExpenseReportStatus.approved;
  bool get isPaid => status == ExpenseReportStatus.paid;
  bool get isRefused => status == ExpenseReportStatus.refused;

  String get displayLabel {
    if (ref != null && ref!.trim().isNotEmpty) return ref!;
    return '(brouillon note de frais)';
  }

  ExpenseReport copyWithSync(SyncStatus next) => ExpenseReport(
        localId: localId,
        remoteId: remoteId,
        ref: ref,
        status: status,
        fkUserAuthor: fkUserAuthor,
        fkUserValid: fkUserValid,
        dateDebut: dateDebut,
        dateFin: dateFin,
        totalHt: totalHt,
        totalTva: totalTva,
        totalTtc: totalTtc,
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
        ref,
        status,
        fkUserAuthor,
        fkUserValid,
        dateDebut,
        dateFin,
        totalHt,
        totalTva,
        totalTtc,
        notePublic,
        notePrivate,
        extrafields,
        tms,
        localUpdatedAt,
        syncStatus,
      ];
}
