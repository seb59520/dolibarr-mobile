import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:equatable/equatable.dart';

/// Ligne de note de frais (`llx_expensereport_det`).
///
/// Dolibarr stocke le type via une FK numérique (`fk_c_type_fees`) vers
/// `llx_c_type_fees`. On garde aussi le `code` textuel pour faciliter
/// l'affichage et la résolution depuis le cache local des types.
final class ExpenseLine extends Equatable {
  const ExpenseLine({
    required this.localId,
    required this.localUpdatedAt,
    this.remoteId,
    this.expenseReportRemote,
    this.expenseReportLocal,
    this.fkCTypeFees,
    this.codeCTypeFees,
    this.date,
    this.comments,
    this.qty = '1',
    this.valueUnit,
    this.tvaTx,
    this.totalHt,
    this.totalTva,
    this.totalTtc,
    this.projetId,
    this.rang = 0,
    this.tms,
    this.syncStatus = SyncStatus.synced,
  });

  final int localId;
  final int? remoteId;

  final int? expenseReportRemote;
  final int? expenseReportLocal;

  /// id Dolibarr (`llx_c_type_fees.id`).
  final int? fkCTypeFees;

  /// Code textuel correspondant (ex. `TF_LUNCH`).
  final String? codeCTypeFees;

  /// Date de la dépense (jour de l'achat).
  final DateTime? date;

  /// Description libre saisie par l'utilisateur.
  final String? comments;

  final String qty;
  final String? valueUnit;

  /// Taux de TVA appliqué (chaîne pour respecter la précision Dolibarr).
  final String? tvaTx;

  final String? totalHt;
  final String? totalTva;
  final String? totalTtc;

  /// Projet associé Dolibarr (`fk_project`).
  final int? projetId;

  final int rang;

  final DateTime? tms;
  final DateTime localUpdatedAt;
  final SyncStatus syncStatus;

  String get displayLabel {
    if (comments != null && comments!.trim().isNotEmpty) return comments!;
    if (codeCTypeFees != null && codeCTypeFees!.isNotEmpty) {
      return codeCTypeFees!;
    }
    return '(ligne sans intitulé)';
  }

  ExpenseLine copyWithSync(SyncStatus next) => ExpenseLine(
        localId: localId,
        remoteId: remoteId,
        expenseReportRemote: expenseReportRemote,
        expenseReportLocal: expenseReportLocal,
        fkCTypeFees: fkCTypeFees,
        codeCTypeFees: codeCTypeFees,
        date: date,
        comments: comments,
        qty: qty,
        valueUnit: valueUnit,
        tvaTx: tvaTx,
        totalHt: totalHt,
        totalTva: totalTva,
        totalTtc: totalTtc,
        projetId: projetId,
        rang: rang,
        tms: tms,
        localUpdatedAt: localUpdatedAt,
        syncStatus: next,
      );

  @override
  List<Object?> get props => [
        localId,
        remoteId,
        expenseReportRemote,
        expenseReportLocal,
        fkCTypeFees,
        codeCTypeFees,
        date,
        comments,
        qty,
        valueUnit,
        tvaTx,
        totalHt,
        totalTva,
        totalTtc,
        projetId,
        rang,
        tms,
        localUpdatedAt,
        syncStatus,
      ];
}
