import 'package:drift/drift.dart';

/// Brouillon de formulaire (édition / création en cours).
///
/// Un brouillon par couple `(entityType, refLocalId)` :
/// - `refLocalId == null` : création nouvelle entité
/// - `refLocalId != null` : édition d'une entité existante
///
/// Persiste l'état du formulaire entre les ouvertures de l'app sans
/// polluer la table cible (qui reste sur la valeur synced jusqu'au commit).
@DataClassName('DraftRow')
class Drafts extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// `thirdparty` ou `contact`.
  TextColumn get entityType => text()();

  /// PK locale Drift de l'entité référencée. `null` pour une création
  /// (le brouillon n'a pas encore d'entité associée).
  IntColumn get refLocalId => integer().nullable()();

  /// Snapshot JSON des valeurs courantes du formulaire.
  TextColumn get fieldsJson => text().withDefault(const Constant('{}'))();

  DateTimeColumn get updatedAt => dateTime()();
}
