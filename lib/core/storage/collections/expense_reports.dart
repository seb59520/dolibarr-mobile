import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:drift/drift.dart';

/// Note de frais Dolibarr (`llx_expensereport`).
///
/// Statuts Dolibarr (constantes `ExpenseReport::STATUS_*`) :
///   0 = brouillon, 2 = validé, 4 = approuvé, 6 = payé, 99 = refusé.
@DataClassName('ExpenseReportRow')
class ExpenseReports extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get remoteId => integer().nullable()();

  /// Référence Dolibarr (ex : `ND2026-0042`). Générée à la validation —
  /// `(PROVxx)` en brouillon.
  TextColumn get ref => text().nullable()();

  /// 0=draft, 2=validated, 4=approved, 6=paid, 99=refused.
  IntColumn get status => integer().withDefault(const Constant(0))();

  /// Auteur de la note de frais (`fk_user_author`).
  IntColumn get fkUserAuthor => integer().nullable()();

  /// Valideur souhaité (`fk_user_valid`).
  IntColumn get fkUserValid => integer().nullable()();

  /// Date de début de période couverte par la note.
  DateTimeColumn get dateDebut => dateTime().nullable()();

  /// Date de fin de période.
  DateTimeColumn get dateFin => dateTime().nullable()();

  TextColumn get totalHt => text().nullable()();
  TextColumn get totalTva => text().nullable()();
  TextColumn get totalTtc => text().nullable()();

  /// Note publique sur la note de frais (visible dans le PDF).
  TextColumn get notePublic => text().nullable()();

  /// Note privée (interne).
  TextColumn get notePrivate => text().nullable()();

  TextColumn get extrafields => text().withDefault(const Constant('{}'))();

  TextColumn get rawJson => text().nullable()();

  DateTimeColumn get tms => dateTime().nullable()();
  DateTimeColumn get localUpdatedAt => dateTime()();

  IntColumn get syncStatus => intEnum<SyncStatus>()
      .withDefault(Constant(SyncStatus.synced.index))();
}

/// Ligne de note de frais (`llx_expensereport_det`).
///
/// Le type de frais Dolibarr est stocké sous deux formes :
///   - `fkCTypeFees` : l'`id` numérique (`llx_c_type_fees.id`),
///     utilisé pour le POST côté API.
///   - `codeCTypeFees` : le `code` textuel (ex. `TF_LUNCH`), utilisé
///     pour l'affichage et la résolution UX.
@DataClassName('ExpenseLineRow')
class ExpenseLines extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// `rowid` Dolibarr (`llx_expensereport_det.rowid`).
  IntColumn get remoteId => integer().nullable()();

  /// `fk_expensereport` côté Dolibarr (rowid du parent).
  IntColumn get expenseReportRemote => integer().nullable()();

  /// FK locale vers ExpenseReports.id quand le parent est encore en
  /// `pendingCreate` (cascade Outbox 2ᵉ niveau notes-de-frais → ligne).
  IntColumn get expenseReportLocal => integer().nullable()();

  /// id Dolibarr (`llx_c_type_fees.id`).
  IntColumn get fkCTypeFees => integer().nullable()();

  /// Code textuel correspondant (ex. `TF_LUNCH`) — utile pour les UIs
  /// et pour reconstruire la FK numérique depuis le cache local des
  /// types si la table ExpenseTypes a été régénérée entretemps.
  TextColumn get codeCTypeFees => text().nullable()();

  /// Date de la dépense (jour de l'achat).
  DateTimeColumn get date => dateTime().nullable()();

  TextColumn get comments => text().nullable()();

  TextColumn get qty => text().withDefault(const Constant('1'))();
  TextColumn get valueUnit => text().nullable()();
  TextColumn get tvaTx => text().nullable()();

  TextColumn get totalHt => text().nullable()();
  TextColumn get totalTva => text().nullable()();
  TextColumn get totalTtc => text().nullable()();

  /// Projet associé Dolibarr (`fk_project`), nullable.
  IntColumn get projetId => integer().nullable()();

  IntColumn get rang => integer().withDefault(const Constant(0))();

  TextColumn get rawJson => text().nullable()();

  DateTimeColumn get tms => dateTime().nullable()();
  DateTimeColumn get localUpdatedAt => dateTime()();

  IntColumn get syncStatus => intEnum<SyncStatus>()
      .withDefault(Constant(SyncStatus.synced.index))();
}

/// Cache local du dictionnaire `llx_c_type_fees` (codes des types de
/// frais : `TF_LUNCH`, `TF_TRIP`, `EX_HOT`...).
///
/// Pré-chargé au premier sync via `GET /setup/dictionary/expensereport_types`,
/// puis rafraîchi à la demande (peu volatil).
@DataClassName('ExpenseTypeRow')
class ExpenseTypes extends Table {
  /// Code stable (ex. `TF_LUNCH`).
  TextColumn get code => text()();

  /// id Dolibarr (`llx_c_type_fees.id`), nécessaire pour le POST.
  IntColumn get remoteId => integer()();

  TextColumn get label => text()();

  TextColumn get accountancyCode => text().nullable()();

  BoolColumn get active => boolean().withDefault(const Constant(true))();

  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {code};
}
