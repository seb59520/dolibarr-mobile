import 'package:drift/drift.dart';

@DataClassName('ProductRow')
class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get remoteId => integer()();

  TextColumn get ref => text()();
  TextColumn get label => text()();
  TextColumn get description => text().nullable()();

  /// 0 = produit, 1 = service.
  IntColumn get productType => integer()();

  /// Prix unitaire HT par défaut (string pour préserver la précision).
  TextColumn get price => text().nullable()();

  /// Taux de TVA appliqué par défaut.
  TextColumn get tvaTx => text().nullable()();

  /// 1 si actif côté vente / achat.
  IntColumn get onSell => integer().withDefault(const Constant(1))();
  IntColumn get onBuy => integer().withDefault(const Constant(0))();

  DateTimeColumn get fetchedAt => dateTime()();
}
