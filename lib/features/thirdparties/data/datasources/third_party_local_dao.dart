import 'dart:convert';

import 'package:dolibarr_mobile/core/storage/app_database.dart';
import 'package:dolibarr_mobile/core/storage/collections/third_parties.dart';
import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:dolibarr_mobile/features/thirdparties/domain/entities/third_party.dart';
import 'package:dolibarr_mobile/features/thirdparties/domain/entities/third_party_filters.dart';
import 'package:drift/drift.dart';

part 'third_party_local_dao.g.dart';

@DriftAccessor(tables: [ThirdParties])
class ThirdPartyLocalDao extends DatabaseAccessor<AppDatabase>
    with _$ThirdPartyLocalDaoMixin {
  ThirdPartyLocalDao(super.attachedDatabase);

  /// Stream filtré localement. La recherche serveur est complémentaire
  /// (l'utilisateur voit immédiatement le sous-ensemble du cache puis
  /// le résultat serveur fusionne).
  Stream<List<ThirdParty>> watchFiltered(ThirdPartyFilters f) {
    final query = select(thirdParties)
      ..orderBy([
        (t) => OrderingTerm(expression: t.name),
      ]);
    if (f.activeOnly) {
      query.where((t) => t.status.equals(1));
    }
    return query.watch().map(
          (rows) => rows
              .map(_fromRow)
              .where((tp) => _matchesLocal(tp, f))
              .toList(),
        );
  }

  Stream<ThirdParty?> watchById(int localId) {
    return (select(thirdParties)..where((t) => t.id.equals(localId)))
        .watchSingleOrNull()
        .map((row) => row == null ? null : _fromRow(row));
  }

  Future<ThirdParty?> findByRemoteId(int remoteId) async {
    final row = await (select(thirdParties)
          ..where((t) => t.remoteId.equals(remoteId)))
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  /// Insertion / update à partir du JSON brut serveur. Ne touche pas
  /// aux entités en `pendingX` ou `conflict` (cf. SyncEngine Étape 9).
  Future<void> upsertFromServer(Map<String, Object?> json) async {
    final remoteId = int.tryParse('${json['id'] ?? ''}');
    if (remoteId == null) return;
    final existing = await findByRemoteId(remoteId);
    if (existing != null && existing.syncStatus != SyncStatus.synced) {
      return;
    }
    final companion = _toCompanionFromJson(json, existing?.localId);
    await into(thirdParties).insertOnConflictUpdate(companion);
  }

  Future<void> upsertManyFromServer(List<Map<String, Object?>> rows) async {
    await transaction(() async {
      for (final r in rows) {
        await upsertFromServer(r);
      }
    });
  }

  ThirdParty _fromRow(ThirdPartyRow r) => ThirdParty(
        localId: r.id,
        remoteId: r.remoteId,
        name: r.name,
        codeClient: r.codeClient,
        codeFournisseur: r.codeFournisseur,
        clientFlags: r.clientType,
        fournisseur: r.fournisseur != 0,
        status: r.status,
        address: r.address,
        zip: r.zip,
        town: r.town,
        countryCode: r.countryCode,
        phone: r.phone,
        email: r.email,
        url: r.url,
        siren: r.siren,
        siret: r.siret,
        tvaIntra: r.tvaIntra,
        notePublic: r.notePublic,
        notePrivate: r.notePrivate,
        categories: _decodeIntList(r.categoriesJson),
        extrafields: _decodeMap(r.extrafields),
        tms: r.tms,
        localUpdatedAt: r.localUpdatedAt,
        syncStatus: r.syncStatus,
      );

  ThirdPartiesCompanion _toCompanionFromJson(
    Map<String, Object?> json,
    int? localId,
  ) {
    String? s(String key) {
      final v = json[key];
      if (v == null || v == '' || v == 'null') return null;
      return '$v';
    }

    int i(String key, {int fallback = 0}) =>
        int.tryParse('${json[key] ?? fallback}') ?? fallback;

    DateTime? d(String key) {
      final raw = json[key];
      if (raw == null) return null;
      final n = int.tryParse('$raw');
      if (n == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(n * 1000);
    }

    return ThirdPartiesCompanion(
      id: localId == null ? const Value.absent() : Value(localId),
      remoteId: Value(int.tryParse('${json['id'] ?? ''}')),
      name: Value(s('name') ?? s('nom') ?? ''),
      codeClient: Value(s('code_client')),
      codeFournisseur: Value(s('code_fournisseur')),
      clientType: Value(i('client')),
      fournisseur: Value(i('fournisseur')),
      status: Value(i('status', fallback: 1)),
      address: Value(s('address')),
      zip: Value(s('zip')),
      town: Value(s('town')),
      countryCode: Value(s('country_code')),
      phone: Value(s('phone')),
      email: Value(s('email')),
      url: Value(s('url')),
      siren: Value(s('idprof1')),
      siret: Value(s('idprof2')),
      tvaIntra: Value(s('tva_intra')),
      notePublic: Value(s('note_public')),
      notePrivate: Value(s('note_private')),
      categoriesJson: Value(_encodeIntListFromJson(json['categories'])),
      extrafields: Value(_encodeExtrafields(json['array_options'])),
      rawJson: Value(jsonEncode(json)),
      tms: Value(d('tms')),
      localUpdatedAt: Value(DateTime.now()),
      syncStatus: const Value(SyncStatus.synced),
    );
  }

  bool _matchesLocal(ThirdParty t, ThirdPartyFilters f) {
    if (f.search.isNotEmpty) {
      final q = f.search.toLowerCase();
      final hay = [t.name, t.codeClient ?? '', t.town ?? '']
          .join(' ')
          .toLowerCase();
      if (!hay.contains(q)) return false;
    }
    if (f.kinds.isNotEmpty) {
      final ok = f.kinds.any((k) => switch (k) {
            ThirdPartyKind.customer => t.isCustomer,
            ThirdPartyKind.prospect => t.isProspect,
            ThirdPartyKind.supplier => t.isSupplier,
          });
      if (!ok) return false;
    }
    if (f.categoryIds.isNotEmpty) {
      if (!t.categories.any(f.categoryIds.contains)) return false;
    }
    return true;
  }

  List<int> _decodeIntList(String json) {
    try {
      final v = jsonDecode(json);
      if (v is List) {
        return v
            .map((e) => int.tryParse('$e'))
            .whereType<int>()
            .toList();
      }
    } catch (_) {
      // ignoré
    }
    return const [];
  }

  String _encodeIntListFromJson(Object? raw) {
    if (raw is List) {
      final ints = raw
          .map((e) => int.tryParse('${(e is Map) ? e['id'] : e}'))
          .whereType<int>()
          .toList();
      return jsonEncode(ints);
    }
    return '[]';
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
