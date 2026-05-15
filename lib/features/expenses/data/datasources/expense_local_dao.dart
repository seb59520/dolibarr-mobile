import 'dart:convert';

import 'package:dolibarr_mobile/core/storage/app_database.dart';
import 'package:dolibarr_mobile/core/storage/collections/expense_reports.dart';
import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:dolibarr_mobile/features/expenses/domain/entities/expense_filters.dart';
import 'package:dolibarr_mobile/features/expenses/domain/entities/expense_line.dart';
import 'package:dolibarr_mobile/features/expenses/domain/entities/expense_report.dart';
import 'package:dolibarr_mobile/features/expenses/domain/entities/expense_type.dart';
import 'package:drift/drift.dart';

part 'expense_local_dao.g.dart';

@DriftAccessor(tables: [ExpenseReports, ExpenseLines, ExpenseTypes])
class ExpenseLocalDao extends DatabaseAccessor<AppDatabase>
    with _$ExpenseLocalDaoMixin {
  ExpenseLocalDao(super.attachedDatabase);

  // ----------------------- Reads ------------------------------------

  Stream<List<ExpenseReport>> watchFiltered(ExpenseFilters f) {
    OrderingTerm primary($ExpenseReportsTable t) {
      final mode =
          f.sortDescending ? OrderingMode.desc : OrderingMode.asc;
      return switch (f.sortBy) {
        ExpenseSortBy.dateDebut =>
          OrderingTerm(expression: t.dateDebut, mode: mode),
        ExpenseSortBy.dateFin =>
          OrderingTerm(expression: t.dateFin, mode: mode),
        ExpenseSortBy.ref => OrderingTerm(expression: t.ref, mode: mode),
      };
    }

    final query = select(expenseReports)
      ..orderBy([
        primary,
        (t) => OrderingTerm.desc(t.id),
      ]);
    return query.watch().map(
          (rows) => rows
              .map(_reportFromRow)
              .where((r) => _matchesLocal(r, f))
              .toList(),
        );
  }

  Stream<ExpenseReport?> watchById(int localId) {
    return (select(expenseReports)..where((r) => r.id.equals(localId)))
        .watchSingleOrNull()
        .map((row) => row == null ? null : _reportFromRow(row));
  }

  Stream<List<ExpenseLine>> watchLinesByReportLocal(int reportLocalId) {
    final query = select(expenseLines).join([
      leftOuterJoin(
        expenseReports,
        expenseReports.id.equalsExp(expenseLines.expenseReportLocal) |
            expenseReports.remoteId
                .equalsExp(expenseLines.expenseReportRemote),
      ),
    ])
      ..where(expenseReports.id.equals(reportLocalId))
      ..orderBy([
        OrderingTerm(expression: expenseLines.rang),
        OrderingTerm(expression: expenseLines.id),
      ]);
    return query.watch().map(
          (rows) => rows
              .map((row) => _lineFromRow(row.readTable(expenseLines)))
              .toList(),
        );
  }

  Stream<List<ExpenseType>> watchTypes() {
    final query = select(expenseTypes)
      ..orderBy([(t) => OrderingTerm(expression: t.code)]);
    return query.watch().map(
          (rows) => rows.map(_typeFromRow).toList(),
        );
  }

  Future<ExpenseReport?> findByRemoteId(int remoteId) async {
    final row = await (select(expenseReports)
          ..where((r) => r.remoteId.equals(remoteId)))
        .getSingleOrNull();
    return row == null ? null : _reportFromRow(row);
  }

  Future<ExpenseLine?> findLineByLocalId(int lineLocalId) async {
    final row = await (select(expenseLines)
          ..where((l) => l.id.equals(lineLocalId)))
        .getSingleOrNull();
    return row == null ? null : _lineFromRow(row);
  }

  Stream<ExpenseLine?> watchLineById(int lineLocalId) {
    return (select(expenseLines)..where((l) => l.id.equals(lineLocalId)))
        .watchSingleOrNull()
        .map((row) => row == null ? null : _lineFromRow(row));
  }

  /// Lookup id Dolibarr depuis le code (`TF_LUNCH` → 3). Renvoie null
  /// si le cache n'est pas peuplé pour ce code.
  Future<int?> resolveTypeIdByCode(String code) async {
    final row = await (select(expenseTypes)
          ..where((t) => t.code.equals(code)))
        .getSingleOrNull();
    return row?.remoteId;
  }

  // ----------------------- Server upserts ---------------------------

  Future<void> upsertFromServer(Map<String, Object?> json) async {
    final remoteId = int.tryParse('${json['id'] ?? ''}');
    if (remoteId == null) return;
    final existing = await findByRemoteId(remoteId);
    if (existing != null && existing.syncStatus != SyncStatus.synced) {
      return;
    }
    await transaction(() async {
      final companion = _toCompanionFromJson(json, existing?.localId);
      await into(expenseReports).insertOnConflictUpdate(companion);
      final fresh = await findByRemoteId(remoteId);
      final lines = json['lines'];
      if (fresh != null && lines is List) {
        await _upsertLines(
          reportLocalId: fresh.localId,
          reportRemoteId: remoteId,
          rawLines: lines.cast<Map<String, Object?>>(),
        );
      }
    });
  }

  Future<void> upsertManyFromServer(List<Map<String, Object?>> rows) async {
    await transaction(() async {
      for (final r in rows) {
        await upsertFromServer(r);
      }
    });
  }

  Future<void> upsertTypesFromServer(List<Map<String, Object?>> rows) async {
    final now = DateTime.now();
    await transaction(() async {
      for (final raw in rows) {
        final t = ExpenseType.fromJson(raw, fetchedAt: now);
        if (t.code.isEmpty) continue;
        await into(expenseTypes).insertOnConflictUpdate(
          ExpenseTypesCompanion(
            code: Value(t.code),
            remoteId: Value(t.remoteId),
            label: Value(t.label),
            accountancyCode: Value(t.accountancyCode),
            active: Value(t.active),
            fetchedAt: Value(t.fetchedAt),
          ),
        );
      }
    });
  }

  // -------------------------- Header writes --------------------------

  Future<int> insertLocal(ExpenseReport r) async {
    return into(expenseReports).insert(
      _reportCompanionFromEntity(
        r.copyWithSync(SyncStatus.pendingCreate),
        forInsert: true,
      ),
    );
  }

  Future<void> updateLocal(ExpenseReport r) async {
    final existing = await (select(expenseReports)
          ..where((row) => row.id.equals(r.localId)))
        .getSingleOrNull();
    if (existing == null) return;
    final nextStatus = existing.syncStatus == SyncStatus.pendingCreate
        ? SyncStatus.pendingCreate
        : SyncStatus.pendingUpdate;
    await (update(expenseReports)..where((row) => row.id.equals(r.localId)))
        .write(
      _reportCompanionFromEntity(
        r.copyWithSync(nextStatus),
        forInsert: false,
      ),
    );
  }

  Future<void> markPendingDelete(int localId) async {
    await (update(expenseReports)..where((r) => r.id.equals(localId)))
        .write(
      ExpenseReportsCompanion(
        syncStatus: const Value(SyncStatus.pendingDelete),
        localUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> hardDelete(int localId) {
    return (delete(expenseReports)..where((r) => r.id.equals(localId))).go();
  }

  Future<void> markSyncedWithRemote({
    required int localId,
    required int remoteId,
    DateTime? tms,
  }) async {
    await (update(expenseReports)..where((r) => r.id.equals(localId)))
        .write(
      ExpenseReportsCompanion(
        remoteId: Value(remoteId),
        tms: Value(tms ?? DateTime.now()),
        syncStatus: const Value(SyncStatus.synced),
        localUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> markConflict(int localId) async {
    await (update(expenseReports)..where((r) => r.id.equals(localId)))
        .write(
      ExpenseReportsCompanion(
        syncStatus: const Value(SyncStatus.conflict),
        localUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> clearAfterServerDelete(int localId) {
    return (delete(expenseReports)..where((r) => r.id.equals(localId))).go();
  }

  // -------------------------- Line writes ----------------------------

  Future<int> insertLocalLine(ExpenseLine line) async {
    return into(expenseLines).insert(
      _lineCompanionFromEntity(
        line.copyWithSync(SyncStatus.pendingCreate),
        forInsert: true,
      ),
    );
  }

  Future<void> updateLocalLine(ExpenseLine line) async {
    final existing = await (select(expenseLines)
          ..where((row) => row.id.equals(line.localId)))
        .getSingleOrNull();
    if (existing == null) return;
    final nextStatus = existing.syncStatus == SyncStatus.pendingCreate
        ? SyncStatus.pendingCreate
        : SyncStatus.pendingUpdate;
    await (update(expenseLines)..where((r) => r.id.equals(line.localId)))
        .write(
      _lineCompanionFromEntity(
        line.copyWithSync(nextStatus),
        forInsert: false,
      ),
    );
  }

  Future<void> markLinePendingDelete(int lineLocalId) async {
    await (update(expenseLines)..where((r) => r.id.equals(lineLocalId)))
        .write(
      ExpenseLinesCompanion(
        syncStatus: const Value(SyncStatus.pendingDelete),
        localUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> hardDeleteLine(int lineLocalId) {
    return (delete(expenseLines)..where((r) => r.id.equals(lineLocalId)))
        .go();
  }

  Future<void> markLineSyncedWithRemote({
    required int localId,
    required int remoteId,
    DateTime? tms,
  }) async {
    await (update(expenseLines)..where((r) => r.id.equals(localId))).write(
      ExpenseLinesCompanion(
        remoteId: Value(remoteId),
        tms: Value(tms ?? DateTime.now()),
        syncStatus: const Value(SyncStatus.synced),
        localUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> markLineConflict(int localId) async {
    await (update(expenseLines)..where((r) => r.id.equals(localId))).write(
      ExpenseLinesCompanion(
        syncStatus: const Value(SyncStatus.conflict),
        localUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> clearLineAfterServerDelete(int localId) {
    return (delete(expenseLines)..where((r) => r.id.equals(localId))).go();
  }

  /// Cascade note→ligne : patche `expenseReportRemote` après push parent.
  Future<int> patchExpenseReportRemoteByParent({
    required int parentLocalId,
    required int parentRemoteId,
  }) async {
    return (update(expenseLines)
          ..where(
            (l) =>
                l.expenseReportLocal.equals(parentLocalId) &
                l.expenseReportRemote.isNull(),
          ))
        .write(
      ExpenseLinesCompanion(
        expenseReportRemote: Value(parentRemoteId),
      ),
    );
  }

  // -------------------------- Mappers --------------------------------

  ExpenseReportsCompanion _reportCompanionFromEntity(
    ExpenseReport r, {
    required bool forInsert,
  }) {
    return ExpenseReportsCompanion(
      id: forInsert ? const Value.absent() : Value(r.localId),
      remoteId: Value(r.remoteId),
      ref: Value(r.ref),
      status: Value(r.status.apiValue),
      fkUserAuthor: Value(r.fkUserAuthor),
      fkUserValid: Value(r.fkUserValid),
      dateDebut: Value(r.dateDebut),
      dateFin: Value(r.dateFin),
      totalHt: Value(r.totalHt),
      totalTva: Value(r.totalTva),
      totalTtc: Value(r.totalTtc),
      notePublic: Value(r.notePublic),
      notePrivate: Value(r.notePrivate),
      extrafields: Value(jsonEncode(r.extrafields)),
      tms: Value(r.tms),
      localUpdatedAt: Value(DateTime.now()),
      syncStatus: Value(r.syncStatus),
    );
  }

  ExpenseLinesCompanion _lineCompanionFromEntity(
    ExpenseLine l, {
    required bool forInsert,
  }) {
    return ExpenseLinesCompanion(
      id: forInsert ? const Value.absent() : Value(l.localId),
      remoteId: Value(l.remoteId),
      expenseReportRemote: Value(l.expenseReportRemote),
      expenseReportLocal: Value(l.expenseReportLocal),
      fkCTypeFees: Value(l.fkCTypeFees),
      codeCTypeFees: Value(l.codeCTypeFees),
      date: Value(l.date),
      comments: Value(l.comments),
      qty: Value(l.qty),
      valueUnit: Value(l.valueUnit),
      tvaTx: Value(l.tvaTx),
      totalHt: Value(l.totalHt),
      totalTva: Value(l.totalTva),
      totalTtc: Value(l.totalTtc),
      projetId: Value(l.projetId),
      rang: Value(l.rang),
      tms: Value(l.tms),
      localUpdatedAt: Value(DateTime.now()),
      syncStatus: Value(l.syncStatus),
    );
  }

  Future<void> _upsertLines({
    required int reportLocalId,
    required int reportRemoteId,
    required List<Map<String, Object?>> rawLines,
  }) async {
    final remoteIds = <int>{};
    for (final raw in rawLines) {
      final lineRemoteId =
          int.tryParse('${raw['id'] ?? raw['rowid'] ?? ''}');
      if (lineRemoteId == null) continue;
      remoteIds.add(lineRemoteId);
      final existing = await (select(expenseLines)
            ..where((l) => l.remoteId.equals(lineRemoteId)))
          .getSingleOrNull();
      if (existing != null && existing.syncStatus != SyncStatus.synced) {
        continue;
      }
      final companion = _lineCompanionFromJson(
        raw,
        existing?.id,
        reportLocalId: reportLocalId,
        reportRemoteId: reportRemoteId,
      );
      await into(expenseLines).insertOnConflictUpdate(companion);
    }
    // Cleanup côté serveur : retire les lignes qui ne sont plus là.
    if (remoteIds.isEmpty) return;
    final stale = await (select(expenseLines)
          ..where(
            (l) =>
                l.expenseReportRemote.equals(reportRemoteId) &
                l.syncStatus.equalsValue(SyncStatus.synced) &
                l.remoteId.isNotIn(remoteIds.toList()),
          ))
        .get();
    for (final s in stale) {
      await (delete(expenseLines)..where((l) => l.id.equals(s.id))).go();
    }
  }

  ExpenseReport _reportFromRow(ExpenseReportRow r) => ExpenseReport(
        localId: r.id,
        remoteId: r.remoteId,
        ref: r.ref,
        status: ExpenseReportStatus.fromInt(r.status),
        fkUserAuthor: r.fkUserAuthor,
        fkUserValid: r.fkUserValid,
        dateDebut: r.dateDebut,
        dateFin: r.dateFin,
        totalHt: r.totalHt,
        totalTva: r.totalTva,
        totalTtc: r.totalTtc,
        notePublic: r.notePublic,
        notePrivate: r.notePrivate,
        extrafields: _decodeMap(r.extrafields),
        tms: r.tms,
        localUpdatedAt: r.localUpdatedAt,
        syncStatus: r.syncStatus,
      );

  ExpenseLine _lineFromRow(ExpenseLineRow r) => ExpenseLine(
        localId: r.id,
        remoteId: r.remoteId,
        expenseReportRemote: r.expenseReportRemote,
        expenseReportLocal: r.expenseReportLocal,
        fkCTypeFees: r.fkCTypeFees,
        codeCTypeFees: r.codeCTypeFees,
        date: r.date,
        comments: r.comments,
        qty: r.qty,
        valueUnit: r.valueUnit,
        tvaTx: r.tvaTx,
        totalHt: r.totalHt,
        totalTva: r.totalTva,
        totalTtc: r.totalTtc,
        projetId: r.projetId,
        rang: r.rang,
        tms: r.tms,
        localUpdatedAt: r.localUpdatedAt,
        syncStatus: r.syncStatus,
      );

  ExpenseType _typeFromRow(ExpenseTypeRow r) => ExpenseType(
        code: r.code,
        remoteId: r.remoteId,
        label: r.label,
        accountancyCode: r.accountancyCode,
        active: r.active,
        fetchedAt: r.fetchedAt,
      );

  ExpenseReportsCompanion _toCompanionFromJson(
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
      if (raw == null || raw == '' || raw == 'null') return null;
      final n = int.tryParse('$raw');
      if (n != null) {
        return DateTime.fromMillisecondsSinceEpoch(n * 1000);
      }
      // Format SQL : YYYY-MM-DD ou YYYY-MM-DD HH:MM:SS
      return DateTime.tryParse('$raw'.replaceFirst(' ', 'T'));
    }

    return ExpenseReportsCompanion(
      id: localId == null ? const Value.absent() : Value(localId),
      remoteId: Value(int.tryParse('${json['id'] ?? ''}')),
      ref: Value(s('ref')),
      // Le détail expose `status`, la liste expose `fk_statut`.
      status: Value(i('status', fallback: i('fk_statut'))),
      fkUserAuthor: Value(iN('fk_user_author')),
      fkUserValid: Value(iN('fk_user_valid')),
      dateDebut: Value(d('date_debut')),
      dateFin: Value(d('date_fin')),
      totalHt: Value(s('total_ht')),
      totalTva: Value(s('total_tva')),
      totalTtc: Value(s('total_ttc')),
      notePublic: Value(s('note_public')),
      notePrivate: Value(s('note_private')),
      extrafields: Value(_encodeExtrafields(json['array_options'])),
      rawJson: Value(jsonEncode(json)),
      tms: Value(d('tms')),
      localUpdatedAt: Value(DateTime.now()),
      syncStatus: const Value(SyncStatus.synced),
    );
  }

  ExpenseLinesCompanion _lineCompanionFromJson(
    Map<String, Object?> json,
    int? localId, {
    required int reportLocalId,
    required int reportRemoteId,
  }) {
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
      if (raw == null || raw == '' || raw == 'null') return null;
      final n = int.tryParse('$raw');
      if (n != null) {
        return DateTime.fromMillisecondsSinceEpoch(n * 1000);
      }
      return DateTime.tryParse('$raw'.replaceFirst(' ', 'T'));
    }

    return ExpenseLinesCompanion(
      id: localId == null ? const Value.absent() : Value(localId),
      remoteId: Value(int.tryParse('${json['id'] ?? json['rowid'] ?? ''}')),
      expenseReportLocal: Value(reportLocalId),
      expenseReportRemote: Value(reportRemoteId),
      fkCTypeFees: Value(iN('fk_c_type_fees')),
      codeCTypeFees: Value(s('code_type_fees') ?? s('type_fees_code')),
      date: Value(d('date')),
      comments: Value(s('comments') ?? s('comment')),
      qty: Value(s('qty') ?? '1'),
      valueUnit: Value(s('value_unit')),
      tvaTx: Value(s('vatrate') ?? s('tva_tx')),
      totalHt: Value(s('total_ht')),
      totalTva: Value(s('total_tva')),
      totalTtc: Value(s('total_ttc')),
      projetId: Value(iN('fk_project') ?? iN('projet_id')),
      rang: Value(i('rang')),
      rawJson: Value(jsonEncode(json)),
      tms: Value(d('tms')),
      localUpdatedAt: Value(DateTime.now()),
      syncStatus: const Value(SyncStatus.synced),
    );
  }

  bool _matchesLocal(ExpenseReport r, ExpenseFilters f) {
    if (f.search.isNotEmpty) {
      final q = f.search.toLowerCase();
      if (!(r.ref ?? '').toLowerCase().contains(q)) return false;
    }
    if (f.statuses.isNotEmpty && !f.statuses.contains(r.status)) {
      return false;
    }
    if (f.fkUserAuthor != null && r.fkUserAuthor != f.fkUserAuthor) {
      return false;
    }
    if (f.dateFrom != null && r.dateDebut != null) {
      if (r.dateDebut!.isBefore(f.dateFrom!)) return false;
    }
    if (f.dateTo != null && r.dateDebut != null) {
      if (r.dateDebut!.isAfter(f.dateTo!)) return false;
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
