import 'dart:convert';

import 'package:dolibarr_mobile/core/errors/error_mapper.dart';
import 'package:dolibarr_mobile/core/errors/exceptions.dart';
import 'package:dolibarr_mobile/core/network/network_info.dart';
import 'package:dolibarr_mobile/core/storage/pending_operation_dao.dart';
import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/proposals/data/datasources/proposal_local_dao.dart';
import 'package:dolibarr_mobile/features/proposals/data/datasources/proposal_remote_datasource.dart';
import 'package:dolibarr_mobile/features/proposals/domain/entities/proposal.dart';
import 'package:dolibarr_mobile/features/proposals/domain/entities/proposal_filters.dart';
import 'package:dolibarr_mobile/features/proposals/domain/entities/proposal_line.dart';
import 'package:dolibarr_mobile/features/proposals/domain/repositories/proposal_repository.dart';
import 'package:dolibarr_mobile/features/thirdparties/data/datasources/draft_local_dao.dart';

const _draftEntityType = 'proposal';

final class ProposalRepositoryImpl implements ProposalRepository {
  ProposalRepositoryImpl({
    required ProposalRemoteDataSource remote,
    required ProposalLocalDao dao,
    required NetworkInfo network,
    required DraftLocalDao draftDao,
    required PendingOperationDao outbox,
  })  : _remote = remote,
        _dao = dao,
        _network = network,
        _draftDao = draftDao,
        _outbox = outbox;

  final ProposalRemoteDataSource _remote;
  final ProposalLocalDao _dao;
  final NetworkInfo _network;
  final DraftLocalDao _draftDao;
  final PendingOperationDao _outbox;

  @override
  Stream<List<Proposal>> watchList(ProposalFilters filters) {
    if (_network.isOnline) {
      // ignore: unawaited_futures
      refreshPage(filters: filters, page: 0);
    }
    return _dao.watchFiltered(filters);
  }

  @override
  Stream<Proposal?> watchById(int localId) => _dao.watchById(localId);

  @override
  Stream<List<Proposal>> watchByThirdPartyLocal(int thirdPartyLocalId) =>
      _dao.watchByThirdPartyLocal(thirdPartyLocalId);

  @override
  Stream<List<ProposalLine>> watchLinesByProposalLocal(int proposalLocalId) =>
      _dao.watchLinesByProposalLocal(proposalLocalId);

