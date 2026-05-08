import 'dart:convert';

import 'package:dolibarr_mobile/core/storage/app_database.dart';
import 'package:dolibarr_mobile/core/storage/collections/drafts.dart';
import 'package:drift/drift.dart';

part 'draft_local_dao.g.dart';

@DriftAccessor(tables: [Drafts])
class DraftLocalDao extends DatabaseAccessor<AppDatabase>
    with _$DraftLocalDaoMixin {
  DraftLocalDao(super.attachedDatabase);

  /// Stream du brouillon courant pour `(entityType, refLocalId)`. Émet
  /// `null` si pas de brouillon, ou la map décodée sinon.
  Stream<Map<String, Object?>?> watch({
    required String entityType,
    int? refLocalId,
  }) {
    final query = select(drafts)
      ..where(
        (d) => d.entityType.equals(entityType) &
            (refLocalId == null
                ? d.refLocalId.isNull()
                : d.refLocalId.equals(refLocalId)),
      )
      ..limit(1);
    return query.watchSingleOrNull().map(
          (row) => row == null ? null : _decode(row.fieldsJson),
        );
  }

  Future<Map<String, Object?>?> read({
    required String entityType,
    int? refLocalId,
  }) async {
    final row = await (select(drafts)
          ..where(
            (d) => d.entityType.equals(entityType) &
                (refLocalId == null
                    ? d.refLocalId.isNull()
                    : d.refLocalId.equals(refLocalId)),
          )
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : _decode(row.fieldsJson);
  }

  /// Upsert : crée le brouillon ou met à jour `fieldsJson` + `updatedAt`.
  Future<void> save({
    required String entityType,
    required Map<String, Object?> fields,
    int? refLocalId,
  }) async {
    final existing = await (select(drafts)
          ..where(
            (d) => d.entityType.equals(entityType) &
                (refLocalId == null
                    ? d.refLocalId.isNull()
                    : d.refLocalId.equals(refLocalId)),
          ))
        .getSingleOrNull();
    final now = DateTime.now();
    if (existing == null) {
      await into(drafts).insert(
        DraftsCompanion.insert(
          entityType: entityType,
          refLocalId: Value(refLocalId),
          fieldsJson: Value(jsonEncode(fields)),
          updatedAt: now,
        ),
      );
    } else {
      await (update(drafts)..where((d) => d.id.equals(existing.id))).write(
        DraftsCompanion(
          fieldsJson: Value(jsonEncode(fields)),
          updatedAt: Value(now),
        ),
      );
    }
  }

  Future<void> discard({
    required String entityType,
    int? refLocalId,
  }) async {
    await (delete(drafts)
          ..where(
            (d) => d.entityType.equals(entityType) &
                (refLocalId == null
                    ? d.refLocalId.isNull()
                    : d.refLocalId.equals(refLocalId)),
          ))
        .go();
  }

  Map<String, Object?>? _decode(String json) {
    try {
      final v = jsonDecode(json);
      if (v is Map) return v.cast<String, Object?>();
    } catch (_) {
      // brouillon corrompu — on ignore, sera écrasé au prochain save.
    }
    return null;
  }
}
