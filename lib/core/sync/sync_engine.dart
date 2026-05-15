import 'dart:async';
import 'dart:convert';

import 'package:dolibarr_mobile/core/errors/exceptions.dart';
import 'package:dolibarr_mobile/core/network/network_info.dart';
import 'package:dolibarr_mobile/core/storage/app_database.dart';
import 'package:dolibarr_mobile/core/storage/pending_operation_dao.dart';
import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:dolibarr_mobile/features/contacts/data/datasources/contact_local_dao.dart';
import 'package:dolibarr_mobile/features/contacts/data/datasources/contact_remote_datasource.dart';
import 'package:dolibarr_mobile/features/expenses/data/datasources/expense_local_dao.dart';
import 'package:dolibarr_mobile/features/expenses/data/datasources/expense_remote_datasource.dart';
import 'package:dolibarr_mobile/features/invoices/data/datasources/invoice_local_dao.dart';
import 'package:dolibarr_mobile/features/invoices/data/datasources/invoice_remote_datasource.dart';
import 'package:dolibarr_mobile/features/projects/data/datasources/project_local_dao.dart';
import 'package:dolibarr_mobile/features/projects/data/datasources/project_remote_datasource.dart';
import 'package:dolibarr_mobile/features/proposals/data/datasources/proposal_local_dao.dart';
import 'package:dolibarr_mobile/features/proposals/data/datasources/proposal_remote_datasource.dart';
import 'package:dolibarr_mobile/features/tasks/data/datasources/task_local_dao.dart';
import 'package:dolibarr_mobile/features/tasks/data/datasources/task_remote_datasource.dart';
import 'package:dolibarr_mobile/features/thirdparties/data/datasources/third_party_local_dao.dart';
import 'package:dolibarr_mobile/features/thirdparties/data/datasources/third_party_remote_datasource.dart';
import 'package:logger/logger.dart';

/// Nombre maximum de tentatives avant de basculer une op en `dead`.
const int kMaxAttempts = 5;

/// Backoff exponentiel : 60s * 2^attempts, clamp à 30 minutes.
Duration backoffFor(int attempts) {
  final seconds = 60 * (1 << attempts);
  final clamped = seconds.clamp(60, 30 * 60);
  return Duration(seconds: clamped);
}

/// Synthèse d'un cycle `runOnce`, exposée à la couche UI/log.
class SyncRunReport {
  const SyncRunReport({
    required this.processed,
    required this.succeeded,
    required this.failed,
    required this.conflicts,
    required this.dead,
  });

  final int processed;
  final int succeeded;
  final int failed;
  final int conflicts;
  final int dead;

  static const empty = SyncRunReport(
    processed: 0,
    succeeded: 0,
    failed: 0,
    conflicts: 0,
    dead: 0,
  );
}

/// Moteur de synchronisation Outbox → API Dolibarr.
///
/// Responsabilités :
/// - exécuter les ops `queued` / `failed (eligible)` ;
/// - appliquer le résultat localement (markSynced, clearAfterDelete,
///   patchSocidRemote pour les enfants) ;
/// - cascader la résolution de dépendances quand un parent est créé ;
/// - détecter les conflits via comparaison `tms` avant un PUT.
class SyncEngine {
  SyncEngine({
    required PendingOperationDao outbox,
    required ThirdPartyRemoteDataSource thirdpartyRemote,
    required ThirdPartyLocalDao thirdpartyDao,
    required ContactRemoteDataSource contactRemote,
    required ContactLocalDao contactDao,
    required ProjectRemoteDataSource projectRemote,
    required ProjectLocalDao projectDao,
    required TaskRemoteDataSource taskRemote,
    required TaskLocalDao taskDao,
    required InvoiceRemoteDataSource invoiceRemote,
    required InvoiceLocalDao invoiceDao,
    required ProposalRemoteDataSource proposalRemote,
    required ProposalLocalDao proposalDao,
    required ExpenseRemoteDataSource expenseRemote,
    required ExpenseLocalDao expenseDao,
    required NetworkInfo network,
    Logger? logger,
    DateTime Function() now = DateTime.now,
  })  : _outbox = outbox,
        _thirdpartyRemote = thirdpartyRemote,
        _thirdpartyDao = thirdpartyDao,
        _contactRemote = contactRemote,
        _contactDao = contactDao,
        _projectRemote = projectRemote,
        _projectDao = projectDao,
        _taskRemote = taskRemote,
        _taskDao = taskDao,
        _invoiceRemote = invoiceRemote,
        _invoiceDao = invoiceDao,
        _proposalRemote = proposalRemote,
        _proposalDao = proposalDao,
        _expenseRemote = expenseRemote,
        _expenseDao = expenseDao,
        _network = network,
        _logger = logger ?? Logger(printer: SimplePrinter()),
        _now = now;

