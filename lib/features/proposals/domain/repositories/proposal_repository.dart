import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/proposals/domain/entities/proposal.dart';
import 'package:dolibarr_mobile/features/proposals/domain/entities/proposal_filters.dart';
import 'package:dolibarr_mobile/features/proposals/domain/entities/proposal_line.dart';

/// Accès aux devis avec écritures offline-first et lignes éditables.
abstract interface class ProposalRepository {
  Stream<List<Proposal>> watchList(ProposalFilters filters);

  Stream<Proposal?> watchById(int localId);

  /// Stream des devis d'un tiers (par PK locale du tiers).
  Stream<List<Proposal>> watchByThirdPartyLocal(int thirdPartyLocalId);

  /// Stream des lignes d'un devis (par PK locale du devis).
  Stream<List<ProposalLine>> watchLinesByProposalLocal(int proposalLocalId);

  Future<Result<int>> refreshPage({
    required ProposalFilters filters,
    required int page,
    int limit = 100,
  });

  Future<Result<Proposal>> refreshById(int remoteId);

  // -------- Écritures header (Outbox + Optimistic UI) --------------

  Future<Result<int>> createLocal(Proposal draft);
  Future<Result<void>> updateLocal(Proposal entity);
  Future<Result<void>> deleteLocal(int localId);

  // -------- Écritures lignes (cascade interne devis→ligne) --------

  Future<Result<int>> createLocalLine(ProposalLine draft);
  Future<Result<void>> updateLocalLine(ProposalLine entity);
  Future<Result<void>> deleteLocalLine(int lineLocalId);

  // ----------------------- Workflow ---------------------------------

  /// Passe le devis de brouillon (0) à validé (1). Refresh derrière.
  Future<Result<Proposal>> validate(int localId);

  /// Clôture le devis : `signed` (2) ou `refused` (-1).
  Future<Result<Proposal>> close(
    int localId,
    ProposalStatus status, {
    String? note,
  });

  /// Marque le devis comme facturé (statut Dolibarr "facturé").
  Future<Result<Proposal>> setInvoiced(int localId);

  /// Télécharge le PDF du devis (base64 décodé en bytes).
  Future<Result<({List<int> bytes, String filename})>> downloadPdf(
    int localId,
  );

  // ----------------------- Brouillons -------------------------------

  Stream<Map<String, Object?>?> watchDraft({int? refLocalId});
  Future<void> saveDraft({
    required Map<String, Object?> fields,
    int? refLocalId,
  });
  Future<void> discardDraft({int? refLocalId});
}
