// ignore_for_file: one_member_abstracts

import 'package:dio/dio.dart';
import 'package:dolibarr_mobile/core/constants/api_paths.dart';
import 'package:dolibarr_mobile/core/errors/error_mapper.dart';
import 'package:dolibarr_mobile/core/errors/exceptions.dart';
import 'package:dolibarr_mobile/features/expenses/domain/entities/expense_filters.dart';

abstract interface class ExpenseRemoteDataSource {
  Future<List<Map<String, Object?>>> fetchPage({
    required ExpenseFilters filters,
    required int page,
    required int limit,
  });

  /// Récupère le détail (clé `lines: [...]` incluse).
  Future<Map<String, Object?>> fetchById(int remoteId);

  Future<int> create(Map<String, Object?> payload);

  Future<Map<String, Object?>> update(
    int remoteId,
    Map<String, Object?> payload,
  );

  Future<void> delete(int remoteId);

  /// Ajoute une ligne à la note. NB : endpoint POST en `/line` (singulier).
  Future<int> createLine(int reportRemoteId, Map<String, Object?> payload);

  Future<Map<String, Object?>> updateLine(
    int reportRemoteId,
    int lineRemoteId,
    Map<String, Object?> payload,
  );

  Future<void> deleteLine(int reportRemoteId, int lineRemoteId);

  Future<Map<String, Object?>> validate(int remoteId);
  Future<Map<String, Object?>> approve(int remoteId);

  /// Catalogue des types de frais (`llx_c_type_fees`).
  Future<List<Map<String, Object?>>> fetchTypes();

  /// Upload d'un justificatif ECM. `filecontent` doit être en base64.
  Future<String> uploadDocument({
    required String ref,
    required String filename,
    required String base64Content,
  });
}

final class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  ExpenseRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<Map<String, Object?>>> fetchPage({
    required ExpenseFilters filters,
    required int page,
    required int limit,
  }) async {
    try {
      final res = await _dio.get<List<dynamic>>(
        ApiPaths.expenseReports,
        queryParameters: <String, Object?>{
          'limit': limit,
          'page': page,
          'sortfield': 't.date_debut',
          'sortorder': filters.sortDescending ? 'DESC' : 'ASC',
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
        ApiPaths.expenseReportById(remoteId),
      );
      return res.data ?? const {};
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  @override
  Future<int> create(Map<String, Object?> payload) async {
    try {
      final res = await _dio.post<Object?>(
        ApiPaths.expenseReports,
        data: payload,
      );
      final body = res.data;
      if (body is int) return body;
      if (body is num) return body.toInt();
      if (body is String) {
        final n = int.tryParse(body);
        if (n != null) return n;
      }
      if (body is Map<String, Object?>) {
        final n = int.tryParse('${body['id'] ?? body['rowid'] ?? ''}');
        if (n != null) return n;
      }
      throw const ServerException(
        statusCode: 200,
        message: 'Réponse de création note de frais inattendue',
      );
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  @override
  Future<Map<String, Object?>> update(
    int remoteId,
    Map<String, Object?> payload,
  ) async {
    try {
      final res = await _dio.put<Map<String, Object?>>(
        ApiPaths.expenseReportById(remoteId),
        data: payload,
      );
      return res.data ?? const {};
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  @override
  Future<void> delete(int remoteId) async {
    try {
      await _dio.delete<void>(ApiPaths.expenseReportById(remoteId));
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  @override
  Future<int> createLine(
    int reportRemoteId,
    Map<String, Object?> payload,
  ) async {
    try {
      // ATTENTION : POST utilise `/line` (singulier) — voir api_paths.dart.
      final res = await _dio.post<Object?>(
        ApiPaths.expenseReportLineCreate(reportRemoteId),
        data: payload,
      );
      final body = res.data;
      if (body is int) return body;
      if (body is num) return body.toInt();
      if (body is String) {
        final n = int.tryParse(body);
        if (n != null) return n;
      }
      if (body is Map<String, Object?>) {
        final n = int.tryParse('${body['id'] ?? body['rowid'] ?? ''}');
        if (n != null) return n;
      }
      throw const ServerException(
        statusCode: 200,
        message: 'Réponse de création ligne note de frais inattendue',
      );
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  @override
  Future<Map<String, Object?>> updateLine(
    int reportRemoteId,
    int lineRemoteId,
    Map<String, Object?> payload,
  ) async {
    try {
      final res = await _dio.put<Map<String, Object?>>(
        ApiPaths.expenseReportLineById(reportRemoteId, lineRemoteId),
        data: payload,
      );
      return res.data ?? const {};
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  @override
  Future<void> deleteLine(int reportRemoteId, int lineRemoteId) async {
    try {
      await _dio.delete<void>(
        ApiPaths.expenseReportLineById(reportRemoteId, lineRemoteId),
      );
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  @override
  Future<Map<String, Object?>> validate(int remoteId) async {
    try {
      final res = await _dio.post<Object?>(
        ApiPaths.expenseReportValidate(remoteId),
        data: const <String, Object?>{},
      );
      final body = res.data;
      if (body is Map<String, Object?>) return body;
      return const {};
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  @override
  Future<Map<String, Object?>> approve(int remoteId) async {
    try {
      final res = await _dio.post<Object?>(
        ApiPaths.expenseReportApprove(remoteId),
        data: const <String, Object?>{},
      );
      final body = res.data;
      if (body is Map<String, Object?>) return body;
      return const {};
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  @override
  Future<List<Map<String, Object?>>> fetchTypes() async {
    try {
      final res = await _dio.get<List<dynamic>>(
        ApiPaths.expenseReportTypes,
      );
      return (res.data ?? const <dynamic>[])
          .cast<Map<String, Object?>>()
          .toList();
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  @override
  Future<String> uploadDocument({
    required String ref,
    required String filename,
    required String base64Content,
  }) async {
    try {
      final res = await _dio.post<Object?>(
        ApiPaths.documentUpload,
        data: <String, Object?>{
          'filename': filename,
          'modulepart': 'expensereport',
          'ref': ref,
          'fileencoding': 'base64',
          'filecontent': base64Content,
        },
      );
      final body = res.data;
      if (body is String) return body;
      if (body is Map<String, Object?>) {
        return '${body['filepath'] ?? body['filename'] ?? filename}';
      }
      return filename;
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  String? _buildSqlFilters(ExpenseFilters f) {
    final parts = <String>[];

    if (f.fkUserAuthor != null) {
      parts.add('(t.fk_user_author:=:${f.fkUserAuthor})');
    }

    if (f.statuses.isNotEmpty && f.statuses.length < 5) {
      final clauses = f.statuses
          .map((s) => '(t.fk_statut:=:${s.apiValue})')
          .toList();
      if (clauses.isNotEmpty) {
        parts.add('(${clauses.join(' OR ')})');
      }
    }

    if (f.dateFrom != null) {
      final ts = f.dateFrom!.millisecondsSinceEpoch ~/ 1000;
      parts.add('(t.date_debut:>=:$ts)');
    }
    if (f.dateTo != null) {
      final ts = f.dateTo!.millisecondsSinceEpoch ~/ 1000;
      parts.add('(t.date_debut:<=:$ts)');
    }

    if (f.search.trim().isNotEmpty) {
      final escaped = f.search.replaceAll("'", r"\'");
      parts.add("(t.ref:like:'%$escaped%')");
    }

    if (parts.isEmpty) return null;
    return parts.join(' AND ');
  }
}
