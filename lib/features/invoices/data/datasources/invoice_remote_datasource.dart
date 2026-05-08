// ignore_for_file: one_member_abstracts

import 'package:dio/dio.dart';
import 'package:dolibarr_mobile/core/constants/api_paths.dart';
import 'package:dolibarr_mobile/core/errors/error_mapper.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice_filters.dart';

abstract interface class InvoiceRemoteDataSource {
  Future<List<Map<String, Object?>>> fetchPage({
    required InvoiceFilters filters,
    required int page,
    required int limit,
  });

  /// Récupère le détail d'une facture. Le body Dolibarr inclut les
  /// lignes dans la clé `lines`.
  Future<Map<String, Object?>> fetchById(int remoteId);
}

final class InvoiceRemoteDataSourceImpl implements InvoiceRemoteDataSource {
  InvoiceRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<Map<String, Object?>>> fetchPage({
    required InvoiceFilters filters,
    required int page,
    required int limit,
  }) async {
    try {
      final res = await _dio.get<List<dynamic>>(
        ApiPaths.invoices,
        queryParameters: <String, Object?>{
          'limit': limit,
          'page': page,
          if (_buildSqlFilters(filters) != null)
            'sqlfilters': _buildSqlFilters(filters),
        },
      );
      return (res.data ?? const <dynamic>[])
          .cast<Map<String, Object?>>()
          .toList();
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  @override
  Future<Map<String, Object?>> fetchById(int remoteId) async {
    try {
      final res = await _dio.get<Map<String, Object?>>(
        ApiPaths.invoiceById(remoteId),
      );
      return res.data ?? const {};
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  String? _buildSqlFilters(InvoiceFilters f) {
    final parts = <String>[];

    if (f.thirdPartyRemoteId != null) {
      parts.add('(t.fk_soc:=:${f.thirdPartyRemoteId})');
    }

    if (f.statuses.isNotEmpty && f.statuses.length < 4) {
      // Statut Dolibarr : on combine `fk_statut` + `paye` car
      // InvoiceStatus.paid n'est pas un statut atomique côté SQL
      // (statut=1 + paye=1).
      final wantsDraft = f.statuses.any((s) => s.apiValue == 0);
      final wantsValidated = f.statuses.any((s) => s.apiValue == 1);
      final wantsPaid = f.statuses.any((s) => s.apiValue == 2);
      final wantsAbandoned = f.statuses.any((s) => s.apiValue == 3);
      final clauses = <String>[];
      if (wantsDraft) clauses.add('(t.fk_statut:=:0)');
      if (wantsValidated) clauses.add('(t.fk_statut:=:1 AND t.paye:=:0)');
      if (wantsPaid) clauses.add('(t.paye:=:1)');
      if (wantsAbandoned) clauses.add('(t.fk_statut:=:3)');
      if (clauses.isNotEmpty) {
        parts.add('(${clauses.join(' OR ')})');
      }
    }

    if (f.unpaidOnly) {
      parts.add('(t.paye:=:0)');
    }

    if (f.dateFrom != null) {
      final ts = f.dateFrom!.millisecondsSinceEpoch ~/ 1000;
      parts.add('(t.datef:>=:$ts)');
    }
    if (f.dateTo != null) {
      final ts = f.dateTo!.millisecondsSinceEpoch ~/ 1000;
      parts.add('(t.datef:<=:$ts)');
    }

    if (f.search.trim().isNotEmpty) {
      final escaped = f.search.replaceAll("'", r"\'");
      parts.add(
        "((t.ref:like:'%$escaped%') "
        "OR (t.ref_client:like:'%$escaped%'))",
      );
    }

    if (parts.isEmpty) return null;
    return parts.join(' AND ');
  }
}
