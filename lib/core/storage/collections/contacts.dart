import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:drift/drift.dart';

@DataClassName('ContactRow')
class Contacts extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get remoteId => integer().nullable()();

  /// `socid` côté Dolibarr — id du tiers parent (`remoteId` de ThirdParty).
  IntColumn get socidRemote => integer().nullable()();

  /// FK locale vers ThirdParties.id quand le parent n'est pas encore poussé
  /// (cascade Outbox). Patché par le SyncEngine après push du parent.
  IntColumn get socidLocal => integer().nullable()();

  TextColumn get firstname => text().nullable()();
  TextColumn get lastname => text().nullable()();
  TextColumn get poste => text().nullable()();

  TextColumn get phonePro => text().nullable()();
  TextColumn get phoneMobile => text().nullable()();
  TextColumn get email => text().nullable()();

  TextColumn get address => text().nullable()();
  TextColumn get zip => text().nullable()();
  TextColumn get town => text().nullable()();

  TextColumn get extrafields => text().withDefault(const Constant('{}'))();
  TextColumn get rawJson => text().nullable()();

  DateTimeColumn get tms => dateTime().nullable()();
  DateTimeColumn get localUpdatedAt => dateTime()();

  IntColumn get syncStatus => intEnum<SyncStatus>()
      .withDefault(Constant(SyncStatus.synced.index))();
}
