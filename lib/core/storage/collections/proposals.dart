import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:drift/drift.dart';

@DataClassName('ProposalRow')
class Proposals extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get remoteId => integer().nullable()();

  /// `socid` côté Dolibarr — tiers (client) bénéficiaire du devis.
  IntColumn get socidRemote => integer().nullable()();
  IntColumn get socidLocal => integer().nullable()();

  /// Référence Dolibarr (ex : `PR2026-0042`). Générée à la validation.
  TextColumn get ref => text().nullable()();

  /// Référence interne client.
  TextColumn get refClient => text().nullable()();

  /// Statut Dolibarr : 0=brouillon, 1=validé, 2=signé/clos, -1=refusé.
  IntColumn get status => integer().withDefault(const Constant(0))();

  /// Date du devis.
  DateTimeColumn get dateProposal => dateTime().nullable()();

  /// Date de fin de validité.
  DateTimeColumn get dateEnd => dateTime().nullable()();

  TextColumn get totalHt => text().nullable()();
  TextColumn get totalTva => text().nullable()();
  TextColumn get totalTtc => text().nullable()();

  IntColumn get fkModeReglement => integer().nullable()();
  IntColumn get fkCondReglement => integer().nullable()();

  TextColumn get notePublic => text().nullable()();
  TextColumn get notePrivate => text().nullable()();

  TextColumn get extrafields => text().withDefault(const Constant('{}'))();

  TextColumn get rawJson => text().nullable()();

  DateTimeColumn get tms => dateTime().nullable()();
  DateTimeColumn get localUpdatedAt => dateTime()();

  IntColumn get syncStatus => intEnum<SyncStatus>()
      .withDefault(Constant(SyncStatus.synced.index))();
}

@DataClassName('ProposalLineRow')
class ProposalLines extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// `rowid` Dolibarr de la ligne (`llx_propaldet.rowid`).
  IntColumn get remoteId => integer().nullable()();

  /// `fk_propal` côté Dolibarr (rowid du devis parent).
  IntColumn get proposalRemote => integer().nullable()();

  /// FK locale vers Proposals.id quand le devis parent est encore en
  /// pendingCreate (cascade Outbox 2ᵉ niveau interne devis).
  IntColumn get proposalLocal => integer().nullable()();

  IntColumn get fkProduct => integer().nullable()();

  TextColumn get label => text().nullable()();
  TextColumn get description => text().nullable()();

  /// 0=produit, 1=service.
  IntColumn get productType => integer().withDefault(const Constant(0))();

  TextColumn get qty => text().withDefault(const Constant('1'))();
  TextColumn get subprice => text().nullable()();
  TextColumn get tvaTx => text().nullable()();
  TextColumn get remisePercent => text().nullable()();

  TextColumn get totalHt => text().nullable()();
  TextColumn get totalTva => text().nullable()();
  TextColumn get totalTtc => text().nullable()();

  IntColumn get rang => integer().withDefault(const Constant(0))();

  TextColumn get extrafields => text().withDefault(const Constant('{}'))();

  DateTimeColumn get tms => dateTime().nullable()();
  DateTimeColumn get localUpdatedAt => dateTime()();

  IntColumn get syncStatus => intEnum<SyncStatus>()
      .withDefault(Constant(SyncStatus.synced.index))();
}
