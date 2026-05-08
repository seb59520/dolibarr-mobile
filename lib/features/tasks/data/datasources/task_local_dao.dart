import 'dart:convert';

import 'package:dolibarr_mobile/core/storage/app_database.dart';
import 'package:dolibarr_mobile/core/storage/collections/projects.dart';
import 'package:dolibarr_mobile/core/storage/collections/tasks.dart';
import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:dolibarr_mobile/features/tasks/domain/entities/task.dart';
import 'package:dolibarr_mobile/features/tasks/domain/entities/task_filters.dart';
import 'package:drift/drift.dart';

part 'task_local_dao.g.dart';

@DriftAccessor(tables: [Tasks, Projects])
class TaskLocalDao extends DatabaseAccessor<AppDatabase>
    with _$TaskLocalDaoMixin {
  TaskLocalDao(super.attachedDatabase);

  Stream<List<Task>> watchFiltered(TaskFilters f) {
    final query = select(tasks)
      ..orderBy([
        (t) => OrderingTerm.desc(t.dateStart),
        (t) => OrderingTerm(expression: t.label),
      ]);
    return query.watch().map(
          (rows) =>
              rows.map(_fromRow).where((t) => _matchesLocal(t, f)).toList(),
        );
  }

  Stream<Task?> watchById(int localId) {
    return (select(tasks)..where((t) => t.id.equals(localId)))
        .watchSingleOrNull()
        .map((row) => row == null ? null : _fromRow(row));
  }

  /// Stream des tâches d'un projet (par PK locale du projet).
  Stream<List<Task>> watchByProjectLocal(int projectLocalId) {
    final query = select(tasks).join([
      leftOuterJoin(
        projects,
        projects.id.equalsExp(tasks.projectLocal) |
            projects.remoteId.equalsExp(tasks.projectRemote),
      ),
    ])
      ..where(projects.id.equals(projectLocalId))
      ..orderBy([
        OrderingTerm.desc(tasks.dateStart),
        OrderingTerm(expression: tasks.label),
      ]);
    return query.watch().map(
          (rows) =>
              rows.map((row) => _fromRow(row.readTable(tasks))).toList(),
        );
  }

  Future<Task?> findByRemoteId(int remoteId) async {
    final row = await (select(tasks)
          ..where((t) => t.remoteId.equals(remoteId)))
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
    await into(tasks).insertOnConflictUpdate(companion);
  }

  Future<void> upsertManyFromServer(List<Map<String, Object?>> rows) async {
    await transaction(() async {
      for (final r in rows) {
        await upsertFromServer(r);
      }
    });
  }

  Future<int> insertLocal(Task t) async {
    return into(tasks).insert(
      _toCompanionFromEntity(
        t.copyWithSync(SyncStatus.pendingCreate),
        forInsert: true,
      ),
    );
  }

  Future<void> updateLocal(Task t) async {
    final existing = await (select(tasks)
          ..where((row) => row.id.equals(t.localId)))
        .getSingleOrNull();
    if (existing == null) return;
    final nextStatus = existing.syncStatus == SyncStatus.pendingCreate
        ? SyncStatus.pendingCreate
        : SyncStatus.pendingUpdate;
    await (update(tasks)..where((r) => r.id.equals(t.localId))).write(
      _toCompanionFromEntity(
        t.copyWithSync(nextStatus),
        forInsert: false,
      ),
    );
  }

  Future<void> markPendingDelete(int localId) async {
    await (update(tasks)..where((r) => r.id.equals(localId))).write(
      TasksCompanion(
        syncStatus: const Value(SyncStatus.pendingDelete),
        localUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> hardDelete(int localId) {
    return (delete(tasks)..where((r) => r.id.equals(localId))).go();
  }

  Future<void> markSyncedWithRemote({
    required int localId,
    required int remoteId,
    DateTime? tms,
  }) async {
    await (update(tasks)..where((r) => r.id.equals(localId))).write(
      TasksCompanion(
        remoteId: Value(remoteId),
        tms: Value(tms ?? DateTime.now()),
        syncStatus: const Value(SyncStatus.synced),
        localUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> markConflict(int localId) async {
    await (update(tasks)..where((r) => r.id.equals(localId))).write(
      TasksCompanion(
        syncStatus: const Value(SyncStatus.conflict),
        localUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> clearAfterServerDelete(int localId) {
    return (delete(tasks)..where((r) => r.id.equals(localId))).go();
  }

  /// Patche `projectRemote` pour les tâches dont le projet parent
  /// vient d'être créé côté serveur. Appelé par le SyncEngine après
  /// le succès de l'op create du projet (cascade Outbox 2ᵉ niveau).
  Future<int> patchProjectRemoteByParent({
    required int parentLocalId,
    required int parentRemoteId,
  }) async {
    return (update(tasks)
          ..where(
            (t) =>
                t.projectLocal.equals(parentLocalId) &
                t.projectRemote.isNull(),
          ))
        .write(TasksCompanion(projectRemote: Value(parentRemoteId)));
  }

  TasksCompanion _toCompanionFromEntity(
    Task t, {
    required bool forInsert,
  }) {
    return TasksCompanion(
      id: forInsert ? const Value.absent() : Value(t.localId),
      remoteId: Value(t.remoteId),
      projectRemote: Value(t.projectRemote),
      projectLocal: Value(t.projectLocal),
      ref: Value(t.ref),
      label: Value(t.label),
      description: Value(t.description),
      status: Value(t.status.apiValue),
      progress: Value(t.progress),
      plannedHours: Value(t.plannedHours),
      fkUser: Value(t.fkUser),
      dateStart: Value(t.dateStart),
      dateEnd: Value(t.dateEnd),
      extrafields: Value(jsonEncode(t.extrafields)),
      tms: Value(t.tms),
      localUpdatedAt: Value(DateTime.now()),
      syncStatus: Value(t.syncStatus),
    );
  }

  Task _fromRow(TaskRow r) => Task(
        localId: r.id,
        remoteId: r.remoteId,
        projectRemote: r.projectRemote,
        projectLocal: r.projectLocal,
        ref: r.ref,
        label: r.label,
        description: r.description,
        status: TaskStatus.fromInt(r.status),
        progress: r.progress,
        plannedHours: r.plannedHours,
        fkUser: r.fkUser,
        dateStart: r.dateStart,
        dateEnd: r.dateEnd,
        extrafields: _decodeMap(r.extrafields),
        tms: r.tms,
        localUpdatedAt: r.localUpdatedAt,
        syncStatus: r.syncStatus,
      );

  TasksCompanion _toCompanionFromJson(
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

    DateTime? d(String key) {
      final raw = json[key];
      if (raw == null) return null;
      final n = int.tryParse('$raw');
      if (n == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(n * 1000);
    }

    return TasksCompanion(
      id: localId == null ? const Value.absent() : Value(localId),
      remoteId: Value(int.tryParse('${json['id'] ?? ''}')),
      projectRemote: Value(iN('fk_projet') ?? iN('fk_project')),
      ref: Value(s('ref')),
      label: Value(s('label') ?? ''),
      description: Value(s('description')),
      status: Value(i('status')),
      progress: Value(i('progress')),
      plannedHours: Value(s('planned_workload') ?? s('duration_effective')),
      fkUser: Value(iN('fk_user')),
      dateStart: Value(d('date_start') ?? d('dateo')),
      dateEnd: Value(d('date_end') ?? d('datee')),
      extrafields: Value(_encodeExtrafields(json['array_options'])),
      rawJson: Value(jsonEncode(json)),
      tms: Value(d('tms')),
      localUpdatedAt: Value(DateTime.now()),
      syncStatus: const Value(SyncStatus.synced),
    );
  }

  bool _matchesLocal(Task t, TaskFilters f) {
    if (f.search.isNotEmpty) {
      final q = f.search.toLowerCase();
      final hay = [t.ref ?? '', t.label].join(' ').toLowerCase();
      if (!hay.contains(q)) return false;
    }
    if (f.statuses.isNotEmpty && !f.statuses.contains(t.status)) {
      return false;
    }
    if (f.projectRemoteId != null &&
        t.projectRemote != f.projectRemoteId) {
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
