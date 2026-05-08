import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:drift/drift.dart';

@DataClassName('TaskRow')
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get remoteId => integer().nullable()();

  /// `fk_projet` côté Dolibarr — id du projet parent
  /// (`remoteId` Project).
  IntColumn get projectRemote => integer().nullable()();

  /// FK locale vers Projects.id quand le projet parent est encore en
  /// pendingCreate (cascade Outbox 2ᵉ niveau). Patché par le SyncEngine
  /// après push du projet parent.
  IntColumn get projectLocal => integer().nullable()();

  TextColumn get ref => text().nullable()();
  TextColumn get label => text().withDefault(const Constant(''))();
  TextColumn get description => text().nullable()();

  /// Statut Dolibarr d'une tâche (0=en cours, 1=terminée).
  IntColumn get status => integer().withDefault(const Constant(0))();

  /// Avancement en pourcent (0..100).
  IntColumn get progress => integer().withDefault(const Constant(0))();

  /// Heures prévues (string pour préserver la précision).
  TextColumn get plannedHours => text().nullable()();

  /// Utilisateur principal de la tâche.
  IntColumn get fkUser => integer().nullable()();

  DateTimeColumn get dateStart => dateTime().nullable()();
  DateTimeColumn get dateEnd => dateTime().nullable()();

  TextColumn get extrafields => text().withDefault(const Constant('{}'))();

  TextColumn get rawJson => text().nullable()();

  DateTimeColumn get tms => dateTime().nullable()();
  DateTimeColumn get localUpdatedAt => dateTime()();

  IntColumn get syncStatus => intEnum<SyncStatus>()
      .withDefault(Constant(SyncStatus.synced.index))();
}
