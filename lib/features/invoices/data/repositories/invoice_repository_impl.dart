import 'package:dolibarr_mobile/core/errors/error_mapper.dart';
import 'package:dolibarr_mobile/core/network/network_info.dart';
import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/invoices/data/datasources/invoice_local_dao.dart';
import 'package:dolibarr_mobile/features/invoices/data/datasources/invoice_remote_datasource.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice_filters.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice_line.dart';
import 'package:dolibarr_mobile/features/invoices/domain/repositories/invoice_repository.dart';

final class InvoiceRepositoryImpl implements InvoiceRepository {
  InvoiceRepositoryImpl({
    required InvoiceRemoteDataSource remote,
    required InvoiceLocalDao dao,
    required NetworkInfo network,
  })  : _remote = remote,
        _dao = dao,
        _network = network;

  final InvoiceRemoteDataSource _remote;
  final InvoiceLocalDao _dao;
  final NetworkInfo _network;

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
}