  @override
  Future<Result<int>> refreshPage({
    required ProposalFilters filters,
    required int page,
    int limit = 100,
  }) async {
    try {
      final rows = await _remote.fetchPage(
        filters: filters,
        page: page,
        limit: limit,
      );
      await _dao.upsertManyFromServer(rows);
      return Success(rows.length);
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }

  @override
  Future<Result<Proposal>> refreshById(int remoteId) async {
    try {
      final json = await _remote.fetchById(remoteId);
      await _dao.upsertFromServer(json);
      final fresh = await _dao.findByRemoteId(remoteId);
      if (fresh == null) {
        throw StateError('Devis $remoteId introuvable après upsert');
      }
      return Success(fresh);
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }

  // ----------------------- Header writes ----------------------------

  @override
  Future<Result<int>> createLocal(Proposal draft) async {
    try {
      final localId = await _dao.insertLocal(draft);

      int? dependsOnLocalId;
      if (draft.socidRemote == null && draft.socidLocal != null) {
        dependsOnLocalId = await _outbox.findLatestPendingCreate(
          entityType: PendingOpEntity.thirdparty,
          targetLocalId: draft.socidLocal!,
        );
      }

      await _outbox.enqueue(
        opType: PendingOpType.create,
        entityType: PendingOpEntity.proposal,
        targetLocalId: localId,
        payload: _payloadFor(draft),
        dependsOnLocalId: dependsOnLocalId,
      );
      return Success(localId);
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }

  @override
  Future<Result<void>> updateLocal(Proposal entity) async {
    try {
      await _dao.updateLocal(entity);
      await _outbox.enqueue(
        opType: PendingOpType.update,
        entityType: PendingOpEntity.proposal,
        targetLocalId: entity.localId,
        targetRemoteId: entity.remoteId,
        payload: _payloadFor(entity),
        expectedTms: entity.tms,
      );
      return const Success<void>(null);
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }

  @override
  Future<Result<void>> deleteLocal(int localId) async {
    try {
      final current = await _dao.watchById(localId).first;
      if (current == null) return const Success<void>(null);
      if (current.remoteId == null) {
        await _outbox.deleteForLocal(
          entityType: PendingOpEntity.proposal,
          targetLocalId: localId,
        );
        await _dao.hardDelete(localId);
        return const Success<void>(null);
      }
      await _dao.markPendingDelete(localId);
      await _outbox.enqueue(
        opType: PendingOpType.delete,
        entityType: PendingOpEntity.proposal,
        targetLocalId: localId,
        targetRemoteId: current.remoteId,
        expectedTms: current.tms,
      );
      return const Success<void>(null);
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }

  // ----------------------- Line writes ------------------------------

  @override
  Future<Result<int>> createLocalLine(ProposalLine draft) async {
    try {
      final localId = await _dao.insertLocalLine(draft);

      int? dependsOnLocalId;
      if (draft.proposalRemote == null && draft.proposalLocal != null) {
        dependsOnLocalId = await _outbox.findLatestPendingCreate(
          entityType: PendingOpEntity.proposal,
          targetLocalId: draft.proposalLocal!,
        );
      }

      await _outbox.enqueue(
        opType: PendingOpType.create,
        entityType: PendingOpEntity.proposalLine,
        targetLocalId: localId,
        payload: _linePayloadFor(draft),
        dependsOnLocalId: dependsOnLocalId,
      );
      return Success(localId);
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }

  @override
  Future<Result<void>> updateLocalLine(ProposalLine entity) async {
    try {
      await _dao.updateLocalLine(entity);
      await _outbox.enqueue(
        opType: PendingOpType.update,
        entityType: PendingOpEntity.proposalLine,
        targetLocalId: entity.localId,
        targetRemoteId: entity.remoteId,
        payload: _linePayloadFor(entity),
        expectedTms: entity.tms,
      );
      return const Success<void>(null);
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }

  @override
  Future<Result<void>> deleteLocalLine(int lineLocalId) async {
    try {
      final current = await _dao.findLineByLocalId(lineLocalId);
      if (current == null) return const Success<void>(null);
      if (current.remoteId == null) {
        await _outbox.deleteForLocal(
          entityType: PendingOpEntity.proposalLine,
          targetLocalId: lineLocalId,
        );
        await _dao.hardDeleteLine(lineLocalId);
        return const Success<void>(null);
      }
      await _dao.markLinePendingDelete(lineLocalId);
      await _outbox.enqueue(
        opType: PendingOpType.delete,
        entityType: PendingOpEntity.proposalLine,
        targetLocalId: lineLocalId,
        targetRemoteId: current.remoteId,
        expectedTms: current.tms,
      );
      return const Success<void>(null);
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }

  // ----------------------- Workflow ---------------------------------

  @override
  Future<Result<Proposal>> validate(int localId) async {
    try {
      final proposal = await _dao.watchById(localId).first;
      if (proposal == null || proposal.remoteId == null) {
        throw const ValidationException(
          message: 'Devis non synchronisé — '
              'validation impossible offline.',
        );
      }
      await _remote.validate(proposal.remoteId!);
      final json = await _remote.fetchById(proposal.remoteId!);
      await _dao.upsertFromServer(json);
      final fresh = await _dao.findByRemoteId(proposal.remoteId!);
      return Success(fresh ?? proposal);
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }

  @override
  Future<Result<Proposal>> close(
    int localId,
    ProposalStatus status, {
    String? note,
  }) async {
    if (status != ProposalStatus.signed &&
        status != ProposalStatus.refused) {
      return FailureResult(
        ErrorMapper.toFailure(
          const ValidationException(
            message: 'close() attend signed ou refused.',
          ),
          StackTrace.current,
        ),
      );
    }
    try {
      final proposal = await _dao.watchById(localId).first;
      if (proposal == null || proposal.remoteId == null) {
        throw const ValidationException(
          message: 'Devis non synchronisé — clôture impossible offline.',
        );
      }
      await _remote.close(
        proposal.remoteId!,
        status.apiValue,
        note: note,
      );
      final json = await _remote.fetchById(proposal.remoteId!);
      await _dao.upsertFromServer(json);
      final fresh = await _dao.findByRemoteId(proposal.remoteId!);
      return Success(fresh ?? proposal);
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }

  @override
  Future<Result<Proposal>> setInvoiced(int localId) async {
    try {
      final proposal = await _dao.watchById(localId).first;
      if (proposal == null || proposal.remoteId == null) {
        throw const ValidationException(
          message: 'Devis non synchronisé — '
              'marquage facturé impossible offline.',
        );
      }
      await _remote.setInvoiced(proposal.remoteId!);
      final json = await _remote.fetchById(proposal.remoteId!);
      await _dao.upsertFromServer(json);
      final fresh = await _dao.findByRemoteId(proposal.remoteId!);
      return Success(fresh ?? proposal);
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }

  @override
  Future<Result<({List<int> bytes, String filename})>> downloadPdf(
    int localId,
  ) async {
    try {
      final proposal = await _dao.watchById(localId).first;
      if (proposal == null || proposal.remoteId == null) {
        throw const ValidationException(
          message: 'Devis non synchronisé — PDF indisponible.',
        );
      }
      final result = await _remote.downloadPdf(proposal.remoteId!);
      final clean = result.content.replaceAll(RegExp(r'\s'), '');
      final bytes = base64.decode(clean);
      return Success((bytes: bytes, filename: result.filename));
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }

  @override
  Stream<Map<String, Object?>?> watchDraft({int? refLocalId}) =>
      _draftDao.watch(entityType: _draftEntityType, refLocalId: refLocalId);

  @override
  Future<void> saveDraft({
    required Map<String, Object?> fields,
    int? refLocalId,
  }) =>
      _draftDao.save(
        entityType: _draftEntityType,
        fields: fields,
        refLocalId: refLocalId,
      );

  @override
  Future<void> discardDraft({int? refLocalId}) =>
      _draftDao.discard(
        entityType: _draftEntityType,
        refLocalId: refLocalId,
      );

  Map<String, Object?> _payloadFor(Proposal p) {
    return {
      if (p.socidRemote != null) 'socid': p.socidRemote,
      if (p.ref != null) 'ref': p.ref,
      if (p.refClient != null) 'ref_client': p.refClient,
      'fk_statut': p.status.apiValue,
      if (p.dateProposal != null)
        'datep': p.dateProposal!.millisecondsSinceEpoch ~/ 1000,
      if (p.dateEnd != null)
        'fin_validite': p.dateEnd!.millisecondsSinceEpoch ~/ 1000,
      if (p.fkModeReglement != null) 'mode_reglement_id': p.fkModeReglement,
      if (p.fkCondReglement != null) 'cond_reglement_id': p.fkCondReglement,
      if (p.notePublic != null) 'note_public': p.notePublic,
      if (p.notePrivate != null) 'note_private': p.notePrivate,
      if (p.extrafields.isNotEmpty) 'array_options': p.extrafields,
    };
  }

  Map<String, Object?> _linePayloadFor(ProposalLine l) {
    return {
      // fk_propal injecté via le path POST /proposals/:id/lines.
      if (l.fkProduct != null) 'fk_product': l.fkProduct,
      if (l.label != null) 'label': l.label,
      if (l.description != null) 'desc': l.description,
      'product_type': l.productType.apiValue,
      'qty': l.qty,
      if (l.subprice != null) 'subprice': l.subprice,
      if (l.tvaTx != null) 'tva_tx': l.tvaTx,
      if (l.remisePercent != null) 'remise_percent': l.remisePercent,
      'rang': l.rang,
      if (l.extrafields.isNotEmpty) 'array_options': l.extrafields,
    };
  }
}
