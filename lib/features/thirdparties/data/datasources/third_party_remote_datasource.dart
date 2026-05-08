// ignore_for_file: one_member_abstracts

import 'package:dio/dio.dart';
import 'package:dolibarr_mobile/core/constants/api_paths.dart';
import 'package:dolibarr_mobile/core/errors/error_mapper.dart';
import 'package:dolibarr_mobile/features/thirdparties/domain/entities/third_party_filters.dart';

abstract interface class ThirdPartyRemoteDataSource {
  /// Récupère une page brute (Map JSON) de tiers correspondant aux filtres.
  /// Le mapping vers l'entité est fait côté repository pour permettre
  /// la persistance Drift en parallèle.
  Future<List<Map<String, Object?>>> fetchPage({
    required ThirdPartyFilters filters,
    required int page,
    required int limit,
    int? userId,
  });

  /// Récupère un tiers par son `rowid` Dolibarr.
  Future<Map<String, Object?>> fetchById(int remoteId);
}

final class ThirdPartyRemoteDataSourceImpl
    implements ThirdPartyRemoteDataSource {
  ThirdPartyRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<Map<String, Object?>>> fetchPage({
    required ThirdPartyFilters filters,
    required int page,
    required int limit,
    int? userId,
  }) async {
    try {
      final res = await _dio.get<List<dynamic>>(
        ApiPaths.thirdparties,
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
        ApiPaths.thirdpartyById(remoteId),
      );
      return res.data ?? const {};
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  /// Construit la chaîne `sqlfilters` Dolibarr depuis les filtres UI.
  ///
  /// Format attendu : `(t.col1:operator:'value') AND (t.col2:...)`.
  /// Le wrapping AND est implicite via `AND` entre paires.
  String? _buildSqlFilters(ThirdPartyFilters f, {int? userId}) {
    final parts = <String>[];

    if (f.activeOnly) {
      parts.add('(t.status:=:1)');
    }

    // client/fournisseur — Dolibarr n'a pas un OR sur sqlfilters fiable
    // pour un bitfield, donc on émet la combinaison la plus simple.
    if (f.kinds.isNotEmpty) {
      final wantsCustomer = f.kinds.contains(ThirdPartyKind.customer);
      final wantsProspect = f.kinds.contains(ThirdPartyKind.prospect);
      final wantsSupplier = f.kinds.contains(ThirdPartyKind.supplier);

      if (wantsSupplier && !wantsCustomer && !wantsProspect) {
        parts.add('(t.fournisseur:=:1)');
      } else if (wantsCustomer && !wantsProspect && !wantsSupplier) {
        parts.add("(t.client:in:'1,3')");
      } else if (wantsProspect && !wantsCustomer && !wantsSupplier) {
        parts.add("(t.client:in:'2,3')");
      }
      // Sinon on laisse passer — filtrage local complet en UI.
    }

    if (f.myOnly && userId != null) {
      parts.add('(t.fk_commercial:=:$userId)');
    }

    if (f.search.trim().isNotEmpty) {
      final escaped = f.search.replaceAll("'", r"\'");
      parts.add(
        "(t.nom:like:'%$escaped%') "
        "OR (t.code_client:like:'%$escaped%') "
        "OR (t.town:like:'%$escaped%')",
      );
    }

    if (parts.isEmpty) return null;
    return parts.join(' AND ');
  }
}
