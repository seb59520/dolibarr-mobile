import 'package:dolibarr_mobile/core/storage/collections/categories.dart';
import 'package:dolibarr_mobile/core/storage/collections/contacts.dart';
import 'package:dolibarr_mobile/core/storage/collections/drafts.dart';
import 'package:dolibarr_mobile/core/storage/collections/extrafield_definitions.dart';
import 'package:dolibarr_mobile/core/storage/collections/invoices.dart';
import 'package:dolibarr_mobile/core/storage/collections/pending_operations.dart';
import 'package:dolibarr_mobile/core/storage/collections/projects.dart';
import 'package:dolibarr_mobile/core/storage/collections/proposals.dart';
import 'package:dolibarr_mobile/core/storage/collections/sync_metadata.dart';
import 'package:dolibarr_mobile/core/storage/collections/tasks.dart';
import 'package:dolibarr_mobile/core/storage/collections/third_parties.dart';
import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Base de données locale Drift de l'application.
///
/// Toutes les tables métier vivent ici. Les DAOs spécifiques par feature
/// seront ajoutés au fur et à mesure (Étape 5+) en composition.
@DriftDatabase(
  tables: [
    ThirdParties,
    Contacts,
    Categories,
    Drafts,
    ExtrafieldDefinitions,
    InvoiceLines,
    Invoices,
    PendingOperations,
    Projects,
    ProposalLines,
    Proposals,
    SyncMetadata,
    Tasks,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Constructor utilisé par les tests (executor in-memory).
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          // Insère la ligne singleton SyncMetadata.
          await into(syncMetadata).insert(
            SyncMetadataCompanion.insert(),
          );
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(drafts);
          }
          if (from < 3) {
            await m.createTable(projects);
          }
          if (from < 4) {
            await m.createTable(tasks);
          }
          if (from < 5) {
            await m.createTable(invoices);
            await m.createTable(invoiceLines);
          }
          if (from < 6) {
            await m.createTable(proposals);
            await m.createTable(proposalLines);
          }
        },
      );
}

QueryExecutor _openConnection() => driftDatabase(
      name: 'dolibarr_mobile',
      // Sur web, drift_flutter exige les URIs vers sqlite3.wasm + un
      // worker compilé depuis drift_worker.dart, tous deux placés dans
      // `web/` et donc servis depuis la racine du bundle PWA.
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.dart.js'),
      ),
    );