  final PendingOperationDao _outbox;
  final ThirdPartyRemoteDataSource _thirdpartyRemote;
  final ThirdPartyLocalDao _thirdpartyDao;
  final ContactRemoteDataSource _contactRemote;
  final ContactLocalDao _contactDao;
  final ProjectRemoteDataSource _projectRemote;
  final ProjectLocalDao _projectDao;
  final TaskRemoteDataSource _taskRemote;
  final TaskLocalDao _taskDao;
  final InvoiceRemoteDataSource _invoiceRemote;
  final InvoiceLocalDao _invoiceDao;
  final ProposalRemoteDataSource _proposalRemote;
  final ProposalLocalDao _proposalDao;
  final ExpenseRemoteDataSource _expenseRemote;
  final ExpenseLocalDao _expenseDao;
  final NetworkInfo _network;
  final Logger _logger;
  final DateTime Function() _now;

  StreamSubscription<bool>? _networkSub;
  bool _running = false;
  bool _started = false;

  /// Démarre l'engine : s'abonne aux changements de réseau et déclenche
  /// un cycle dès que la connectivité est rétablie. Idempotent.
  Future<void> start() async {
    if (_started) return;
    _started = true;
    _networkSub = _network.onStatusChange.listen((online) {
      if (online) {
        // ignore: unawaited_futures
        runOnce();
      }
    });
    if (_network.isOnline) {
      // ignore: unawaited_futures
      runOnce();
    }
  }

  Future<void> stop() async {
    await _networkSub?.cancel();
    _networkSub = null;
    _started = false;
  }

  /// Exécute toutes les ops dispatchables maintenant. Renvoie un rapport
  /// agrégé. Ne lance jamais d'exception — toute erreur est convertie
  /// en mise à jour d'op (failed/conflict/dead).
  Future<SyncRunReport> runOnce() async {
    if (_running) return SyncRunReport.empty;
    _running = true;
    var processed = 0;
    var succeeded = 0;
    var failed = 0;
    var conflicts = 0;
    var dead = 0;
    try {
      while (true) {
        final batch = await _outbox.dispatchable(now: _now());
        if (batch.isEmpty) break;
        for (final op in batch) {
          processed += 1;
          final outcome = await _dispatch(op);
          switch (outcome) {
            case _Outcome.success:
              succeeded += 1;
            case _Outcome.failed:
              failed += 1;
            case _Outcome.conflict:
              conflicts += 1;
            case _Outcome.dead:
              dead += 1;
          }
        }
      }
    } finally {
      _running = false;
    }
    return SyncRunReport(
      processed: processed,
      succeeded: succeeded,
      failed: failed,
      conflicts: conflicts,
      dead: dead,
    );
  }

  /// Force le retry d'une op et déclenche un cycle.
  Future<void> retryNow(int opId) async {
    await _outbox.retryNow(opId);
    // ignore: unawaited_futures
    runOnce();
  }

  /// Discarde une op : la supprime de la file. Si `alsoDeleteEntity`,
  /// purge également l'entité locale (utile pour annuler une création).
  Future<void> discard(int opId, {bool alsoDeleteEntity = false}) async {
    final row = await _outbox.findById(opId);
    if (row == null) return;
    if (alsoDeleteEntity && row.opType == PendingOpType.create) {
      switch (row.entityType) {
        case PendingOpEntity.thirdparty:
          await _thirdpartyDao.hardDelete(row.targetLocalId);
        case PendingOpEntity.contact:
          await _contactDao.hardDelete(row.targetLocalId);
        case PendingOpEntity.project:
          await _projectDao.hardDelete(row.targetLocalId);
        case PendingOpEntity.task:
          await _taskDao.hardDelete(row.targetLocalId);
        case PendingOpEntity.invoice:
          await _invoiceDao.hardDelete(row.targetLocalId);
        case PendingOpEntity.invoiceLine:
          await _invoiceDao.hardDeleteLine(row.targetLocalId);
        case PendingOpEntity.proposal:
          await _proposalDao.hardDelete(row.targetLocalId);
        case PendingOpEntity.proposalLine:
          await _proposalDao.hardDeleteLine(row.targetLocalId);
        case PendingOpEntity.expenseReport:
          await _expenseDao.hardDelete(row.targetLocalId);
        case PendingOpEntity.expenseLine:
          await _expenseDao.hardDeleteLine(row.targetLocalId);
      }
    }
    await _outbox.deleteById(opId);
  }

  // -------------------------- Dispatch --------------------------------

