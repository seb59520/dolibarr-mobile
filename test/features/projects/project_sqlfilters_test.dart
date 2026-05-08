import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dolibarr_mobile/features/projects/data/datasources/project_remote_datasource.dart';
import 'package:dolibarr_mobile/features/projects/domain/entities/project.dart';
import 'package:dolibarr_mobile/features/projects/domain/entities/project_filters.dart';
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
  late ProjectRemoteDataSourceImpl remote;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://erp.example/api/index.php'));
    adapter = _CapturingAdapter();
    dio.httpClientAdapter = adapter;
    remote = ProjectRemoteDataSourceImpl(dio);
  });

  group('project sqlfilters builder', () {
    test('défaut (draft + opened) → IN sur fk_statut', () async {
      await remote.fetchPage(
        filters: const ProjectFilters(),
        page: 0,
        limit: 50,
      );
      expect(adapter.lastSqlFilters, contains("(t.fk_statut:in:'0,1')"));
      expect(adapter.lastQuery!['limit'], ['50']);
      expect(adapter.lastQuery!['page'], ['0']);
    });

    test('tous les statuts → pas de filtre statut', () async {
      await remote.fetchPage(
        filters: ProjectFilters(statuses: ProjectStatus.values.toSet()),
        page: 0,
        limit: 100,
      );
      expect(adapter.lastSqlFilters, isNull);
    });

    test('thirdPartyRemoteId → fk_soc', () async {
      await remote.fetchPage(
        filters: const ProjectFilters(thirdPartyRemoteId: 42),
        page: 0,
        limit: 100,
      );
      expect(adapter.lastSqlFilters, contains('(t.fk_soc:=:42)'));
    });

    test('mineOnly + userId → fk_user_resp', () async {
      await remote.fetchPage(
        filters: const ProjectFilters(mineOnly: true),
        page: 0,
        limit: 100,
        userId: 7,
      );
      expect(adapter.lastSqlFilters, contains('(t.fk_user_resp:=:7)'));
    });

    test('mineOnly sans userId → ignoré', () async {
      await remote.fetchPage(
        filters: const ProjectFilters(mineOnly: true),
        page: 0,
        limit: 100,
      );
      expect(adapter.lastSqlFilters, isNot(contains('fk_user_resp')));
    });

    test('search → like ref/title + escape apostrophes', () async {
      await remote.fetchPage(
        filters: const ProjectFilters(search: "O'Hara"),
        page: 0,
        limit: 100,
      );
      expect(adapter.lastSqlFilters, contains('t.ref:like:'));
      expect(adapter.lastSqlFilters, contains('t.title:like:'));
      expect(adapter.lastSqlFilters, contains(r"O\'Hara"));
    });
  });

  group('endpoints', () {
    test('fetchById → /projects/:id', () async {
      adapter.responseBody = '{}';
      await remote.fetchById(99);
      expect(adapter.lastPath, contains('/projects/99'));
    });
  });
}
