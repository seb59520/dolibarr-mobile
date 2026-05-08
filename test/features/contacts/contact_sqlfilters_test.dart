import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dolibarr_mobile/features/contacts/data/datasources/contact_remote_datasource.dart';
import 'package:dolibarr_mobile/features/contacts/domain/entities/contact_filters.dart';
import 'package:flutter_test/flutter_test.dart';

class _CapturingAdapter implements HttpClientAdapter {
  String? lastSqlFilters;
  Map<String, List<String>>? lastQuery;
  String? lastPath;
  String responseBody = '[]';

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastQuery = options.uri.queryParametersAll;
    lastSqlFilters = options.queryParameters['sqlfilters'] as String?;
    lastPath = options.uri.path;
    return ResponseBody.fromString(
      responseBody,
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
  late Dio dio;
  late _CapturingAdapter adapter;
  late ContactRemoteDataSourceImpl remote;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://erp.example/api/index.php'));
    adapter = _CapturingAdapter();
    dio.httpClientAdapter = adapter;
    remote = ContactRemoteDataSourceImpl(dio);
  });

  group('contact sqlfilters builder', () {
    test('aucun filtre actif → pas de paramètre sqlfilters', () async {
      await remote.fetchPage(
        filters: const ContactFilters(),
        page: 0,
        limit: 50,
      );
      expect(adapter.lastSqlFilters, isNull);
      expect(adapter.lastQuery!['limit'], ['50']);
      expect(adapter.lastQuery!['page'], ['0']);
    });

    test('thirdPartyRemoteId → filtre fk_soc', () async {
      await remote.fetchPage(
        filters: const ContactFilters(thirdPartyRemoteId: 42),
        page: 0,
        limit: 100,
      );
      expect(adapter.lastSqlFilters, contains('(t.fk_soc:=:42)'));
    });

    test('hasEmail seul → contraintes non-null/non-vide', () async {
      await remote.fetchPage(
        filters: const ContactFilters(hasEmail: true),
        page: 0,
        limit: 100,
      );
      expect(adapter.lastSqlFilters, contains("(t.email:!=:'')"));
      expect(adapter.lastSqlFilters, contains('(t.email:is not:NULL)'));
    });

    test('hasPhone seul → OR sur phone + phone_mobile', () async {
      await remote.fetchPage(
        filters: const ContactFilters(hasPhone: true),
        page: 0,
        limit: 100,
      );
      expect(adapter.lastSqlFilters, contains('t.phone:!=:'));
      expect(adapter.lastSqlFilters, contains('t.phone_mobile:!=:'));
    });

    test('search escape les apostrophes', () async {
      await remote.fetchPage(
        filters: const ContactFilters(search: "O'Connor"),
        page: 0,
        limit: 100,
      );
      expect(adapter.lastSqlFilters, contains(r"O\'Connor"));
      expect(adapter.lastSqlFilters, contains('t.lastname:like:'));
      expect(adapter.lastSqlFilters, contains('t.firstname:like:'));
      expect(adapter.lastSqlFilters, contains('t.email:like:'));
    });

    test('combinaison hasEmail + thirdParty + search', () async {
      await remote.fetchPage(
        filters: const ContactFilters(
          hasEmail: true,
          thirdPartyRemoteId: 7,
          search: 'paul',
        ),
        page: 0,
        limit: 100,
      );
      // 3 segments AND-joinés.
      final f = adapter.lastSqlFilters!;
      expect(f, contains('AND'));
      expect(f, contains('t.fk_soc:=:7'));
      expect(f, contains("t.email:!=:''"));
      expect(f, contains("'%paul%'"));
    });
  });

  group('endpoints', () {
    test('fetchByThirdParty appelle /thirdparties/:id/contacts', () async {
      await remote.fetchByThirdParty(13);
      expect(adapter.lastPath, contains('/thirdparties/13/contacts'));
    });

    test('fetchById appelle /contacts/:id', () async {
      adapter.responseBody = '{}';
      await remote.fetchById(99);
      expect(adapter.lastPath, contains('/contacts/99'));
    });
  });
}
