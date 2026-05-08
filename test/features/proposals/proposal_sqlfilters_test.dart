import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dolibarr_mobile/features/proposals/data/datasources/proposal_remote_datasource.dart';
import 'package:dolibarr_mobile/features/proposals/domain/entities/proposal.dart';
import 'package:dolibarr_mobile/features/proposals/domain/entities/proposal_filters.dart';
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
  late ProposalRemoteDataSourceImpl remote;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://erp.example/api/index.php'));
    adapter = _CapturingAdapter();
    dio.httpClientAdapter = adapter;
    remote = ProposalRemoteDataSourceImpl(dio);
  });

  group('proposal sqlfilters builder', () {
    test('défaut (draft + validated + signed) → in:0,1,2', () async {
      await remote.fetchPage(
        filters: const ProposalFilters(),
        page: 0,
        limit: 50,
      );
      final f = adapter.lastSqlFilters!;
      // Les valeurs sont triées : -1 (refused) absent, 0,1,2 présents.
      expect(f, contains("t.fk_statut:in:'0,1,2'"));
    });

    test('tous les statuts → pas de filtre statut', () async {
      await remote.fetchPage(
        filters: ProposalFilters(statuses: ProposalStatus.values.toSet()),
        page: 0,
        limit: 100,
      );
      expect(adapter.lastSqlFilters, isNull);
    });

    test('thirdPartyRemoteId → fk_soc', () async {
      await remote.fetchPage(
        filters: const ProposalFilters(thirdPartyRemoteId: 42),
        page: 0,
        limit: 100,
      );
      expect(adapter.lastSqlFilters, contains('(t.fk_soc:=:42)'));
    });

    test('dates → datep avec timestamp seconds', () async {
      final from = DateTime(2026, 2);
      final to = DateTime(2026, 12, 31);
      await remote.fetchPage(
        filters: ProposalFilters(dateFrom: from, dateTo: to),
        page: 0,
        limit: 100,
      );
      final f = adapter.lastSqlFilters!;
      final fromTs = from.millisecondsSinceEpoch ~/ 1000;
      final toTs = to.millisecondsSinceEpoch ~/ 1000;
      expect(f, contains('(t.datep:>=:$fromTs)'));
      expect(f, contains('(t.datep:<=:$toTs)'));
    });

    test('search → like ref/ref_client + escape apostrophes', () async {
      await remote.fetchPage(
        filters: const ProposalFilters(search: "O'Hara"),
        page: 0,
        limit: 100,
      );
      expect(adapter.lastSqlFilters, contains('t.ref:like:'));
      expect(adapter.lastSqlFilters, contains('t.ref_client:like:'));
      expect(adapter.lastSqlFilters, contains(r"O\'Hara"));
    });
  });

  group('endpoints', () {
    test('fetchById → /proposals/:id', () async {
      adapter.responseBody = '{}';
      await remote.fetchById(99);
      expect(adapter.lastPath, contains('/proposals/99'));
    });

    test('createLine → POST /proposals/:id/lines', () async {
      adapter.responseBody = '42';
      await remote.createLine(99, const {'qty': '1'});
      expect(adapter.lastPath, contains('/proposals/99/lines'));
    });

    test('validate → POST /proposals/:id/validate', () async {
      adapter.responseBody = '{}';
      await remote.validate(99);
      expect(adapter.lastPath, contains('/proposals/99/validate'));
    });

    test('close → POST /proposals/:id/close avec status', () async {
      adapter.responseBody = '{}';
      await remote.close(99, 2, note: 'OK');
      expect(adapter.lastPath, contains('/proposals/99/close'));
    });

    test('setInvoiced → POST /proposals/:id/setinvoiced', () async {
      adapter.responseBody = '{}';
      await remote.setInvoiced(99);
      expect(adapter.lastPath, contains('/proposals/99/setinvoiced'));
    });
  });
}
