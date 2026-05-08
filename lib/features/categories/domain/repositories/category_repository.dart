import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/categories/domain/entities/category.dart';

/// Accès aux catégories Dolibarr (lecture seule + cache local).
abstract interface class CategoryRepository {
  /// Stream SWR : émet d'abord depuis le cache puis se met à jour dès
  /// que la requête API retourne. Émet aussi en cas d'invalidation
  /// (refresh manuel).
  Stream<List<Category>> watchByType(CategoryType type);

  /// Force un refresh depuis l'API (utilisé par pull-to-refresh).
  Future<Result<void>> refresh(CategoryType type);
}
