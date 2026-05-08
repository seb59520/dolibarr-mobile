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
