// ignore_for_file: one_member_abstracts

import 'package:dio/dio.dart';
import 'package:dolibarr_mobile/core/constants/api_paths.dart';
import 'package:dolibarr_mobile/core/errors/error_mapper.dart';
import 'package:dolibarr_mobile/features/products/domain/entities/product.dart';

abstract interface class ProductRemoteDataSource {
  /// Récupère la liste paginée des produits actifs en vente.
  /// La pagination interne charge toutes les pages (limite raisonnable
  /// au démarrage : `maxPages * pageSize`).
  Future<List<Product>> fetchAllForSell();
}

final class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  ProductRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  static const _pageSize = 100;
  static const _maxPages = 10; // garde-fou : 1000 produits max au démarrage.

  @override
  Future<List<Product>> fetchAllForSell() async {
    try {
      final all = <Product>[];
      var page = 0;
      while (page < _maxPages) {
        final res = await _dio.get<List<dynamic>>(
          ApiPaths.products,
          queryParameters: <String, Object?>{
            'limit': _pageSize,
            'page': page,
            'sqlfilters': '(t.tosell:=:1) AND (t.tostatut:=:1)',
          },
        );
        final data = res.data ?? const <dynamic>[];
        all.addAll(data.cast<Map<String, Object?>>().map(_fromJson));
        if (data.length < _pageSize) break;
        page++;
      }
      return all;
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  Product _fromJson(Map<String, Object?> json) {
    String? s(String key) {
      final v = json[key];
      if (v == null || v == '' || v == 'null') return null;
      return '$v';
    }

    int i(String key, {int fallback = 0}) =>
        int.tryParse('${json[key] ?? fallback}') ?? fallback;

    return Product(
      remoteId: i('id'),
      ref: s('ref') ?? '',
      label: s('label') ?? '',
      description: s('description'),
      type: ProductType.fromInt(i('type')),
      price: s('price'),
      tvaTx: s('tva_tx'),
      onSell: i('tosell', fallback: 1) == 1,
      onBuy: i('tobuy') == 1,
    );
  }
}
