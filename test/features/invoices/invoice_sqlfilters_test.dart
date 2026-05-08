import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dolibarr_mobile/features/invoices/data/datasources/invoice_remote_datasource.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice_filters.dart';
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
  late InvoiceRemoteDataSourceImpl remote;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://erp.example/api/index.php'));
    adapter = _CapturingAdapter();
    dio.httpClientAdapter = adapter;
    remote = InvoiceRemoteDataSourceImpl(dio);
  });

  group('invoice sqlfilters builder', () {
    test('défaut (draft + validated + paid) → 3 clauses OR', () async {
      await remote.fetchPage(
        filters: const InvoiceFilters(),
        page: 0,
        limit: 50,
      );
      final f = adapter.lastSqlFilters!;
      expect(f, contains('t.fk_statut:=:0'));
      expect(f, contains('t.fk_statut:=:1 AND t.paye:=:0'));
      expect(f, contains('t.paye:=:1'));
      // Pas d'abandoned dans le défaut.
      expect(f, isNot(contains('t.fk_statut:=:3')));
    });

    test('tous les statuts (4) → pas de filtre statut', () async {
      await remote.fetchPage(
        filters: InvoiceFilters(statuses: InvoiceStatus.values.toSet()),
        page: 0,
        limit: 100,
      );
      // Aucun fragment statut.
      expect(adapter.lastSqlFilters, isNull);
    });

    test('thirdPartyRemoteId → fk_soc', () async {
      await remote.fetchPage(
        filters: const InvoiceFilters(thirdPartyRemoteId: 42),
        page: 0,
        limit: 100,
      );
      expect(adapter.lastSqlFilters, contains('(t.fk_soc:=:42)'));
    });

    test('unpaidOnly seul → contrainte paye=0', () async {
      await remote.fetchPage(
        filters: const InvoiceFilters(unpaidOnly: true),
        page: 0,
        limit: 100,
      );
      expect(adapter.lastSqlFilters, contains('(t.paye:=:0)'));
    });

    test('dates → datef avec timestamp seconds', () async {
      final from = DateTime(2026, 2);
      final to = DateTime(2026, 12, 31);
      await remote.fetchPage(
        filters: InvoiceFilters(dateFrom: from, dateTo: to),
        page: 0,
        limit: 100,
      );
      final f = adapter.lastSqlFilters!;
      final fromTs = from.millisecondsSinceEpoch ~/ 1000;
      final toTs = to.millisecondsSinceEpoch ~/ 1000;
      expect(f, contains('(t.datef:>=:$fromTs)'));
      expect(f, contains('(t.datef:<=:$toTs)'));
    });

    test('search → like ref/ref_client + escape apostrophes', () async {
      await remote.fetchPage(
        filters: const InvoiceFilters(search: "O'Hara"),
        page: 0,
        limit: 100,
      );
      expect(adapter.lastSqlFilters, contains('t.ref:like:'));
      expect(adapter.lastSqlFilters, contains('t.ref_client:like:'));
      expect(adapter.lastSqlFilters, contains(r"O\'Hara"));
    });
  });

  group('endpoints', () {
    test('fetchById → /invoices/:id', () async {
      adapter.responseBody = '{}';
      await remote.fetchById(99);
      expect(adapter.lastPath, contains('/invoices/99'));
    });
  });
}
