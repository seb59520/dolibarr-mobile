import 'package:dolibarr_mobile/core/storage/collections/categories.dart';
import 'package:dolibarr_mobile/core/storage/collections/contacts.dart';
import 'package:dolibarr_mobile/core/storage/collections/extrafield_definitions.dart';
import 'package:dolibarr_mobile/core/storage/collections/pending_operations.dart';
import 'package:dolibarr_mobile/core/storage/collections/sync_metadata.dart';
import 'package:dolibarr_mobile/core/storage/collections/third_parties.dart';
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
    ExtrafieldDefinitions,
    PendingOperations,
    SyncMetadata,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Constructor utilisé par les tests (executor in-memory).
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          // Insère la ligne singleton SyncMetadata.
          await into(syncMetadata).insert(
            SyncMetadataCompanion.insert(),
          );
        },
      );
}

QueryExecutor _openConnection() => driftDatabase(name: 'dolibarr_mobile');