  Future<_Outcome> _dispatch(PendingOperationRow op) async {
    await _outbox.markInProgress(op.id);
    try {
      switch (op.entityType) {
        case PendingOpEntity.thirdparty:
          await _dispatchThirdParty(op);
        case PendingOpEntity.contact:
          await _dispatchContact(op);
        case PendingOpEntity.project:
          await _dispatchProject(op);
        case PendingOpEntity.task:
          await _dispatchTask(op);
        case PendingOpEntity.invoice:
          await _dispatchInvoice(op);
        case PendingOpEntity.invoiceLine:
          await _dispatchInvoiceLine(op);
        case PendingOpEntity.proposal:
          await _dispatchProposal(op);
        case PendingOpEntity.proposalLine:
          await _dispatchProposalLine(op);
        case PendingOpEntity.expenseReport:
          await _dispatchExpenseReport(op);
        case PendingOpEntity.expenseLine:
          await _dispatchExpenseLine(op);
      }
      await _outbox.completeAndUnblockChildren(op.id);
      return _Outcome.success;
    } on _ConflictDetected catch (e) {
      await _onConflict(op, e.message);
      return _Outcome.conflict;
    } on UnauthorizedException catch (e) {
      // 401 : on stoppe la boucle, l'auth_guard prendra le relais. On
      // marque l'op failed pour qu'elle soit retentée à la reconnexion.
      return _onFailed(op, 'Session expirée : ${e.message ?? ''}');
    } on ForbiddenException catch (e) {
      await _outbox.markDead(opId: op.id, message: 'Refusé : ${e.message}');
      return _Outcome.dead;
    } on NotFoundException catch (e) {
      // Souvent : entité supprimée côté serveur entretemps.
      if (op.opType == PendingOpType.delete) {
        // Cohérent : on a déjà l'objectif atteint.
        await _applyAfterDelete(op);
        await _outbox.completeAndUnblockChildren(op.id);
        return _Outcome.success;
      }
      await _outbox.markDead(
        opId: op.id,
        message: 'Ressource introuvable : ${e.message}',
      );
      return _Outcome.dead;
    } on ValidationException catch (e) {
      await _outbox.markDead(
        opId: op.id,
        message: 'Validation : ${e.message ?? e.fieldErrors}',
      );
      return _Outcome.dead;
    } on NetworkException catch (e) {
      return _onFailed(op, 'Réseau : ${e.message ?? ''}');
    } on ServerException catch (e) {
      return _onFailed(op, 'Serveur ${e.statusCode} : ${e.message ?? ''}');
    } catch (e, st) {
      _logger.e(
        'SyncEngine: erreur inattendue op#${op.id}',
        error: e,
        stackTrace: st,
      );
      return _onFailed(op, 'Inattendu : $e');
    }
  }

  Future<void> _onConflict(PendingOperationRow op, String message) async {
    await _outbox.markConflict(opId: op.id, message: message);
    switch (op.entityType) {
      case PendingOpEntity.thirdparty:
        await _thirdpartyDao.markConflict(op.targetLocalId);
      case PendingOpEntity.contact:
        await _contactDao.markConflict(op.targetLocalId);
      case PendingOpEntity.project:
        await _projectDao.markConflict(op.targetLocalId);
      case PendingOpEntity.task:
        await _taskDao.markConflict(op.targetLocalId);
      case PendingOpEntity.invoice:
        await _invoiceDao.markConflict(op.targetLocalId);
      case PendingOpEntity.invoiceLine:
        await _invoiceDao.markLineConflict(op.targetLocalId);
      case PendingOpEntity.proposal:
        await _proposalDao.markConflict(op.targetLocalId);
      case PendingOpEntity.proposalLine:
        await _proposalDao.markLineConflict(op.targetLocalId);
      case PendingOpEntity.expenseReport:
        await _expenseDao.markConflict(op.targetLocalId);
      case PendingOpEntity.expenseLine:
        await _expenseDao.markLineConflict(op.targetLocalId);
    }
  }

  Future<_Outcome> _onFailed(
    PendingOperationRow op,
    String message,
  ) async {
    final attempts = op.attempts + 1;
    if (attempts >= kMaxAttempts) {
      await _outbox.markDead(
        opId: op.id,
        message: 'Échec définitif après $attempts tentatives : $message',
      );
      return _Outcome.dead;
    }
    final next = _now().add(backoffFor(attempts));
    await _outbox.markFailed(
      opId: op.id,
      message: message,
      nextRetryAt: next,
    );
    return _Outcome.failed;
  }

  // -------------------------- Thirdparty --------------------------------

