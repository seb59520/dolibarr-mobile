import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dolibarr_mobile/features/expenses/data/datasources/expense_remote_datasource.dart';
import 'package:dolibarr_mobile/features/expenses/domain/entities/expense_filters.dart';
import 'package:dolibarr_mobile/features/expenses/domain/entities/expense_report.dart';
import 'package:flutter_test/flutter_test.dart';

class _CapturingAdapter implements HttpClientAdapter {
  String? lastSqlFilters;
  Map<String, List<String>>? lastQuery;
  String? lastPath;
  String? lastMethod;
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
    lastMethod = options.method;
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
  late ExpenseRemoteDataSourceImpl remote;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://erp.example/api/index.php'));
    adapter = _CapturingAdapter();
    dio.httpClientAdapter = adapter;
    remote = ExpenseRemoteDataSourceImpl(dio);
  });

  group('expense sqlfilters builder', () {
    test('défaut sans statuses → pas de filtre statut', () async {
      await remote.fetchPage(
        filters: const ExpenseFilters(statuses: {}),
        page: 0,
        limit: 100,
      );
      expect(adapter.lastSqlFilters, isNull);
    });

    test('un seul statut → 1 clause OR atomique', () async {
      await remote.fetchPage(
        filters: const ExpenseFilters(
          statuses: {ExpenseReportStatus.draft},
        ),
        page: 0,
        limit: 100,
      );
      expect(adapter.lastSqlFilters, contains('t.fk_statut:=:0'));
    });

    test('5 statuts (tous) → pas de filtre statut', () async {
      await remote.fetchPage(
        filters: ExpenseFilters(
          statuses: ExpenseReportStatus.values.toSet(),
        ),
        page: 0,
        limit: 100,
      );
      expect(adapter.lastSqlFilters, isNull);
    });

    test('fkUserAuthor → fk_user_author', () async {
      await remote.fetchPage(
        filters: const ExpenseFilters(fkUserAuthor: 5),
        page: 0,
        limit: 100,
      );
      expect(adapter.lastSqlFilters, contains('(t.fk_user_author:=:5)'));
    });

    test('dates → date_debut avec timestamp seconds', () async {
      final from = DateTime(2026, 2);
      final to = DateTime(2026, 12, 31);
      await remote.fetchPage(
        filters: ExpenseFilters(dateFrom: from, dateTo: to, statuses: const {}),
        page: 0,
        limit: 100,
      );
      final f = adapter.lastSqlFilters!;
      final fromTs = from.millisecondsSinceEpoch ~/ 1000;
      final toTs = to.millisecondsSinceEpoch ~/ 1000;
      expect(f, contains('(t.date_debut:>=:$fromTs)'));
      expect(f, contains('(t.date_debut:<=:$toTs)'));
    });

    test('search → like ref + escape apostrophes', () async {
      await remote.fetchPage(
        filters: const ExpenseFilters(search: "O'Hara", statuses: {}),
        page: 0,
        limit: 100,
      );
      expect(adapter.lastSqlFilters, contains('t.ref:like:'));
      expect(adapter.lastSqlFilters, contains(r"O\'Hara"));
    });
  });

  group('endpoints', () {
    test('fetchById → /expensereports/:id', () async {
      adapter.responseBody = '{}';
      await remote.fetchById(99);
      expect(adapter.lastPath, contains('/expensereports/99'));
    });

    test('createLine utilise /line (singulier) et non /lines', () async {
      adapter.responseBody = '42';
      await remote.createLine(7, {'qty': 1, 'value_unit': 10, 'vatrate': 20});
      expect(adapter.lastMethod, 'POST');
      // /expensereports/7/line — pas /lines.
      expect(adapter.lastPath, endsWith('/expensereports/7/line'));
      expect(adapter.lastPath, isNot(endsWith('/lines')));
    });

    test('updateLine → PUT /lines/:id (pluriel)', () async {
      adapter.responseBody = '{}';
      await remote.updateLine(7, 12, {'qty': 2});
      expect(adapter.lastMethod, 'PUT');
      expect(adapter.lastPath, endsWith('/expensereports/7/lines/12'));
    });

    test('deleteLine → DELETE /lines/:id', () async {
      adapter.responseBody = '{}';
      await remote.deleteLine(7, 12);
      expect(adapter.lastMethod, 'DELETE');
      expect(adapter.lastPath, endsWith('/expensereports/7/lines/12'));
    });

    test('validate → POST /validate', () async {
      adapter.responseBody = '{}';
      await remote.validate(7);
      expect(adapter.lastPath, endsWith('/expensereports/7/validate'));
    });

    test('approve → POST /approve', () async {
      adapter.responseBody = '{}';
      await remote.approve(7);
      expect(adapter.lastPath, endsWith('/expensereports/7/approve'));
    });

    test('fetchTypes → /setup/dictionary/expensereport_types', () async {
      await remote.fetchTypes();
      expect(
        adapter.lastPath,
        endsWith('/setup/dictionary/expensereport_types'),
      );
    });
  });
}
