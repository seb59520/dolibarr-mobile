import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dolibarr_mobile/features/tasks/data/datasources/task_remote_datasource.dart';
import 'package:dolibarr_mobile/features/tasks/domain/entities/task.dart';
import 'package:dolibarr_mobile/features/tasks/domain/entities/task_filters.dart';
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
  late TaskRemoteDataSourceImpl remote;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://erp.example/api/index.php'));
    adapter = _CapturingAdapter();
    dio.httpClientAdapter = adapter;
    remote = TaskRemoteDataSourceImpl(dio);
  });

  group('task sqlfilters builder', () {
    test('défaut (in_progress) → IN sur status', () async {
      await remote.fetchPage(
        filters: const TaskFilters(),
        page: 0,
        limit: 50,
      );
      expect(adapter.lastSqlFilters, contains("(t.status:in:'0')"));
    });

    test('tous les statuts → pas de filtre status', () async {
      await remote.fetchPage(
        filters: TaskFilters(statuses: TaskStatus.values.toSet()),
        page: 0,
        limit: 100,
      );
      expect(adapter.lastSqlFilters, isNull);
    });

    test('projectRemoteId → fk_projet', () async {
      await remote.fetchPage(
        filters: const TaskFilters(projectRemoteId: 42),
        page: 0,
        limit: 100,
      );
      expect(adapter.lastSqlFilters, contains('(t.fk_projet:=:42)'));
    });

    test('mineOnly + userId → fk_user', () async {
      await remote.fetchPage(
        filters: const TaskFilters(mineOnly: true),
        page: 0,
        limit: 100,
        userId: 7,
      );
      expect(adapter.lastSqlFilters, contains('(t.fk_user:=:7)'));
    });

    test('search → like label/ref + escape apostrophes', () async {
      await remote.fetchPage(
        filters: const TaskFilters(search: "O'Brien"),
        page: 0,
        limit: 100,
      );
      expect(adapter.lastSqlFilters, contains('t.label:like:'));
      expect(adapter.lastSqlFilters, contains('t.ref:like:'));
      expect(adapter.lastSqlFilters, contains(r"O\'Brien"));
    });
  });

  group('endpoints', () {
    test('fetchById → /tasks/:id', () async {
      adapter.responseBody = '{}';
      await remote.fetchById(99);
      expect(adapter.lastPath, contains('/tasks/99'));
    });

    test('fetchByProject → /projects/:id/tasks', () async {
      await remote.fetchByProject(13);
      expect(adapter.lastPath, contains('/projects/13/tasks'));
    });
  });
}
