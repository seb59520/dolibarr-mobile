import 'dart:convert';

import 'package:dolibarr_mobile/core/storage/app_database.dart';
import 'package:dolibarr_mobile/core/storage/collections/proposals.dart';
import 'package:dolibarr_mobile/core/storage/collections/third_parties.dart';
import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:dolibarr_mobile/features/proposals/domain/entities/proposal.dart';
import 'package:dolibarr_mobile/features/proposals/domain/entities/proposal_filters.dart';
import 'package:dolibarr_mobile/features/proposals/domain/entities/proposal_line.dart';
import 'package:drift/drift.dart';

part 'proposal_local_dao.g.dart';

@DriftAccessor(tables: [Proposals, ProposalLines, ThirdParties])
class ProposalLocalDao extends DatabaseAccessor<AppDatabase>
    with _$ProposalLocalDaoMixin {
  ProposalLocalDao(super.attachedDatabase);

  Stream<List<Proposal>> watchFiltered(ProposalFilters f) {
    final query = select(proposals)
      ..orderBy([
        (t) => OrderingTerm.desc(t.dateProposal),
        (t) => OrderingTerm.desc(t.id),
      ]);
    return query.watch().map(
          (rows) => rows
              .map(_proposalFromRow)
              .where((p) => _matchesLocal(p, f))
              .toList(),
        );
  }

  Stream<Proposal?> watchById(int localId) {
    return (select(proposals)..where((p) => p.id.equals(localId)))
        .watchSingleOrNull()
        .map((row) => row == null ? null : _proposalFromRow(row));
  }

  Stream<List<Proposal>> watchByThirdPartyLocal(int thirdPartyLocalId) {
    final query = select(proposals).join([
      leftOuterJoin(
        thirdParties,
        thirdParties.id.equalsExp(proposals.socidLocal) |
            thirdParties.remoteId.equalsExp(proposals.socidRemote),
      ),
    ])
      ..where(thirdParties.id.equals(thirdPartyLocalId))
      ..orderBy([
        OrderingTerm.desc(proposals.dateProposal),
      ]);
    return query.watch().map(
          (rows) => rows
              .map((row) => _proposalFromRow(row.readTable(proposals)))
              .toList(),
        );
  }

  Stream<List<ProposalLine>> watchLinesByProposalLocal(
    int proposalLocalId,
  ) {
    final query = select(proposalLines).join([
      leftOuterJoin(
        proposals,
        proposals.id.equalsExp(proposalLines.proposalLocal) |
            proposals.remoteId.equalsExp(proposalLines.proposalRemote),
      ),
    ])
      ..where(proposals.id.equals(proposalLocalId))
      ..orderBy([
        OrderingTerm(expression: proposalLines.rang),
        OrderingTerm(expression: proposalLines.id),
      ]);
    return query.watch().map(
          (rows) => rows
              .map((row) => _lineFromRow(row.readTable(proposalLines)))
              .toList(),
        );
  }

  Future<Proposal?> findByRemoteId(int remoteId) async {
    final row = await (select(proposals)
          ..where((p) => p.remoteId.equals(remoteId)))
        .getSingleOrNull();
    return row == null ? null : _proposalFromRow(row);
  }

  Future<void> upsertFromServer(Map<String, Object?> json) async {
    final remoteId = int.tryParse('${json['id'] ?? ''}');
    if (remoteId == null) return;
    final existing = await findByRemoteId(remoteId);
    if (existing != null && existing.syncStatus != SyncStatus.synced) {
      return;
    }
    await transaction(() async {
      final companion = _proposalCompanionFromJson(json, existing?.localId);
      await into(proposals).insertOnConflictUpdate(companion);
      final fresh = await findByRemoteId(remoteId);
      final lines = json['lines'];
      if (fresh != null && lines is List) {
        await _upsertLines(
          proposalLocalId: fresh.localId,
          proposalRemoteId: remoteId,
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

  Future<void> _upsertLines({
    required int proposalLocalId,
    required int proposalRemoteId,
    required List<Map<String, Object?>> rawLines,
  }) async {
    final remoteIds = <int>{};
    for (final raw in rawLines) {
      final lineRemoteId = int.tryParse('${raw['id'] ?? raw['rowid'] ?? ''}');
      if (lineRemoteId == null) continue;
      remoteIds.add(lineRemoteId);
      final existing = await (select(proposalLines)
            ..where((l) => l.remoteId.equals(lineRemoteId)))
          .getSingleOrNull();
      if (existing != null && existing.syncStatus != SyncStatus.synced) {
        continue;
      }
      final companion = _lineCompanionFromJson(
        raw,
        existing?.id,
        proposalLocalId: proposalLocalId,
        proposalRemoteId: proposalRemoteId,
      );
      await into(proposalLines).insertOnConflictUpdate(companion);
    }
    if (remoteIds.isEmpty) return;
    final stale = await (select(proposalLines)
          ..where(
            (l) =>
                l.proposalRemote.equals(proposalRemoteId) &
                l.syncStatus.equalsValue(SyncStatus.synced) &
                l.remoteId.isNotIn(remoteIds.toList()),
          ))
        .get();
    for (final s in stale) {
      await (delete(proposalLines)..where((l) => l.id.equals(s.id))).go();
    }
  }

  // -------------------------- Header writes --------------------------

  Future<int> insertLocal(Proposal p) async {
    return into(proposals).insert(
      _proposalCompanionFromEntity(
        p.copyWithSync(SyncStatus.pendingCreate),
        forInsert: true,
      ),
    );
  }

  Future<void> updateLocal(Proposal p) async {
    final existing = await (select(proposals)
          ..where((row) => row.id.equals(p.localId)))
        .getSingleOrNull();
    if (existing == null) return;
    final nextStatus = existing.syncStatus == SyncStatus.pendingCreate
        ? SyncStatus.pendingCreate
        : SyncStatus.pendingUpdate;
    await (update(proposals)..where((r) => r.id.equals(p.localId))).write(
      _proposalCompanionFromEntity(
        p.copyWithSync(nextStatus),
        forInsert: false,
      ),
    );
  }

  Future<void> markPendingDelete(int localId) async {
    await (update(proposals)..where((r) => r.id.equals(localId))).write(
      ProposalsCompanion(
        syncStatus: const Value(SyncStatus.pendingDelete),
        localUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> hardDelete(int localId) {
    return (delete(proposals)..where((r) => r.id.equals(localId))).go();
  }

  Future<void> markSyncedWithRemote({
    required int localId,
    required int remoteId,
    DateTime? tms,
  }) async {
    await (update(proposals)..where((r) => r.id.equals(localId))).write(
      ProposalsCompanion(
        remoteId: Value(remoteId),
        tms: Value(tms ?? DateTime.now()),
        syncStatus: const Value(SyncStatus.synced),
        localUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> markConflict(int localId) async {
    await (update(proposals)..where((r) => r.id.equals(localId))).write(
      ProposalsCompanion(
        syncStatus: const Value(SyncStatus.conflict),
        localUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> clearAfterServerDelete(int localId) {
    return (delete(proposals)..where((r) => r.id.equals(localId))).go();
  }

  /// Cascade tiers→devis : patche `socidRemote` après push du parent.
  Future<int> patchSocidRemoteByParent({
    required int parentLocalId,
    required int parentRemoteId,
  }) async {
    return (update(proposals)
          ..where(
            (p) =>
                p.socidLocal.equals(parentLocalId) &
                p.socidRemote.isNull(),
          ))
        .write(ProposalsCompanion(socidRemote: Value(parentRemoteId)));
  }

  // -------------------------- Line writes ----------------------------

  Future<ProposalLine?> findLineByLocalId(int lineLocalId) async {
    final row = await (select(proposalLines)
          ..where((l) => l.id.equals(lineLocalId)))
        .getSingleOrNull();
    return row == null ? null : _lineFromRow(row);
  }

  Stream<ProposalLine?> watchLineById(int lineLocalId) {
    return (select(proposalLines)..where((l) => l.id.equals(lineLocalId)))
        .watchSingleOrNull()
        .map((row) => row == null ? null : _lineFromRow(row));
  }

  Future<int> insertLocalLine(ProposalLine line) async {
    return into(proposalLines).insert(
      _lineCompanionFromEntity(
        line.copyWithSync(SyncStatus.pendingCreate),
        forInsert: true,
      ),
    );
  }

  Future<void> updateLocalLine(ProposalLine line) async {
    final existing = await (select(proposalLines)
          ..where((row) => row.id.equals(line.localId)))
        .getSingleOrNull();
    if (existing == null) return;
    final nextStatus = existing.syncStatus == SyncStatus.pendingCreate
        ? SyncStatus.pendingCreate
        : SyncStatus.pendingUpdate;
    await (update(proposalLines)
          ..where((r) => r.id.equals(line.localId)))
        .write(
      _lineCompanionFromEntity(
        line.copyWithSync(nextStatus),
        forInsert: false,
      ),
    );
  }

  Future<void> markLinePendingDelete(int lineLocalId) async {
    await (update(proposalLines)..where((r) => r.id.equals(lineLocalId)))
        .write(
      ProposalLinesCompanion(
        syncStatus: const Value(SyncStatus.pendingDelete),
        localUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> hardDeleteLine(int lineLocalId) {
    return (delete(proposalLines)..where((r) => r.id.equals(lineLocalId)))
        .go();
  }

  Future<void> markLineSyncedWithRemote({
    required int localId,
    required int remoteId,
    DateTime? tms,
  }) async {
    await (update(proposalLines)..where((r) => r.id.equals(localId)))
        .write(
      ProposalLinesCompanion(
        remoteId: Value(remoteId),
        tms: Value(tms ?? DateTime.now()),
        syncStatus: const Value(SyncStatus.synced),
        localUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> markLineConflict(int localId) async {
    await (update(proposalLines)..where((r) => r.id.equals(localId)))
        .write(
      ProposalLinesCompanion(
        syncStatus: const Value(SyncStatus.conflict),
        localUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> clearLineAfterServerDelete(int localId) {
    return (delete(proposalLines)..where((r) => r.id.equals(localId)))
        .go();
  }

  /// Cascade devis→ligne : patche `proposalRemote` après push du parent.
  Future<int> patchProposalRemoteByParent({
    required int parentLocalId,
    required int parentRemoteId,
  }) async {
    return (update(proposalLines)
          ..where(
            (l) =>
                l.proposalLocal.equals(parentLocalId) &
                l.proposalRemote.isNull(),
          ))
        .write(
      ProposalLinesCompanion(proposalRemote: Value(parentRemoteId)),
    );
  }

  // -------------------------- Mappers --------------------------------

  ProposalsCompanion _proposalCompanionFromEntity(
    Proposal p, {
    required bool forInsert,
  }) {
    return ProposalsCompanion(
      id: forInsert ? const Value.absent() : Value(p.localId),
      remoteId: Value(p.remoteId),
      socidRemote: Value(p.socidRemote),
      socidLocal: Value(p.socidLocal),
      ref: Value(p.ref),
      refClient: Value(p.refClient),
      status: Value(p.status.apiValue),
      dateProposal: Value(p.dateProposal),
      dateEnd: Value(p.dateEnd),
      totalHt: Value(p.totalHt),
      totalTva: Value(p.totalTva),
      totalTtc: Value(p.totalTtc),
      fkModeReglement: Value(p.fkModeReglement),
      fkCondReglement: Value(p.fkCondReglement),
      notePublic: Value(p.notePublic),
      notePrivate: Value(p.notePrivate),
      extrafields: Value(jsonEncode(p.extrafields)),
      tms: Value(p.tms),
      localUpdatedAt: Value(DateTime.now()),
      syncStatus: Value(p.syncStatus),
    );
  }

  ProposalLinesCompanion _lineCompanionFromEntity(
    ProposalLine l, {
    required bool forInsert,
  }) {
    return ProposalLinesCompanion(
      id: forInsert ? const Value.absent() : Value(l.localId),
      remoteId: Value(l.remoteId),
      proposalRemote: Value(l.proposalRemote),
      proposalLocal: Value(l.proposalLocal),
      fkProduct: Value(l.fkProduct),
      label: Value(l.label),
      description: Value(l.description),
      productType: Value(l.productType.apiValue),
      qty: Value(l.qty),
      subprice: Value(l.subprice),
      tvaTx: Value(l.tvaTx),
      remisePercent: Value(l.remisePercent),
      totalHt: Value(l.totalHt),
      totalTva: Value(l.totalTva),
      totalTtc: Value(l.totalTtc),
      rang: Value(l.rang),
      extrafields: Value(jsonEncode(l.extrafields)),
      tms: Value(l.tms),
      localUpdatedAt: Value(DateTime.now()),
      syncStatus: Value(l.syncStatus),
    );
  }

  Proposal _proposalFromRow(ProposalRow r) => Proposal(
        localId: r.id,
        remoteId: r.remoteId,
        socidRemote: r.socidRemote,
        socidLocal: r.socidLocal,
        ref: r.ref,
        refClient: r.refClient,
        status: ProposalStatus.fromInt(r.status),
        dateProposal: r.dateProposal,
        dateEnd: r.dateEnd,
        totalHt: r.totalHt,
        totalTva: r.totalTva,
        totalTtc: r.totalTtc,
        fkModeReglement: r.fkModeReglement,
        fkCondReglement: r.fkCondReglement,
        notePublic: r.notePublic,
        notePrivate: r.notePrivate,
        extrafields: _decodeMap(r.extrafields),
        tms: r.tms,
        localUpdatedAt: r.localUpdatedAt,
        syncStatus: r.syncStatus,
      );

  ProposalLine _lineFromRow(ProposalLineRow r) => ProposalLine(
        localId: r.id,
        remoteId: r.remoteId,
        proposalRemote: r.proposalRemote,
        proposalLocal: r.proposalLocal,
        fkProduct: r.fkProduct,
        label: r.label,
        description: r.description,
        productType: ProposalLineProductType.fromInt(r.productType),
        qty: r.qty,
        subprice: r.subprice,
        tvaTx: r.tvaTx,
        remisePercent: r.remisePercent,
        totalHt: r.totalHt,
        totalTva: r.totalTva,
        totalTtc: r.totalTtc,
        rang: r.rang,
        extrafields: _decodeMap(r.extrafields),
        tms: r.tms,
        localUpdatedAt: r.localUpdatedAt,
        syncStatus: r.syncStatus,
      );

  ProposalsCompanion _proposalCompanionFromJson(
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

    return ProposalsCompanion(
      id: localId == null ? const Value.absent() : Value(localId),
      remoteId: Value(int.tryParse('${json['id'] ?? ''}')),
      socidRemote: Value(iN('socid') ?? iN('fk_soc')),
      ref: Value(s('ref')),
      refClient: Value(s('ref_client')),
      status: Value(i('fk_statut') == 0 ? i('status') : i('fk_statut')),
      dateProposal: Value(d('datep') ?? d('date')),
      dateEnd: Value(d('fin_validite') ?? d('date_fin_validite')),
      totalHt: Value(s('total_ht')),
      totalTva: Value(s('total_tva')),
      totalTtc: Value(s('total_ttc')),
      fkModeReglement:
          Value(iN('fk_mode_reglement') ?? iN('mode_reglement_id')),
      fkCondReglement:
          Value(iN('fk_cond_reglement') ?? iN('cond_reglement_id')),
      notePublic: Value(s('note_public')),
      notePrivate: Value(s('note_private')),
      extrafields: Value(_encodeExtrafields(json['array_options'])),
      rawJson: Value(jsonEncode(json)),
      tms: Value(d('tms')),
      localUpdatedAt: Value(DateTime.now()),
      syncStatus: const Value(SyncStatus.synced),
    );
  }

  ProposalLinesCompanion _lineCompanionFromJson(
    Map<String, Object?> json,
    int? localId, {
    required int proposalLocalId,
    required int proposalRemoteId,
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
      if (raw == null) return null;
      final n = int.tryParse('$raw');
      if (n == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(n * 1000);
    }

    return ProposalLinesCompanion(
      id: localId == null ? const Value.absent() : Value(localId),
      remoteId: Value(int.tryParse('${json['id'] ?? json['rowid'] ?? ''}')),
      proposalLocal: Value(proposalLocalId),
      proposalRemote: Value(proposalRemoteId),
      fkProduct: Value(iN('fk_product')),
      label: Value(s('label')),
      description: Value(s('description') ?? s('desc')),
      productType: Value(i('product_type')),
      qty: Value(s('qty') ?? '1'),
      subprice: Value(s('subprice')),
      tvaTx: Value(s('tva_tx')),
      remisePercent: Value(s('remise_percent')),
      totalHt: Value(s('total_ht')),
      totalTva: Value(s('total_tva')),
      totalTtc: Value(s('total_ttc')),
      rang: Value(i('rang')),
      extrafields: Value(_encodeExtrafields(json['array_options'])),
      tms: Value(d('tms')),
      localUpdatedAt: Value(DateTime.now()),
      syncStatus: const Value(SyncStatus.synced),
    );
  }

  bool _matchesLocal(Proposal p, ProposalFilters f) {
    if (f.search.isNotEmpty) {
      final q = f.search.toLowerCase();
      final hay =
          [p.ref ?? '', p.refClient ?? ''].join(' ').toLowerCase();
      if (!hay.contains(q)) return false;
    }
    if (f.statuses.isNotEmpty && !f.statuses.contains(p.status)) {
      return false;
    }
    if (f.thirdPartyRemoteId != null &&
        p.socidRemote != f.thirdPartyRemoteId) {
      return false;
    }
    if (f.dateFrom != null && p.dateProposal != null) {
      if (p.dateProposal!.isBefore(f.dateFrom!)) return false;
    }
    if (f.dateTo != null && p.dateProposal != null) {
      if (p.dateProposal!.isAfter(f.dateTo!)) return false;
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
