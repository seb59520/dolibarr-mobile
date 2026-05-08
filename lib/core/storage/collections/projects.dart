import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:drift/drift.dart';

@DataClassName('ProjectRow')
class Projects extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get remoteId => integer().nullable()();

  /// `socid` côté Dolibarr — id du tiers parent (`remoteId` ThirdParty).
  IntColumn get socidRemote => integer().nullable()();

  /// FK locale vers ThirdParties.id quand le parent est encore en
  /// pendingCreate (cascade Outbox). Patché par le SyncEngine après
  /// push du parent.
  IntColumn get socidLocal => integer().nullable()();

  /// Référence Dolibarr (ex : `PJ2026-001`). Générée côté serveur à
  /// la validation, peut être nulle en pendingCreate.
  TextColumn get ref => text().nullable()();

  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get description => text().nullable()();

  /// Statut Dolibarr : 0=brouillon, 1=ouvert, 2=fermé.
  IntColumn get status => integer().withDefault(const Constant(0))();

  /// 0 = privé (visible auteur seulement), 1 = public projet.
  IntColumn get publicLevel => integer().withDefault(const Constant(0))();

  /// Utilisateur responsable côté Dolibarr.
  IntColumn get fkUserResp => integer().nullable()();

  DateTimeColumn get dateStart => dateTime().nullable()();
  DateTimeColumn get dateEnd => dateTime().nullable()();

  /// Budget alloué (HT). Stocké en string pour préserver la précision.
  TextColumn get budgetAmount => text().nullable()();

  /// Statut d'opportunité (lead/proposition/won/lost). Cf table
  /// llx_c_lead_status côté Dolibarr.
  IntColumn get oppStatus => integer().nullable()();
  TextColumn get oppAmount => text().nullable()();
  RealColumn get oppPercent => real().nullable()();

  TextColumn get extrafields => text().withDefault(const Constant('{}'))();

  TextColumn get rawJson => text().nullable()();

  DateTimeColumn get tms => dateTime().nullable()();
  DateTimeColumn get localUpdatedAt => dateTime()();

  IntColumn get syncStatus => intEnum<SyncStatus>()
      .withDefault(Constant(SyncStatus.synced.index))();
}