  Future<void> _dispatchThirdParty(PendingOperationRow op) async {
    final payload = _decodePayload(op.payload);
    switch (op.opType) {
      case PendingOpType.create:
        final remoteId = await _thirdpartyRemote.create(payload);
        DateTime? serverTms;
        try {
          final fresh = await _thirdpartyRemote.fetchById(remoteId);
          serverTms = _parseTms(fresh['tms']);
        } catch (_) {
          // Le re-fetch n'est pas critique : on continue avec now().
        }
        await _thirdpartyDao.markSyncedWithRemote(
          localId: op.targetLocalId,
          remoteId: remoteId,
          tms: serverTms,
        );
        // Cascade : patche les enfants directs (contacts + projets +
        // factures) en attente avec le nouveau socidRemote.
        await _contactDao.patchSocidRemoteByParent(
          parentLocalId: op.targetLocalId,
          parentRemoteId: remoteId,
        );
        await _projectDao.patchSocidRemoteByParent(
          parentLocalId: op.targetLocalId,
          parentRemoteId: remoteId,
        );
        await _invoiceDao.patchSocidRemoteByParent(
          parentLocalId: op.targetLocalId,
          parentRemoteId: remoteId,
        );
        await _proposalDao.patchSocidRemoteByParent(
          parentLocalId: op.targetLocalId,
          parentRemoteId: remoteId,
        );

      case PendingOpType.update:
        if (op.expectedTms != null) {
          final fresh = await _thirdpartyRemote.fetchById(op.targetRemoteId!);
          final serverTms = _parseTms(fresh['tms']);
          if (serverTms != null && serverTms.isAfter(op.expectedTms!)) {
            throw _ConflictDetected(
              'Modifié sur le serveur (tms=$serverTms vs ${op.expectedTms})',
            );
          }
        }
        final body = await _thirdpartyRemote.update(
          op.targetRemoteId!,
          payload,
        );
        await _thirdpartyDao.markSyncedWithRemote(
          localId: op.targetLocalId,
          remoteId: op.targetRemoteId!,
          tms: _parseTms(body['tms']),
        );

      case PendingOpType.delete:
        await _thirdpartyRemote.delete(op.targetRemoteId!);
        await _thirdpartyDao.clearAfterServerDelete(op.targetLocalId);
    }
  }

  // -------------------------- Contact ----------------------------------

  Future<void> _dispatchContact(PendingOperationRow op) async {
    final payload = _decodePayload(op.payload);
    switch (op.opType) {
      case PendingOpType.create:
        // Ré-injecte le `socid` depuis l'entité courante (cas où le
        // parent vient juste d'être créé et son remoteId a été patché).
        final fresh = await _contactDao.watchById(op.targetLocalId).first;
        if (fresh != null && fresh.socidRemote != null) {
          payload['socid'] = fresh.socidRemote;
        }
        if (payload['socid'] == null) {
          throw const ValidationException(
            message: 'Tiers parent non synchronisé — '
                'impossible de créer le contact.',
          );
        }
        final remoteId = await _contactRemote.create(payload);
        DateTime? serverTms;
        try {
          final got = await _contactRemote.fetchById(remoteId);
          serverTms = _parseTms(got['tms']);
        } catch (_) {
          // pas critique
        }
        await _contactDao.markSyncedWithRemote(
          localId: op.targetLocalId,
          remoteId: remoteId,
          tms: serverTms,
        );

      case PendingOpType.update:
        if (op.expectedTms != null) {
          final fresh = await _contactRemote.fetchById(op.targetRemoteId!);
          final serverTms = _parseTms(fresh['tms']);
          if (serverTms != null && serverTms.isAfter(op.expectedTms!)) {
            throw _ConflictDetected(
              'Modifié sur le serveur (tms=$serverTms vs ${op.expectedTms})',
            );
          }
        }
        final body = await _contactRemote.update(
          op.targetRemoteId!,
          payload,
        );
        await _contactDao.markSyncedWithRemote(
          localId: op.targetLocalId,
          remoteId: op.targetRemoteId!,
          tms: _parseTms(body['tms']),
        );

      case PendingOpType.delete:
        await _contactRemote.delete(op.targetRemoteId!);
        await _contactDao.clearAfterServerDelete(op.targetLocalId);
    }
  }

  // -------------------------- Project ----------------------------------

