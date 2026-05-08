// ignore_for_file: one_member_abstracts

import 'package:dio/dio.dart';
import 'package:dolibarr_mobile/core/constants/api_paths.dart';
import 'package:dolibarr_mobile/core/errors/error_mapper.dart';
import 'package:dolibarr_mobile/core/errors/exceptions.dart';
import 'package:dolibarr_mobile/features/proposals/domain/entities/proposal.dart';
import 'package:dolibarr_mobile/features/proposals/domain/entities/proposal_filters.dart';

abstract interface class ProposalRemoteDataSource {
  Future<List<Map<String, Object?>>> fetchPage({
    required ProposalFilters filters,
    required int page,
    required int limit,
  });

  Future<Map<String, Object?>> fetchById(int remoteId);

  Future<int> create(Map<String, Object?> payload);

  Future<Map<String, Object?>> update(
    int remoteId,
    Map<String, Object?> payload,
  );

  Future<void> delete(int remoteId);

  Future<int> createLine(int proposalRemoteId, Map<String, Object?> payload);

  Future<Map<String, Object?>> updateLine(
    int proposalRemoteId,
    int lineRemoteId,
    Map<String, Object?> payload,
  );

  Future<void> deleteLine(int proposalRemoteId, int lineRemoteId);

  /// Passe le devis de brouillon (0) à validé (1).
  Future<Map<String, Object?>> validate(int remoteId);

  /// Clôture le devis avec un statut final.
  /// `status` Dolibarr : 2 (signé) ou 3 (refusé/abandonné).
  Future<Map<String, Object?>> close(
    int remoteId,
    int status, {
    String? note,
  });

  /// Marque le devis comme facturé. Appelé après création de la
  /// facture liée.
  Future<Map<String, Object?>> setInvoiced(int remoteId);

  /// Télécharge le PDF du devis en base64.
  Future<({String content, String filename})> downloadPdf(int remoteId);
}

final class ProposalRemoteDataSourceImpl implements ProposalRemoteDataSource {
  ProposalRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<Map<String, Object?>>> fetchPage({
    required ProposalFilters filters,
    required int page,
    required int limit,
  }) async {
    try {
      final res = await _dio.get<List<dynamic>>(
        ApiPaths.proposals,
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
        ApiPaths.proposalById(remoteId),
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
        ApiPaths.proposals,
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
        message: 'Réponse de création devis inattendue',
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
        ApiPaths.proposalById(remoteId),
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
      await _dio.delete<void>(ApiPaths.proposalById(remoteId));
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  @override
  Future<int> createLine(
    int proposalRemoteId,
    Map<String, Object?> payload,
  ) async {
    try {
      final res = await _dio.post<Object?>(
        ApiPaths.proposalLines(proposalRemoteId),
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
        message: 'Réponse de création ligne devis inattendue',
      );
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  @override
  Future<Map<String, Object?>> updateLine(
    int proposalRemoteId,
    int lineRemoteId,
    Map<String, Object?> payload,
  ) async {
    try {
      final res = await _dio.put<Map<String, Object?>>(
        ApiPaths.proposalLineById(proposalRemoteId, lineRemoteId),
        data: payload,
      );
      return res.data ?? const {};
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  @override
  Future<void> deleteLine(
    int proposalRemoteId,
    int lineRemoteId,
  ) async {
    try {
      await _dio.delete<void>(
        ApiPaths.proposalLineById(proposalRemoteId, lineRemoteId),
      );
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  @override
  Future<Map<String, Object?>> validate(int remoteId) async {
    try {
      final res = await _dio.post<Object?>(
        ApiPaths.proposalValidate(remoteId),
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
  Future<Map<String, Object?>> close(
    int remoteId,
    int status, {
    String? note,
  }) async {
    try {
      final res = await _dio.post<Object?>(
        ApiPaths.proposalClose(remoteId),
        data: <String, Object?>{
          'status': status,
          if (note != null) 'note_private': note,
        },
      );
      final body = res.data;
      if (body is Map<String, Object?>) return body;
      return const {};
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  @override
  Future<Map<String, Object?>> setInvoiced(int remoteId) async {
    try {
      final res = await _dio.post<Object?>(
        ApiPaths.proposalSetInvoiced(remoteId),
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
  Future<({String content, String filename})> downloadPdf(
    int remoteId,
  ) async {
    try {
      final fresh = await fetchById(remoteId);
      final ref = '${fresh['ref'] ?? ''}';
      if (ref.isEmpty) {
        throw const ValidationException(
          message: 'Devis sans référence — PDF indisponible avant '
              'validation.',
        );
      }
      final res = await _dio.get<Map<String, Object?>>(
        ApiPaths.documentDownload,
        queryParameters: <String, Object?>{
          'modulepart': 'propal',
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

  String? _buildSqlFilters(ProposalFilters f) {
    final parts = <String>[];

    if (f.thirdPartyRemoteId != null) {
      parts.add('(t.fk_soc:=:${f.thirdPartyRemoteId})');
    }

    if (f.statuses.isNotEmpty &&
        f.statuses.length < ProposalStatus.values.length) {
      final values = f.statuses.map((s) => s.apiValue).toList()..sort();
      parts.add("(t.fk_statut:in:'${values.join(',')}')");
    }

    if (f.dateFrom != null) {
      final ts = f.dateFrom!.millisecondsSinceEpoch ~/ 1000;
      parts.add('(t.datep:>=:$ts)');
    }
    if (f.dateTo != null) {
      final ts = f.dateTo!.millisecondsSinceEpoch ~/ 1000;
      parts.add('(t.datep:<=:$ts)');
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
