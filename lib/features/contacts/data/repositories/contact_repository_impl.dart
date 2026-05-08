import 'package:dolibarr_mobile/core/errors/error_mapper.dart';
import 'package:dolibarr_mobile/core/network/network_info.dart';
import 'package:dolibarr_mobile/core/storage/pending_operation_dao.dart';
import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/contacts/data/datasources/contact_local_dao.dart';
import 'package:dolibarr_mobile/features/contacts/data/datasources/contact_remote_datasource.dart';
import 'package:dolibarr_mobile/features/contacts/domain/entities/contact.dart';
import 'package:dolibarr_mobile/features/contacts/domain/entities/contact_filters.dart';
import 'package:dolibarr_mobile/features/contacts/domain/repositories/contact_repository.dart';
import 'package:dolibarr_mobile/features/thirdparties/data/datasources/draft_local_dao.dart';

const _draftEntityType = 'contact';

final class ContactRepositoryImpl implements ContactRepository {
  ContactRepositoryImpl({
    required ContactRemoteDataSource remote,
    required ContactLocalDao dao,
    required NetworkInfo network,
    required DraftLocalDao draftDao,
    required PendingOperationDao outbox,
  })  : _remote = remote,
        _dao = dao,
        _network = network,
        _draftDao = draftDao,
        _outbox = outbox;

  final ContactRemoteDataSource _remote;
  final ContactLocalDao _dao;
  final NetworkInfo _network;
  final DraftLocalDao _draftDao;
  final PendingOperationDao _outbox;

  @override
  Stream<List<Contact>> watchList(ContactFilters filters) {
    if (_network.isOnline) {
      // ignore: unawaited_futures
      refreshPage(filters: filters, page: 0);
    }
    return _dao.watchFiltered(filters);
  }

  @override
  Stream<Contact?> watchById(int localId) => _dao.watchById(localId);

  @override
  Stream<List<Contact>> watchByThirdPartyLocal(int thirdPartyLocalId) =>
      _dao.watchByThirdPartyLocal(thirdPartyLocalId);

  @override
  Future<Result<int>> refreshPage({
    required ContactFilters filters,
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
  Future<Result<Contact>> refreshById(int remoteId) async {
    try {
      final json = await _remote.fetchById(remoteId);
      await _dao.upsertFromServer(json);
      final fresh = await _dao.findByRemoteId(remoteId);
      if (fresh == null) {
        throw StateError('Contact $remoteId introuvable après upsert');
      }
      return Success(fresh);
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }

  @override
  Future<Result<int>> refreshForThirdParty(int thirdPartyRemoteId) async {
    try {
      final rows = await _remote.fetchByThirdParty(thirdPartyRemoteId);
      await _dao.upsertManyFromServer(rows);
      return Success(rows.length);
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }

  @override
  Future<Result<int>> createLocal(Contact draft) async {
    try {
      final localId = await _dao.insertLocal(draft);

      // Si le tiers parent n'a pas de remoteId mais a un socidLocal,
      // on cherche son op create en attente pour cascader.
      int? dependsOnLocalId;
      if (draft.socidRemote == null && draft.socidLocal != null) {
        dependsOnLocalId = await _outbox.findLatestPendingCreate(
          entityType: PendingOpEntity.thirdparty,
          targetLocalId: draft.socidLocal!,
        );
      }

      await _outbox.enqueue(
        opType: PendingOpType.create,
        entityType: PendingOpEntity.contact,
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
  Future<Result<void>> updateLocal(Contact entity) async {
    try {
      await _dao.updateLocal(entity);
      await _outbox.enqueue(
        opType: PendingOpType.update,
        entityType: PendingOpEntity.contact,
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
          entityType: PendingOpEntity.contact,
          targetLocalId: localId,
        );
        await _dao.hardDelete(localId);
        return const Success<void>(null);
      }
      await _dao.markPendingDelete(localId);
      await _outbox.enqueue(
        opType: PendingOpType.delete,
        entityType: PendingOpEntity.contact,
        targetLocalId: localId,
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

  /// Construit le payload JSON envoyé à `POST/PUT /contacts`.
  Map<String, Object?> _payloadFor(Contact c) {
    return {
      // socid : préférer remote ; sinon laisser null — le sync engine
      // patchera après push du parent (cf. dependsOnLocalId).
      if (c.socidRemote != null) 'socid': c.socidRemote,
      if (c.firstname != null) 'firstname': c.firstname,
      if (c.lastname != null) 'lastname': c.lastname,
      if (c.poste != null) 'poste': c.poste,
      if (c.phonePro != null) 'phone_pro': c.phonePro,
      if (c.phoneMobile != null) 'phone_mobile': c.phoneMobile,
      if (c.email != null) 'email': c.email,
      if (c.address != null) 'address': c.address,
      if (c.zip != null) 'zip': c.zip,
      if (c.town != null) 'town': c.town,
      if (c.extrafields.isNotEmpty) 'array_options': c.extrafields,
    };
  }
}
