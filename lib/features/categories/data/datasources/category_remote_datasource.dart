// ignore_for_file: one_member_abstracts

import 'package:dio/dio.dart';
import 'package:dolibarr_mobile/core/constants/api_paths.dart';
import 'package:dolibarr_mobile/core/errors/error_mapper.dart';
import 'package:dolibarr_mobile/features/categories/domain/entities/category.dart';

abstract interface class CategoryRemoteDataSource {
  /// Récupère la liste paginée des catégories d'un type donné.
  /// La pagination interne charge toutes les pages (catégories peu nombreuses).
  Future<List<Category>> fetchByType(CategoryType type);
}

final class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  CategoryRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  static const _pageSize = 100;

  @override
  Future<List<Category>> fetchByType(CategoryType type) async {
    try {
      final all = <Category>[];
      var page = 0;
      while (true) {
        final res = await _dio.get<List<dynamic>>(
          ApiPaths.categories,
          queryParameters: <String, Object?>{
            'type': type.apiValue,
            'limit': _pageSize,
            'page': page,
          },
        );
        final data = res.data ?? const <dynamic>[];
        all.addAll(data.cast<Map<String, Object?>>().map(
              (json) => _fromJson(json, type),
            ));
        if (data.length < _pageSize) break;
        page++;
      }
      return all;
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  Category _fromJson(Map<String, Object?> json, CategoryType requestedType) {
    final rawType = json['type'];
    final type = rawType is String
        ? CategoryType.fromApi(rawType)
        : requestedType;
    return Category(
      remoteId: int.parse('${json['id'] ?? 0}'),
      label: '${json['label'] ?? ''}',
      type: type,
      parentRemoteId: int.tryParse('${json['fk_parent'] ?? ''}'),
      color: json['color'] is String ? json['color']! as String : null,
    );
  }
}
