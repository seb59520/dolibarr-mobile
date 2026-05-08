import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dolibarr_mobile/features/categories/data/datasources/category_remote_datasource.dart';
import 'package:dolibarr_mobile/features/categories/domain/entities/category.dart';
import 'package:flutter_test/flutter_test.dart';

class _StaticAdapter implements HttpClientAdapter {
  _StaticAdapter(this.body);
  final String body;
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
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

void main() {
  group('CategoryRemoteDataSource.fetchByType', () {
    test('parse une page de catégories customer', () async {
      const body = '''
[
  {"id": "10", "label": "Stratégique", "type": "customer", "fk_parent": "0", "color": "#FF0000"},
  {"id": "11", "label": "Volumique",   "type": "customer", "fk_parent": "10"}
]
''';
      final adapter = _StaticAdapter(body);
      final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'))
        ..httpClientAdapter = adapter;
      final ds = CategoryRemoteDataSourceImpl(dio);

      final cats = await ds.fetchByType(CategoryType.customer);

      // Body fait 2 < pageSize 100 → 1 seul appel.
      expect(adapter.calls, 1);
      expect(cats, hasLength(2));
      expect(cats.first.label, 'Stratégique');
      expect(cats.first.parentRemoteId, 0);
      expect(cats.first.color, '#FF0000');
      expect(cats.last.parentRemoteId, 10);
    });

    test('liste vide → retourne []', () async {
      final adapter = _StaticAdapter('[]');
      final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'))
        ..httpClientAdapter = adapter;
      final ds = CategoryRemoteDataSourceImpl(dio);

      expect(await ds.fetchByType(CategoryType.supplier), isEmpty);
    });
  });
}
