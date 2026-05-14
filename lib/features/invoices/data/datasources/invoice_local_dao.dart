import 'dart:convert';

import 'package:dolibarr_mobile/core/storage/app_database.dart';
import 'package:dolibarr_mobile/core/storage/collections/invoices.dart';
import 'package:dolibarr_mobile/core/storage/collections/third_parties.dart';
import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice_filters.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice_line.dart';
import 'package:drift/drift.dart';

part 'invoice_local_dao.g.dart';

@DriftAccessor(tables: [Invoices, InvoiceLines, ThirdParties])
class InvoiceLocalDao extends DatabaseAccessor<AppDatabase>
    with _$InvoiceLocalDaoMixin {
  InvoiceLocalDao(super.attachedDatabase);

  Stream<List<Invoice>> watchFiltered(InvoiceFilters f) {
    OrderingTerm primary($InvoicesTable t) {
      final mode =
          f.sortDescending ? OrderingMode.desc : OrderingMode.asc;
      return switch (f.sortBy) {
        InvoiceSortBy.dateInvoice =>
          OrderingTerm(expression: t.dateInvoice, mode: mode),
        InvoiceSortBy.dateDue =>
          OrderingTerm(expression: t.dateDue, mode: mode),
        InvoiceSortBy.ref => OrderingTerm(expression: t.ref, mode: mode),
      };
    }

    final query = select(invoices)
      ..orderBy([
        primary,
        (t) => OrderingTerm.desc(t.id),
      ]);
    return query.watch().map(
          (rows) => rows
              .map(_invoiceFromRow)
              .where((i) => _matchesLocal(i, f))
              .toList(),
        );
  }

  Stream<Invoice?> watchById(int localId) {
    return (select(invoices)..where((i) => i.id.equals(localId)))
        .watchSingleOrNull()
        .map((row) => row == null ? null : _invoiceFromRow(row));
  }

  Stream<List<Invoice>> watchByThirdPartyLocal(int thirdPartyLocalId) {
    final query = select(invoices).join([
      leftOuterJoin(
        thirdParties,
        thirdParties.id.equalsExp(invoices.socidLocal) |
            thirdParties.remoteId.equalsExp(invoices.socidRemote),
      ),
    ])
      ..where(thirdParties.id.equals(thirdPartyLocalId))
      ..orderBy([
        OrderingTerm.desc(invoices.dateInvoice),
      ]);
    return query.watch().map(
          (rows) => rows
              .map((row) => _invoiceFromRow(row.readTable(invoices)))
              .toList(),
        );
  }

  Stream<List<InvoiceLine>> watchLinesByInvoiceLocal(int invoiceLocalId) {
    final query = select(invoiceLines).join([
      leftOuterJoin(
        invoices,
        invoices.id.equalsExp(invoiceLines.invoiceLocal) |
            invoices.remoteId.equalsExp(invoiceLines.invoiceRemote),
      ),
    ])
      ..where(invoices.id.equals(invoiceLocalId))
      ..orderBy([
        OrderingTerm(expression: invoiceLines.rang),
        OrderingTerm(expression: invoiceLines.id),
      ]);
    return query.watch().map(
          (rows) => rows
              .map((row) => _lineFromRow(row.readTable(invoiceLines)))
              .toList(),
        );
  }

  Future<Invoice?> findByRemoteId(int remoteId) async {
    final row = await (select(invoices)
          ..where((i) => i.remoteId.equals(remoteId)))
        .getSingleOrNull();
    return row == null ? null : _invoiceFromRow(row);
  }

  /// Upsert depuis le payload Dolibarr (qui inclut potentiellement
  /// la clé `lines` — on la traite séparément via [_upsertLines]).
  Future<void> upsertFromServer(Map<String, Object?> json) async {
    final remoteId = int.tryParse('${json['id'] ?? ''}');
    if (remoteId == null) return;
    final existing = await findByRemoteId(remoteId);
    if (existing != null && existing.syncStatus != SyncStatus.synced) {
      return;
    }
    // Résout le tiers local (`socidLocal`) depuis `socid`/`fk_soc` afin
    // que les UIs qui s'appuient sur `socidLocal` (cartes factures,
    // tuiles dashboard, fiche détail) affichent le nom du client sans
    // attendre une seconde sync.
    final socidRemote =
        int.tryParse('${json['socid'] ?? json['fk_soc'] ?? ''}');
    int? socidLocal;
    if (socidRemote != null) {
      final tp = await (select(thirdParties)
            ..where((t) => t.remoteId.equals(socidRemote)))
          .getSingleOrNull();
      socidLocal = tp?.id;
    }
    await transaction(() async {
      final companion = _toCompanionFromJson(
        json,
        existing?.localId,
        socidLocal: socidLocal,
      );
      await into(invoices).insertOnConflictUpdate(companion);
      // Récupère le localId résolu (upsert peut avoir alloué un id).
      final fresh = await findByRemoteId(remoteId);
      final lines = json['lines'];
      if (fresh != null && lines is List) {
        await _upsertLines(
          invoiceLocalId: fresh.localId,
          invoiceRemoteId: remoteId,
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

  // -------------------------- Header writes --------------------------

  Future<int> insertLocal(Invoice i) async {
    return into(invoices).insert(
      _invoiceCompanionFromEntity(
        i.copyWithSync(SyncStatus.pendingCreate),
        forInsert: true,
      ),
    );
  }

  Future<void> updateLocal(Invoice i) async {
    final existing = await (select(invoices)
          ..where((row) => row.id.equals(i.localId)))
        .getSingleOrNull();
    if (existing == null) return;
    final nextStatus = existing.syncStatus == SyncStatus.pendingCreate
        ? SyncStatus.pendingCreate
        : SyncStatus.pendingUpdate;
    await (update(invoices)..where((r) => r.id.equals(i.localId))).write(
      _invoiceCompanionFromEntity(
        i.copyWithSync(nextStatus),
        forInsert: false,
      ),
    );
  }

  Future<void> markPendingDelete(int localId) async {
    await (update(invoices)..where((r) => r.id.equals(localId))).write(
      InvoicesCompanion(
        syncStatus: const Value(SyncStatus.pendingDelete),
        localUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> hardDelete(int localId) {
    return (delete(invoices)..where((r) => r.id.equals(localId))).go();
  }

  Future<void> markSyncedWithRemote({
    required int localId,
    required int remoteId,
    DateTime? tms,
  }) async {
    await (update(invoices)..where((r) => r.id.equals(localId))).write(
      InvoicesCompanion(
        remoteId: Value(remoteId),
        tms: Value(tms ?? DateTime.now()),
        syncStatus: const Value(SyncStatus.synced),
        localUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> markConflict(int localId) async {
    await (update(invoices)..where((r) => r.id.equals(localId))).write(
      InvoicesCompanion(
        syncStatus: const Value(SyncStatus.conflict),
        localUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> clearAfterServerDelete(int localId) {
    return (delete(invoices)..where((r) => r.id.equals(localId))).go();
  }

  /// Patche `socidRemote` pour les factures dont le tiers parent
  /// vient d'être créé côté serveur. Cascade Outbox 1ᵉʳ niveau
  /// (tiers → facture).
  Future<int> patchSocidRemoteByParent({
    required int parentLocalId,
    required int parentRemoteId,
  }) async {
    return (update(invoices)
          ..where(
            (i) =>
                i.socidLocal.equals(parentLocalId) &
                i.socidRemote.isNull(),
          ))
        .write(InvoicesCompanion(socidRemote: Value(parentRemoteId)));
  }

  // -------------------------- Line writes ----------------------------

  Future<InvoiceLine?> findLineByLocalId(int lineLocalId) async {
    final row = await (select(invoiceLines)
          ..where((l) => l.id.equals(lineLocalId)))
        .getSingleOrNull();
    return row == null ? null : _lineFromRow(row);
  }

  Stream<InvoiceLine?> watchLineById(int lineLocalId) {
    return (select(invoiceLines)..where((l) => l.id.equals(lineLocalId)))
        .watchSingleOrNull()
        .map((row) => row == null ? null : _lineFromRow(row));
  }

  Future<int> insertLocalLine(InvoiceLine line) async {
    return into(invoiceLines).insert(
      _lineCompanionFromEntity(
        line.copyWithSync(SyncStatus.pendingCreate),
        forInsert: true,
      ),
    );
  }

  Future<void> updateLocalLine(InvoiceLine line) async {
    final existing = await (select(invoiceLines)
          ..where((row) => row.id.equals(line.localId)))
        .getSingleOrNull();
    if (existing == null) return;
    final nextStatus = existing.syncStatus == SyncStatus.pendingCreate
        ? SyncStatus.pendingCreate
        : SyncStatus.pendingUpdate;
    await (update(invoiceLines)
          ..where((r) => r.id.equals(line.localId)))
        .write(
      _lineCompanionFromEntity(
        line.copyWithSync(nextStatus),
        forInsert: false,
      ),
    );
  }

  Future<void> markLinePendingDelete(int lineLocalId) async {
    await (update(invoiceLines)..where((r) => r.id.equals(lineLocalId)))
        .write(
      InvoiceLinesCompanion(
        syncStatus: const Value(SyncStatus.pendingDelete),
        localUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> hardDeleteLine(int lineLocalId) {
    return (delete(invoiceLines)..where((r) => r.id.equals(lineLocalId)))
        .go();
  }

  Future<void> markLineSyncedWithRemote({
    required int localId,
    required int remoteId,
    DateTime? tms,
  }) async {
    await (update(invoiceLines)..where((r) => r.id.equals(localId)))
        .write(
      InvoiceLinesCompanion(
        remoteId: Value(remoteId),
        tms: Value(tms ?? DateTime.now()),
        syncStatus: const Value(SyncStatus.synced),
        localUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> markLineConflict(int localId) async {
    await (update(invoiceLines)..where((r) => r.id.equals(localId)))
        .write(
      InvoiceLinesCompanion(
        syncStatus: const Value(SyncStatus.conflict),
        localUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> clearLineAfterServerDelete(int localId) {
    return (delete(invoiceLines)..where((r) => r.id.equals(localId))).go();
  }

  /// Patche `invoiceRemote` pour les lignes dont la facture parente
  /// vient d'être créée côté serveur. Cascade Outbox 2ᵉ niveau
  /// (facture → ligne).
  Future<int> patchInvoiceRemoteByParent({
    required int parentLocalId,
    required int parentRemoteId,
  }) async {
    return (update(invoiceLines)
          ..where(
            (l) =>
                l.invoiceLocal.equals(parentLocalId) &
                l.invoiceRemote.isNull(),
          ))
        .write(
      InvoiceLinesCompanion(invoiceRemote: Value(parentRemoteId)),
    );
  }

  // -------------------------- Mappers --------------------------------

  InvoicesCompanion _invoiceCompanionFromEntity(
    Invoice i, {
    required bool forInsert,
  }) {
    return InvoicesCompanion(
      id: forInsert ? const Value.absent() : Value(i.localId),
      remoteId: Value(i.remoteId),
      socidRemote: Value(i.socidRemote),
      socidLocal: Value(i.socidLocal),
      ref: Value(i.ref),
      refClient: Value(i.refClient),
      type: Value(i.type.apiValue),
      status: Value(i.status.apiValue),
      paye: Value(i.paye),
      dateInvoice: Value(i.dateInvoice),
      dateDue: Value(i.dateDue),
      totalHt: Value(i.totalHt),
      totalTva: Value(i.totalTva),
      totalTtc: Value(i.totalTtc),
      fkModeReglement: Value(i.fkModeReglement),
      fkCondReglement: Value(i.fkCondReglement),
      notePublic: Value(i.notePublic),
      notePrivate: Value(i.notePrivate),
      extrafields: Value(jsonEncode(i.extrafields)),
      tms: Value(i.tms),
      localUpdatedAt: Value(DateTime.now()),
      syncStatus: Value(i.syncStatus),
    );
  }

  InvoiceLinesCompanion _lineCompanionFromEntity(
    InvoiceLine l, {
    required bool forInsert,
  }) {
    return InvoiceLinesCompanion(
      id: forInsert ? const Value.absent() : Value(l.localId),
      remoteId: Value(l.remoteId),
      invoiceRemote: Value(l.invoiceRemote),
      invoiceLocal: Value(l.invoiceLocal),
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

  Future<void> _upsertLines({
    required int invoiceLocalId,
    required int invoiceRemoteId,
    required List<Map<String, Object?>> rawLines,
  }) async {
    final remoteIds = <int>{};
    for (final raw in rawLines) {
      final lineRemoteId = int.tryParse('${raw['id'] ?? raw['rowid'] ?? ''}');
      if (lineRemoteId == null) continue;
      remoteIds.add(lineRemoteId);
      final existing = await (select(invoiceLines)
            ..where((l) => l.remoteId.equals(lineRemoteId)))
          .getSingleOrNull();
      if (existing != null && existing.syncStatus != SyncStatus.synced) {
        continue;
      }
      final companion = _lineCompanionFromJson(
        raw,
        existing?.id,
        invoiceLocalId: invoiceLocalId,
        invoiceRemoteId: invoiceRemoteId,
      );
      await into(invoiceLines).insertOnConflictUpdate(companion);
    }
    // Cleanup : supprime les lignes serveur qui ne sont plus présentes
    // (sauf celles en pendingX local, à conserver).
    if (remoteIds.isEmpty) return;
    final stale = await (select(invoiceLines)
          ..where(
            (l) =>
                l.invoiceRemote.equals(invoiceRemoteId) &
                l.syncStatus.equalsValue(SyncStatus.synced) &
                l.remoteId.isNotIn(remoteIds.toList()),
          ))
        .get();
    for (final s in stale) {
      await (delete(invoiceLines)..where((l) => l.id.equals(s.id))).go();
    }
  }

  Invoice _invoiceFromRow(InvoiceRow r) => Invoice(
        localId: r.id,
        remoteId: r.remoteId,
        socidRemote: r.socidRemote,
        socidLocal: r.socidLocal,
        ref: r.ref,
        refClient: r.refClient,
        type: InvoiceType.fromInt(r.type),
        status: InvoiceStatus.fromInt(r.status, paye: r.paye),
        paye: r.paye,
        dateInvoice: r.dateInvoice,
        dateDue: r.dateDue,
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

  InvoiceLine _lineFromRow(InvoiceLineRow r) => InvoiceLine(
        localId: r.id,
        remoteId: r.remoteId,
        invoiceRemote: r.invoiceRemote,
        invoiceLocal: r.invoiceLocal,
        fkProduct: r.fkProduct,
        label: r.label,
        description: r.description,
        productType: InvoiceLineProductType.fromInt(r.productType),
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

  InvoicesCompanion _toCompanionFromJson(
    Map<String, Object?> json,
    int? localId, {
    int? socidLocal,
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

    return InvoicesCompanion(
      id: localId == null ? const Value.absent() : Value(localId),
      remoteId: Value(int.tryParse('${json['id'] ?? ''}')),
      socidRemote: Value(iN('socid') ?? iN('fk_soc')),
      socidLocal:
          socidLocal == null ? const Value.absent() : Value(socidLocal),
      ref: Value(s('ref')),
      refClient: Value(s('ref_client')),
      type: Value(i('type')),
      status: Value(i('fk_statut') == 0 ? i('status') : i('fk_statut')),
      paye: Value(i('paye')),
      dateInvoice: Value(d('date') ?? d('datef')),
      dateDue: Value(d('date_lim_reglement') ?? d('date_echeance')),
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

  InvoiceLinesCompanion _lineCompanionFromJson(
    Map<String, Object?> json,
    int? localId, {
    required int invoiceLocalId,
    required int invoiceRemoteId,
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

    return InvoiceLinesCompanion(
      id: localId == null ? const Value.absent() : Value(localId),
      remoteId: Value(int.tryParse('${json['id'] ?? json['rowid'] ?? ''}')),
      invoiceLocal: Value(invoiceLocalId),
      invoiceRemote: Value(invoiceRemoteId),
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

  bool _matchesLocal(Invoice i, InvoiceFilters f) {
    if (f.search.isNotEmpty) {
      final q = f.search.toLowerCase();
      final hay = [i.ref ?? '', i.refClient ?? ''].join(' ').toLowerCase();
      if (!hay.contains(q)) return false;
    }
    if (f.statuses.isNotEmpty && !f.statuses.contains(i.status)) {
      return false;
    }
    if (f.thirdPartyRemoteId != null &&
        i.socidRemote != f.thirdPartyRemoteId) {
      return false;
    }
    if (f.unpaidOnly && i.paye == 1) return false;
    if (f.dateFrom != null && i.dateInvoice != null) {
      if (i.dateInvoice!.isBefore(f.dateFrom!)) return false;
    }
    if (f.dateTo != null && i.dateInvoice != null) {
      if (i.dateInvoice!.isAfter(f.dateTo!)) return false;
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
