import 'package:drift/drift.dart';

@DataClassName('InvoicePaymentRow')
class InvoicePayments extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// `rowid` Dolibarr du paiement (`llx_paiement.rowid`).
  IntColumn get remoteId => integer().unique()();

  /// `fk_facture` rattaché — on conserve uniquement le `remoteId` côté
  /// facture car les paiements ne sont jamais créés offline depuis
  /// l'app (lecture-seule depuis Stats).
  IntColumn get invoiceRemoteId => integer()();

  /// Date du règlement (`llx_paiement.datep`).
  DateTimeColumn get date => dateTime().nullable()();

  /// Montant TTC stringifié pour préserver la précision décimale
  /// (cohérent avec les autres montants stockés en TEXT dans le projet).
  TextColumn get amount => text().nullable()();

  /// Code mode de paiement (`CHQ`, `VIR`, `LIQ`…). Optionnel.
  TextColumn get type => text().nullable()();

  /// Numéro/référence du moyen de paiement (n° chèque, ref virement).
  TextColumn get num => text().nullable()();

  /// Référence Dolibarr (`PAY-…`) si générée.
  TextColumn get ref => text().nullable()();

  DateTimeColumn get localUpdatedAt => dateTime()();
}
