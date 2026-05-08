import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:drift/drift.dart';

@DataClassName('InvoiceRow')
class Invoices extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get remoteId => integer().nullable()();

  /// `socid` côté Dolibarr — tiers (client) facturé.
  IntColumn get socidRemote => integer().nullable()();
  IntColumn get socidLocal => integer().nullable()();

  /// Référence Dolibarr (ex : `FA2026-0042`). Générée au passage à
  /// l'état validé.
  TextColumn get ref => text().nullable()();

  /// Référence interne client (saisie libre).
  TextColumn get refClient => text().nullable()();

  /// Type Dolibarr : 0=standard, 1=replacement, 2=credit_note,
  /// 3=deposit, 4=proforma, 5=situation.
  IntColumn get type => integer().withDefault(const Constant(0))();

  /// Statut Dolibarr : 0=brouillon, 1=validée, 2=payée, 3=abandonnée.
  IntColumn get status => integer().withDefault(const Constant(0))();

  /// Flag payé : 0=impayée, 1=payée.
  IntColumn get paye => integer().withDefault(const Constant(0))();

  /// Date facture (création comptable).
  DateTimeColumn get dateInvoice => dateTime().nullable()();

  /// Date d'échéance.
  DateTimeColumn get dateDue => dateTime().nullable()();

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

@DataClassName('InvoiceLineRow')
class InvoiceLines extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// `rowid` Dolibarr de la ligne (`llx_facturedet.rowid`).
  IntColumn get remoteId => integer().nullable()();

  /// `fk_facture` côté Dolibarr (rowid de la facture parente).
  IntColumn get invoiceRemote => integer().nullable()();

  /// FK locale vers Invoices.id quand la facture parente est encore
  /// en pendingCreate (cascade Outbox 2ᵉ niveau pour les factures).
  IntColumn get invoiceLocal => integer().nullable()();

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
