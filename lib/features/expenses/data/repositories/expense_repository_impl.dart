import 'dart:convert';

import 'package:dolibarr_mobile/core/errors/error_mapper.dart';
import 'package:dolibarr_mobile/core/errors/exceptions.dart';
import 'package:dolibarr_mobile/core/network/network_info.dart';
import 'package:dolibarr_mobile/core/storage/pending_operation_dao.dart';
import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/expenses/data/datasources/expense_local_dao.dart';
import 'package:dolibarr_mobile/features/expenses/data/datasources/expense_remote_datasource.dart';
import 'package:dolibarr_mobile/features/expenses/domain/entities/expense_filters.dart';
import 'package:dolibarr_mobile/features/expenses/domain/entities/expense_line.dart';
import 'package:dolibarr_mobile/features/expenses/domain/entities/expense_report.dart';
import 'package:dolibarr_mobile/features/expenses/domain/entities/expense_type.dart';
import 'package:dolibarr_mobile/features/expenses/domain/repositories/expense_repository.dart';

final class ExpenseRepositoryImpl implements ExpenseRepository {
  ExpenseRepositoryImpl({
    required ExpenseRemoteDataSource remote,
    required ExpenseLocalDao dao,
    required NetworkInfo network,
    required PendingOperationDao outbox,
  })  : _remote = remote,
        _dao = dao,
        _network = network,
        _outbox = outbox;

  final ExpenseRemoteDataSource _remote;
  final ExpenseLocalDao _dao;
  final NetworkInfo _network;
  final PendingOperationDao _outbox;

  @override
  Stream<List<ExpenseReport>> watchList(ExpenseFilters filters) {
    if (_network.isOnline) {
      // ignore: unawaited_futures
      refreshPage(filters: filters, page: 0);
    }
    return _dao.watchFiltered(filters);
  }

  @override
  Stream<ExpenseReport?> watchById(int localId) => _dao.watchById(localId);

  @override
  Stream<List<ExpenseLine>> watchLinesByReportLocal(int reportLocalId) =>
      _dao.watchLinesByReportLocal(reportLocalId);

  @override
  Stream<List<ExpenseType>> watchTypes() => _dao.watchTypes();

