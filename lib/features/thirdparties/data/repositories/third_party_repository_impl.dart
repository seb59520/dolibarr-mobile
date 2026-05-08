import 'package:dolibarr_mobile/core/errors/error_mapper.dart';
import 'package:dolibarr_mobile/core/network/network_info.dart';
import 'package:dolibarr_mobile/core/storage/pending_operation_dao.dart';
import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/thirdparties/data/datasources/draft_local_dao.dart';
import 'package:dolibarr_mobile/features/thirdparties/data/datasources/third_party_local_dao.dart';
import 'package:dolibarr_mobile/features/thirdparties/data/datasources/third_party_remote_datasource.dart';
import 'package:dolibarr_mobile/features/thirdparties/domain/entities/third_party.dart';
import 'package:dolibarr_mobile/features/thirdparties/domain/entities/third_party_filters.dart';
import 'package:dolibarr_mobile/features/thirdparties/domain/repositories/third_party_repository.dart';

const _draftEntityType = 'thirdparty';

final class ThirdPartyRepositoryImpl implements ThirdPartyRepository {
  ThirdPartyRepositoryImpl({
    required ThirdPartyRemoteDataSource remote,
    required ThirdPartyLocalDao dao,
    required NetworkInfo network,
    required DraftLocalDao draftDao,
    required PendingOperationDao outbox,
  })  : _remote = remote,
        _dao = dao,
        _network = network,
        _draftDao = draftDao,
        _outbox = outbox;

  final ThirdPartyRemoteDataSource _remote;
  final ThirdPartyLocalDao _dao;
  final NetworkInfo _network;
  final DraftLocalDao _draftDao;
  final PendingOperationDao _outbox;

  @override
  Stream<List<ThirdParty>> watchList(
    ThirdPartyFilters filters, {
    int? userId,
  }) {
    if (_network.isOnline) {
      // ignore: unawaited_futures
      refreshPage(filters: filters, page: 0, userId: userId);
    }
    return _dao.watchFiltered(filters);
  }

  @override
  Stream<ThirdParty?> watchById(int localId) => _dao.watchById(localId);

  @override
  Future<Result<int>> refreshPage({
    required ThirdPartyFilters filters,
    required int page,
    int limit = 100,
    int? userId,
  }) async {
    try {
      final rows = await _remote.fetchPage(
        filters: filters,
        page: page,
        limit: limit,
        userId: userId,
      );
      await _dao.upsertManyFromServer(rows);
      return Success(rows.length);
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }

  @override
  Future<Result<ThirdParty>> refreshById(int remoteId) async {
    try {
      final json = await _remote.fetchById(remoteId);
      await _dao.upsertFromServer(json);
      final fresh = await _dao.findByRemoteId(remoteId);
      if (fresh == null) {
        throw StateError('Tier $remoteId introuvable après upsert');
      }
      return Success(fresh);
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }

  @override
  Future<Result<int>> createLocal(ThirdParty draft) async {
    try {
      final localId = await _dao.insertLocal(draft);
      await _outbox.enqueue(
        opType: PendingOpType.create,
        entityType: PendingOpEntity.thirdparty,
        targetLocalId: localId,
        payload: _payloadFor(draft),
      );
      return Success(localId);
    } catch (e, st) {
      return FailureResult(ErrorMapper.toFailure(e, st));
    }
  }

  @override
  Future<Result<void>> updateLocal(ThirdParty entity) async {
    try {
      await _dao.updateLocal(entity);
      await _outbox.enqueue(
        opType: PendingOpType.update,
        entityType: PendingOpEntity.thirdparty,
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
        // Jamais poussée serveur : suppression directe + drop des ops liées.
        await _outbox.deleteForLocal(
          entityType: PendingOpEntity.thirdparty,
          targetLocalId: localId,
        );
        await _dao.hardDelete(localId);
        return const Success<void>(null);
      }
      await _dao.markPendingDelete(localId);
      await _outbox.enqueue(
        opType: PendingOpType.delete,
        entityType: PendingOpEntity.thirdparty,
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

  /// Construit le payload JSON envoyé à `POST/PUT /thirdparties`.
  Map<String, Object?> _payloadFor(ThirdParty t) => {
        'name': t.name,
        if (t.codeClient != null) 'code_client': t.codeClient,
        if (t.codeFournisseur != null)
          'code_fournisseur': t.codeFournisseur,
        'client': t.clientFlags,
        'fournisseur': t.fournisseur ? 1 : 0,
        'status': t.status,
        if (t.address != null) 'address': t.address,
        if (t.zip != null) 'zip': t.zip,
        if (t.town != null) 'town': t.town,
        if (t.countryCode != null) 'country_code': t.countryCode,
        if (t.phone != null) 'phone': t.phone,
        if (t.email != null) 'email': t.email,
        if (t.url != null) 'url': t.url,
        if (t.siren != null) 'idprof1': t.siren,
        if (t.siret != null) 'idprof2': t.siret,
        if (t.tvaIntra != null) 'tva_intra': t.tvaIntra,
        if (t.notePublic != null) 'note_public': t.notePublic,
        if (t.notePrivate != null) 'note_private': t.notePrivate,
        if (t.categories.isNotEmpty) 'categories': t.categories,
        if (t.extrafields.isNotEmpty) 'array_options': t.extrafields,
      };
}
