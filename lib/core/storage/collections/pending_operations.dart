import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:drift/drift.dart';

@DataClassName('PendingOperationRow')
class PendingOperations extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get opType => intEnum<PendingOpType>()();
  IntColumn get entityType => intEnum<PendingOpEntity>()();

  /// `rowid` Dolibarr cible (null pour un create local non poussé).
  IntColumn get targetRemoteId => integer().nullable()();

  /// PK locale Drift de l'entité ciblée (toujours présente).
  IntColumn get targetLocalId => integer()();

  /// Payload JSON sérialisé prêt à être envoyé.
  TextColumn get payload => text().withDefault(const Constant('{}'))();

  /// `tms` attendu pour la détection de conflit (update / delete).
  DateTimeColumn get expectedTms => dateTime().nullable()();

  /// FK locale d'une autre PendingOperation dont il faut attendre la
  /// résolution (cascade — ex: contact qui dépend du tiers parent).
  IntColumn get dependsOnLocalId => integer().nullable()();

  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get nextRetryAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  IntColumn get status => intEnum<PendingOpStatus>()
      .withDefault(Constant(PendingOpStatus.queued.index))();
}