  @override
  Future<Result<int>> refreshPage({
    required ExpenseFilters filters,
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
  Future<Result<ExpenseReport>> refreshById(int remoteId) async {
    try {
      final json = await _remote.fetchById(remoteId);
      await _dao.upsertFromServer(json);
      final fresh = await _dao.findByRemoteId(remoteId);
      if (fresh == null) {
        throw StateError('Note de frais $remoteId introuvable après upsert');
      }
      return Success(fresh);
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }

  @override
  Future<Result<int>> refreshTypes() async {
    try {
      final rows = await _remote.fetchTypes();
      await _dao.upsertTypesFromServer(rows);
      return Success(rows.length);
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }

  // ----------------------- Header writes ----------------------------

  @override
  Future<Result<int>> createLocal(ExpenseReport draft) async {
    try {
      final localId = await _dao.insertLocal(draft);
      await _outbox.enqueue(
        opType: PendingOpType.create,
        entityType: PendingOpEntity.expenseReport,
        targetLocalId: localId,
        payload: _payloadFor(draft),
      );
      return Success(localId);
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }

  @override
  Future<Result<void>> updateLocal(ExpenseReport entity) async {
    try {
      await _dao.updateLocal(entity);
      await _outbox.enqueue(
        opType: PendingOpType.update,
        entityType: PendingOpEntity.expenseReport,
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
          entityType: PendingOpEntity.expenseReport,
          targetLocalId: localId,
        );
        await _dao.hardDelete(localId);
        return const Success<void>(null);
      }
      await _dao.markPendingDelete(localId);
      await _outbox.enqueue(
        opType: PendingOpType.delete,
        entityType: PendingOpEntity.expenseReport,
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
  Future<Result<int>> createLocalLine(ExpenseLine draft) async {
    try {
      final localId = await _dao.insertLocalLine(draft);

      int? dependsOnLocalId;
      if (draft.expenseReportRemote == null &&
          draft.expenseReportLocal != null) {
        dependsOnLocalId = await _outbox.findLatestPendingCreate(
          entityType: PendingOpEntity.expenseReport,
          targetLocalId: draft.expenseReportLocal!,
        );
      }

      await _outbox.enqueue(
        opType: PendingOpType.create,
        entityType: PendingOpEntity.expenseLine,
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
  Future<Result<void>> updateLocalLine(ExpenseLine entity) async {
    try {
      await _dao.updateLocalLine(entity);
      await _outbox.enqueue(
        opType: PendingOpType.update,
        entityType: PendingOpEntity.expenseLine,
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
          entityType: PendingOpEntity.expenseLine,
          targetLocalId: lineLocalId,
        );
        await _dao.hardDeleteLine(lineLocalId);
        return const Success<void>(null);
      }
      await _dao.markLinePendingDelete(lineLocalId);
      await _outbox.enqueue(
        opType: PendingOpType.delete,
        entityType: PendingOpEntity.expenseLine,
        targetLocalId: lineLocalId,
        targetRemoteId: current.remoteId,
        expectedTms: current.tms,
      );
      return const Success<void>(null);
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }

  // ---------- Workflow ----------------------------------------------

  @override
  Future<Result<ExpenseReport>> validate(int localId) async {
    try {
      final report = await _dao.watchById(localId).first;
      if (report == null || report.remoteId == null) {
        throw const ValidationException(
          message: 'Note de frais non synchronisée — '
              'validation impossible offline.',
        );
      }
      await _remote.validate(report.remoteId!);
      final json = await _remote.fetchById(report.remoteId!);
      await _dao.upsertFromServer(json);
      final fresh = await _dao.findByRemoteId(report.remoteId!);
      return Success(fresh ?? report);
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }

  @override
  Future<Result<ExpenseReport>> approve(int localId) async {
    try {
      final report = await _dao.watchById(localId).first;
      if (report == null || report.remoteId == null) {
        throw const ValidationException(
          message: 'Note de frais non synchronisée — '
              'approbation impossible offline.',
        );
      }
      await _remote.approve(report.remoteId!);
      final json = await _remote.fetchById(report.remoteId!);
      await _dao.upsertFromServer(json);
      final fresh = await _dao.findByRemoteId(report.remoteId!);
      return Success(fresh ?? report);
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }

  @override
  Future<Result<String>> uploadJustificatif({
    required int localId,
    required String filename,
    required List<int> bytes,
  }) async {
    try {
      final report = await _dao.watchById(localId).first;
      if (report == null ||
          report.remoteId == null ||
          report.ref == null ||
          report.ref!.isEmpty) {
        throw const ValidationException(
          message: 'Note de frais non synchronisée — '
              'justificatif impossible avant push initial.',
        );
      }
      final content = base64Encode(bytes);
      final result = await _remote.uploadDocument(
        ref: report.ref!,
        filename: filename,
        base64Content: content,
      );
      return Success(result);
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }

  // ----------------------- Payload builders -------------------------

  Map<String, Object?> _payloadFor(ExpenseReport r) {
    return {
      if (r.fkUserAuthor != null) 'fk_user_author': r.fkUserAuthor,
      if (r.fkUserValid != null) 'fk_user_valid': r.fkUserValid,
      if (r.dateDebut != null)
        'date_debut': r.dateDebut!.millisecondsSinceEpoch ~/ 1000,
      if (r.dateFin != null)
        'date_fin': r.dateFin!.millisecondsSinceEpoch ~/ 1000,
      if (r.notePublic != null) 'note_public': r.notePublic,
      if (r.notePrivate != null) 'note_private': r.notePrivate,
      if (r.extrafields.isNotEmpty) 'array_options': r.extrafields,
    };
  }

  Map<String, Object?> _linePayloadFor(ExpenseLine l) {
    // Dolibarr exige `vatrate` (et non `tva_tx`) côté POST/PUT line.
    return {
      if (l.fkCTypeFees != null) 'fk_c_type_fees': l.fkCTypeFees,
      if (l.date != null) 'date': l.date!.millisecondsSinceEpoch ~/ 1000,
      if (l.comments != null) 'comments': l.comments,
      'qty': l.qty,
      if (l.valueUnit != null) 'value_unit': l.valueUnit,
      if (l.tvaTx != null) 'vatrate': l.tvaTx,
      if (l.projetId != null) 'fk_project': l.projetId,
    };
  }
}
