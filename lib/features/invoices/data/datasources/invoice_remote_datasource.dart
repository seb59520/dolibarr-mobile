// ignore_for_file: one_member_abstracts

import 'package:dio/dio.dart';
import 'package:dolibarr_mobile/core/constants/api_paths.dart';
import 'package:dolibarr_mobile/core/errors/error_mapper.dart';
import 'package:dolibarr_mobile/core/errors/exceptions.dart';
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

  Future<int> create(Map<String, Object?> payload);

  Future<Map<String, Object?>> update(
    int remoteId,
    Map<String, Object?> payload,
  );

  Future<void> delete(int remoteId);

  Future<int> createLine(int invoiceRemoteId, Map<String, Object?> payload);

  Future<Map<String, Object?>> updateLine(
    int invoiceRemoteId,
    int lineRemoteId,
    Map<String, Object?> payload,
  );

  Future<void> deleteLine(int invoiceRemoteId, int lineRemoteId);

  Future<Map<String, Object?>> validate(int remoteId);

  Future<Map<String, Object?>> markAsPaid(int remoteId);

  Future<List<Map<String, Object?>>> fetchPayments(int remoteId);

  Future<int> createPayment(int remoteId, Map<String, Object?> payload);

  /// Télécharge le PDF de la facture en base64.
  Future<({String content, String filename})> downloadPdf(int remoteId);
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

  @override
  Future<int> create(Map<String, Object?> payload) async {
    try {
      final res = await _dio.post<Object?>(
        ApiPaths.invoices,
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
        message: 'Réponse de création facture inattendue',
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
        ApiPaths.invoiceById(remoteId),
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
      await _dio.delete<void>(ApiPaths.invoiceById(remoteId));
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  @override
  Future<int> createLine(
    int invoiceRemoteId,
    Map<String, Object?> payload,
  ) async {
    try {
      final res = await _dio.post<Object?>(
        ApiPaths.invoiceLines(invoiceRemoteId),
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
        message: 'Réponse de création ligne facture inattendue',
      );
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  @override
  Future<Map<String, Object?>> updateLine(
    int invoiceRemoteId,
    int lineRemoteId,
    Map<String, Object?> payload,
  ) async {
    try {
      final res = await _dio.put<Map<String, Object?>>(
        ApiPaths.invoiceLineById(invoiceRemoteId, lineRemoteId),
        data: payload,
      );
      return res.data ?? const {};
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  @override
  Future<void> deleteLine(
    int invoiceRemoteId,
    int lineRemoteId,
  ) async {
    try {
      await _dio.delete<void>(
        ApiPaths.invoiceLineById(invoiceRemoteId, lineRemoteId),
      );
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  @override
  Future<Map<String, Object?>> validate(int remoteId) async {
    try {
      final res = await _dio.post<Object?>(
        ApiPaths.invoiceValidate(remoteId),
        // Dolibarr accepte un body vide ou {idwarehouse:0}.
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
  Future<Map<String, Object?>> markAsPaid(int remoteId) async {
    try {
      final res = await _dio.post<Object?>(
        ApiPaths.invoiceMarkPaid(remoteId),
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
  Future<List<Map<String, Object?>>> fetchPayments(int remoteId) async {
    try {
      final res = await _dio.get<List<dynamic>>(
        ApiPaths.invoicePayments(remoteId),
      );
      return (res.data ?? const <dynamic>[])
          .cast<Map<String, Object?>>()
          .toList();
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  @override
  Future<int> createPayment(
    int remoteId,
    Map<String, Object?> payload,
  ) async {
    try {
      final res = await _dio.post<Object?>(
        ApiPaths.invoicePayments(remoteId),
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
        message: 'Réponse de création paiement inattendue',
      );
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  @override
  Future<({String content, String filename})> downloadPdf(
    int remoteId,
  ) async {
    try {
      // Dolibarr nomme le PDF d'après la ref de la facture, qu'on
      // récupère via fetchById si on n'a pas la ref localement.
      // Pour simplifier, on demande le doc avec original_file=ref/ref.pdf.
      // Le format réel est : facture/<REF>/<REF>.pdf
      final fresh = await fetchById(remoteId);
      final ref = '${fresh['ref'] ?? ''}';
      if (ref.isEmpty) {
        throw const ValidationException(
          message: 'Facture sans référence — PDF indisponible avant '
              'validation.',
        );
      }
      final res = await _dio.get<Map<String, Object?>>(
        ApiPaths.documentDownload,
        queryParameters: <String, Object?>{
          'modulepart': 'facture',
          'original_file': '$ref/$ref.pdf',
        },
      );
      final body = res.data ?? const {};
      final content = '${body['content'] ?? ''}';
      final filename = '${body['filename'] ?? '$ref.pdf'}';
      if (content.isEmpty) {
        throw const ServerException(
          statusCode: 200,
          message: 'Réponse PDF vide',
        );
      }
      return (content: content, filename: filename);
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
