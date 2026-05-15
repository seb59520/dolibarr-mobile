import 'dart:convert';

import 'package:dolibarr_mobile/core/errors/error_mapper.dart';
import 'package:dolibarr_mobile/core/errors/exceptions.dart';
import 'package:dolibarr_mobile/core/network/network_info.dart';
import 'package:dolibarr_mobile/core/storage/pending_operation_dao.dart';
import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/invoices/data/datasources/invoice_local_dao.dart';
import 'package:dolibarr_mobile/features/invoices/data/datasources/invoice_remote_datasource.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice_filters.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice_line.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice_payment.dart';
import 'package:dolibarr_mobile/features/invoices/domain/repositories/invoice_repository.dart';
import 'package:dolibarr_mobile/features/thirdparties/data/datasources/draft_local_dao.dart';

const _draftEntityType = 'invoice';

final class InvoiceRepositoryImpl implements InvoiceRepository {
  InvoiceRepositoryImpl({
    required InvoiceRemoteDataSource remote,
    required InvoiceLocalDao dao,
    required NetworkInfo network,
    required DraftLocalDao draftDao,
    required PendingOperationDao outbox,
  })  : _remote = remote,
        _dao = dao,
        _network = network,
        _draftDao = draftDao,
        _outbox = outbox;

  final InvoiceRemoteDataSource _remote;
  final InvoiceLocalDao _dao;
  final NetworkInfo _network;
  final DraftLocalDao _draftDao;
  final PendingOperationDao _outbox;

  @override
  Stream<List<Invoice>> watchList(InvoiceFilters filters) {
    if (_network.isOnline) {
      // ignore: unawaited_futures
      refreshPage(filters: filters, page: 0);
    }
    return _dao.watchFiltered(filters);
  }

  @override
  Stream<Invoice?> watchById(int localId) => _dao.watchById(localId);

  @override
  Stream<List<Invoice>> watchByThirdPartyLocal(int thirdPartyLocalId) =>
      _dao.watchByThirdPartyLocal(thirdPartyLocalId);

  @override
  Stream<List<InvoiceLine>> watchLinesByInvoiceLocal(int invoiceLocalId) =>
      _dao.watchLinesByInvoiceLocal(invoiceLocalId);

