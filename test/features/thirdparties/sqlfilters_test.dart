import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dolibarr_mobile/features/thirdparties/data/datasources/third_party_remote_datasource.dart';
import 'package:dolibarr_mobile/features/thirdparties/domain/entities/third_party_filters.dart';
import 'package:flutter_test/flutter_test.dart';

class _CapturingAdapter implements HttpClientAdapter {
  String? lastSqlFilters;
  Map<String, List<String>>? lastQuery;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastQuery = options.uri.queryParametersAll;
    lastSqlFilters = options.queryParameters['sqlfilters'] as String?;
    return ResponseBody.fromString(
      '[]',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

ThirdPartyRemoteDataSource _ds(_CapturingAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'))
    ..httpClientAdapter = adapter;
  return ThirdPartyRemoteDataSourceImpl(dio);
}

void main() {
  group('sqlfilters builder', () {
    test('aucun filtre actif → pas de paramètre sqlfilters', () async {
      final adapter = _CapturingAdapter();
      await _ds(adapter).fetchPage(
        filters: const ThirdPartyFilters(activeOnly: false),
        page: 0,
        limit: 100,
      );
      expect(adapter.lastSqlFilters, isNull);
    });

    test(
      'myOnly est volontairement no-op côté API '
      "(la colonne `t.fk_commercial` n'existe pas dans `llx_societe`, "
      'cf commentaire dans third_party_remote_datasource.dart)',
      () async {
        final adapter = _CapturingAdapter();
        await _ds(adapter).fetchPage(
          filters: const ThirdPartyFilters(myOnly: true),
          page: 0,
          limit: 100,
          userId: 7,
        );
        final f = adapter.lastSqlFilters!;
        expect(f, contains('(t.status:=:1)'));
        expect(f, isNot(contains('fk_commercial')));
      },
    );

    test('kind=customer seul → client in 1,3', () async {
      final adapter = _CapturingAdapter();
      await _ds(adapter).fetchPage(
        filters: const ThirdPartyFilters(
          kinds: {ThirdPartyKind.customer},
          activeOnly: false,
        ),
        page: 0,
        limit: 100,
      );
      expect(adapter.lastSqlFilters, contains("(t.client:in:'1,3')"));
    });

    test('kind=supplier seul → fournisseur=1', () async {
      final adapter = _CapturingAdapter();
      await _ds(adapter).fetchPage(
        filters: const ThirdPartyFilters(
          kinds: {ThirdPartyKind.supplier},
          activeOnly: false,
        ),
        page: 0,
        limit: 100,
      );
      expect(adapter.lastSqlFilters, contains('(t.fournisseur:=:1)'));
    });

    test('search escape les apostrophes', () async {
      final adapter = _CapturingAdapter();
      await _ds(adapter).fetchPage(
        filters: const ThirdPartyFilters(
          search: "L'Oréal",
          activeOnly: false,
        ),
        page: 0,
        limit: 100,
      );
      final f = adapter.lastSqlFilters!;
      expect(f, contains(r"L\'Oréal"));
      expect(f, contains('OR (t.code_client:like'));
    });

    test('limit + page transmis comme query params', () async {
      final adapter = _CapturingAdapter();
      await _ds(adapter).fetchPage(
        filters: const ThirdPartyFilters(activeOnly: false),
        page: 3,
        limit: 50,
      );
      expect(adapter.lastQuery!['limit'], ['50']);
      expect(adapter.lastQuery!['page'], ['3']);
    });
  });
}
