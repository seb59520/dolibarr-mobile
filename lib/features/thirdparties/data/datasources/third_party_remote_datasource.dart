// ignore_for_file: one_member_abstracts

import 'package:dio/dio.dart';
import 'package:dolibarr_mobile/core/constants/api_paths.dart';
import 'package:dolibarr_mobile/core/errors/error_mapper.dart';
import 'package:dolibarr_mobile/core/errors/exceptions.dart';
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

  /// Crée un tiers via `POST /thirdparties` et retourne le `rowid` créé.
  Future<int> create(Map<String, Object?> payload);

  /// Met à jour un tiers existant via `PUT /thirdparties/:id`.
  Future<Map<String, Object?>> update(
    int remoteId,
    Map<String, Object?> payload,
  );

  /// Supprime un tiers via `DELETE /thirdparties/:id`.
  Future<void> delete(int remoteId);
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

  @override
  Future<int> create(Map<String, Object?> payload) async {
    try {
      // Dolibarr renvoie soit l'`id` créé en int, soit un Map { id: N }.
      final res = await _dio.post<Object?>(
        ApiPaths.thirdparties,
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
        ApiPaths.thirdpartyById(remoteId),
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
      await _dio.delete<void>(ApiPaths.thirdpartyById(remoteId));
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

    // "Mes tiers uniquement" : volontairement no-op côté sqlfilters.
    // Dolibarr stocke le commercial-suiveur dans la table de relation
    // `llx_societe_commerciaux`, et `sqlfilters` n'accepte ni JOIN ni
    // sous-requête (`(t.rowid:in:(SELECT …))` → 400 Bad syntax).
    // Implémenter ce filtre nécessite un sync dédié des representatives
    // par tier (endpoint `/thirdparties/{id}/representatives`) — out of
    // scope ici. Le toggle UI est grisé en attendant.
    // userId conservé dans la signature pour la future implémentation.
    if (f.myOnly && userId != null) {
      // intentionnellement vide — voir commentaire ci-dessus
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