  Future<void> _dispatchProject(PendingOperationRow op) async {
    final payload = _decodePayload(op.payload);
    switch (op.opType) {
      case PendingOpType.create:
        // Ré-injecte le `socid` depuis l'entité courante (cas où le
        // tiers parent vient juste d'être créé et son remoteId a été
        // patché en cascade).
        final fresh = await _projectDao.watchById(op.targetLocalId).first;
        if (fresh != null && fresh.socidRemote != null) {
          payload['socid'] = fresh.socidRemote;
        }
        if (payload['socid'] == null) {
          throw const ValidationException(
            message: 'Tiers parent non synchronisé — '
                'impossible de créer le projet.',
          );
        }
        final remoteId = await _projectRemote.create(payload);
        DateTime? serverTms;
        try {
          final got = await _projectRemote.fetchById(remoteId);
          serverTms = _parseTms(got['tms']);
        } catch (_) {
          // pas critique
        }
        await _projectDao.markSyncedWithRemote(
          localId: op.targetLocalId,
          remoteId: remoteId,
          tms: serverTms,
        );
        // Cascade 2ᵉ niveau : patche les tâches dont le projet parent
        // vient d'être créé.
        await _taskDao.patchProjectRemoteByParent(
          parentLocalId: op.targetLocalId,
          parentRemoteId: remoteId,
        );

      case PendingOpType.update:
        if (op.expectedTms != null) {
          final freshFromServer =
              await _projectRemote.fetchById(op.targetRemoteId!);
          final serverTms = _parseTms(freshFromServer['tms']);
          if (serverTms != null && serverTms.isAfter(op.expectedTms!)) {
            throw _ConflictDetected(
              'Modifié sur le serveur (tms=$serverTms vs ${op.expectedTms})',
            );
          }
        }
        final body = await _projectRemote.update(
          op.targetRemoteId!,
          payload,
        );
        await _projectDao.markSyncedWithRemote(
          localId: op.targetLocalId,
          remoteId: op.targetRemoteId!,
          tms: _parseTms(body['tms']),
        );

      case PendingOpType.delete:
        await _projectRemote.delete(op.targetRemoteId!);
        await _projectDao.clearAfterServerDelete(op.targetLocalId);
    }
  }

  // -------------------------- Task -------------------------------------

  Future<void> _dispatchTask(PendingOperationRow op) async {
    final payload = _decodePayload(op.payload);
    switch (op.opType) {
      case PendingOpType.create:
        // Ré-injecte fk_projet depuis l'entité courante (cas où le
        // projet parent vient juste d'être créé et son remoteId
        // patché en cascade).
        final fresh = await _taskDao.watchById(op.targetLocalId).first;
        if (fresh != null && fresh.projectRemote != null) {
          payload['fk_projet'] = fresh.projectRemote;
        }
        if (payload['fk_projet'] == null) {
          throw const ValidationException(
            message: 'Projet parent non synchronisé — '
                'impossible de créer la tâche.',
          );
        }
        final remoteId = await _taskRemote.create(payload);
        DateTime? serverTms;
        try {
          final got = await _taskRemote.fetchById(remoteId);
          serverTms = _parseTms(got['tms']);
        } catch (_) {
          // pas critique
        }
        await _taskDao.markSyncedWithRemote(
          localId: op.targetLocalId,
          remoteId: remoteId,
          tms: serverTms,
        );

      case PendingOpType.update:
        if (op.expectedTms != null) {
          final freshFromServer =
              await _taskRemote.fetchById(op.targetRemoteId!);
          final serverTms = _parseTms(freshFromServer['tms']);
          if (serverTms != null && serverTms.isAfter(op.expectedTms!)) {
            throw _ConflictDetected(
              'Modifié sur le serveur (tms=$serverTms vs ${op.expectedTms})',
            );
          }
        }
        final body = await _taskRemote.update(
          op.targetRemoteId!,
          payload,
        );
        await _taskDao.markSyncedWithRemote(
          localId: op.targetLocalId,
          remoteId: op.targetRemoteId!,
          tms: _parseTms(body['tms']),
        );

      case PendingOpType.delete:
        await _taskRemote.delete(op.targetRemoteId!);
        await _taskDao.clearAfterServerDelete(op.targetLocalId);
    }
  }

  // -------------------------- Invoice ----------------------------------

