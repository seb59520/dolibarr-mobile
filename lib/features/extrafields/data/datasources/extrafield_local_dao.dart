import 'dart:convert';

import 'package:dolibarr_mobile/core/storage/app_database.dart';
import 'package:dolibarr_mobile/core/storage/collections/extrafield_definitions.dart';
import 'package:dolibarr_mobile/features/extrafields/domain/entities/extrafield_definition.dart';
import 'package:drift/drift.dart';

part 'extrafield_local_dao.g.dart';

@DriftAccessor(tables: [ExtrafieldDefinitions])
class ExtrafieldLocalDao extends DatabaseAccessor<AppDatabase>
    with _$ExtrafieldLocalDaoMixin {
  ExtrafieldLocalDao(super.attachedDatabase);

  Stream<List<ExtrafieldDefinition>> watchByEntityType(String entityType) {
    final query = select(extrafieldDefinitions)
      ..where((e) => e.entityType.equals(entityType))
      ..orderBy([(e) => OrderingTerm(expression: e.position)]);
    return query.watch().map((rows) => rows.map(_fromRow).toList());
  }

  /// Remplace toutes les définitions cachées par la liste fournie.
  /// Atomique : transactional.
  Future<void> replaceAll(List<ExtrafieldDefinition> defs) async {
    await transaction(() async {
      await delete(extrafieldDefinitions).go();
      if (defs.isEmpty) return;
      await batch((b) {
        b.insertAll(extrafieldDefinitions, defs.map(_toCompanion).toList());
      });
    });
  }

  ExtrafieldDefinition _fromRow(ExtrafieldDefinitionRow r) =>
      ExtrafieldDefinition(
        entityType: r.entityType,
        fieldName: r.fieldName,
        label: r.label,
        type: ExtrafieldType.fromApi(r.type),
        required: r.required,
        options: r.options == null
            ? const {}
            : ExtrafieldDefinition.decodeOptions(r.options),
        position: r.position,
      );

  ExtrafieldDefinitionsCompanion _toCompanion(ExtrafieldDefinition d) =>
      ExtrafieldDefinitionsCompanion.insert(
        entityType: d.entityType,
        fieldName: d.fieldName,
        label: d.label,
        type: d.type.name,
        required: Value(d.required),
        options: Value(d.options.isEmpty ? null : jsonEncode(d.options)),
        position: Value(d.position),
        fetchedAt: DateTime.now(),
      );
}
