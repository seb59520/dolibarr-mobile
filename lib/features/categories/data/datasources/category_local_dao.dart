import 'package:dolibarr_mobile/core/storage/app_database.dart';
import 'package:dolibarr_mobile/core/storage/collections/categories.dart';
import 'package:dolibarr_mobile/features/categories/domain/entities/category.dart';
import 'package:drift/drift.dart';

part 'category_local_dao.g.dart';

/// DAO Drift pour la table `categories`. Encapsule les requêtes locales.
@DriftAccessor(tables: [Categories])
class CategoryLocalDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryLocalDaoMixin {
  CategoryLocalDao(super.attachedDatabase);

  /// Stream réactif filtré par type. Drift réémet automatiquement à
  /// chaque insert/update/delete sur la table.
  Stream<List<Category>> watchByType(CategoryType type) {
    final query = select(categories)
      ..where((c) => c.type.equals(type.apiValue));
    return query.watch().map(
          (rows) => rows.map(_fromRow).toList(),
        );
  }

  /// Remplace l'ensemble des catégories d'un type donné par la liste
  /// fournie (utilisé après un refresh API). Atomique via transaction.
  Future<void> replaceAllForType(
    CategoryType type,
    List<Category> items,
  ) async {
    await transaction(() async {
      await (delete(categories)
            ..where((c) => c.type.equals(type.apiValue)))
          .go();
      if (items.isEmpty) return;
      await batch((batch) {
        batch.insertAll(
          categories,
          items.map(_toCompanion).toList(),
        );
      });
    });
  }

  Category _fromRow(CategoryRow r) => Category(
        remoteId: r.remoteId,
        label: r.label,
        type: CategoryType.fromApi(r.type),
        parentRemoteId: r.parentRemoteId,
        color: r.color,
      );

  CategoriesCompanion _toCompanion(Category c) => CategoriesCompanion.insert(
        remoteId: c.remoteId,
        label: c.label,
        type: c.type.apiValue,
        parentRemoteId: Value(c.parentRemoteId),
        color: Value(c.color),
        fetchedAt: DateTime.now(),
      );
}
