import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:drift/drift.dart';

@DataClassName('ThirdPartyRow')
class ThirdParties extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// `rowid` Dolibarr — null tant que l'entité n'a pas été poussée.
  IntColumn get remoteId => integer().nullable()();

  TextColumn get name => text().withDefault(const Constant(''))();
  TextColumn get codeClient => text().nullable()();
  TextColumn get codeFournisseur => text().nullable()();
  IntColumn get clientType => integer().withDefault(const Constant(0))();
  IntColumn get fournisseur => integer().withDefault(const Constant(0))();
  IntColumn get status => integer().withDefault(const Constant(1))();

  TextColumn get address => text().nullable()();
  TextColumn get zip => text().nullable()();
  TextColumn get town => text().nullable()();
  TextColumn get countryCode => text().nullable()();

  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get url => text().nullable()();

  TextColumn get siren => text().nullable()();
  TextColumn get siret => text().nullable()();
  TextColumn get tvaIntra => text().nullable()();

  TextColumn get notePublic => text().nullable()();
  TextColumn get notePrivate => text().nullable()();

  /// IDs catégories Dolibarr (JSON list of int).
  TextColumn get categoriesJson =>
      text().withDefault(const Constant('[]'))();

  /// Champs personnalisés (JSON map String -> dynamic).
  TextColumn get extrafields => text().withDefault(const Constant('{}'))();

  /// Snapshot brut de la dernière réponse API.
  TextColumn get rawJson => text().nullable()();

  DateTimeColumn get tms => dateTime().nullable()();
  DateTimeColumn get localUpdatedAt => dateTime()();

  IntColumn get syncStatus => intEnum<SyncStatus>()
      .withDefault(Constant(SyncStatus.synced.index))();
}
