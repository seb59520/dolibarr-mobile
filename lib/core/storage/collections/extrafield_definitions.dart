import 'package:drift/drift.dart';

@DataClassName('ExtrafieldDefinitionRow')
class ExtrafieldDefinitions extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// `thirdparty`, `socpeople` (= contact), etc. (cf. Dolibarr).
  TextColumn get entityType => text()();

  TextColumn get fieldName => text()();
  TextColumn get label => text()();

  /// `varchar`, `int`, `date`, `select`, `boolean`, `text`…
  TextColumn get type => text()();

  BoolColumn get required =>
      boolean().withDefault(const Constant(false))();

  /// JSON (typiquement la liste d'options pour un select).
  TextColumn get options => text().nullable()();

  IntColumn get position => integer().withDefault(const Constant(0))();
  DateTimeColumn get fetchedAt => dateTime()();
}
