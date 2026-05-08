import 'dart:convert';

import 'package:dolibarr_mobile/core/storage/app_database.dart';
import 'package:dolibarr_mobile/core/storage/collections/contacts.dart';
import 'package:dolibarr_mobile/core/storage/collections/third_parties.dart';
import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:dolibarr_mobile/features/contacts/domain/entities/contact.dart';
import 'package:dolibarr_mobile/features/contacts/domain/entities/contact_filters.dart';
import 'package:drift/drift.dart';

part 'contact_local_dao.g.dart';

@DriftAccessor(tables: [Contacts, ThirdParties])
class ContactLocalDao extends DatabaseAccessor<AppDatabase>
    with _$ContactLocalDaoMixin {
  ContactLocalDao(super.attachedDatabase);

  Stream<List<Contact>> watchFiltered(ContactFilters f) {
    final query = select(contacts)
      ..orderBy([
        (t) => OrderingTerm(expression: t.lastname),
        (t) => OrderingTerm(expression: t.firstname),
      ]);
    return query.watch().map(
          (rows) => rows
              .map(_fromRow)
              .where((c) => _matchesLocal(c, f))
              .toList(),
        );
  }

  Stream<Contact?> watchById(int localId) {
    return (select(contacts)..where((c) => c.id.equals(localId)))
        .watchSingleOrNull()
        .map((row) => row == null ? null : _fromRow(row));
  }

  /// Stream des contacts d'un tiers via son `localId` (matche
  /// `socidLocal` direct ou `socidRemote == thirdParty.remoteId`).
  Stream<List<Contact>> watchByThirdPartyLocal(int thirdPartyLocalId) {
    final query = select(contacts).join([
      leftOuterJoin(
        thirdParties,
        thirdParties.id.equalsExp(contacts.socidLocal) |
            thirdParties.remoteId.equalsExp(contacts.socidRemote),
      ),
    ])
      ..where(thirdParties.id.equals(thirdPartyLocalId))
      ..orderBy([
        OrderingTerm(expression: contacts.lastname),
        OrderingTerm(expression: contacts.firstname),
      ]);
    return query.watch().map(
          (rows) =>
              rows.map((row) => _fromRow(row.readTable(contacts))).toList(),
        );
  }

  Future<Contact?> findByRemoteId(int remoteId) async {
    final row = await (select(contacts)
          ..where((c) => c.remoteId.equals(remoteId)))
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
    await into(contacts).insertOnConflictUpdate(companion);
  }

  Future<void> upsertManyFromServer(List<Map<String, Object?>> rows) async {
    await transaction(() async {
      for (final r in rows) {
        await upsertFromServer(r);
      }
    });
  }

  Future<int> insertLocal(Contact c) async {
    return into(contacts).insert(
      _toCompanionFromEntity(
        c.copyWithSync(SyncStatus.pendingCreate),
        forInsert: true,
      ),
    );
  }

  Future<void> updateLocal(Contact c) async {
    final existing = await (select(contacts)
          ..where((row) => row.id.equals(c.localId)))
        .getSingleOrNull();
    if (existing == null) return;
    final nextStatus = existing.syncStatus == SyncStatus.pendingCreate
        ? SyncStatus.pendingCreate
        : SyncStatus.pendingUpdate;
    await (update(contacts)..where((r) => r.id.equals(c.localId))).write(
      _toCompanionFromEntity(
        c.copyWithSync(nextStatus),
        forInsert: false,
      ),
    );
  }

  Future<void> markPendingDelete(int localId) async {
    await (update(contacts)..where((r) => r.id.equals(localId))).write(
      ContactsCompanion(
        syncStatus: const Value(SyncStatus.pendingDelete),
        localUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> hardDelete(int localId) {
    return (delete(contacts)..where((r) => r.id.equals(localId))).go();
  }

  /// Marque un contact synced après push réussi.
  Future<void> markSyncedWithRemote({
    required int localId,
    required int remoteId,
    DateTime? tms,
  }) async {
    await (update(contacts)..where((r) => r.id.equals(localId))).write(
      ContactsCompanion(
        remoteId: Value(remoteId),
        tms: Value(tms ?? DateTime.now()),
        syncStatus: const Value(SyncStatus.synced),
        localUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Marque un contact en conflit.
  Future<void> markConflict(int localId) async {
    await (update(contacts)..where((r) => r.id.equals(localId))).write(
      ContactsCompanion(
        syncStatus: const Value(SyncStatus.conflict),
        localUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Suppression définitive après confirmation serveur.
  Future<int> clearAfterServerDelete(int localId) {
    return (delete(contacts)..where((r) => r.id.equals(localId))).go();
  }

  /// Patche `socidRemote` pour tous les contacts dont le tiers parent
  /// vient juste d'être créé côté serveur. Appelé par le SyncEngine
  /// après le succès de l'op create du parent.
  Future<int> patchSocidRemoteByParent({
    required int parentLocalId,
    required int parentRemoteId,
  }) async {
    return (update(contacts)
          ..where(
            (c) =>
                c.socidLocal.equals(parentLocalId) &
                c.socidRemote.isNull(),
          ))
        .write(ContactsCompanion(socidRemote: Value(parentRemoteId)));
  }

  ContactsCompanion _toCompanionFromEntity(
    Contact c, {
    required bool forInsert,
  }) {
    return ContactsCompanion(
      id: forInsert ? const Value.absent() : Value(c.localId),
      remoteId: Value(c.remoteId),
      socidRemote: Value(c.socidRemote),
      socidLocal: Value(c.socidLocal),
      firstname: Value(c.firstname),
      lastname: Value(c.lastname),
      poste: Value(c.poste),
      phonePro: Value(c.phonePro),
      phoneMobile: Value(c.phoneMobile),
      email: Value(c.email),
      address: Value(c.address),
      zip: Value(c.zip),
      town: Value(c.town),
      extrafields: Value(jsonEncode(c.extrafields)),
      tms: Value(c.tms),
      localUpdatedAt: Value(DateTime.now()),
      syncStatus: Value(c.syncStatus),
    );
  }

  Contact _fromRow(ContactRow r) => Contact(
        localId: r.id,
        remoteId: r.remoteId,
        socidRemote: r.socidRemote,
        socidLocal: r.socidLocal,
        firstname: r.firstname,
        lastname: r.lastname,
        poste: r.poste,
        phonePro: r.phonePro,
        phoneMobile: r.phoneMobile,
        email: r.email,
        address: r.address,
        zip: r.zip,
        town: r.town,
        extrafields: _decodeMap(r.extrafields),
        tms: r.tms,
        localUpdatedAt: r.localUpdatedAt,
        syncStatus: r.syncStatus,
      );

  ContactsCompanion _toCompanionFromJson(
    Map<String, Object?> json,
    int? localId,
  ) {
    String? s(String key) {
      final v = json[key];
      if (v == null || v == '' || v == 'null') return null;
      return '$v';
    }

    int? iN(String key) => int.tryParse('${json[key] ?? ''}');

    DateTime? d(String key) {
      final raw = json[key];
      if (raw == null) return null;
      final n = int.tryParse('$raw');
      if (n == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(n * 1000);
    }

    return ContactsCompanion(
      id: localId == null ? const Value.absent() : Value(localId),
      remoteId: Value(int.tryParse('${json['id'] ?? ''}')),
      socidRemote: Value(iN('socid') ?? iN('fk_soc')),
      firstname: Value(s('firstname')),
      lastname: Value(s('lastname')),
      poste: Value(s('poste')),
      phonePro: Value(s('phone_pro') ?? s('phone')),
      phoneMobile: Value(s('phone_mobile')),
      email: Value(s('email')),
      address: Value(s('address')),
      zip: Value(s('zip')),
      town: Value(s('town')),
      extrafields: Value(_encodeExtrafields(json['array_options'])),
      rawJson: Value(jsonEncode(json)),
      tms: Value(d('tms')),
      localUpdatedAt: Value(DateTime.now()),
      syncStatus: const Value(SyncStatus.synced),
    );
  }

  bool _matchesLocal(Contact c, ContactFilters f) {
    if (f.search.isNotEmpty) {
      final q = f.search.toLowerCase();
      final hay = [
        c.firstname ?? '',
        c.lastname ?? '',
        c.email ?? '',
        c.town ?? '',
      ].join(' ').toLowerCase();
      if (!hay.contains(q)) return false;
    }
    if (f.hasEmail && (c.email == null || c.email!.isEmpty)) return false;
    if (f.hasPhone) {
      final hasAny = (c.phonePro != null && c.phonePro!.isNotEmpty) ||
          (c.phoneMobile != null && c.phoneMobile!.isNotEmpty);
      if (!hasAny) return false;
    }
    if (f.thirdPartyRemoteId != null) {
      if (c.socidRemote != f.thirdPartyRemoteId) return false;
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
