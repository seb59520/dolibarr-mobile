import 'package:dolibarr_mobile/core/storage/app_database.dart';
import 'package:dolibarr_mobile/core/storage/collections/products.dart';
import 'package:dolibarr_mobile/features/products/domain/entities/product.dart';
import 'package:drift/drift.dart';

part 'product_local_dao.g.dart';

@DriftAccessor(tables: [Products])
class ProductLocalDao extends DatabaseAccessor<AppDatabase>
    with _$ProductLocalDaoMixin {
  ProductLocalDao(super.attachedDatabase);

  Stream<List<Product>> watch({String search = ''}) {
    final query = select(products)
      ..where((p) => p.onSell.equals(1))
      ..orderBy([(p) => OrderingTerm(expression: p.label)]);
    return query.watch().map(
          (rows) => rows
              .map(_fromRow)
              .where((p) => _matches(p, search))
              .toList(),
        );
  }

  Future<void> replaceAll(List<Product> items) async {
    await transaction(() async {
      await delete(products).go();
      if (items.isEmpty) return;
      await batch((batch) {
        batch.insertAll(
          products,
          items.map(_toCompanion).toList(),
        );
      });
    });
  }

  Product _fromRow(ProductRow r) => Product(
        remoteId: r.remoteId,
        ref: r.ref,
        label: r.label,
        description: r.description,
        type: ProductType.fromInt(r.productType),
        price: r.price,
        tvaTx: r.tvaTx,
        onSell: r.onSell == 1,
        onBuy: r.onBuy == 1,
      );

  ProductsCompanion _toCompanion(Product p) => ProductsCompanion.insert(
        remoteId: p.remoteId,
        ref: p.ref,
        label: p.label,
        description: Value(p.description),
        productType: p.type.apiValue,
        price: Value(p.price),
        tvaTx: Value(p.tvaTx),
        onSell: Value(p.onSell ? 1 : 0),
        onBuy: Value(p.onBuy ? 1 : 0),
        fetchedAt: DateTime.now(),
      );

  bool _matches(Product p, String search) {
    if (search.trim().isEmpty) return true;
    final q = search.toLowerCase();
    return [p.ref, p.label, p.description ?? '']
        .join(' ')
        .toLowerCase()
        .contains(q);
  }
}
