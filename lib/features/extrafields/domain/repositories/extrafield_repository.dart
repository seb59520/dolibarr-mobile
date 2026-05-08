import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/extrafields/domain/entities/extrafield_definition.dart';

/// Accès aux définitions de champs personnalisés.
abstract interface class ExtrafieldRepository {
  /// Stream SWR des définitions pour un type d'entité donné
  /// (`thirdparty`, `socpeople`).
  Stream<List<ExtrafieldDefinition>> watchByEntityType(String entityType);

  /// Force un refresh depuis l'API. Met à jour la table localement.
  Future<Result<void>> refresh();
}
