import 'package:drift/drift.dart';

@DataClassName('CategoryRow')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get remoteId => integer()();
  TextColumn get label => text()();

  /// `customer`, `supplier` ou `contact` (cf. Dolibarr API).
  TextColumn get type => text()();

  IntColumn get parentRemoteId => integer().nullable()();
  TextColumn get color => text().nullable()();
  DateTimeColumn get fetchedAt => dateTime()();
}