  Future<void> _dispatchInvoice(PendingOperationRow op) async {
    final payload = _decodePayload(op.payload);
    switch (op.opType) {
      case PendingOpType.create:
        // Ré-injecte socid depuis l'entité fraîche (cas où le tiers
        // parent vient juste d'être créé en cascade).
        final fresh = await _invoiceDao.watchById(op.targetLocalId).first;
        if (fresh != null && fresh.socidRemote != null) {
          payload['socid'] = fresh.socidRemote;
        }
        if (payload['socid'] == null) {
          throw const ValidationException(
            message: 'Tiers parent non synchronisé — '
                'impossible de créer la facture.',
          );
        }
        final remoteId = await _invoiceRemote.create(payload);
        DateTime? serverTms;
        try {
          final got = await _invoiceRemote.fetchById(remoteId);
          serverTms = _parseTms(got['tms']);
        } catch (_) {
          // pas critique
        }
        await _invoiceDao.markSyncedWithRemote(
          localId: op.targetLocalId,
          remoteId: remoteId,
          tms: serverTms,
        );
        // Cascade 2ᵉ niveau : patche les lignes orphelines (en
        // attente que la facture parent soit créée).
        await _invoiceDao.patchInvoiceRemoteByParent(
          parentLocalId: op.targetLocalId,
          parentRemoteId: remoteId,
        );

      case PendingOpType.update:
        if (op.expectedTms != null) {
          final freshFromServer =
              await _invoiceRemote.fetchById(op.targetRemoteId!);
          final serverTms = _parseTms(freshFromServer['tms']);
          if (serverTms != null && serverTms.isAfter(op.expectedTms!)) {
            throw _ConflictDetected(
              'Modifié sur le serveur (tms=$serverTms vs ${op.expectedTms})',
            );
          }
        }
        final body = await _invoiceRemote.update(
          op.targetRemoteId!,
          payload,
        );
        await _invoiceDao.markSyncedWithRemote(
          localId: op.targetLocalId,
          remoteId: op.targetRemoteId!,
          tms: _parseTms(body['tms']),
        );

      case PendingOpType.delete:
        await _invoiceRemote.delete(op.targetRemoteId!);
        await _invoiceDao.clearAfterServerDelete(op.targetLocalId);
    }
  }

  // -------------------------- Invoice line -----------------------------

  Future<void> _dispatchInvoiceLine(PendingOperationRow op) async {
    final payload = _decodePayload(op.payload);
    switch (op.opType) {
      case PendingOpType.create:
        // Ré-injecte fk_facture depuis l'entité ligne fraîche (la
        // facture parente vient peut-être d'être créée en cascade).
        final fresh = await _invoiceDao.watchLineById(op.targetLocalId).first;
        final invoiceRemote = fresh?.invoiceRemote;
        if (invoiceRemote == null) {
          throw const ValidationException(
            message: 'Facture parente non synchronisée — '
                'impossible de créer la ligne.',
          );
        }
        final remoteId = await _invoiceRemote.createLine(
          invoiceRemote,
          payload,
        );
        await _invoiceDao.markLineSyncedWithRemote(
          localId: op.targetLocalId,
          remoteId: remoteId,
        );

      case PendingOpType.update:
        // L'API ligne n'expose pas un endpoint séparé pour le tms,
        // donc pas de pré-check conflit ici. Le serveur fait foi.
        final fresh = await _invoiceDao.findLineByLocalId(op.targetLocalId);
        final invoiceRemote = fresh?.invoiceRemote;
        if (invoiceRemote == null) {
          throw const ValidationException(
            message: 'Facture parente non synchronisée — '
                'impossible de modifier la ligne.',
          );
        }
        await _invoiceRemote.updateLine(
          invoiceRemote,
          op.targetRemoteId!,
          payload,
        );
        await _invoiceDao.markLineSyncedWithRemote(
          localId: op.targetLocalId,
          remoteId: op.targetRemoteId!,
        );

      case PendingOpType.delete:
        final fresh = await _invoiceDao.findLineByLocalId(op.targetLocalId);
        final invoiceRemote = fresh?.invoiceRemote;
        if (invoiceRemote == null) {
          // La facture parent a disparu : on supprime la ligne en
          // local sans appel serveur (idempotent).
          await _invoiceDao.clearLineAfterServerDelete(op.targetLocalId);
          return;
        }
        await _invoiceRemote.deleteLine(
          invoiceRemote,
          op.targetRemoteId!,
        );
        await _invoiceDao.clearLineAfterServerDelete(op.targetLocalId);
    }
  }

  // -------------------------- Proposal ---------------------------------

