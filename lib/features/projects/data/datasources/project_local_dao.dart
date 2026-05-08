import 'dart:convert';

import 'package:dolibarr_mobile/core/storage/app_database.dart';
import 'package:dolibarr_mobile/core/storage/collections/projects.dart';
import 'package:dolibarr_mobile/core/storage/collections/third_parties.dart';
import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:dolibarr_mobile/features/projects/domain/entities/project.dart';
import 'package:dolibarr_mobile/features/projects/domain/entities/project_filters.dart';
import 'package:drift/drift.dart';

part 'project_local_dao.g.dart';

@DriftAccessor(tables: [Projects, ThirdParties])
class ProjectLocalDao extends DatabaseAccessor<AppDatabase>
    with _$ProjectLocalDaoMixin {
  ProjectLocalDao(super.attachedDatabase);

  Stream<List<Project>> watchFiltered(ProjectFilters f) {
    final query = select(projects)
      ..orderBy([
        (t) => OrderingTerm.desc(t.dateStart),
        (t) => OrderingTerm(expression: t.title),
      ]);
    return query.watch().map(
          (rows) =>
              rows.map(_fromRow).where((p) => _matchesLocal(p, f)).toList(),
        );
  }

  Stream<Project?> watchById(int localId) {
    return (select(projects)..where((p) => p.id.equals(localId)))
        .watchSingleOrNull()
        .map((row) => row == null ? null : _fromRow(row));
  }

  /// Stream des projets d'un tiers (par PK locale du tiers).
  Stream<List<Project>> watchByThirdPartyLocal(int thirdPartyLocalId) {
    final query = select(projects).join([
      leftOuterJoin(
        thirdParties,
        thirdParties.id.equalsExp(projects.socidLocal) |
            thirdParties.remoteId.equalsExp(projects.socidRemote),
      ),
    ])
      ..where(thirdParties.id.equals(thirdPartyLocalId))
      ..orderBy([
        OrderingTerm.desc(projects.dateStart),
        OrderingTerm(expression: projects.title),
      ]);
    return query.watch().map(
          (rows) =>
              rows.map((row) => _fromRow(row.readTable(projects))).toList(),
        );
  }

  Future<Project?> findByRemoteId(int remoteId) async {
    final row = await (select(projects)
          ..where((p) => p.remoteId.equals(remoteId)))
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  Future<void> upsertFromServer(Map<String, Object?> json) async {
    final remoteId = int.tryParse('${json['id'] ?? ''}');
    if (remoteId == null) return;
    final existing = await findByRemoteId(remoteId);
    if (existing != null && existing.syncStatus != SyncStatus.synced) {
      return;
    }
    final companion = _toCompanionFromJson(json, existing?.localId);
    await into(projects).insertOnConflictUpdate(companion);
  }

  Future<void> upsertManyFromServer(List<Map<String, Object?>> rows) async {
    await transaction(() async {
      for (final r in rows) {
        await upsertFromServer(r);
      }
    });
  }

  Future<int> insertLocal(Project p) async {
    return into(projects).insert(
      _toCompanionFromEntity(
        p.copyWithSync(SyncStatus.pendingCreate),
        forInsert: true,
      ),
    );
  }

  Future<void> updateLocal(Project p) async {
    final existing = await (select(projects)
          ..where((row) => row.id.equals(p.localId)))
        .getSingleOrNull();
    if (existing == null) return;
    final nextStatus = existing.syncStatus == SyncStatus.pendingCreate
        ? SyncStatus.pendingCreate
        : SyncStatus.pendingUpdate;
    await (update(projects)..where((r) => r.id.equals(p.localId))).write(
      _toCompanionFromEntity(
        p.copyWithSync(nextStatus),
        forInsert: false,
      ),
    );
  }

  Future<void> markPendingDelete(int localId) async {
    await (update(projects)..where((r) => r.id.equals(localId))).write(
      ProjectsCompanion(
        syncStatus: const Value(SyncStatus.pendingDelete),
        localUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> hardDelete(int localId) {
    return (delete(projects)..where((r) => r.id.equals(localId))).go();
  }

  Future<void> markSyncedWithRemote({
    required int localId,
    required int remoteId,
    DateTime? tms,
  }) async {
    await (update(projects)..where((r) => r.id.equals(localId))).write(
      ProjectsCompanion(
        remoteId: Value(remoteId),
        tms: Value(tms ?? DateTime.now()),
        syncStatus: const Value(SyncStatus.synced),
        localUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> markConflict(int localId) async {
    await (update(projects)..where((r) => r.id.equals(localId))).write(
      ProjectsCompanion(
        syncStatus: const Value(SyncStatus.conflict),
        localUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> clearAfterServerDelete(int localId) {
    return (delete(projects)..where((r) => r.id.equals(localId))).go();
  }

  /// Patche `socidRemote` pour les projets dont le tiers parent vient
  /// d'être créé côté serveur. Appelé par le SyncEngine après le succès
  /// de l'op create du parent (cf. cascade Outbox).
  Future<int> patchSocidRemoteByParent({
    required int parentLocalId,
    required int parentRemoteId,
  }) async {
    return (update(projects)
          ..where(
            (p) =>
                p.socidLocal.equals(parentLocalId) &
                p.socidRemote.isNull(),
          ))
        .write(ProjectsCompanion(socidRemote: Value(parentRemoteId)));
  }

  ProjectsCompanion _toCompanionFromEntity(
    Project p, {
    required bool forInsert,
  }) {
    return ProjectsCompanion(
      id: forInsert ? const Value.absent() : Value(p.localId),
      remoteId: Value(p.remoteId),
      socidRemote: Value(p.socidRemote),
      socidLocal: Value(p.socidLocal),
      ref: Value(p.ref),
      title: Value(p.title),
      description: Value(p.description),
      status: Value(p.status.apiValue),
      publicLevel: Value(p.publicLevel),
      fkUserResp: Value(p.fkUserResp),
      dateStart: Value(p.dateStart),
      dateEnd: Value(p.dateEnd),
      budgetAmount: Value(p.budgetAmount),
      oppStatus: Value(p.oppStatus),
      oppAmount: Value(p.oppAmount),
      oppPercent: Value(p.oppPercent),
      extrafields: Value(jsonEncode(p.extrafields)),
      tms: Value(p.tms),
      localUpdatedAt: Value(DateTime.now()),
      syncStatus: Value(p.syncStatus),
    );
  }

  Project _fromRow(ProjectRow r) => Project(
        localId: r.id,
        remoteId: r.remoteId,
        socidRemote: r.socidRemote,
        socidLocal: r.socidLocal,
        ref: r.ref,
        title: r.title,
        description: r.description,
        status: ProjectStatus.fromInt(r.status),
        publicLevel: r.publicLevel,
        fkUserResp: r.fkUserResp,
        dateStart: r.dateStart,
        dateEnd: r.dateEnd,
        budgetAmount: r.budgetAmount,
        oppStatus: r.oppStatus,
        oppAmount: r.oppAmount,
        oppPercent: r.oppPercent,
        extrafields: _decodeMap(r.extrafields),
        tms: r.tms,
        localUpdatedAt: r.localUpdatedAt,
        syncStatus: r.syncStatus,
      );

  ProjectsCompanion _toCompanionFromJson(
    Map<String, Object?> json,
    int? localId,
  ) {
    String? s(String key) {
      final v = json[key];
      if (v == null || v == '' || v == 'null') return null;
      return '$v';
    }

    int? iN(String key) => int.tryParse('${json[key] ?? ''}');
    int i(String key, {int fallback = 0}) =>
        int.tryParse('${json[key] ?? fallback}') ?? fallback;
    double? dN(String key) =>
        double.tryParse('${json[key] ?? ''}'.replaceAll(',', '.'));

    DateTime? d(String key) {
      final raw = json[key];
      if (raw == null) return null;
      final n = int.tryParse('$raw');
      if (n == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(n * 1000);
    }

    return ProjectsCompanion(
      id: localId == null ? const Value.absent() : Value(localId),
      remoteId: Value(int.tryParse('${json['id'] ?? ''}')),
      socidRemote: Value(iN('socid') ?? iN('fk_soc')),
      ref: Value(s('ref')),
      title: Value(s('title') ?? ''),
      description: Value(s('description')),
      status: Value(i('fk_statut') == 0 ? i('status') : i('fk_statut')),
      publicLevel: Value(i('public')),
      fkUserResp: Value(iN('fk_user_resp')),
      dateStart: Value(d('date_start') ?? d('dateo')),
      dateEnd: Value(d('date_end') ?? d('datee')),
      budgetAmount: Value(s('budget_amount')),
      oppStatus: Value(iN('opp_status') ?? iN('fk_opp_status')),
      oppAmount: Value(s('opp_amount')),
      oppPercent: Value(dN('opp_percent')),
      extrafields: Value(_encodeExtrafields(json['array_options'])),
      rawJson: Value(jsonEncode(json)),
      tms: Value(d('tms')),
      localUpdatedAt: Value(DateTime.now()),
      syncStatus: const Value(SyncStatus.synced),
    );
  }

  bool _matchesLocal(Project p, ProjectFilters f) {
    if (f.search.isNotEmpty) {
      final q = f.search.toLowerCase();
      final hay = [p.ref ?? '', p.title].join(' ').toLowerCase();
      if (!hay.contains(q)) return false;
    }
    if (f.statuses.isNotEmpty && !f.statuses.contains(p.status)) {
      return false;
    }
    if (f.thirdPartyRemoteId != null &&
        p.socidRemote != f.thirdPartyRemoteId) {
      return false;
    }
    return true;
  }

  Map<String, Object?> _decodeMap(String json) {
    try {
      final v = jsonDecode(json);
      if (v is Map) return v.cast<String, Object?>();
    } catch (_) {
      // ignoré
    }
    return const {};
  }

  String _encodeExtrafields(Object? raw) {
    if (raw is Map) return jsonEncode(raw);
    return '{}';
  }
}
