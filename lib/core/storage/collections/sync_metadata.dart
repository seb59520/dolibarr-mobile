import 'package:drift/drift.dart';

/// Singleton (1 seule ligne, id = 1) portant les métadonnées de
/// synchronisation globale.
@DataClassName('SyncMetadataRow')
class SyncMetadata extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  DateTimeColumn get lastFullSyncAt => dateTime().nullable()();
  DateTimeColumn get lastDeltaSyncAt => dateTime().nullable()();
  TextColumn get apiVersion => text().nullable()();
  IntColumn get schemaVersion =>
      integer().withDefault(const Constant(1))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