  Future<void> _dispatchProposal(PendingOperationRow op) async {
    final payload = _decodePayload(op.payload);
    switch (op.opType) {
      case PendingOpType.create:
        final fresh = await _proposalDao.watchById(op.targetLocalId).first;
        if (fresh != null && fresh.socidRemote != null) {
          payload['socid'] = fresh.socidRemote;
        }
        if (payload['socid'] == null) {
          throw const ValidationException(
            message: 'Tiers parent non synchronisé — '
                'impossible de créer le devis.',
          );
        }
        final remoteId = await _proposalRemote.create(payload);
        DateTime? serverTms;
        try {
          final got = await _proposalRemote.fetchById(remoteId);
          serverTms = _parseTms(got['tms']);
        } catch (_) {
          // pas critique
        }
        await _proposalDao.markSyncedWithRemote(
          localId: op.targetLocalId,
          remoteId: remoteId,
          tms: serverTms,
        );
        await _proposalDao.patchProposalRemoteByParent(
          parentLocalId: op.targetLocalId,
          parentRemoteId: remoteId,
        );

      case PendingOpType.update:
        if (op.expectedTms != null) {
          final freshFromServer =
              await _proposalRemote.fetchById(op.targetRemoteId!);
          final serverTms = _parseTms(freshFromServer['tms']);
          if (serverTms != null && serverTms.isAfter(op.expectedTms!)) {
            throw _ConflictDetected(
              'Modifié sur le serveur (tms=$serverTms vs ${op.expectedTms})',
            );
          }
        }
        final body = await _proposalRemote.update(
          op.targetRemoteId!,
          payload,
        );
        await _proposalDao.markSyncedWithRemote(
          localId: op.targetLocalId,
          remoteId: op.targetRemoteId!,
          tms: _parseTms(body['tms']),
        );

      case PendingOpType.delete:
        await _proposalRemote.delete(op.targetRemoteId!);
        await _proposalDao.clearAfterServerDelete(op.targetLocalId);
    }
  }

  // -------------------------- Proposal line ----------------------------

  Future<void> _dispatchProposalLine(PendingOperationRow op) async {
    final payload = _decodePayload(op.payload);
    switch (op.opType) {
      case PendingOpType.create:
        final fresh = await _proposalDao.watchLineById(op.targetLocalId).first;
        final proposalRemote = fresh?.proposalRemote;
        if (proposalRemote == null) {
          throw const ValidationException(
            message: 'Devis parent non synchronisé — '
                'impossible de créer la ligne.',
          );
        }
        final remoteId = await _proposalRemote.createLine(
          proposalRemote,
          payload,
        );
        await _proposalDao.markLineSyncedWithRemote(
          localId: op.targetLocalId,
          remoteId: remoteId,
        );

      case PendingOpType.update:
        final fresh =
            await _proposalDao.findLineByLocalId(op.targetLocalId);
        final proposalRemote = fresh?.proposalRemote;
        if (proposalRemote == null) {
          throw const ValidationException(
            message: 'Devis parent non synchronisé — '
                'impossible de modifier la ligne.',
          );
        }
        await _proposalRemote.updateLine(
          proposalRemote,
          op.targetRemoteId!,
          payload,
        );
        await _proposalDao.markLineSyncedWithRemote(
          localId: op.targetLocalId,
          remoteId: op.targetRemoteId!,
        );

      case PendingOpType.delete:
        final fresh =
            await _proposalDao.findLineByLocalId(op.targetLocalId);
        final proposalRemote = fresh?.proposalRemote;
        if (proposalRemote == null) {
          await _proposalDao.clearLineAfterServerDelete(op.targetLocalId);
          return;
        }
        await _proposalRemote.deleteLine(
          proposalRemote,
          op.targetRemoteId!,
        );
        await _proposalDao.clearLineAfterServerDelete(op.targetLocalId);
    }
  }

  // -------------------------- Expense report ---------------------------

  Future<void> _dispatchExpenseReport(PendingOperationRow op) async {
    final payload = _decodePayload(op.payload);
    switch (op.opType) {
      case PendingOpType.create:
        final remoteId = await _expenseRemote.create(payload);
        DateTime? serverTms;
        try {
          final got = await _expenseRemote.fetchById(remoteId);
          serverTms = _parseTms(got['tms']);
        } catch (_) {
          // pas critique
        }
        await _expenseDao.markSyncedWithRemote(
          localId: op.targetLocalId,
          remoteId: remoteId,
          tms: serverTms,
        );
        // Cascade 2ᵉ niveau : patche les lignes orphelines en attente.
        await _expenseDao.patchExpenseReportRemoteByParent(
          parentLocalId: op.targetLocalId,
          parentRemoteId: remoteId,
        );

      case PendingOpType.update:
        if (op.expectedTms != null) {
          final freshFromServer =
              await _expenseRemote.fetchById(op.targetRemoteId!);
          final serverTms = _parseTms(freshFromServer['tms']);
          if (serverTms != null && serverTms.isAfter(op.expectedTms!)) {
            throw _ConflictDetected(
              'Modifié sur le serveur (tms=$serverTms vs ${op.expectedTms})',
            );
          }
        }
        final body = await _expenseRemote.update(
          op.targetRemoteId!,
          payload,
        );
        await _expenseDao.markSyncedWithRemote(
          localId: op.targetLocalId,
          remoteId: op.targetRemoteId!,
          tms: _parseTms(body['tms']),
        );

      case PendingOpType.delete:
        await _expenseRemote.delete(op.targetRemoteId!);
        await _expenseDao.clearAfterServerDelete(op.targetLocalId);
    }
  }

