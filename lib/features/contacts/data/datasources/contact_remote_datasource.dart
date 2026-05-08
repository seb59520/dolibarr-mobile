// ignore_for_file: one_member_abstracts

import 'package:dio/dio.dart';
import 'package:dolibarr_mobile/core/constants/api_paths.dart';
import 'package:dolibarr_mobile/core/errors/error_mapper.dart';
import 'package:dolibarr_mobile/core/errors/exceptions.dart';
import 'package:dolibarr_mobile/features/contacts/domain/entities/contact_filters.dart';

abstract interface class ContactRemoteDataSource {
  /// Récupère une page brute filtrée.
  Future<List<Map<String, Object?>>> fetchPage({
    required ContactFilters filters,
    required int page,
    required int limit,
  });

  /// Récupère un contact par `rowid` Dolibarr.
  Future<Map<String, Object?>> fetchById(int remoteId);

  /// Récupère tous les contacts d'un tiers donné (endpoint dédié — pas
  /// de pagination Dolibarr explicite).
  Future<List<Map<String, Object?>>> fetchByThirdParty(int thirdPartyRemoteId);

  /// Crée un contact via `POST /contacts` et retourne le `rowid` créé.
  Future<int> create(Map<String, Object?> payload);

  /// Met à jour un contact via `PUT /contacts/:id`.
  Future<Map<String, Object?>> update(
    int remoteId,
    Map<String, Object?> payload,
  );

  /// Supprime un contact via `DELETE /contacts/:id`.
  Future<void> delete(int remoteId);
}

final class ContactRemoteDataSourceImpl implements ContactRemoteDataSource {
  ContactRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<Map<String, Object?>>> fetchPage({
    required ContactFilters filters,
    required int page,
    required int limit,
  }) async {
    try {
      final res = await _dio.get<List<dynamic>>(
        ApiPaths.contacts,
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
        ApiPaths.contactById(remoteId),
      );
      return res.data ?? const {};
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  @override
  Future<List<Map<String, Object?>>> fetchByThirdParty(
    int thirdPartyRemoteId,
  ) async {
    try {
      final res = await _dio.get<List<dynamic>>(
        ApiPaths.thirdpartyContacts(thirdPartyRemoteId),
      );
      return (res.data ?? const <dynamic>[])
          .cast<Map<String, Object?>>()
          .toList();
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  @override
  Future<int> create(Map<String, Object?> payload) async {
    try {
      final res = await _dio.post<Object?>(
        ApiPaths.contacts,
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
        message: 'Réponse de création inattendue',
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
        ApiPaths.contactById(remoteId),
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
      await _dio.delete<void>(ApiPaths.contactById(remoteId));
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  /// Construit la chaîne `sqlfilters` Dolibarr pour les contacts.
  /// Format attendu : `(t.col1:operator:'value') AND (t.col2:...)`.
  String? _buildSqlFilters(ContactFilters f) {
    final parts = <String>[];

    if (f.thirdPartyRemoteId != null) {
      parts.add('(t.fk_soc:=:${f.thirdPartyRemoteId})');
    }

    if (f.hasEmail) {
      parts.add("(t.email:!=:'') AND (t.email:is not:NULL)");
    }

    if (f.hasPhone) {
      parts.add(
        "((t.phone:!=:'') OR (t.phone_mobile:!=:''))",
      );
    }

    if (f.search.trim().isNotEmpty) {
      final escaped = f.search.replaceAll("'", r"\'");
      parts.add(
        "((t.lastname:like:'%$escaped%') "
        "OR (t.firstname:like:'%$escaped%') "
        "OR (t.email:like:'%$escaped%') "
        "OR (t.town:like:'%$escaped%'))",
      );
    }

    if (parts.isEmpty) return null;
    return parts.join(' AND ');
  }
}
