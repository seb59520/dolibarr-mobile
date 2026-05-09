import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/products/domain/entities/product.dart';

/// Lecture seule du catalogue produits/services. Un refresh au démarrage
/// peuple le cache local ; les recherches s'appuient ensuite sur Drift.
abstract interface class ProductRepository {
  /// Stream tous les produits actifs en vente, optionnellement filtrés
  /// par texte (search dans `ref` + `label`).
  Stream<List<Product>> watch({String search = ''});

  /// Rafraîchit le cache local depuis l'API. À appeler au login + à la
  /// demande (pull-to-refresh sur le picker).
  Future<Result<int>> refresh();
}
