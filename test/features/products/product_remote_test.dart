import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dolibarr_mobile/features/products/data/datasources/product_remote_datasource.dart';
import 'package:dolibarr_mobile/features/products/domain/entities/product.dart';
import 'package:flutter_test/flutter_test.dart';

class _CapturingAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  String responseBody = '[]';

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
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
  late ProductRemoteDataSourceImpl remote;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://erp.example/api/index.php'));
    adapter = _CapturingAdapter();
    dio.httpClientAdapter = adapter;
    remote = ProductRemoteDataSourceImpl(dio);
  });

  test('fetchAllForSell envoie sqlfilters tosell=1 + tostatut=1', () async {
    await remote.fetchAllForSell();
    final f = adapter.requests.first.queryParameters['sqlfilters'] as String;
    expect(f, contains('t.tosell:=:1'));
    expect(f, contains('t.tostatut:=:1'));
  });

  test('parse JSON Dolibarr → Product', () async {
    adapter.responseBody = '''
[
  {
    "id": 12,
    "ref": "SVC-DEV",
    "label": "Développement",
    "description": "Prestation jour",
    "type": "1",
    "price": "650.00",
    "tva_tx": "20",
    "tosell": "1",
    "tobuy": "0"
  }
]
''';
    final list = await remote.fetchAllForSell();
    expect(list, hasLength(1));
    final p = list.first;
    expect(p.remoteId, 12);
    expect(p.ref, 'SVC-DEV');
    expect(p.label, 'Développement');
    expect(p.type, ProductType.service);
    expect(p.price, '650.00');
    expect(p.tvaTx, '20');
    expect(p.onSell, isTrue);
    expect(p.onBuy, isFalse);
  });

  test("pagination boucle jusqu'à page partielle", () async {
    const tile = '{"id": 1, "ref": "A", "label": "x"}';
    final fullPage = '[${List.filled(100, tile).join(',')}]';
    dio.httpClientAdapter = _SequencedAdapter(
      pages: [
        fullPage,
        '[{"id": 99, "ref": "Z", "label": "fin"}]',
      ],
    );
    remote = ProductRemoteDataSourceImpl(dio);

    final list = await remote.fetchAllForSell();
    expect(list.length, 101);
  });
}

class _SequencedAdapter implements HttpClientAdapter {
  _SequencedAdapter({required this.pages});
  final List<String> pages;
  int _i = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final body = _i < pages.length ? pages[_i] : '[]';
    _i++;
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