  // -------------------------- Expense line -----------------------------

  Future<void> _dispatchExpenseLine(PendingOperationRow op) async {
    final payload = _decodePayload(op.payload);
    switch (op.opType) {
      case PendingOpType.create:
        // Ré-injecte le code_type_fees → fk_c_type_fees depuis le cache
        // local si la note parente est désormais résolue.
        final fresh =
            await _expenseDao.watchLineById(op.targetLocalId).first;
        final reportRemote = fresh?.expenseReportRemote;
        if (reportRemote == null) {
          throw const ValidationException(
            message: 'Note de frais parente non synchronisée — '
                'impossible de créer la ligne.',
          );
        }
        // Garde-fou : si le payload a un code mais pas d'id (lookup
        // raté côté repo), on essaie de résoudre depuis le cache local.
        if (payload['fk_c_type_fees'] == null &&
            fresh?.codeCTypeFees != null) {
          final id = await _expenseDao
              .resolveTypeIdByCode(fresh!.codeCTypeFees!);
          if (id != null) payload['fk_c_type_fees'] = id;
        }
        final remoteId =
            await _expenseRemote.createLine(reportRemote, payload);
        await _expenseDao.markLineSyncedWithRemote(
          localId: op.targetLocalId,
          remoteId: remoteId,
        );

      case PendingOpType.update:
        final fresh =
            await _expenseDao.findLineByLocalId(op.targetLocalId);
        final reportRemote = fresh?.expenseReportRemote;
        if (reportRemote == null) {
          throw const ValidationException(
            message: 'Note de frais parente non synchronisée — '
                'impossible de modifier la ligne.',
          );
        }
        await _expenseRemote.updateLine(
          reportRemote,
          op.targetRemoteId!,
          payload,
        );
        await _expenseDao.markLineSyncedWithRemote(
          localId: op.targetLocalId,
          remoteId: op.targetRemoteId!,
        );

      case PendingOpType.delete:
        final fresh =
            await _expenseDao.findLineByLocalId(op.targetLocalId);
        final reportRemote = fresh?.expenseReportRemote;
        if (reportRemote == null) {
          await _expenseDao.clearLineAfterServerDelete(op.targetLocalId);
          return;
        }
        await _expenseRemote.deleteLine(
          reportRemote,
          op.targetRemoteId!,
        );
        await _expenseDao.clearLineAfterServerDelete(op.targetLocalId);
    }
  }

  // -------------------------- Helpers ----------------------------------

  Future<void> _applyAfterDelete(PendingOperationRow op) async {
    switch (op.entityType) {
      case PendingOpEntity.thirdparty:
        await _thirdpartyDao.clearAfterServerDelete(op.targetLocalId);
      case PendingOpEntity.contact:
        await _contactDao.clearAfterServerDelete(op.targetLocalId);
      case PendingOpEntity.project:
        await _projectDao.clearAfterServerDelete(op.targetLocalId);
      case PendingOpEntity.task:
        await _taskDao.clearAfterServerDelete(op.targetLocalId);
      case PendingOpEntity.invoice:
        await _invoiceDao.clearAfterServerDelete(op.targetLocalId);
      case PendingOpEntity.invoiceLine:
        await _invoiceDao.clearLineAfterServerDelete(op.targetLocalId);
      case PendingOpEntity.proposal:
        await _proposalDao.clearAfterServerDelete(op.targetLocalId);
      case PendingOpEntity.proposalLine:
        await _proposalDao.clearLineAfterServerDelete(op.targetLocalId);
      case PendingOpEntity.expenseReport:
        await _expenseDao.clearAfterServerDelete(op.targetLocalId);
      case PendingOpEntity.expenseLine:
        await _expenseDao.clearLineAfterServerDelete(op.targetLocalId);
    }
  }

  Map<String, Object?> _decodePayload(String raw) {
    try {
      final v = jsonDecode(raw);
      if (v is Map) return v.cast<String, Object?>();
    } catch (_) {
      // payload corrompu — l'op finira en dead via la suite du dispatch
    }
    return {};
  }

  DateTime? _parseTms(Object? raw) {
    if (raw == null) return null;
    final n = int.tryParse('$raw');
    if (n == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(n * 1000);
  }
}

/// Issue d'une op individuelle, agrégée par `runOnce`.
enum _Outcome { success, failed, conflict, dead }

class _ConflictDetected implements Exception {
  const _ConflictDetected(this.message);
  final String message;
}