  @override
  Future<Result<int>> refreshPage({
    required InvoiceFilters filters,
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
  Future<Result<Invoice>> refreshById(int remoteId) async {
    try {
      final json = await _remote.fetchById(remoteId);
      await _dao.upsertFromServer(json);
      final fresh = await _dao.findByRemoteId(remoteId);
      if (fresh == null) {
        throw StateError('Facture $remoteId introuvable après upsert');
      }
      return Success(fresh);
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }

  // ----------------------- Header writes ----------------------------

  @override
  Future<Result<int>> createLocal(Invoice draft) async {
    try {
      final localId = await _dao.insertLocal(draft);

      // Cascade : si le tiers parent n'a pas de remoteId, on cherche
      // son op create en attente pour bloquer la facture derrière.
      int? dependsOnLocalId;
      if (draft.socidRemote == null && draft.socidLocal != null) {
        dependsOnLocalId = await _outbox.findLatestPendingCreate(
          entityType: PendingOpEntity.thirdparty,
          targetLocalId: draft.socidLocal!,
        );
      }

      await _outbox.enqueue(
        opType: PendingOpType.create,
        entityType: PendingOpEntity.invoice,
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
  Future<Result<void>> updateLocal(Invoice entity) async {
    try {
      await _dao.updateLocal(entity);
      await _outbox.enqueue(
        opType: PendingOpType.update,
        entityType: PendingOpEntity.invoice,
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
          entityType: PendingOpEntity.invoice,
          targetLocalId: localId,
        );
        await _dao.hardDelete(localId);
        return const Success<void>(null);
      }
      await _dao.markPendingDelete(localId);
      await _outbox.enqueue(
        opType: PendingOpType.delete,
        entityType: PendingOpEntity.invoice,
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
  Future<Result<int>> createLocalLine(InvoiceLine draft) async {
    try {
      final localId = await _dao.insertLocalLine(draft);

      // Cascade : si la facture parente n'a pas de remoteId, on
      // cherche son op create en attente.
      int? dependsOnLocalId;
      if (draft.invoiceRemote == null && draft.invoiceLocal != null) {
        dependsOnLocalId = await _outbox.findLatestPendingCreate(
          entityType: PendingOpEntity.invoice,
          targetLocalId: draft.invoiceLocal!,
        );
      }

      await _outbox.enqueue(
        opType: PendingOpType.create,
        entityType: PendingOpEntity.invoiceLine,
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
  Future<Result<void>> updateLocalLine(InvoiceLine entity) async {
    try {
      await _dao.updateLocalLine(entity);
      await _outbox.enqueue(
        opType: PendingOpType.update,
        entityType: PendingOpEntity.invoiceLine,
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
          entityType: PendingOpEntity.invoiceLine,
          targetLocalId: lineLocalId,
        );
        await _dao.hardDeleteLine(lineLocalId);
        return const Success<void>(null);
      }
      await _dao.markLinePendingDelete(lineLocalId);
      await _outbox.enqueue(
        opType: PendingOpType.delete,
        entityType: PendingOpEntity.invoiceLine,
        targetLocalId: lineLocalId,
        targetRemoteId: current.remoteId,
        expectedTms: current.tms,
      );
      return const Success<void>(null);
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

  Map<String, Object?> _payloadFor(Invoice i) {
    return {
      if (i.socidRemote != null) 'socid': i.socidRemote,
      if (i.ref != null) 'ref': i.ref,
      if (i.refClient != null) 'ref_client': i.refClient,
      'type': i.type.apiValue,
      // En création, on reste en brouillon (statut 0). Les actions de
      // validation passent par /invoices/:id/validate (Étape 16).
      'fk_statut': i.status.apiValue,
      if (i.dateInvoice != null)
        'date': i.dateInvoice!.millisecondsSinceEpoch ~/ 1000,
      if (i.dateDue != null)
        'date_lim_reglement':
            i.dateDue!.millisecondsSinceEpoch ~/ 1000,
      if (i.fkModeReglement != null) 'mode_reglement_id': i.fkModeReglement,
      if (i.fkCondReglement != null) 'cond_reglement_id': i.fkCondReglement,
      if (i.notePublic != null) 'note_public': i.notePublic,
      if (i.notePrivate != null) 'note_private': i.notePrivate,
      if (i.extrafields.isNotEmpty) 'array_options': i.extrafields,
    };
  }

  Map<String, Object?> _linePayloadFor(InvoiceLine l) {
    return {
      // fk_facture est injecté par le SyncEngine au dispatch (path
      // POST /invoices/:id/lines), pas dans le body.
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

  // ---------- Workflow & paiements ----------------------------------

  @override
  Future<Result<Invoice>> validate(int localId) async {
    try {
      final invoice = await _dao.watchById(localId).first;
      if (invoice == null || invoice.remoteId == null) {
        throw const ValidationException(
          message: 'Facture non synchronisée — '
              'validation impossible offline.',
        );
      }
      await _remote.validate(invoice.remoteId!);
      // Refresh : Dolibarr a changé le statut + ref + tms.
      final json = await _remote.fetchById(invoice.remoteId!);
      await _dao.upsertFromServer(json);
      final fresh = await _dao.findByRemoteId(invoice.remoteId!);
      return Success(fresh ?? invoice);
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }

  @override
  Future<Result<Invoice>> markAsPaid(int localId) async {
    try {
      final invoice = await _dao.watchById(localId).first;
      if (invoice == null || invoice.remoteId == null) {
        throw const ValidationException(
          message: 'Facture non synchronisée — '
              'marquage payée impossible offline.',
        );
      }
      await _remote.markAsPaid(invoice.remoteId!);
      final json = await _remote.fetchById(invoice.remoteId!);
      await _dao.upsertFromServer(json);
      final fresh = await _dao.findByRemoteId(invoice.remoteId!);
      return Success(fresh ?? invoice);
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }

  @override
  Future<Result<List<InvoicePayment>>> fetchPayments(int localId) async {
    try {
      final invoice = await _dao.watchById(localId).first;
      if (invoice == null || invoice.remoteId == null) {
        return const Success([]);
      }
      final rows = await _remote.fetchPayments(invoice.remoteId!);
      return Success(rows.map(InvoicePayment.fromJson).toList());
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }

  @override
  Future<Result<int>> createPayment({
    required int localId,
    required DateTime date,
    required int accountId,
    String? paymentTypeCode,
    String? num,
    String? note,
    bool closePaidInvoices = true,
  }) async {
    try {
      final invoice = await _dao.watchById(localId).first;
      if (invoice == null || invoice.remoteId == null) {
        throw const ValidationException(
          message: 'Facture non synchronisée — '
              'paiement impossible offline.',
        );
      }
      // Dolibarr /invoices/{id}/payments :
      //  - encaisse systématiquement le solde restant (pas de partiel),
      //  - exige `accountid` quand le module Banque est actif,
      //  - exige `paymentid` (mode de règlement) + `closepaidinvoices`.
      final payload = <String, Object?>{
        'datepaye': date.millisecondsSinceEpoch ~/ 1000,
        'accountid': accountId,
        'closepaidinvoices': closePaidInvoices ? 'yes' : 'no',
        if (paymentTypeCode != null) 'paymentid': paymentTypeCode,
        if (num != null) 'num_payment': num,
        if (note != null) 'comment': note,
      };
      final id = await _remote.createPayment(invoice.remoteId!, payload);
      // Refresh la facture (paye, totaux peuvent évoluer).
      try {
        final json = await _remote.fetchById(invoice.remoteId!);
        await _dao.upsertFromServer(json);
      } catch (_) {
        // pas critique
      }
      return Success(id);
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }

  @override
  Future<Result<({List<int> bytes, String filename})>> downloadPdf(
    int localId,
  ) async {
    try {
      final invoice = await _dao.watchById(localId).first;
      if (invoice == null || invoice.remoteId == null) {
        throw const ValidationException(
          message: 'Facture non synchronisée — PDF indisponible.',
        );
      }
      final result = await _remote.downloadPdf(invoice.remoteId!);
      // Le contenu est en base64 (souvent avec wrap newlines).
      final clean = result.content.replaceAll(RegExp(r'\s'), '');
      final bytes = base64.decode(clean);
      return Success((bytes: bytes, filename: result.filename));
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }
}
