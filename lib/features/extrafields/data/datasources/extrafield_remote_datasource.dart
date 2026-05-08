// ignore_for_file: one_member_abstracts

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dolibarr_mobile/core/constants/api_paths.dart';
import 'package:dolibarr_mobile/core/errors/error_mapper.dart';
import 'package:dolibarr_mobile/features/extrafields/domain/entities/extrafield_definition.dart';

abstract interface class ExtrafieldRemoteDataSource {
  /// Récupère et aplatit l'arborescence retournée par
  /// `GET /setup/extrafields`. Le format Dolibarr est :
  ///
  /// ```json
  /// {
  ///   "label":    {"thirdparty": {"field1": "Mon label"}},
  ///   "type":     {"thirdparty": {"field1": "varchar"}},
  ///   "required": {"thirdparty": {"field1": "1"}},
  ///   "options":  {"thirdparty": {"field1": {"k":"v"}}},
  ///   "position": {"thirdparty": {"field1": "10"}}
  /// }
  /// ```
  Future<List<ExtrafieldDefinition>> fetchAll();
}

final class ExtrafieldRemoteDataSourceImpl
    implements ExtrafieldRemoteDataSource {
  ExtrafieldRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<ExtrafieldDefinition>> fetchAll() async {
    try {
      final res = await _dio.get<Map<String, Object?>>(
        ApiPaths.setupExtrafields,
      );
      final data = res.data ?? const <String, Object?>{};
      return _flatten(data);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  List<ExtrafieldDefinition> _flatten(Map<String, Object?> data) {
    final labels = _asNestedMap(data['label']);
    final types = _asNestedMap(data['type']);
    final required = _asNestedMap(data['required']);
    final options = _asNestedMap(data['options']);
    final positions = _asNestedMap(data['position']);

    final out = <ExtrafieldDefinition>[];
    for (final entityType in labels.keys) {
      final fieldsForEntity = labels[entityType] ?? const {};
      for (final entry in fieldsForEntity.entries) {
        final fieldName = entry.key;
        final label = '${entry.value}';
        final rawType = '${types[entityType]?[fieldName] ?? 'varchar'}';
        final rawRequired = '${required[entityType]?[fieldName] ?? 0}';
        final rawPosition = '${positions[entityType]?[fieldName] ?? 0}';
        final rawOptions = options[entityType]?[fieldName];

        out.add(
          ExtrafieldDefinition(
            entityType: entityType,
            fieldName: fieldName,
            label: label,
            type: ExtrafieldType.fromApi(rawType),
            required: rawRequired == '1' || rawRequired == 'true',
            options: ExtrafieldDefinition.decodeOptions(rawOptions),
            position: int.tryParse(rawPosition) ?? 0,
          ),
        );
      }
    }
    out.sort((a, b) => a.position.compareTo(b.position));
    return out;
  }

  /// Helper : `data['label']` peut être un Map<String,Map> mais l'API
  /// renvoie parfois une liste vide quand pas d'extrafields. On normalise.
  Map<String, Map<String, Object?>> _asNestedMap(Object? raw) {
    if (raw is Map) {
      return raw.map(
        (k, v) => MapEntry(
          '$k',
          v is Map
              ? v.map((k2, v2) => MapEntry('$k2', v2 as Object?))
              : <String, Object?>{},
        ),
      );
    }
    if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) return _asNestedMap(decoded);
      } catch (_) {
        // ignoré
      }
    }
    return const {};
  }
}
