import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dolibarr_mobile/features/extrafields/data/datasources/extrafield_remote_datasource.dart';
import 'package:dolibarr_mobile/features/extrafields/domain/entities/extrafield_definition.dart';
import 'package:flutter_test/flutter_test.dart';

class _StaticAdapter implements HttpClientAdapter {
  _StaticAdapter(this.body);
  final String body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      body,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio _dio(String body) => Dio(
      BaseOptions(baseUrl: 'https://example.invalid'),
    )..httpClientAdapter = _StaticAdapter(body);

void main() {
  group('ExtrafieldRemoteDataSource.fetchAll', () {
    test('aplatit la réponse Dolibarr nested par entité', () async {
      const body = '''
{
  "label": {
    "thirdparty": {"siret_secondaire": "SIRET secondaire", "vip": "VIP ?"},
    "socpeople": {"langue": "Langue préférée"}
  },
  "type": {
    "thirdparty": {"siret_secondaire": "varchar", "vip": "boolean"},
    "socpeople": {"langue": "select"}
  },
  "required": {
    "thirdparty": {"siret_secondaire": "0", "vip": "1"},
    "socpeople": {"langue": "0"}
  },
  "options": {
    "thirdparty": {"siret_secondaire": null, "vip": null},
    "socpeople": {"langue": {"fr": "Français", "en": "Anglais"}}
  },
  "position": {
    "thirdparty": {"siret_secondaire": "10", "vip": "20"},
    "socpeople": {"langue": "5"}
  }
}
''';
      final ds = ExtrafieldRemoteDataSourceImpl(_dio(body));
      final result = await ds.fetchAll();

      expect(result, hasLength(3));
      expect(
        result.where((d) => d.entityType == 'thirdparty'),
        hasLength(2),
      );
      final vip =
          result.firstWhere((d) => d.fieldName == 'vip');
      expect(vip.type, ExtrafieldType.boolean);
      expect(vip.required, isTrue);

      final langue =
          result.firstWhere((d) => d.fieldName == 'langue');
      expect(langue.type, ExtrafieldType.select);
      expect(langue.options, {'fr': 'Français', 'en': 'Anglais'});
      expect(langue.entityType, 'socpeople');
    });

    test('retourne liste vide si la réponse est vide', () async {
      final ds = ExtrafieldRemoteDataSourceImpl(_dio('{}'));
      expect(await ds.fetchAll(), isEmpty);
    });

    test('trie par position croissante', () async {
      const body = '''
{
  "label": {"thirdparty": {"a": "A", "b": "B", "c": "C"}},
  "type": {"thirdparty": {"a": "varchar", "b": "varchar", "c": "varchar"}},
  "position": {"thirdparty": {"a": "30", "b": "10", "c": "20"}}
}
''';
      final ds = ExtrafieldRemoteDataSourceImpl(_dio(body));
      final result = await ds.fetchAll();
      expect(result.map((d) => d.fieldName).toList(), ['b', 'c', 'a']);
    });
  });

  group('ExtrafieldType.fromApi', () {
    test('mappe les variantes connues', () {
      expect(ExtrafieldType.fromApi('varchar'), ExtrafieldType.varchar);
      expect(ExtrafieldType.fromApi('int'), ExtrafieldType.integer);
      expect(ExtrafieldType.fromApi('integer'), ExtrafieldType.integer);
      expect(ExtrafieldType.fromApi('boolean'), ExtrafieldType.boolean);
      expect(ExtrafieldType.fromApi('checkbox'), ExtrafieldType.boolean);
      expect(ExtrafieldType.fromApi('sellist'), ExtrafieldType.select);
      expect(ExtrafieldType.fromApi('?'), ExtrafieldType.unknown);
    });
  });
}
