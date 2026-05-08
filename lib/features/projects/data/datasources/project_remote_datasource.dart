// ignore_for_file: one_member_abstracts

import 'package:dio/dio.dart';
import 'package:dolibarr_mobile/core/constants/api_paths.dart';
import 'package:dolibarr_mobile/core/errors/error_mapper.dart';
import 'package:dolibarr_mobile/features/projects/domain/entities/project.dart';
import 'package:dolibarr_mobile/features/projects/domain/entities/project_filters.dart';

abstract interface class ProjectRemoteDataSource {
  Future<List<Map<String, Object?>>> fetchPage({
    required ProjectFilters filters,
    required int page,
    required int limit,
    int? userId,
  });

  Future<Map<String, Object?>> fetchById(int remoteId);
}

final class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  ProjectRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<Map<String, Object?>>> fetchPage({
    required ProjectFilters filters,
    required int page,
    required int limit,
    int? userId,
  }) async {
    try {
      final res = await _dio.get<List<dynamic>>(
        ApiPaths.projects,
        queryParameters: <String, Object?>{
          'limit': limit,
          'page': page,
          if (_buildSqlFilters(filters, userId: userId) != null)
            'sqlfilters': _buildSqlFilters(filters, userId: userId),
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
        ApiPaths.projectById(remoteId),
      );
      return res.data ?? const {};
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  String? _buildSqlFilters(ProjectFilters f, {int? userId}) {
    final parts = <String>[];

    if (f.thirdPartyRemoteId != null) {
      parts.add('(t.fk_soc:=:${f.thirdPartyRemoteId})');
    }

    // Statuts : on émet un IN si on est strict, sinon on omet le filtre.
    if (f.statuses.isNotEmpty &&
        f.statuses.length < ProjectStatus.values.length) {
      final values =
          f.statuses.map((s) => s.apiValue).toList()..sort();
      parts.add("(t.fk_statut:in:'${values.join(',')}')");
    }

    if (f.mineOnly && userId != null) {
      parts.add('(t.fk_user_resp:=:$userId)');
    }

    if (f.search.trim().isNotEmpty) {
      final escaped = f.search.replaceAll("'", r"\'");
      parts.add(
        "((t.ref:like:'%$escaped%') OR (t.title:like:'%$escaped%'))",
      );
    }

    if (parts.isEmpty) return null;
    return parts.join(' AND ');
  }
}
