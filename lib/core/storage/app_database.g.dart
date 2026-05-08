// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ThirdPartiesTable extends ThirdParties
    with TableInfo<$ThirdPartiesTable, ThirdPartyRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ThirdPartiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<int> remoteId = GeneratedColumn<int>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _codeClientMeta = const VerificationMeta(
    'codeClient',
  );
  @override
  late final GeneratedColumn<String> codeClient = GeneratedColumn<String>(
    'code_client',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _codeFournisseurMeta = const VerificationMeta(
    'codeFournisseur',
  );
  @override
  late final GeneratedColumn<String> codeFournisseur = GeneratedColumn<String>(
    'code_fournisseur',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clientTypeMeta = const VerificationMeta(
    'clientType',
  );
  @override
  late final GeneratedColumn<int> clientType = GeneratedColumn<int>(
    'client_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _fournisseurMeta = const VerificationMeta(
    'fournisseur',
  );
  @override
  late final GeneratedColumn<int> fournisseur = GeneratedColumn<int>(
    'fournisseur',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _zipMeta = const VerificationMeta('zip');
  @override
  late final GeneratedColumn<String> zip = GeneratedColumn<String>(
    'zip',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _townMeta = const VerificationMeta('town');
  @override
  late final GeneratedColumn<String> town = GeneratedColumn<String>(
    'town',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countryCodeMeta = const VerificationMeta(
    'countryCode',
  );
  @override
  late final GeneratedColumn<String> countryCode = GeneratedColumn<String>(
    'country_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sirenMeta = const VerificationMeta('siren');
  @override
  late final GeneratedColumn<String> siren = GeneratedColumn<String>(
    'siren',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _siretMeta = const VerificationMeta('siret');
  @override
  late final GeneratedColumn<String> siret = GeneratedColumn<String>(
    'siret',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tvaIntraMeta = const VerificationMeta(
    'tvaIntra',
  );
  @override
  late final GeneratedColumn<String> tvaIntra = GeneratedColumn<String>(
    'tva_intra',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notePublicMeta = const VerificationMeta(
    'notePublic',
  );
  @override
  late final GeneratedColumn<String> notePublic = GeneratedColumn<String>(
    'note_public',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notePrivateMeta = const VerificationMeta(
    'notePrivate',
  );
  @override
  late final GeneratedColumn<String> notePrivate = GeneratedColumn<String>(
    'note_private',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoriesJsonMeta = const VerificationMeta(
    'categoriesJson',
  );
  @override
  late final GeneratedColumn<String> categoriesJson = GeneratedColumn<String>(
    'categories_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _extrafieldsMeta = const VerificationMeta(
    'extrafields',
  );
  @override
  late final GeneratedColumn<String> extrafields = GeneratedColumn<String>(
    'extrafields',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _rawJsonMeta = const VerificationMeta(
    'rawJson',
  );
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
    'raw_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tmsMeta = const VerificationMeta('tms');
  @override
  late final GeneratedColumn<DateTime> tms = GeneratedColumn<DateTime>(
    'tms',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>(
        'local_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: Constant(SyncStatus.synced.index),
      ).withConverter<SyncStatus>($ThirdPartiesTable.$convertersyncStatus);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    remoteId,
    name,
    codeClient,
    codeFournisseur,
    clientType,
    fournisseur,
    status,
    address,
    zip,
    town,
    countryCode,
    phone,
    email,
    url,
    siren,
    siret,
    tvaIntra,
    notePublic,
    notePrivate,
    categoriesJson,
    extrafields,
    rawJson,
    tms,
    localUpdatedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'third_parties';
  @override
  VerificationContext validateIntegrity(
    Insertable<ThirdPartyRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('code_client')) {
      context.handle(
        _codeClientMeta,
        codeClient.isAcceptableOrUnknown(data['code_client']!, _codeClientMeta),
      );
    }
    if (data.containsKey('code_fournisseur')) {
      context.handle(
        _codeFournisseurMeta,
        codeFournisseur.isAcceptableOrUnknown(
          data['code_fournisseur']!,
          _codeFournisseurMeta,
        ),
      );
    }
    if (data.containsKey('client_type')) {
      context.handle(
        _clientTypeMeta,
        clientType.isAcceptableOrUnknown(data['client_type']!, _clientTypeMeta),
      );
    }
    if (data.containsKey('fournisseur')) {
      context.handle(
        _fournisseurMeta,
        fournisseur.isAcceptableOrUnknown(
          data['fournisseur']!,
          _fournisseurMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('zip')) {
      context.handle(
        _zipMeta,
        zip.isAcceptableOrUnknown(data['zip']!, _zipMeta),
      );
    }
    if (data.containsKey('town')) {
      context.handle(
        _townMeta,
        town.isAcceptableOrUnknown(data['town']!, _townMeta),
      );
    }
    if (data.containsKey('country_code')) {
      context.handle(
        _countryCodeMeta,
        countryCode.isAcceptableOrUnknown(
          data['country_code']!,
          _countryCodeMeta,
        ),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    if (data.containsKey('siren')) {
      context.handle(
        _sirenMeta,
        siren.isAcceptableOrUnknown(data['siren']!, _sirenMeta),
      );
    }
    if (data.containsKey('siret')) {
      context.handle(
        _siretMeta,
        siret.isAcceptableOrUnknown(data['siret']!, _siretMeta),
      );
    }
    if (data.containsKey('tva_intra')) {
      context.handle(
        _tvaIntraMeta,
        tvaIntra.isAcceptableOrUnknown(data['tva_intra']!, _tvaIntraMeta),
      );
    }
    if (data.containsKey('note_public')) {
      context.handle(
        _notePublicMeta,
        notePublic.isAcceptableOrUnknown(data['note_public']!, _notePublicMeta),
      );
    }
    if (data.containsKey('note_private')) {
      context.handle(
        _notePrivateMeta,
        notePrivate.isAcceptableOrUnknown(
          data['note_private']!,
          _notePrivateMeta,
        ),
      );
    }
    if (data.containsKey('categories_json')) {
      context.handle(
        _categoriesJsonMeta,
        categoriesJson.isAcceptableOrUnknown(
          data['categories_json']!,
          _categoriesJsonMeta,
        ),
      );
    }
    if (data.containsKey('extrafields')) {
      context.handle(
        _extrafieldsMeta,
        extrafields.isAcceptableOrUnknown(
          data['extrafields']!,
          _extrafieldsMeta,
        ),
      );
    }
    if (data.containsKey('raw_json')) {
      context.handle(
        _rawJsonMeta,
        rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta),
      );
    }
    if (data.containsKey('tms')) {
      context.handle(
        _tmsMeta,
        tms.isAcceptableOrUnknown(data['tms']!, _tmsMeta),
      );
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ThirdPartyRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ThirdPartyRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remote_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      codeClient: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code_client'],
      ),
      codeFournisseur: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code_fournisseur'],
      ),
      clientType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}client_type'],
      )!,
      fournisseur: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fournisseur'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      zip: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}zip'],
      ),
      town: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}town'],
      ),
      countryCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country_code'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      ),
      siren: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}siren'],
      ),
      siret: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}siret'],
      ),
      tvaIntra: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tva_intra'],
      ),
      notePublic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_public'],
      ),
      notePrivate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_private'],
      ),
      categoriesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categories_json'],
      )!,
      extrafields: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extrafields'],
      )!,
      rawJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_json'],
      ),
      tms: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}tms'],
      ),
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}local_updated_at'],
      )!,
      syncStatus: $ThirdPartiesTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
    );
  }

  @override
  $ThirdPartiesTable createAlias(String alias) {
    return $ThirdPartiesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class ThirdPartyRow extends DataClass implements Insertable<ThirdPartyRow> {
  final int id;

  /// `rowid` Dolibarr — null tant que l'entité n'a pas été poussée.
  final int? remoteId;
  final String name;
  final String? codeClient;
  final String? codeFournisseur;
  final int clientType;
  final int fournisseur;
  final int status;
  final String? address;
  final String? zip;
  final String? town;
  final String? countryCode;
  final String? phone;
  final String? email;
  final String? url;
  final String? siren;
  final String? siret;
  final String? tvaIntra;
  final String? notePublic;
  final String? notePrivate;

  /// IDs catégories Dolibarr (JSON list of int).
  final String categoriesJson;

  /// Champs personnalisés (JSON map String -> dynamic).
  final String extrafields;

  /// Snapshot brut de la dernière réponse API.
  final String? rawJson;
  final DateTime? tms;
  final DateTime localUpdatedAt;
  final SyncStatus syncStatus;
  const ThirdPartyRow({
    required this.id,
    this.remoteId,
    required this.name,
    this.codeClient,
    this.codeFournisseur,
    required this.clientType,
    required this.fournisseur,
    required this.status,
    this.address,
    this.zip,
    this.town,
    this.countryCode,
    this.phone,
    this.email,
    this.url,
    this.siren,
    this.siret,
    this.tvaIntra,
    this.notePublic,
    this.notePrivate,
    required this.categoriesJson,
    required this.extrafields,
    this.rawJson,
    this.tms,
    required this.localUpdatedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<int>(remoteId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || codeClient != null) {
      map['code_client'] = Variable<String>(codeClient);
    }
    if (!nullToAbsent || codeFournisseur != null) {
      map['code_fournisseur'] = Variable<String>(codeFournisseur);
    }
    map['client_type'] = Variable<int>(clientType);
    map['fournisseur'] = Variable<int>(fournisseur);
    map['status'] = Variable<int>(status);
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || zip != null) {
      map['zip'] = Variable<String>(zip);
    }
    if (!nullToAbsent || town != null) {
      map['town'] = Variable<String>(town);
    }
    if (!nullToAbsent || countryCode != null) {
      map['country_code'] = Variable<String>(countryCode);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    if (!nullToAbsent || siren != null) {
      map['siren'] = Variable<String>(siren);
    }
    if (!nullToAbsent || siret != null) {
      map['siret'] = Variable<String>(siret);
    }
    if (!nullToAbsent || tvaIntra != null) {
      map['tva_intra'] = Variable<String>(tvaIntra);
    }
    if (!nullToAbsent || notePublic != null) {
      map['note_public'] = Variable<String>(notePublic);
    }
    if (!nullToAbsent || notePrivate != null) {
      map['note_private'] = Variable<String>(notePrivate);
    }
    map['categories_json'] = Variable<String>(categoriesJson);
    map['extrafields'] = Variable<String>(extrafields);
    if (!nullToAbsent || rawJson != null) {
      map['raw_json'] = Variable<String>(rawJson);
    }
    if (!nullToAbsent || tms != null) {
      map['tms'] = Variable<DateTime>(tms);
    }
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    {
      map['sync_status'] = Variable<int>(
        $ThirdPartiesTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    return map;
  }

  ThirdPartiesCompanion toCompanion(bool nullToAbsent) {
    return ThirdPartiesCompanion(
      id: Value(id),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      name: Value(name),
      codeClient: codeClient == null && nullToAbsent
          ? const Value.absent()
          : Value(codeClient),
      codeFournisseur: codeFournisseur == null && nullToAbsent
          ? const Value.absent()
          : Value(codeFournisseur),
      clientType: Value(clientType),
      fournisseur: Value(fournisseur),
      status: Value(status),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      zip: zip == null && nullToAbsent ? const Value.absent() : Value(zip),
      town: town == null && nullToAbsent ? const Value.absent() : Value(town),
      countryCode: countryCode == null && nullToAbsent
          ? const Value.absent()
          : Value(countryCode),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      siren: siren == null && nullToAbsent
          ? const Value.absent()
          : Value(siren),
      siret: siret == null && nullToAbsent
          ? const Value.absent()
          : Value(siret),
      tvaIntra: tvaIntra == null && nullToAbsent
          ? const Value.absent()
          : Value(tvaIntra),
      notePublic: notePublic == null && nullToAbsent
          ? const Value.absent()
          : Value(notePublic),
      notePrivate: notePrivate == null && nullToAbsent
          ? const Value.absent()
          : Value(notePrivate),
      categoriesJson: Value(categoriesJson),
      extrafields: Value(extrafields),
      rawJson: rawJson == null && nullToAbsent
          ? const Value.absent()
          : Value(rawJson),
      tms: tms == null && nullToAbsent ? const Value.absent() : Value(tms),
      localUpdatedAt: Value(localUpdatedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory ThirdPartyRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ThirdPartyRow(
      id: serializer.fromJson<int>(json['id']),
      remoteId: serializer.fromJson<int?>(json['remoteId']),
      name: serializer.fromJson<String>(json['name']),
      codeClient: serializer.fromJson<String?>(json['codeClient']),
      codeFournisseur: serializer.fromJson<String?>(json['codeFournisseur']),
      clientType: serializer.fromJson<int>(json['clientType']),
      fournisseur: serializer.fromJson<int>(json['fournisseur']),
      status: serializer.fromJson<int>(json['status']),
      address: serializer.fromJson<String?>(json['address']),
      zip: serializer.fromJson<String?>(json['zip']),
      town: serializer.fromJson<String?>(json['town']),
      countryCode: serializer.fromJson<String?>(json['countryCode']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      url: serializer.fromJson<String?>(json['url']),
      siren: serializer.fromJson<String?>(json['siren']),
      siret: serializer.fromJson<String?>(json['siret']),
      tvaIntra: serializer.fromJson<String?>(json['tvaIntra']),
      notePublic: serializer.fromJson<String?>(json['notePublic']),
      notePrivate: serializer.fromJson<String?>(json['notePrivate']),
      categoriesJson: serializer.fromJson<String>(json['categoriesJson']),
      extrafields: serializer.fromJson<String>(json['extrafields']),
      rawJson: serializer.fromJson<String?>(json['rawJson']),
      tms: serializer.fromJson<DateTime?>(json['tms']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      syncStatus: $ThirdPartiesTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'remoteId': serializer.toJson<int?>(remoteId),
      'name': serializer.toJson<String>(name),
      'codeClient': serializer.toJson<String?>(codeClient),
      'codeFournisseur': serializer.toJson<String?>(codeFournisseur),
      'clientType': serializer.toJson<int>(clientType),
      'fournisseur': serializer.toJson<int>(fournisseur),
      'status': serializer.toJson<int>(status),
      'address': serializer.toJson<String?>(address),
      'zip': serializer.toJson<String?>(zip),
      'town': serializer.toJson<String?>(town),
      'countryCode': serializer.toJson<String?>(countryCode),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'url': serializer.toJson<String?>(url),
      'siren': serializer.toJson<String?>(siren),
      'siret': serializer.toJson<String?>(siret),
      'tvaIntra': serializer.toJson<String?>(tvaIntra),
      'notePublic': serializer.toJson<String?>(notePublic),
      'notePrivate': serializer.toJson<String?>(notePrivate),
      'categoriesJson': serializer.toJson<String>(categoriesJson),
      'extrafields': serializer.toJson<String>(extrafields),
      'rawJson': serializer.toJson<String?>(rawJson),
      'tms': serializer.toJson<DateTime?>(tms),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'syncStatus': serializer.toJson<int>(
        $ThirdPartiesTable.$convertersyncStatus.toJson(syncStatus),
      ),
    };
  }

  ThirdPartyRow copyWith({
    int? id,
    Value<int?> remoteId = const Value.absent(),
    String? name,
    Value<String?> codeClient = const Value.absent(),
    Value<String?> codeFournisseur = const Value.absent(),
    int? clientType,
    int? fournisseur,
    int? status,
    Value<String?> address = const Value.absent(),
    Value<String?> zip = const Value.absent(),
    Value<String?> town = const Value.absent(),
    Value<String?> countryCode = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> url = const Value.absent(),
    Value<String?> siren = const Value.absent(),
    Value<String?> siret = const Value.absent(),
    Value<String?> tvaIntra = const Value.absent(),
    Value<String?> notePublic = const Value.absent(),
    Value<String?> notePrivate = const Value.absent(),
    String? categoriesJson,
    String? extrafields,
    Value<String?> rawJson = const Value.absent(),
    Value<DateTime?> tms = const Value.absent(),
    DateTime? localUpdatedAt,
    SyncStatus? syncStatus,
  }) => ThirdPartyRow(
    id: id ?? this.id,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    name: name ?? this.name,
    codeClient: codeClient.present ? codeClient.value : this.codeClient,
    codeFournisseur: codeFournisseur.present
        ? codeFournisseur.value
        : this.codeFournisseur,
    clientType: clientType ?? this.clientType,
    fournisseur: fournisseur ?? this.fournisseur,
    status: status ?? this.status,
    address: address.present ? address.value : this.address,
    zip: zip.present ? zip.value : this.zip,
    town: town.present ? town.value : this.town,
    countryCode: countryCode.present ? countryCode.value : this.countryCode,
    phone: phone.present ? phone.value : this.phone,
    email: email.present ? email.value : this.email,
    url: url.present ? url.value : this.url,
    siren: siren.present ? siren.value : this.siren,
    siret: siret.present ? siret.value : this.siret,
    tvaIntra: tvaIntra.present ? tvaIntra.value : this.tvaIntra,
    notePublic: notePublic.present ? notePublic.value : this.notePublic,
    notePrivate: notePrivate.present ? notePrivate.value : this.notePrivate,
    categoriesJson: categoriesJson ?? this.categoriesJson,
    extrafields: extrafields ?? this.extrafields,
    rawJson: rawJson.present ? rawJson.value : this.rawJson,
    tms: tms.present ? tms.value : this.tms,
    localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  ThirdPartyRow copyWithCompanion(ThirdPartiesCompanion data) {
    return ThirdPartyRow(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      name: data.name.present ? data.name.value : this.name,
      codeClient: data.codeClient.present
          ? data.codeClient.value
          : this.codeClient,
      codeFournisseur: data.codeFournisseur.present
          ? data.codeFournisseur.value
          : this.codeFournisseur,
      clientType: data.clientType.present
          ? data.clientType.value
          : this.clientType,
      fournisseur: data.fournisseur.present
          ? data.fournisseur.value
          : this.fournisseur,
      status: data.status.present ? data.status.value : this.status,
      address: data.address.present ? data.address.value : this.address,
      zip: data.zip.present ? data.zip.value : this.zip,
      town: data.town.present ? data.town.value : this.town,
      countryCode: data.countryCode.present
          ? data.countryCode.value
          : this.countryCode,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      url: data.url.present ? data.url.value : this.url,
      siren: data.siren.present ? data.siren.value : this.siren,
      siret: data.siret.present ? data.siret.value : this.siret,
      tvaIntra: data.tvaIntra.present ? data.tvaIntra.value : this.tvaIntra,
      notePublic: data.notePublic.present
          ? data.notePublic.value
          : this.notePublic,
      notePrivate: data.notePrivate.present
          ? data.notePrivate.value
          : this.notePrivate,
      categoriesJson: data.categoriesJson.present
          ? data.categoriesJson.value
          : this.categoriesJson,
      extrafields: data.extrafields.present
          ? data.extrafields.value
          : this.extrafields,
      rawJson: data.rawJson.present ? data.rawJson.value : this.rawJson,
      tms: data.tms.present ? data.tms.value : this.tms,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ThirdPartyRow(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('name: $name, ')
          ..write('codeClient: $codeClient, ')
          ..write('codeFournisseur: $codeFournisseur, ')
          ..write('clientType: $clientType, ')
          ..write('fournisseur: $fournisseur, ')
          ..write('status: $status, ')
          ..write('address: $address, ')
          ..write('zip: $zip, ')
          ..write('town: $town, ')
          ..write('countryCode: $countryCode, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('url: $url, ')
          ..write('siren: $siren, ')
          ..write('siret: $siret, ')
          ..write('tvaIntra: $tvaIntra, ')
          ..write('notePublic: $notePublic, ')
          ..write('notePrivate: $notePrivate, ')
          ..write('categoriesJson: $categoriesJson, ')
          ..write('extrafields: $extrafields, ')
          ..write('rawJson: $rawJson, ')
          ..write('tms: $tms, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    remoteId,
    name,
    codeClient,
    codeFournisseur,
    clientType,
    fournisseur,
    status,
    address,
    zip,
    town,
    countryCode,
    phone,
    email,
    url,
    siren,
    siret,
    tvaIntra,
    notePublic,
    notePrivate,
    categoriesJson,
    extrafields,
    rawJson,
    tms,
    localUpdatedAt,
    syncStatus,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ThirdPartyRow &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.name == this.name &&
          other.codeClient == this.codeClient &&
          other.codeFournisseur == this.codeFournisseur &&
          other.clientType == this.clientType &&
          other.fournisseur == this.fournisseur &&
          other.status == this.status &&
          other.address == this.address &&
          other.zip == this.zip &&
          other.town == this.town &&
          other.countryCode == this.countryCode &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.url == this.url &&
          other.siren == this.siren &&
          other.siret == this.siret &&
          other.tvaIntra == this.tvaIntra &&
          other.notePublic == this.notePublic &&
          other.notePrivate == this.notePrivate &&
          other.categoriesJson == this.categoriesJson &&
          other.extrafields == this.extrafields &&
          other.rawJson == this.rawJson &&
          other.tms == this.tms &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.syncStatus == this.syncStatus);
}

class ThirdPartiesCompanion extends UpdateCompanion<ThirdPartyRow> {
  final Value<int> id;
  final Value<int?> remoteId;
  final Value<String> name;
  final Value<String?> codeClient;
  final Value<String?> codeFournisseur;
  final Value<int> clientType;
  final Value<int> fournisseur;
  final Value<int> status;
  final Value<String?> address;
  final Value<String?> zip;
  final Value<String?> town;
  final Value<String?> countryCode;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> url;
  final Value<String?> siren;
  final Value<String?> siret;
  final Value<String?> tvaIntra;
  final Value<String?> notePublic;
  final Value<String?> notePrivate;
  final Value<String> categoriesJson;
  final Value<String> extrafields;
  final Value<String?> rawJson;
  final Value<DateTime?> tms;
  final Value<DateTime> localUpdatedAt;
  final Value<SyncStatus> syncStatus;
  const ThirdPartiesCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.name = const Value.absent(),
    this.codeClient = const Value.absent(),
    this.codeFournisseur = const Value.absent(),
    this.clientType = const Value.absent(),
    this.fournisseur = const Value.absent(),
    this.status = const Value.absent(),
    this.address = const Value.absent(),
    this.zip = const Value.absent(),
    this.town = const Value.absent(),
    this.countryCode = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.url = const Value.absent(),
    this.siren = const Value.absent(),
    this.siret = const Value.absent(),
    this.tvaIntra = const Value.absent(),
    this.notePublic = const Value.absent(),
    this.notePrivate = const Value.absent(),
    this.categoriesJson = const Value.absent(),
    this.extrafields = const Value.absent(),
    this.rawJson = const Value.absent(),
    this.tms = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
  });
  ThirdPartiesCompanion.insert({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.name = const Value.absent(),
    this.codeClient = const Value.absent(),
    this.codeFournisseur = const Value.absent(),
    this.clientType = const Value.absent(),
    this.fournisseur = const Value.absent(),
    this.status = const Value.absent(),
    this.address = const Value.absent(),
    this.zip = const Value.absent(),
    this.town = const Value.absent(),
    this.countryCode = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.url = const Value.absent(),
    this.siren = const Value.absent(),
    this.siret = const Value.absent(),
    this.tvaIntra = const Value.absent(),
    this.notePublic = const Value.absent(),
    this.notePrivate = const Value.absent(),
    this.categoriesJson = const Value.absent(),
    this.extrafields = const Value.absent(),
    this.rawJson = const Value.absent(),
    this.tms = const Value.absent(),
    required DateTime localUpdatedAt,
    this.syncStatus = const Value.absent(),
  }) : localUpdatedAt = Value(localUpdatedAt);
  static Insertable<ThirdPartyRow> custom({
    Expression<int>? id,
    Expression<int>? remoteId,
    Expression<String>? name,
    Expression<String>? codeClient,
    Expression<String>? codeFournisseur,
    Expression<int>? clientType,
    Expression<int>? fournisseur,
    Expression<int>? status,
    Expression<String>? address,
    Expression<String>? zip,
    Expression<String>? town,
    Expression<String>? countryCode,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? url,
    Expression<String>? siren,
    Expression<String>? siret,
    Expression<String>? tvaIntra,
    Expression<String>? notePublic,
    Expression<String>? notePrivate,
    Expression<String>? categoriesJson,
    Expression<String>? extrafields,
    Expression<String>? rawJson,
    Expression<DateTime>? tms,
    Expression<DateTime>? localUpdatedAt,
    Expression<int>? syncStatus,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (name != null) 'name': name,
      if (codeClient != null) 'code_client': codeClient,
      if (codeFournisseur != null) 'code_fournisseur': codeFournisseur,
      if (clientType != null) 'client_type': clientType,
      if (fournisseur != null) 'fournisseur': fournisseur,
      if (status != null) 'status': status,
      if (address != null) 'address': address,
      if (zip != null) 'zip': zip,
      if (town != null) 'town': town,
      if (countryCode != null) 'country_code': countryCode,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (url != null) 'url': url,
      if (siren != null) 'siren': siren,
      if (siret != null) 'siret': siret,
      if (tvaIntra != null) 'tva_intra': tvaIntra,
      if (notePublic != null) 'note_public': notePublic,
      if (notePrivate != null) 'note_private': notePrivate,
      if (categoriesJson != null) 'categories_json': categoriesJson,
      if (extrafields != null) 'extrafields': extrafields,
      if (rawJson != null) 'raw_json': rawJson,
      if (tms != null) 'tms': tms,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
    });
  }

  ThirdPartiesCompanion copyWith({
    Value<int>? id,
    Value<int?>? remoteId,
    Value<String>? name,
    Value<String?>? codeClient,
    Value<String?>? codeFournisseur,
    Value<int>? clientType,
    Value<int>? fournisseur,
    Value<int>? status,
    Value<String?>? address,
    Value<String?>? zip,
    Value<String?>? town,
    Value<String?>? countryCode,
    Value<String?>? phone,
    Value<String?>? email,
    Value<String?>? url,
    Value<String?>? siren,
    Value<String?>? siret,
    Value<String?>? tvaIntra,
    Value<String?>? notePublic,
    Value<String?>? notePrivate,
    Value<String>? categoriesJson,
    Value<String>? extrafields,
    Value<String?>? rawJson,
    Value<DateTime?>? tms,
    Value<DateTime>? localUpdatedAt,
    Value<SyncStatus>? syncStatus,
  }) {
    return ThirdPartiesCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      name: name ?? this.name,
      codeClient: codeClient ?? this.codeClient,
      codeFournisseur: codeFournisseur ?? this.codeFournisseur,
      clientType: clientType ?? this.clientType,
      fournisseur: fournisseur ?? this.fournisseur,
      status: status ?? this.status,
      address: address ?? this.address,
      zip: zip ?? this.zip,
      town: town ?? this.town,
      countryCode: countryCode ?? this.countryCode,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      url: url ?? this.url,
      siren: siren ?? this.siren,
      siret: siret ?? this.siret,
      tvaIntra: tvaIntra ?? this.tvaIntra,
      notePublic: notePublic ?? this.notePublic,
      notePrivate: notePrivate ?? this.notePrivate,
      categoriesJson: categoriesJson ?? this.categoriesJson,
      extrafields: extrafields ?? this.extrafields,
      rawJson: rawJson ?? this.rawJson,
      tms: tms ?? this.tms,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<int>(remoteId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (codeClient.present) {
      map['code_client'] = Variable<String>(codeClient.value);
    }
    if (codeFournisseur.present) {
      map['code_fournisseur'] = Variable<String>(codeFournisseur.value);
    }
    if (clientType.present) {
      map['client_type'] = Variable<int>(clientType.value);
    }
    if (fournisseur.present) {
      map['fournisseur'] = Variable<int>(fournisseur.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (zip.present) {
      map['zip'] = Variable<String>(zip.value);
    }
    if (town.present) {
      map['town'] = Variable<String>(town.value);
    }
    if (countryCode.present) {
      map['country_code'] = Variable<String>(countryCode.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (siren.present) {
      map['siren'] = Variable<String>(siren.value);
    }
    if (siret.present) {
      map['siret'] = Variable<String>(siret.value);
    }
    if (tvaIntra.present) {
      map['tva_intra'] = Variable<String>(tvaIntra.value);
    }
    if (notePublic.present) {
      map['note_public'] = Variable<String>(notePublic.value);
    }
    if (notePrivate.present) {
      map['note_private'] = Variable<String>(notePrivate.value);
    }
    if (categoriesJson.present) {
      map['categories_json'] = Variable<String>(categoriesJson.value);
    }
    if (extrafields.present) {
      map['extrafields'] = Variable<String>(extrafields.value);
    }
    if (rawJson.present) {
      map['raw_json'] = Variable<String>(rawJson.value);
    }
    if (tms.present) {
      map['tms'] = Variable<DateTime>(tms.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $ThirdPartiesTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ThirdPartiesCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('name: $name, ')
          ..write('codeClient: $codeClient, ')
          ..write('codeFournisseur: $codeFournisseur, ')
          ..write('clientType: $clientType, ')
          ..write('fournisseur: $fournisseur, ')
          ..write('status: $status, ')
          ..write('address: $address, ')
          ..write('zip: $zip, ')
          ..write('town: $town, ')
          ..write('countryCode: $countryCode, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('url: $url, ')
          ..write('siren: $siren, ')
          ..write('siret: $siret, ')
          ..write('tvaIntra: $tvaIntra, ')
          ..write('notePublic: $notePublic, ')
          ..write('notePrivate: $notePrivate, ')
          ..write('categoriesJson: $categoriesJson, ')
          ..write('extrafields: $extrafields, ')
          ..write('rawJson: $rawJson, ')
          ..write('tms: $tms, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }
}

class $ContactsTable extends Contacts
    with TableInfo<$ContactsTable, ContactRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<int> remoteId = GeneratedColumn<int>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _socidRemoteMeta = const VerificationMeta(
    'socidRemote',
  );
  @override
  late final GeneratedColumn<int> socidRemote = GeneratedColumn<int>(
    'socid_remote',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _socidLocalMeta = const VerificationMeta(
    'socidLocal',
  );
  @override
  late final GeneratedColumn<int> socidLocal = GeneratedColumn<int>(
    'socid_local',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _firstnameMeta = const VerificationMeta(
    'firstname',
  );
  @override
  late final GeneratedColumn<String> firstname = GeneratedColumn<String>(
    'firstname',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastnameMeta = const VerificationMeta(
    'lastname',
  );
  @override
  late final GeneratedColumn<String> lastname = GeneratedColumn<String>(
    'lastname',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _posteMeta = const VerificationMeta('poste');
  @override
  late final GeneratedColumn<String> poste = GeneratedColumn<String>(
    'poste',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneProMeta = const VerificationMeta(
    'phonePro',
  );
  @override
  late final GeneratedColumn<String> phonePro = GeneratedColumn<String>(
    'phone_pro',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMobileMeta = const VerificationMeta(
    'phoneMobile',
  );
  @override
  late final GeneratedColumn<String> phoneMobile = GeneratedColumn<String>(
    'phone_mobile',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _zipMeta = const VerificationMeta('zip');
  @override
  late final GeneratedColumn<String> zip = GeneratedColumn<String>(
    'zip',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _townMeta = const VerificationMeta('town');
  @override
  late final GeneratedColumn<String> town = GeneratedColumn<String>(
    'town',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _extrafieldsMeta = const VerificationMeta(
    'extrafields',
  );
  @override
  late final GeneratedColumn<String> extrafields = GeneratedColumn<String>(
    'extrafields',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _rawJsonMeta = const VerificationMeta(
    'rawJson',
  );
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
    'raw_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tmsMeta = const VerificationMeta('tms');
  @override
  late final GeneratedColumn<DateTime> tms = GeneratedColumn<DateTime>(
    'tms',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>(
        'local_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: Constant(SyncStatus.synced.index),
      ).withConverter<SyncStatus>($ContactsTable.$convertersyncStatus);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    remoteId,
    socidRemote,
    socidLocal,
    firstname,
    lastname,
    poste,
    phonePro,
    phoneMobile,
    email,
    address,
    zip,
    town,
    extrafields,
    rawJson,
    tms,
    localUpdatedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contacts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContactRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('socid_remote')) {
      context.handle(
        _socidRemoteMeta,
        socidRemote.isAcceptableOrUnknown(
          data['socid_remote']!,
          _socidRemoteMeta,
        ),
      );
    }
    if (data.containsKey('socid_local')) {
      context.handle(
        _socidLocalMeta,
        socidLocal.isAcceptableOrUnknown(data['socid_local']!, _socidLocalMeta),
      );
    }
    if (data.containsKey('firstname')) {
      context.handle(
        _firstnameMeta,
        firstname.isAcceptableOrUnknown(data['firstname']!, _firstnameMeta),
      );
    }
    if (data.containsKey('lastname')) {
      context.handle(
        _lastnameMeta,
        lastname.isAcceptableOrUnknown(data['lastname']!, _lastnameMeta),
      );
    }
    if (data.containsKey('poste')) {
      context.handle(
        _posteMeta,
        poste.isAcceptableOrUnknown(data['poste']!, _posteMeta),
      );
    }
    if (data.containsKey('phone_pro')) {
      context.handle(
        _phoneProMeta,
        phonePro.isAcceptableOrUnknown(data['phone_pro']!, _phoneProMeta),
      );
    }
    if (data.containsKey('phone_mobile')) {
      context.handle(
        _phoneMobileMeta,
        phoneMobile.isAcceptableOrUnknown(
          data['phone_mobile']!,
          _phoneMobileMeta,
        ),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('zip')) {
      context.handle(
        _zipMeta,
        zip.isAcceptableOrUnknown(data['zip']!, _zipMeta),
      );
    }
    if (data.containsKey('town')) {
      context.handle(
        _townMeta,
        town.isAcceptableOrUnknown(data['town']!, _townMeta),
      );
    }
    if (data.containsKey('extrafields')) {
      context.handle(
        _extrafieldsMeta,
        extrafields.isAcceptableOrUnknown(
          data['extrafields']!,
          _extrafieldsMeta,
        ),
      );
    }
    if (data.containsKey('raw_json')) {
      context.handle(
        _rawJsonMeta,
        rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta),
      );
    }
    if (data.containsKey('tms')) {
      context.handle(
        _tmsMeta,
        tms.isAcceptableOrUnknown(data['tms']!, _tmsMeta),
      );
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContactRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContactRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remote_id'],
      ),
      socidRemote: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}socid_remote'],
      ),
      socidLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}socid_local'],
      ),
      firstname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}firstname'],
      ),
      lastname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lastname'],
      ),
      poste: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}poste'],
      ),
      phonePro: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_pro'],
      ),
      phoneMobile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_mobile'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      zip: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}zip'],
      ),
      town: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}town'],
      ),
      extrafields: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extrafields'],
      )!,
      rawJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_json'],
      ),
      tms: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}tms'],
      ),
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}local_updated_at'],
      )!,
      syncStatus: $ContactsTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
    );
  }

  @override
  $ContactsTable createAlias(String alias) {
    return $ContactsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class ContactRow extends DataClass implements Insertable<ContactRow> {
  final int id;
  final int? remoteId;

  /// `socid` côté Dolibarr — id du tiers parent (`remoteId` de ThirdParty).
  final int? socidRemote;

  /// FK locale vers ThirdParties.id quand le parent n'est pas encore poussé
  /// (cascade Outbox). Patché par le SyncEngine après push du parent.
  final int? socidLocal;
  final String? firstname;
  final String? lastname;
  final String? poste;
  final String? phonePro;
  final String? phoneMobile;
  final String? email;
  final String? address;
  final String? zip;
  final String? town;
  final String extrafields;
  final String? rawJson;
  final DateTime? tms;
  final DateTime localUpdatedAt;
  final SyncStatus syncStatus;
  const ContactRow({
    required this.id,
    this.remoteId,
    this.socidRemote,
    this.socidLocal,
    this.firstname,
    this.lastname,
    this.poste,
    this.phonePro,
    this.phoneMobile,
    this.email,
    this.address,
    this.zip,
    this.town,
    required this.extrafields,
    this.rawJson,
    this.tms,
    required this.localUpdatedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<int>(remoteId);
    }
    if (!nullToAbsent || socidRemote != null) {
      map['socid_remote'] = Variable<int>(socidRemote);
    }
    if (!nullToAbsent || socidLocal != null) {
      map['socid_local'] = Variable<int>(socidLocal);
    }
    if (!nullToAbsent || firstname != null) {
      map['firstname'] = Variable<String>(firstname);
    }
    if (!nullToAbsent || lastname != null) {
      map['lastname'] = Variable<String>(lastname);
    }
    if (!nullToAbsent || poste != null) {
      map['poste'] = Variable<String>(poste);
    }
    if (!nullToAbsent || phonePro != null) {
      map['phone_pro'] = Variable<String>(phonePro);
    }
    if (!nullToAbsent || phoneMobile != null) {
      map['phone_mobile'] = Variable<String>(phoneMobile);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || zip != null) {
      map['zip'] = Variable<String>(zip);
    }
    if (!nullToAbsent || town != null) {
      map['town'] = Variable<String>(town);
    }
    map['extrafields'] = Variable<String>(extrafields);
    if (!nullToAbsent || rawJson != null) {
      map['raw_json'] = Variable<String>(rawJson);
    }
    if (!nullToAbsent || tms != null) {
      map['tms'] = Variable<DateTime>(tms);
    }
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    {
      map['sync_status'] = Variable<int>(
        $ContactsTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    return map;
  }

  ContactsCompanion toCompanion(bool nullToAbsent) {
    return ContactsCompanion(
      id: Value(id),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      socidRemote: socidRemote == null && nullToAbsent
          ? const Value.absent()
          : Value(socidRemote),
      socidLocal: socidLocal == null && nullToAbsent
          ? const Value.absent()
          : Value(socidLocal),
      firstname: firstname == null && nullToAbsent
          ? const Value.absent()
          : Value(firstname),
      lastname: lastname == null && nullToAbsent
          ? const Value.absent()
          : Value(lastname),
      poste: poste == null && nullToAbsent
          ? const Value.absent()
          : Value(poste),
      phonePro: phonePro == null && nullToAbsent
          ? const Value.absent()
          : Value(phonePro),
      phoneMobile: phoneMobile == null && nullToAbsent
          ? const Value.absent()
          : Value(phoneMobile),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      zip: zip == null && nullToAbsent ? const Value.absent() : Value(zip),
      town: town == null && nullToAbsent ? const Value.absent() : Value(town),
      extrafields: Value(extrafields),
      rawJson: rawJson == null && nullToAbsent
          ? const Value.absent()
          : Value(rawJson),
      tms: tms == null && nullToAbsent ? const Value.absent() : Value(tms),
      localUpdatedAt: Value(localUpdatedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory ContactRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContactRow(
      id: serializer.fromJson<int>(json['id']),
      remoteId: serializer.fromJson<int?>(json['remoteId']),
      socidRemote: serializer.fromJson<int?>(json['socidRemote']),
      socidLocal: serializer.fromJson<int?>(json['socidLocal']),
      firstname: serializer.fromJson<String?>(json['firstname']),
      lastname: serializer.fromJson<String?>(json['lastname']),
      poste: serializer.fromJson<String?>(json['poste']),
      phonePro: serializer.fromJson<String?>(json['phonePro']),
      phoneMobile: serializer.fromJson<String?>(json['phoneMobile']),
      email: serializer.fromJson<String?>(json['email']),
      address: serializer.fromJson<String?>(json['address']),
      zip: serializer.fromJson<String?>(json['zip']),
      town: serializer.fromJson<String?>(json['town']),
      extrafields: serializer.fromJson<String>(json['extrafields']),
      rawJson: serializer.fromJson<String?>(json['rawJson']),
      tms: serializer.fromJson<DateTime?>(json['tms']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      syncStatus: $ContactsTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'remoteId': serializer.toJson<int?>(remoteId),
      'socidRemote': serializer.toJson<int?>(socidRemote),
      'socidLocal': serializer.toJson<int?>(socidLocal),
      'firstname': serializer.toJson<String?>(firstname),
      'lastname': serializer.toJson<String?>(lastname),
      'poste': serializer.toJson<String?>(poste),
      'phonePro': serializer.toJson<String?>(phonePro),
      'phoneMobile': serializer.toJson<String?>(phoneMobile),
      'email': serializer.toJson<String?>(email),
      'address': serializer.toJson<String?>(address),
      'zip': serializer.toJson<String?>(zip),
      'town': serializer.toJson<String?>(town),
      'extrafields': serializer.toJson<String>(extrafields),
      'rawJson': serializer.toJson<String?>(rawJson),
      'tms': serializer.toJson<DateTime?>(tms),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'syncStatus': serializer.toJson<int>(
        $ContactsTable.$convertersyncStatus.toJson(syncStatus),
      ),
    };
  }

  ContactRow copyWith({
    int? id,
    Value<int?> remoteId = const Value.absent(),
    Value<int?> socidRemote = const Value.absent(),
    Value<int?> socidLocal = const Value.absent(),
    Value<String?> firstname = const Value.absent(),
    Value<String?> lastname = const Value.absent(),
    Value<String?> poste = const Value.absent(),
    Value<String?> phonePro = const Value.absent(),
    Value<String?> phoneMobile = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> zip = const Value.absent(),
    Value<String?> town = const Value.absent(),
    String? extrafields,
    Value<String?> rawJson = const Value.absent(),
    Value<DateTime?> tms = const Value.absent(),
    DateTime? localUpdatedAt,
    SyncStatus? syncStatus,
  }) => ContactRow(
    id: id ?? this.id,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    socidRemote: socidRemote.present ? socidRemote.value : this.socidRemote,
    socidLocal: socidLocal.present ? socidLocal.value : this.socidLocal,
    firstname: firstname.present ? firstname.value : this.firstname,
    lastname: lastname.present ? lastname.value : this.lastname,
    poste: poste.present ? poste.value : this.poste,
    phonePro: phonePro.present ? phonePro.value : this.phonePro,
    phoneMobile: phoneMobile.present ? phoneMobile.value : this.phoneMobile,
    email: email.present ? email.value : this.email,
    address: address.present ? address.value : this.address,
    zip: zip.present ? zip.value : this.zip,
    town: town.present ? town.value : this.town,
    extrafields: extrafields ?? this.extrafields,
    rawJson: rawJson.present ? rawJson.value : this.rawJson,
    tms: tms.present ? tms.value : this.tms,
    localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  ContactRow copyWithCompanion(ContactsCompanion data) {
    return ContactRow(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      socidRemote: data.socidRemote.present
          ? data.socidRemote.value
          : this.socidRemote,
      socidLocal: data.socidLocal.present
          ? data.socidLocal.value
          : this.socidLocal,
      firstname: data.firstname.present ? data.firstname.value : this.firstname,
      lastname: data.lastname.present ? data.lastname.value : this.lastname,
      poste: data.poste.present ? data.poste.value : this.poste,
      phonePro: data.phonePro.present ? data.phonePro.value : this.phonePro,
      phoneMobile: data.phoneMobile.present
          ? data.phoneMobile.value
          : this.phoneMobile,
      email: data.email.present ? data.email.value : this.email,
      address: data.address.present ? data.address.value : this.address,
      zip: data.zip.present ? data.zip.value : this.zip,
      town: data.town.present ? data.town.value : this.town,
      extrafields: data.extrafields.present
          ? data.extrafields.value
          : this.extrafields,
      rawJson: data.rawJson.present ? data.rawJson.value : this.rawJson,
      tms: data.tms.present ? data.tms.value : this.tms,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContactRow(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('socidRemote: $socidRemote, ')
          ..write('socidLocal: $socidLocal, ')
          ..write('firstname: $firstname, ')
          ..write('lastname: $lastname, ')
          ..write('poste: $poste, ')
          ..write('phonePro: $phonePro, ')
          ..write('phoneMobile: $phoneMobile, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('zip: $zip, ')
          ..write('town: $town, ')
          ..write('extrafields: $extrafields, ')
          ..write('rawJson: $rawJson, ')
          ..write('tms: $tms, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    remoteId,
    socidRemote,
    socidLocal,
    firstname,
    lastname,
    poste,
    phonePro,
    phoneMobile,
    email,
    address,
    zip,
    town,
    extrafields,
    rawJson,
    tms,
    localUpdatedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContactRow &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.socidRemote == this.socidRemote &&
          other.socidLocal == this.socidLocal &&
          other.firstname == this.firstname &&
          other.lastname == this.lastname &&
          other.poste == this.poste &&
          other.phonePro == this.phonePro &&
          other.phoneMobile == this.phoneMobile &&
          other.email == this.email &&
          other.address == this.address &&
          other.zip == this.zip &&
          other.town == this.town &&
          other.extrafields == this.extrafields &&
          other.rawJson == this.rawJson &&
          other.tms == this.tms &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.syncStatus == this.syncStatus);
}

class ContactsCompanion extends UpdateCompanion<ContactRow> {
  final Value<int> id;
  final Value<int?> remoteId;
  final Value<int?> socidRemote;
  final Value<int?> socidLocal;
  final Value<String?> firstname;
  final Value<String?> lastname;
  final Value<String?> poste;
  final Value<String?> phonePro;
  final Value<String?> phoneMobile;
  final Value<String?> email;
  final Value<String?> address;
  final Value<String?> zip;
  final Value<String?> town;
  final Value<String> extrafields;
  final Value<String?> rawJson;
  final Value<DateTime?> tms;
  final Value<DateTime> localUpdatedAt;
  final Value<SyncStatus> syncStatus;
  const ContactsCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.socidRemote = const Value.absent(),
    this.socidLocal = const Value.absent(),
    this.firstname = const Value.absent(),
    this.lastname = const Value.absent(),
    this.poste = const Value.absent(),
    this.phonePro = const Value.absent(),
    this.phoneMobile = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.zip = const Value.absent(),
    this.town = const Value.absent(),
    this.extrafields = const Value.absent(),
    this.rawJson = const Value.absent(),
    this.tms = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
  });
  ContactsCompanion.insert({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.socidRemote = const Value.absent(),
    this.socidLocal = const Value.absent(),
    this.firstname = const Value.absent(),
    this.lastname = const Value.absent(),
    this.poste = const Value.absent(),
    this.phonePro = const Value.absent(),
    this.phoneMobile = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.zip = const Value.absent(),
    this.town = const Value.absent(),
    this.extrafields = const Value.absent(),
    this.rawJson = const Value.absent(),
    this.tms = const Value.absent(),
    required DateTime localUpdatedAt,
    this.syncStatus = const Value.absent(),
  }) : localUpdatedAt = Value(localUpdatedAt);
  static Insertable<ContactRow> custom({
    Expression<int>? id,
    Expression<int>? remoteId,
    Expression<int>? socidRemote,
    Expression<int>? socidLocal,
    Expression<String>? firstname,
    Expression<String>? lastname,
    Expression<String>? poste,
    Expression<String>? phonePro,
    Expression<String>? phoneMobile,
    Expression<String>? email,
    Expression<String>? address,
    Expression<String>? zip,
    Expression<String>? town,
    Expression<String>? extrafields,
    Expression<String>? rawJson,
    Expression<DateTime>? tms,
    Expression<DateTime>? localUpdatedAt,
    Expression<int>? syncStatus,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (socidRemote != null) 'socid_remote': socidRemote,
      if (socidLocal != null) 'socid_local': socidLocal,
      if (firstname != null) 'firstname': firstname,
      if (lastname != null) 'lastname': lastname,
      if (poste != null) 'poste': poste,
      if (phonePro != null) 'phone_pro': phonePro,
      if (phoneMobile != null) 'phone_mobile': phoneMobile,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (zip != null) 'zip': zip,
      if (town != null) 'town': town,
      if (extrafields != null) 'extrafields': extrafields,
      if (rawJson != null) 'raw_json': rawJson,
      if (tms != null) 'tms': tms,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
    });
  }

  ContactsCompanion copyWith({
    Value<int>? id,
    Value<int?>? remoteId,
    Value<int?>? socidRemote,
    Value<int?>? socidLocal,
    Value<String?>? firstname,
    Value<String?>? lastname,
    Value<String?>? poste,
    Value<String?>? phonePro,
    Value<String?>? phoneMobile,
    Value<String?>? email,
    Value<String?>? address,
    Value<String?>? zip,
    Value<String?>? town,
    Value<String>? extrafields,
    Value<String?>? rawJson,
    Value<DateTime?>? tms,
    Value<DateTime>? localUpdatedAt,
    Value<SyncStatus>? syncStatus,
  }) {
    return ContactsCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      socidRemote: socidRemote ?? this.socidRemote,
      socidLocal: socidLocal ?? this.socidLocal,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      poste: poste ?? this.poste,
      phonePro: phonePro ?? this.phonePro,
      phoneMobile: phoneMobile ?? this.phoneMobile,
      email: email ?? this.email,
      address: address ?? this.address,
      zip: zip ?? this.zip,
      town: town ?? this.town,
      extrafields: extrafields ?? this.extrafields,
      rawJson: rawJson ?? this.rawJson,
      tms: tms ?? this.tms,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<int>(remoteId.value);
    }
    if (socidRemote.present) {
      map['socid_remote'] = Variable<int>(socidRemote.value);
    }
    if (socidLocal.present) {
      map['socid_local'] = Variable<int>(socidLocal.value);
    }
    if (firstname.present) {
      map['firstname'] = Variable<String>(firstname.value);
    }
    if (lastname.present) {
      map['lastname'] = Variable<String>(lastname.value);
    }
    if (poste.present) {
      map['poste'] = Variable<String>(poste.value);
    }
    if (phonePro.present) {
      map['phone_pro'] = Variable<String>(phonePro.value);
    }
    if (phoneMobile.present) {
      map['phone_mobile'] = Variable<String>(phoneMobile.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (zip.present) {
      map['zip'] = Variable<String>(zip.value);
    }
    if (town.present) {
      map['town'] = Variable<String>(town.value);
    }
    if (extrafields.present) {
      map['extrafields'] = Variable<String>(extrafields.value);
    }
    if (rawJson.present) {
      map['raw_json'] = Variable<String>(rawJson.value);
    }
    if (tms.present) {
      map['tms'] = Variable<DateTime>(tms.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $ContactsTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactsCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('socidRemote: $socidRemote, ')
          ..write('socidLocal: $socidLocal, ')
          ..write('firstname: $firstname, ')
          ..write('lastname: $lastname, ')
          ..write('poste: $poste, ')
          ..write('phonePro: $phonePro, ')
          ..write('phoneMobile: $phoneMobile, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('zip: $zip, ')
          ..write('town: $town, ')
          ..write('extrafields: $extrafields, ')
          ..write('rawJson: $rawJson, ')
          ..write('tms: $tms, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<int> remoteId = GeneratedColumn<int>(
    'remote_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentRemoteIdMeta = const VerificationMeta(
    'parentRemoteId',
  );
  @override
  late final GeneratedColumn<int> parentRemoteId = GeneratedColumn<int>(
    'parent_remote_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    remoteId,
    label,
    type,
    parentRemoteId,
    color,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_remoteIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('parent_remote_id')) {
      context.handle(
        _parentRemoteIdMeta,
        parentRemoteId.isAcceptableOrUnknown(
          data['parent_remote_id']!,
          _parentRemoteIdMeta,
        ),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remote_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      parentRemoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_remote_id'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final int id;
  final int remoteId;
  final String label;

  /// `customer`, `supplier` ou `contact` (cf. Dolibarr API).
  final String type;
  final int? parentRemoteId;
  final String? color;
  final DateTime fetchedAt;
  const CategoryRow({
    required this.id,
    required this.remoteId,
    required this.label,
    required this.type,
    this.parentRemoteId,
    this.color,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['remote_id'] = Variable<int>(remoteId);
    map['label'] = Variable<String>(label);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || parentRemoteId != null) {
      map['parent_remote_id'] = Variable<int>(parentRemoteId);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      remoteId: Value(remoteId),
      label: Value(label),
      type: Value(type),
      parentRemoteId: parentRemoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentRemoteId),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory CategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      id: serializer.fromJson<int>(json['id']),
      remoteId: serializer.fromJson<int>(json['remoteId']),
      label: serializer.fromJson<String>(json['label']),
      type: serializer.fromJson<String>(json['type']),
      parentRemoteId: serializer.fromJson<int?>(json['parentRemoteId']),
      color: serializer.fromJson<String?>(json['color']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'remoteId': serializer.toJson<int>(remoteId),
      'label': serializer.toJson<String>(label),
      'type': serializer.toJson<String>(type),
      'parentRemoteId': serializer.toJson<int?>(parentRemoteId),
      'color': serializer.toJson<String?>(color),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  CategoryRow copyWith({
    int? id,
    int? remoteId,
    String? label,
    String? type,
    Value<int?> parentRemoteId = const Value.absent(),
    Value<String?> color = const Value.absent(),
    DateTime? fetchedAt,
  }) => CategoryRow(
    id: id ?? this.id,
    remoteId: remoteId ?? this.remoteId,
    label: label ?? this.label,
    type: type ?? this.type,
    parentRemoteId: parentRemoteId.present
        ? parentRemoteId.value
        : this.parentRemoteId,
    color: color.present ? color.value : this.color,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  CategoryRow copyWithCompanion(CategoriesCompanion data) {
    return CategoryRow(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      label: data.label.present ? data.label.value : this.label,
      type: data.type.present ? data.type.value : this.type,
      parentRemoteId: data.parentRemoteId.present
          ? data.parentRemoteId.value
          : this.parentRemoteId,
      color: data.color.present ? data.color.value : this.color,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('label: $label, ')
          ..write('type: $type, ')
          ..write('parentRemoteId: $parentRemoteId, ')
          ..write('color: $color, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, remoteId, label, type, parentRemoteId, color, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.label == this.label &&
          other.type == this.type &&
          other.parentRemoteId == this.parentRemoteId &&
          other.color == this.color &&
          other.fetchedAt == this.fetchedAt);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<int> id;
  final Value<int> remoteId;
  final Value<String> label;
  final Value<String> type;
  final Value<int?> parentRemoteId;
  final Value<String?> color;
  final Value<DateTime> fetchedAt;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.label = const Value.absent(),
    this.type = const Value.absent(),
    this.parentRemoteId = const Value.absent(),
    this.color = const Value.absent(),
    this.fetchedAt = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required int remoteId,
    required String label,
    required String type,
    this.parentRemoteId = const Value.absent(),
    this.color = const Value.absent(),
    required DateTime fetchedAt,
  }) : remoteId = Value(remoteId),
       label = Value(label),
       type = Value(type),
       fetchedAt = Value(fetchedAt);
  static Insertable<CategoryRow> custom({
    Expression<int>? id,
    Expression<int>? remoteId,
    Expression<String>? label,
    Expression<String>? type,
    Expression<int>? parentRemoteId,
    Expression<String>? color,
    Expression<DateTime>? fetchedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (label != null) 'label': label,
      if (type != null) 'type': type,
      if (parentRemoteId != null) 'parent_remote_id': parentRemoteId,
      if (color != null) 'color': color,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<int>? remoteId,
    Value<String>? label,
    Value<String>? type,
    Value<int?>? parentRemoteId,
    Value<String?>? color,
    Value<DateTime>? fetchedAt,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      label: label ?? this.label,
      type: type ?? this.type,
      parentRemoteId: parentRemoteId ?? this.parentRemoteId,
      color: color ?? this.color,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<int>(remoteId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (parentRemoteId.present) {
      map['parent_remote_id'] = Variable<int>(parentRemoteId.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('label: $label, ')
          ..write('type: $type, ')
          ..write('parentRemoteId: $parentRemoteId, ')
          ..write('color: $color, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }
}

class $DraftsTable extends Drafts with TableInfo<$DraftsTable, DraftRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refLocalIdMeta = const VerificationMeta(
    'refLocalId',
  );
  @override
  late final GeneratedColumn<int> refLocalId = GeneratedColumn<int>(
    'ref_local_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fieldsJsonMeta = const VerificationMeta(
    'fieldsJson',
  );
  @override
  late final GeneratedColumn<String> fieldsJson = GeneratedColumn<String>(
    'fields_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    refLocalId,
    fieldsJson,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'drafts';
  @override
  VerificationContext validateIntegrity(
    Insertable<DraftRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('ref_local_id')) {
      context.handle(
        _refLocalIdMeta,
        refLocalId.isAcceptableOrUnknown(
          data['ref_local_id']!,
          _refLocalIdMeta,
        ),
      );
    }
    if (data.containsKey('fields_json')) {
      context.handle(
        _fieldsJsonMeta,
        fieldsJson.isAcceptableOrUnknown(data['fields_json']!, _fieldsJsonMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DraftRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DraftRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      refLocalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ref_local_id'],
      ),
      fieldsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fields_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DraftsTable createAlias(String alias) {
    return $DraftsTable(attachedDatabase, alias);
  }
}

class DraftRow extends DataClass implements Insertable<DraftRow> {
  final int id;

  /// `thirdparty` ou `contact`.
  final String entityType;

  /// PK locale Drift de l'entité référencée. `null` pour une création
  /// (le brouillon n'a pas encore d'entité associée).
  final int? refLocalId;

  /// Snapshot JSON des valeurs courantes du formulaire.
  final String fieldsJson;
  final DateTime updatedAt;
  const DraftRow({
    required this.id,
    required this.entityType,
    this.refLocalId,
    required this.fieldsJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_type'] = Variable<String>(entityType);
    if (!nullToAbsent || refLocalId != null) {
      map['ref_local_id'] = Variable<int>(refLocalId);
    }
    map['fields_json'] = Variable<String>(fieldsJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DraftsCompanion toCompanion(bool nullToAbsent) {
    return DraftsCompanion(
      id: Value(id),
      entityType: Value(entityType),
      refLocalId: refLocalId == null && nullToAbsent
          ? const Value.absent()
          : Value(refLocalId),
      fieldsJson: Value(fieldsJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory DraftRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DraftRow(
      id: serializer.fromJson<int>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      refLocalId: serializer.fromJson<int?>(json['refLocalId']),
      fieldsJson: serializer.fromJson<String>(json['fieldsJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityType': serializer.toJson<String>(entityType),
      'refLocalId': serializer.toJson<int?>(refLocalId),
      'fieldsJson': serializer.toJson<String>(fieldsJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DraftRow copyWith({
    int? id,
    String? entityType,
    Value<int?> refLocalId = const Value.absent(),
    String? fieldsJson,
    DateTime? updatedAt,
  }) => DraftRow(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    refLocalId: refLocalId.present ? refLocalId.value : this.refLocalId,
    fieldsJson: fieldsJson ?? this.fieldsJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DraftRow copyWithCompanion(DraftsCompanion data) {
    return DraftRow(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      refLocalId: data.refLocalId.present
          ? data.refLocalId.value
          : this.refLocalId,
      fieldsJson: data.fieldsJson.present
          ? data.fieldsJson.value
          : this.fieldsJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DraftRow(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('refLocalId: $refLocalId, ')
          ..write('fieldsJson: $fieldsJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, entityType, refLocalId, fieldsJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DraftRow &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.refLocalId == this.refLocalId &&
          other.fieldsJson == this.fieldsJson &&
          other.updatedAt == this.updatedAt);
}

class DraftsCompanion extends UpdateCompanion<DraftRow> {
  final Value<int> id;
  final Value<String> entityType;
  final Value<int?> refLocalId;
  final Value<String> fieldsJson;
  final Value<DateTime> updatedAt;
  const DraftsCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.refLocalId = const Value.absent(),
    this.fieldsJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DraftsCompanion.insert({
    this.id = const Value.absent(),
    required String entityType,
    this.refLocalId = const Value.absent(),
    this.fieldsJson = const Value.absent(),
    required DateTime updatedAt,
  }) : entityType = Value(entityType),
       updatedAt = Value(updatedAt);
  static Insertable<DraftRow> custom({
    Expression<int>? id,
    Expression<String>? entityType,
    Expression<int>? refLocalId,
    Expression<String>? fieldsJson,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (refLocalId != null) 'ref_local_id': refLocalId,
      if (fieldsJson != null) 'fields_json': fieldsJson,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DraftsCompanion copyWith({
    Value<int>? id,
    Value<String>? entityType,
    Value<int?>? refLocalId,
    Value<String>? fieldsJson,
    Value<DateTime>? updatedAt,
  }) {
    return DraftsCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      refLocalId: refLocalId ?? this.refLocalId,
      fieldsJson: fieldsJson ?? this.fieldsJson,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (refLocalId.present) {
      map['ref_local_id'] = Variable<int>(refLocalId.value);
    }
    if (fieldsJson.present) {
      map['fields_json'] = Variable<String>(fieldsJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DraftsCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('refLocalId: $refLocalId, ')
          ..write('fieldsJson: $fieldsJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ExtrafieldDefinitionsTable extends ExtrafieldDefinitions
    with TableInfo<$ExtrafieldDefinitionsTable, ExtrafieldDefinitionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExtrafieldDefinitionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldNameMeta = const VerificationMeta(
    'fieldName',
  );
  @override
  late final GeneratedColumn<String> fieldName = GeneratedColumn<String>(
    'field_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requiredMeta = const VerificationMeta(
    'required',
  );
  @override
  late final GeneratedColumn<bool> required = GeneratedColumn<bool>(
    'required',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("required" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _optionsMeta = const VerificationMeta(
    'options',
  );
  @override
  late final GeneratedColumn<String> options = GeneratedColumn<String>(
    'options',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    fieldName,
    label,
    type,
    required,
    options,
    position,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'extrafield_definitions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExtrafieldDefinitionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('field_name')) {
      context.handle(
        _fieldNameMeta,
        fieldName.isAcceptableOrUnknown(data['field_name']!, _fieldNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldNameMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('required')) {
      context.handle(
        _requiredMeta,
        required.isAcceptableOrUnknown(data['required']!, _requiredMeta),
      );
    }
    if (data.containsKey('options')) {
      context.handle(
        _optionsMeta,
        options.isAcceptableOrUnknown(data['options']!, _optionsMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExtrafieldDefinitionRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExtrafieldDefinitionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      fieldName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field_name'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      required: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}required'],
      )!,
      options: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}options'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $ExtrafieldDefinitionsTable createAlias(String alias) {
    return $ExtrafieldDefinitionsTable(attachedDatabase, alias);
  }
}

class ExtrafieldDefinitionRow extends DataClass
    implements Insertable<ExtrafieldDefinitionRow> {
  final int id;

  /// `thirdparty`, `socpeople` (= contact), etc. (cf. Dolibarr).
  final String entityType;
  final String fieldName;
  final String label;

  /// `varchar`, `int`, `date`, `select`, `boolean`, `text`…
  final String type;
  final bool required;

  /// JSON (typiquement la liste d'options pour un select).
  final String? options;
  final int position;
  final DateTime fetchedAt;
  const ExtrafieldDefinitionRow({
    required this.id,
    required this.entityType,
    required this.fieldName,
    required this.label,
    required this.type,
    required this.required,
    this.options,
    required this.position,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['field_name'] = Variable<String>(fieldName);
    map['label'] = Variable<String>(label);
    map['type'] = Variable<String>(type);
    map['required'] = Variable<bool>(required);
    if (!nullToAbsent || options != null) {
      map['options'] = Variable<String>(options);
    }
    map['position'] = Variable<int>(position);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  ExtrafieldDefinitionsCompanion toCompanion(bool nullToAbsent) {
    return ExtrafieldDefinitionsCompanion(
      id: Value(id),
      entityType: Value(entityType),
      fieldName: Value(fieldName),
      label: Value(label),
      type: Value(type),
      required: Value(required),
      options: options == null && nullToAbsent
          ? const Value.absent()
          : Value(options),
      position: Value(position),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory ExtrafieldDefinitionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExtrafieldDefinitionRow(
      id: serializer.fromJson<int>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      fieldName: serializer.fromJson<String>(json['fieldName']),
      label: serializer.fromJson<String>(json['label']),
      type: serializer.fromJson<String>(json['type']),
      required: serializer.fromJson<bool>(json['required']),
      options: serializer.fromJson<String?>(json['options']),
      position: serializer.fromJson<int>(json['position']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityType': serializer.toJson<String>(entityType),
      'fieldName': serializer.toJson<String>(fieldName),
      'label': serializer.toJson<String>(label),
      'type': serializer.toJson<String>(type),
      'required': serializer.toJson<bool>(required),
      'options': serializer.toJson<String?>(options),
      'position': serializer.toJson<int>(position),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  ExtrafieldDefinitionRow copyWith({
    int? id,
    String? entityType,
    String? fieldName,
    String? label,
    String? type,
    bool? required,
    Value<String?> options = const Value.absent(),
    int? position,
    DateTime? fetchedAt,
  }) => ExtrafieldDefinitionRow(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    fieldName: fieldName ?? this.fieldName,
    label: label ?? this.label,
    type: type ?? this.type,
    required: required ?? this.required,
    options: options.present ? options.value : this.options,
    position: position ?? this.position,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  ExtrafieldDefinitionRow copyWithCompanion(
    ExtrafieldDefinitionsCompanion data,
  ) {
    return ExtrafieldDefinitionRow(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      fieldName: data.fieldName.present ? data.fieldName.value : this.fieldName,
      label: data.label.present ? data.label.value : this.label,
      type: data.type.present ? data.type.value : this.type,
      required: data.required.present ? data.required.value : this.required,
      options: data.options.present ? data.options.value : this.options,
      position: data.position.present ? data.position.value : this.position,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExtrafieldDefinitionRow(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('fieldName: $fieldName, ')
          ..write('label: $label, ')
          ..write('type: $type, ')
          ..write('required: $required, ')
          ..write('options: $options, ')
          ..write('position: $position, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    fieldName,
    label,
    type,
    required,
    options,
    position,
    fetchedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExtrafieldDefinitionRow &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.fieldName == this.fieldName &&
          other.label == this.label &&
          other.type == this.type &&
          other.required == this.required &&
          other.options == this.options &&
          other.position == this.position &&
          other.fetchedAt == this.fetchedAt);
}

class ExtrafieldDefinitionsCompanion
    extends UpdateCompanion<ExtrafieldDefinitionRow> {
  final Value<int> id;
  final Value<String> entityType;
  final Value<String> fieldName;
  final Value<String> label;
  final Value<String> type;
  final Value<bool> required;
  final Value<String?> options;
  final Value<int> position;
  final Value<DateTime> fetchedAt;
  const ExtrafieldDefinitionsCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.fieldName = const Value.absent(),
    this.label = const Value.absent(),
    this.type = const Value.absent(),
    this.required = const Value.absent(),
    this.options = const Value.absent(),
    this.position = const Value.absent(),
    this.fetchedAt = const Value.absent(),
  });
  ExtrafieldDefinitionsCompanion.insert({
    this.id = const Value.absent(),
    required String entityType,
    required String fieldName,
    required String label,
    required String type,
    this.required = const Value.absent(),
    this.options = const Value.absent(),
    this.position = const Value.absent(),
    required DateTime fetchedAt,
  }) : entityType = Value(entityType),
       fieldName = Value(fieldName),
       label = Value(label),
       type = Value(type),
       fetchedAt = Value(fetchedAt);
  static Insertable<ExtrafieldDefinitionRow> custom({
    Expression<int>? id,
    Expression<String>? entityType,
    Expression<String>? fieldName,
    Expression<String>? label,
    Expression<String>? type,
    Expression<bool>? required,
    Expression<String>? options,
    Expression<int>? position,
    Expression<DateTime>? fetchedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (fieldName != null) 'field_name': fieldName,
      if (label != null) 'label': label,
      if (type != null) 'type': type,
      if (required != null) 'required': required,
      if (options != null) 'options': options,
      if (position != null) 'position': position,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
    });
  }

  ExtrafieldDefinitionsCompanion copyWith({
    Value<int>? id,
    Value<String>? entityType,
    Value<String>? fieldName,
    Value<String>? label,
    Value<String>? type,
    Value<bool>? required,
    Value<String?>? options,
    Value<int>? position,
    Value<DateTime>? fetchedAt,
  }) {
    return ExtrafieldDefinitionsCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      fieldName: fieldName ?? this.fieldName,
      label: label ?? this.label,
      type: type ?? this.type,
      required: required ?? this.required,
      options: options ?? this.options,
      position: position ?? this.position,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (fieldName.present) {
      map['field_name'] = Variable<String>(fieldName.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (required.present) {
      map['required'] = Variable<bool>(required.value);
    }
    if (options.present) {
      map['options'] = Variable<String>(options.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExtrafieldDefinitionsCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('fieldName: $fieldName, ')
          ..write('label: $label, ')
          ..write('type: $type, ')
          ..write('required: $required, ')
          ..write('options: $options, ')
          ..write('position: $position, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }
}

class $InvoiceLinesTable extends InvoiceLines
    with TableInfo<$InvoiceLinesTable, InvoiceLineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoiceLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<int> remoteId = GeneratedColumn<int>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _invoiceRemoteMeta = const VerificationMeta(
    'invoiceRemote',
  );
  @override
  late final GeneratedColumn<int> invoiceRemote = GeneratedColumn<int>(
    'invoice_remote',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _invoiceLocalMeta = const VerificationMeta(
    'invoiceLocal',
  );
  @override
  late final GeneratedColumn<int> invoiceLocal = GeneratedColumn<int>(
    'invoice_local',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fkProductMeta = const VerificationMeta(
    'fkProduct',
  );
  @override
  late final GeneratedColumn<int> fkProduct = GeneratedColumn<int>(
    'fk_product',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productTypeMeta = const VerificationMeta(
    'productType',
  );
  @override
  late final GeneratedColumn<int> productType = GeneratedColumn<int>(
    'product_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _qtyMeta = const VerificationMeta('qty');
  @override
  late final GeneratedColumn<String> qty = GeneratedColumn<String>(
    'qty',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('1'),
  );
  static const VerificationMeta _subpriceMeta = const VerificationMeta(
    'subprice',
  );
  @override
  late final GeneratedColumn<String> subprice = GeneratedColumn<String>(
    'subprice',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tvaTxMeta = const VerificationMeta('tvaTx');
  @override
  late final GeneratedColumn<String> tvaTx = GeneratedColumn<String>(
    'tva_tx',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remisePercentMeta = const VerificationMeta(
    'remisePercent',
  );
  @override
  late final GeneratedColumn<String> remisePercent = GeneratedColumn<String>(
    'remise_percent',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalHtMeta = const VerificationMeta(
    'totalHt',
  );
  @override
  late final GeneratedColumn<String> totalHt = GeneratedColumn<String>(
    'total_ht',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalTvaMeta = const VerificationMeta(
    'totalTva',
  );
  @override
  late final GeneratedColumn<String> totalTva = GeneratedColumn<String>(
    'total_tva',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalTtcMeta = const VerificationMeta(
    'totalTtc',
  );
  @override
  late final GeneratedColumn<String> totalTtc = GeneratedColumn<String>(
    'total_ttc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rangMeta = const VerificationMeta('rang');
  @override
  late final GeneratedColumn<int> rang = GeneratedColumn<int>(
    'rang',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _extrafieldsMeta = const VerificationMeta(
    'extrafields',
  );
  @override
  late final GeneratedColumn<String> extrafields = GeneratedColumn<String>(
    'extrafields',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _tmsMeta = const VerificationMeta('tms');
  @override
  late final GeneratedColumn<DateTime> tms = GeneratedColumn<DateTime>(
    'tms',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>(
        'local_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: Constant(SyncStatus.synced.index),
      ).withConverter<SyncStatus>($InvoiceLinesTable.$convertersyncStatus);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    remoteId,
    invoiceRemote,
    invoiceLocal,
    fkProduct,
    label,
    description,
    productType,
    qty,
    subprice,
    tvaTx,
    remisePercent,
    totalHt,
    totalTva,
    totalTtc,
    rang,
    extrafields,
    tms,
    localUpdatedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoice_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<InvoiceLineRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('invoice_remote')) {
      context.handle(
        _invoiceRemoteMeta,
        invoiceRemote.isAcceptableOrUnknown(
          data['invoice_remote']!,
          _invoiceRemoteMeta,
        ),
      );
    }
    if (data.containsKey('invoice_local')) {
      context.handle(
        _invoiceLocalMeta,
        invoiceLocal.isAcceptableOrUnknown(
          data['invoice_local']!,
          _invoiceLocalMeta,
        ),
      );
    }
    if (data.containsKey('fk_product')) {
      context.handle(
        _fkProductMeta,
        fkProduct.isAcceptableOrUnknown(data['fk_product']!, _fkProductMeta),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('product_type')) {
      context.handle(
        _productTypeMeta,
        productType.isAcceptableOrUnknown(
          data['product_type']!,
          _productTypeMeta,
        ),
      );
    }
    if (data.containsKey('qty')) {
      context.handle(
        _qtyMeta,
        qty.isAcceptableOrUnknown(data['qty']!, _qtyMeta),
      );
    }
    if (data.containsKey('subprice')) {
      context.handle(
        _subpriceMeta,
        subprice.isAcceptableOrUnknown(data['subprice']!, _subpriceMeta),
      );
    }
    if (data.containsKey('tva_tx')) {
      context.handle(
        _tvaTxMeta,
        tvaTx.isAcceptableOrUnknown(data['tva_tx']!, _tvaTxMeta),
      );
    }
    if (data.containsKey('remise_percent')) {
      context.handle(
        _remisePercentMeta,
        remisePercent.isAcceptableOrUnknown(
          data['remise_percent']!,
          _remisePercentMeta,
        ),
      );
    }
    if (data.containsKey('total_ht')) {
      context.handle(
        _totalHtMeta,
        totalHt.isAcceptableOrUnknown(data['total_ht']!, _totalHtMeta),
      );
    }
    if (data.containsKey('total_tva')) {
      context.handle(
        _totalTvaMeta,
        totalTva.isAcceptableOrUnknown(data['total_tva']!, _totalTvaMeta),
      );
    }
    if (data.containsKey('total_ttc')) {
      context.handle(
        _totalTtcMeta,
        totalTtc.isAcceptableOrUnknown(data['total_ttc']!, _totalTtcMeta),
      );
    }
    if (data.containsKey('rang')) {
      context.handle(
        _rangMeta,
        rang.isAcceptableOrUnknown(data['rang']!, _rangMeta),
      );
    }
    if (data.containsKey('extrafields')) {
      context.handle(
        _extrafieldsMeta,
        extrafields.isAcceptableOrUnknown(
          data['extrafields']!,
          _extrafieldsMeta,
        ),
      );
    }
    if (data.containsKey('tms')) {
      context.handle(
        _tmsMeta,
        tms.isAcceptableOrUnknown(data['tms']!, _tmsMeta),
      );
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InvoiceLineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvoiceLineRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remote_id'],
      ),
      invoiceRemote: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}invoice_remote'],
      ),
      invoiceLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}invoice_local'],
      ),
      fkProduct: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fk_product'],
      ),
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      productType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}product_type'],
      )!,
      qty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}qty'],
      )!,
      subprice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subprice'],
      ),
      tvaTx: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tva_tx'],
      ),
      remisePercent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remise_percent'],
      ),
      totalHt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}total_ht'],
      ),
      totalTva: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}total_tva'],
      ),
      totalTtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}total_ttc'],
      ),
      rang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rang'],
      )!,
      extrafields: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extrafields'],
      )!,
      tms: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}tms'],
      ),
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}local_updated_at'],
      )!,
      syncStatus: $InvoiceLinesTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
    );
  }

  @override
  $InvoiceLinesTable createAlias(String alias) {
    return $InvoiceLinesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class InvoiceLineRow extends DataClass implements Insertable<InvoiceLineRow> {
  final int id;

  /// `rowid` Dolibarr de la ligne (`llx_facturedet.rowid`).
  final int? remoteId;

  /// `fk_facture` côté Dolibarr (rowid de la facture parente).
  final int? invoiceRemote;

  /// FK locale vers Invoices.id quand la facture parente est encore
  /// en pendingCreate (cascade Outbox 2ᵉ niveau pour les factures).
  final int? invoiceLocal;
  final int? fkProduct;
  final String? label;
  final String? description;

  /// 0=produit, 1=service.
  final int productType;
  final String qty;
  final String? subprice;
  final String? tvaTx;
  final String? remisePercent;
  final String? totalHt;
  final String? totalTva;
  final String? totalTtc;
  final int rang;
  final String extrafields;
  final DateTime? tms;
  final DateTime localUpdatedAt;
  final SyncStatus syncStatus;
  const InvoiceLineRow({
    required this.id,
    this.remoteId,
    this.invoiceRemote,
    this.invoiceLocal,
    this.fkProduct,
    this.label,
    this.description,
    required this.productType,
    required this.qty,
    this.subprice,
    this.tvaTx,
    this.remisePercent,
    this.totalHt,
    this.totalTva,
    this.totalTtc,
    required this.rang,
    required this.extrafields,
    this.tms,
    required this.localUpdatedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<int>(remoteId);
    }
    if (!nullToAbsent || invoiceRemote != null) {
      map['invoice_remote'] = Variable<int>(invoiceRemote);
    }
    if (!nullToAbsent || invoiceLocal != null) {
      map['invoice_local'] = Variable<int>(invoiceLocal);
    }
    if (!nullToAbsent || fkProduct != null) {
      map['fk_product'] = Variable<int>(fkProduct);
    }
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['product_type'] = Variable<int>(productType);
    map['qty'] = Variable<String>(qty);
    if (!nullToAbsent || subprice != null) {
      map['subprice'] = Variable<String>(subprice);
    }
    if (!nullToAbsent || tvaTx != null) {
      map['tva_tx'] = Variable<String>(tvaTx);
    }
    if (!nullToAbsent || remisePercent != null) {
      map['remise_percent'] = Variable<String>(remisePercent);
    }
    if (!nullToAbsent || totalHt != null) {
      map['total_ht'] = Variable<String>(totalHt);
    }
    if (!nullToAbsent || totalTva != null) {
      map['total_tva'] = Variable<String>(totalTva);
    }
    if (!nullToAbsent || totalTtc != null) {
      map['total_ttc'] = Variable<String>(totalTtc);
    }
    map['rang'] = Variable<int>(rang);
    map['extrafields'] = Variable<String>(extrafields);
    if (!nullToAbsent || tms != null) {
      map['tms'] = Variable<DateTime>(tms);
    }
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    {
      map['sync_status'] = Variable<int>(
        $InvoiceLinesTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    return map;
  }

  InvoiceLinesCompanion toCompanion(bool nullToAbsent) {
    return InvoiceLinesCompanion(
      id: Value(id),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      invoiceRemote: invoiceRemote == null && nullToAbsent
          ? const Value.absent()
          : Value(invoiceRemote),
      invoiceLocal: invoiceLocal == null && nullToAbsent
          ? const Value.absent()
          : Value(invoiceLocal),
      fkProduct: fkProduct == null && nullToAbsent
          ? const Value.absent()
          : Value(fkProduct),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      productType: Value(productType),
      qty: Value(qty),
      subprice: subprice == null && nullToAbsent
          ? const Value.absent()
          : Value(subprice),
      tvaTx: tvaTx == null && nullToAbsent
          ? const Value.absent()
          : Value(tvaTx),
      remisePercent: remisePercent == null && nullToAbsent
          ? const Value.absent()
          : Value(remisePercent),
      totalHt: totalHt == null && nullToAbsent
          ? const Value.absent()
          : Value(totalHt),
      totalTva: totalTva == null && nullToAbsent
          ? const Value.absent()
          : Value(totalTva),
      totalTtc: totalTtc == null && nullToAbsent
          ? const Value.absent()
          : Value(totalTtc),
      rang: Value(rang),
      extrafields: Value(extrafields),
      tms: tms == null && nullToAbsent ? const Value.absent() : Value(tms),
      localUpdatedAt: Value(localUpdatedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory InvoiceLineRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvoiceLineRow(
      id: serializer.fromJson<int>(json['id']),
      remoteId: serializer.fromJson<int?>(json['remoteId']),
      invoiceRemote: serializer.fromJson<int?>(json['invoiceRemote']),
      invoiceLocal: serializer.fromJson<int?>(json['invoiceLocal']),
      fkProduct: serializer.fromJson<int?>(json['fkProduct']),
      label: serializer.fromJson<String?>(json['label']),
      description: serializer.fromJson<String?>(json['description']),
      productType: serializer.fromJson<int>(json['productType']),
      qty: serializer.fromJson<String>(json['qty']),
      subprice: serializer.fromJson<String?>(json['subprice']),
      tvaTx: serializer.fromJson<String?>(json['tvaTx']),
      remisePercent: serializer.fromJson<String?>(json['remisePercent']),
      totalHt: serializer.fromJson<String?>(json['totalHt']),
      totalTva: serializer.fromJson<String?>(json['totalTva']),
      totalTtc: serializer.fromJson<String?>(json['totalTtc']),
      rang: serializer.fromJson<int>(json['rang']),
      extrafields: serializer.fromJson<String>(json['extrafields']),
      tms: serializer.fromJson<DateTime?>(json['tms']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      syncStatus: $InvoiceLinesTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'remoteId': serializer.toJson<int?>(remoteId),
      'invoiceRemote': serializer.toJson<int?>(invoiceRemote),
      'invoiceLocal': serializer.toJson<int?>(invoiceLocal),
      'fkProduct': serializer.toJson<int?>(fkProduct),
      'label': serializer.toJson<String?>(label),
      'description': serializer.toJson<String?>(description),
      'productType': serializer.toJson<int>(productType),
      'qty': serializer.toJson<String>(qty),
      'subprice': serializer.toJson<String?>(subprice),
      'tvaTx': serializer.toJson<String?>(tvaTx),
      'remisePercent': serializer.toJson<String?>(remisePercent),
      'totalHt': serializer.toJson<String?>(totalHt),
      'totalTva': serializer.toJson<String?>(totalTva),
      'totalTtc': serializer.toJson<String?>(totalTtc),
      'rang': serializer.toJson<int>(rang),
      'extrafields': serializer.toJson<String>(extrafields),
      'tms': serializer.toJson<DateTime?>(tms),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'syncStatus': serializer.toJson<int>(
        $InvoiceLinesTable.$convertersyncStatus.toJson(syncStatus),
      ),
    };
  }

  InvoiceLineRow copyWith({
    int? id,
    Value<int?> remoteId = const Value.absent(),
    Value<int?> invoiceRemote = const Value.absent(),
    Value<int?> invoiceLocal = const Value.absent(),
    Value<int?> fkProduct = const Value.absent(),
    Value<String?> label = const Value.absent(),
    Value<String?> description = const Value.absent(),
    int? productType,
    String? qty,
    Value<String?> subprice = const Value.absent(),
    Value<String?> tvaTx = const Value.absent(),
    Value<String?> remisePercent = const Value.absent(),
    Value<String?> totalHt = const Value.absent(),
    Value<String?> totalTva = const Value.absent(),
    Value<String?> totalTtc = const Value.absent(),
    int? rang,
    String? extrafields,
    Value<DateTime?> tms = const Value.absent(),
    DateTime? localUpdatedAt,
    SyncStatus? syncStatus,
  }) => InvoiceLineRow(
    id: id ?? this.id,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    invoiceRemote: invoiceRemote.present
        ? invoiceRemote.value
        : this.invoiceRemote,
    invoiceLocal: invoiceLocal.present ? invoiceLocal.value : this.invoiceLocal,
    fkProduct: fkProduct.present ? fkProduct.value : this.fkProduct,
    label: label.present ? label.value : this.label,
    description: description.present ? description.value : this.description,
    productType: productType ?? this.productType,
    qty: qty ?? this.qty,
    subprice: subprice.present ? subprice.value : this.subprice,
    tvaTx: tvaTx.present ? tvaTx.value : this.tvaTx,
    remisePercent: remisePercent.present
        ? remisePercent.value
        : this.remisePercent,
    totalHt: totalHt.present ? totalHt.value : this.totalHt,
    totalTva: totalTva.present ? totalTva.value : this.totalTva,
    totalTtc: totalTtc.present ? totalTtc.value : this.totalTtc,
    rang: rang ?? this.rang,
    extrafields: extrafields ?? this.extrafields,
    tms: tms.present ? tms.value : this.tms,
    localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  InvoiceLineRow copyWithCompanion(InvoiceLinesCompanion data) {
    return InvoiceLineRow(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      invoiceRemote: data.invoiceRemote.present
          ? data.invoiceRemote.value
          : this.invoiceRemote,
      invoiceLocal: data.invoiceLocal.present
          ? data.invoiceLocal.value
          : this.invoiceLocal,
      fkProduct: data.fkProduct.present ? data.fkProduct.value : this.fkProduct,
      label: data.label.present ? data.label.value : this.label,
      description: data.description.present
          ? data.description.value
          : this.description,
      productType: data.productType.present
          ? data.productType.value
          : this.productType,
      qty: data.qty.present ? data.qty.value : this.qty,
      subprice: data.subprice.present ? data.subprice.value : this.subprice,
      tvaTx: data.tvaTx.present ? data.tvaTx.value : this.tvaTx,
      remisePercent: data.remisePercent.present
          ? data.remisePercent.value
          : this.remisePercent,
      totalHt: data.totalHt.present ? data.totalHt.value : this.totalHt,
      totalTva: data.totalTva.present ? data.totalTva.value : this.totalTva,
      totalTtc: data.totalTtc.present ? data.totalTtc.value : this.totalTtc,
      rang: data.rang.present ? data.rang.value : this.rang,
      extrafields: data.extrafields.present
          ? data.extrafields.value
          : this.extrafields,
      tms: data.tms.present ? data.tms.value : this.tms,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceLineRow(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('invoiceRemote: $invoiceRemote, ')
          ..write('invoiceLocal: $invoiceLocal, ')
          ..write('fkProduct: $fkProduct, ')
          ..write('label: $label, ')
          ..write('description: $description, ')
          ..write('productType: $productType, ')
          ..write('qty: $qty, ')
          ..write('subprice: $subprice, ')
          ..write('tvaTx: $tvaTx, ')
          ..write('remisePercent: $remisePercent, ')
          ..write('totalHt: $totalHt, ')
          ..write('totalTva: $totalTva, ')
          ..write('totalTtc: $totalTtc, ')
          ..write('rang: $rang, ')
          ..write('extrafields: $extrafields, ')
          ..write('tms: $tms, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    remoteId,
    invoiceRemote,
    invoiceLocal,
    fkProduct,
    label,
    description,
    productType,
    qty,
    subprice,
    tvaTx,
    remisePercent,
    totalHt,
    totalTva,
    totalTtc,
    rang,
    extrafields,
    tms,
    localUpdatedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvoiceLineRow &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.invoiceRemote == this.invoiceRemote &&
          other.invoiceLocal == this.invoiceLocal &&
          other.fkProduct == this.fkProduct &&
          other.label == this.label &&
          other.description == this.description &&
          other.productType == this.productType &&
          other.qty == this.qty &&
          other.subprice == this.subprice &&
          other.tvaTx == this.tvaTx &&
          other.remisePercent == this.remisePercent &&
          other.totalHt == this.totalHt &&
          other.totalTva == this.totalTva &&
          other.totalTtc == this.totalTtc &&
          other.rang == this.rang &&
          other.extrafields == this.extrafields &&
          other.tms == this.tms &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.syncStatus == this.syncStatus);
}

class InvoiceLinesCompanion extends UpdateCompanion<InvoiceLineRow> {
  final Value<int> id;
  final Value<int?> remoteId;
  final Value<int?> invoiceRemote;
  final Value<int?> invoiceLocal;
  final Value<int?> fkProduct;
  final Value<String?> label;
  final Value<String?> description;
  final Value<int> productType;
  final Value<String> qty;
  final Value<String?> subprice;
  final Value<String?> tvaTx;
  final Value<String?> remisePercent;
  final Value<String?> totalHt;
  final Value<String?> totalTva;
  final Value<String?> totalTtc;
  final Value<int> rang;
  final Value<String> extrafields;
  final Value<DateTime?> tms;
  final Value<DateTime> localUpdatedAt;
  final Value<SyncStatus> syncStatus;
  const InvoiceLinesCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.invoiceRemote = const Value.absent(),
    this.invoiceLocal = const Value.absent(),
    this.fkProduct = const Value.absent(),
    this.label = const Value.absent(),
    this.description = const Value.absent(),
    this.productType = const Value.absent(),
    this.qty = const Value.absent(),
    this.subprice = const Value.absent(),
    this.tvaTx = const Value.absent(),
    this.remisePercent = const Value.absent(),
    this.totalHt = const Value.absent(),
    this.totalTva = const Value.absent(),
    this.totalTtc = const Value.absent(),
    this.rang = const Value.absent(),
    this.extrafields = const Value.absent(),
    this.tms = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
  });
  InvoiceLinesCompanion.insert({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.invoiceRemote = const Value.absent(),
    this.invoiceLocal = const Value.absent(),
    this.fkProduct = const Value.absent(),
    this.label = const Value.absent(),
    this.description = const Value.absent(),
    this.productType = const Value.absent(),
    this.qty = const Value.absent(),
    this.subprice = const Value.absent(),
    this.tvaTx = const Value.absent(),
    this.remisePercent = const Value.absent(),
    this.totalHt = const Value.absent(),
    this.totalTva = const Value.absent(),
    this.totalTtc = const Value.absent(),
    this.rang = const Value.absent(),
    this.extrafields = const Value.absent(),
    this.tms = const Value.absent(),
    required DateTime localUpdatedAt,
    this.syncStatus = const Value.absent(),
  }) : localUpdatedAt = Value(localUpdatedAt);
  static Insertable<InvoiceLineRow> custom({
    Expression<int>? id,
    Expression<int>? remoteId,
    Expression<int>? invoiceRemote,
    Expression<int>? invoiceLocal,
    Expression<int>? fkProduct,
    Expression<String>? label,
    Expression<String>? description,
    Expression<int>? productType,
    Expression<String>? qty,
    Expression<String>? subprice,
    Expression<String>? tvaTx,
    Expression<String>? remisePercent,
    Expression<String>? totalHt,
    Expression<String>? totalTva,
    Expression<String>? totalTtc,
    Expression<int>? rang,
    Expression<String>? extrafields,
    Expression<DateTime>? tms,
    Expression<DateTime>? localUpdatedAt,
    Expression<int>? syncStatus,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (invoiceRemote != null) 'invoice_remote': invoiceRemote,
      if (invoiceLocal != null) 'invoice_local': invoiceLocal,
      if (fkProduct != null) 'fk_product': fkProduct,
      if (label != null) 'label': label,
      if (description != null) 'description': description,
      if (productType != null) 'product_type': productType,
      if (qty != null) 'qty': qty,
      if (subprice != null) 'subprice': subprice,
      if (tvaTx != null) 'tva_tx': tvaTx,
      if (remisePercent != null) 'remise_percent': remisePercent,
      if (totalHt != null) 'total_ht': totalHt,
      if (totalTva != null) 'total_tva': totalTva,
      if (totalTtc != null) 'total_ttc': totalTtc,
      if (rang != null) 'rang': rang,
      if (extrafields != null) 'extrafields': extrafields,
      if (tms != null) 'tms': tms,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
    });
  }

  InvoiceLinesCompanion copyWith({
    Value<int>? id,
    Value<int?>? remoteId,
    Value<int?>? invoiceRemote,
    Value<int?>? invoiceLocal,
    Value<int?>? fkProduct,
    Value<String?>? label,
    Value<String?>? description,
    Value<int>? productType,
    Value<String>? qty,
    Value<String?>? subprice,
    Value<String?>? tvaTx,
    Value<String?>? remisePercent,
    Value<String?>? totalHt,
    Value<String?>? totalTva,
    Value<String?>? totalTtc,
    Value<int>? rang,
    Value<String>? extrafields,
    Value<DateTime?>? tms,
    Value<DateTime>? localUpdatedAt,
    Value<SyncStatus>? syncStatus,
  }) {
    return InvoiceLinesCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      invoiceRemote: invoiceRemote ?? this.invoiceRemote,
      invoiceLocal: invoiceLocal ?? this.invoiceLocal,
      fkProduct: fkProduct ?? this.fkProduct,
      label: label ?? this.label,
      description: description ?? this.description,
      productType: productType ?? this.productType,
      qty: qty ?? this.qty,
      subprice: subprice ?? this.subprice,
      tvaTx: tvaTx ?? this.tvaTx,
      remisePercent: remisePercent ?? this.remisePercent,
      totalHt: totalHt ?? this.totalHt,
      totalTva: totalTva ?? this.totalTva,
      totalTtc: totalTtc ?? this.totalTtc,
      rang: rang ?? this.rang,
      extrafields: extrafields ?? this.extrafields,
      tms: tms ?? this.tms,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<int>(remoteId.value);
    }
    if (invoiceRemote.present) {
      map['invoice_remote'] = Variable<int>(invoiceRemote.value);
    }
    if (invoiceLocal.present) {
      map['invoice_local'] = Variable<int>(invoiceLocal.value);
    }
    if (fkProduct.present) {
      map['fk_product'] = Variable<int>(fkProduct.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (productType.present) {
      map['product_type'] = Variable<int>(productType.value);
    }
    if (qty.present) {
      map['qty'] = Variable<String>(qty.value);
    }
    if (subprice.present) {
      map['subprice'] = Variable<String>(subprice.value);
    }
    if (tvaTx.present) {
      map['tva_tx'] = Variable<String>(tvaTx.value);
    }
    if (remisePercent.present) {
      map['remise_percent'] = Variable<String>(remisePercent.value);
    }
    if (totalHt.present) {
      map['total_ht'] = Variable<String>(totalHt.value);
    }
    if (totalTva.present) {
      map['total_tva'] = Variable<String>(totalTva.value);
    }
    if (totalTtc.present) {
      map['total_ttc'] = Variable<String>(totalTtc.value);
    }
    if (rang.present) {
      map['rang'] = Variable<int>(rang.value);
    }
    if (extrafields.present) {
      map['extrafields'] = Variable<String>(extrafields.value);
    }
    if (tms.present) {
      map['tms'] = Variable<DateTime>(tms.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $InvoiceLinesTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceLinesCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('invoiceRemote: $invoiceRemote, ')
          ..write('invoiceLocal: $invoiceLocal, ')
          ..write('fkProduct: $fkProduct, ')
          ..write('label: $label, ')
          ..write('description: $description, ')
          ..write('productType: $productType, ')
          ..write('qty: $qty, ')
          ..write('subprice: $subprice, ')
          ..write('tvaTx: $tvaTx, ')
          ..write('remisePercent: $remisePercent, ')
          ..write('totalHt: $totalHt, ')
          ..write('totalTva: $totalTva, ')
          ..write('totalTtc: $totalTtc, ')
          ..write('rang: $rang, ')
          ..write('extrafields: $extrafields, ')
          ..write('tms: $tms, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }
}

class $InvoicesTable extends Invoices
    with TableInfo<$InvoicesTable, InvoiceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<int> remoteId = GeneratedColumn<int>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _socidRemoteMeta = const VerificationMeta(
    'socidRemote',
  );
  @override
  late final GeneratedColumn<int> socidRemote = GeneratedColumn<int>(
    'socid_remote',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _socidLocalMeta = const VerificationMeta(
    'socidLocal',
  );
  @override
  late final GeneratedColumn<int> socidLocal = GeneratedColumn<int>(
    'socid_local',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _refMeta = const VerificationMeta('ref');
  @override
  late final GeneratedColumn<String> ref = GeneratedColumn<String>(
    'ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _refClientMeta = const VerificationMeta(
    'refClient',
  );
  @override
  late final GeneratedColumn<String> refClient = GeneratedColumn<String>(
    'ref_client',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _payeMeta = const VerificationMeta('paye');
  @override
  late final GeneratedColumn<int> paye = GeneratedColumn<int>(
    'paye',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dateInvoiceMeta = const VerificationMeta(
    'dateInvoice',
  );
  @override
  late final GeneratedColumn<DateTime> dateInvoice = GeneratedColumn<DateTime>(
    'date_invoice',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateDueMeta = const VerificationMeta(
    'dateDue',
  );
  @override
  late final GeneratedColumn<DateTime> dateDue = GeneratedColumn<DateTime>(
    'date_due',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalHtMeta = const VerificationMeta(
    'totalHt',
  );
  @override
  late final GeneratedColumn<String> totalHt = GeneratedColumn<String>(
    'total_ht',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalTvaMeta = const VerificationMeta(
    'totalTva',
  );
  @override
  late final GeneratedColumn<String> totalTva = GeneratedColumn<String>(
    'total_tva',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalTtcMeta = const VerificationMeta(
    'totalTtc',
  );
  @override
  late final GeneratedColumn<String> totalTtc = GeneratedColumn<String>(
    'total_ttc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fkModeReglementMeta = const VerificationMeta(
    'fkModeReglement',
  );
  @override
  late final GeneratedColumn<int> fkModeReglement = GeneratedColumn<int>(
    'fk_mode_reglement',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fkCondReglementMeta = const VerificationMeta(
    'fkCondReglement',
  );
  @override
  late final GeneratedColumn<int> fkCondReglement = GeneratedColumn<int>(
    'fk_cond_reglement',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notePublicMeta = const VerificationMeta(
    'notePublic',
  );
  @override
  late final GeneratedColumn<String> notePublic = GeneratedColumn<String>(
    'note_public',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notePrivateMeta = const VerificationMeta(
    'notePrivate',
  );
  @override
  late final GeneratedColumn<String> notePrivate = GeneratedColumn<String>(
    'note_private',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _extrafieldsMeta = const VerificationMeta(
    'extrafields',
  );
  @override
  late final GeneratedColumn<String> extrafields = GeneratedColumn<String>(
    'extrafields',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _rawJsonMeta = const VerificationMeta(
    'rawJson',
  );
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
    'raw_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tmsMeta = const VerificationMeta('tms');
  @override
  late final GeneratedColumn<DateTime> tms = GeneratedColumn<DateTime>(
    'tms',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>(
        'local_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: Constant(SyncStatus.synced.index),
      ).withConverter<SyncStatus>($InvoicesTable.$convertersyncStatus);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    remoteId,
    socidRemote,
    socidLocal,
    ref,
    refClient,
    type,
    status,
    paye,
    dateInvoice,
    dateDue,
    totalHt,
    totalTva,
    totalTtc,
    fkModeReglement,
    fkCondReglement,
    notePublic,
    notePrivate,
    extrafields,
    rawJson,
    tms,
    localUpdatedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoices';
  @override
  VerificationContext validateIntegrity(
    Insertable<InvoiceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('socid_remote')) {
      context.handle(
        _socidRemoteMeta,
        socidRemote.isAcceptableOrUnknown(
          data['socid_remote']!,
          _socidRemoteMeta,
        ),
      );
    }
    if (data.containsKey('socid_local')) {
      context.handle(
        _socidLocalMeta,
        socidLocal.isAcceptableOrUnknown(data['socid_local']!, _socidLocalMeta),
      );
    }
    if (data.containsKey('ref')) {
      context.handle(
        _refMeta,
        ref.isAcceptableOrUnknown(data['ref']!, _refMeta),
      );
    }
    if (data.containsKey('ref_client')) {
      context.handle(
        _refClientMeta,
        refClient.isAcceptableOrUnknown(data['ref_client']!, _refClientMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('paye')) {
      context.handle(
        _payeMeta,
        paye.isAcceptableOrUnknown(data['paye']!, _payeMeta),
      );
    }
    if (data.containsKey('date_invoice')) {
      context.handle(
        _dateInvoiceMeta,
        dateInvoice.isAcceptableOrUnknown(
          data['date_invoice']!,
          _dateInvoiceMeta,
        ),
      );
    }
    if (data.containsKey('date_due')) {
      context.handle(
        _dateDueMeta,
        dateDue.isAcceptableOrUnknown(data['date_due']!, _dateDueMeta),
      );
    }
    if (data.containsKey('total_ht')) {
      context.handle(
        _totalHtMeta,
        totalHt.isAcceptableOrUnknown(data['total_ht']!, _totalHtMeta),
      );
    }
    if (data.containsKey('total_tva')) {
      context.handle(
        _totalTvaMeta,
        totalTva.isAcceptableOrUnknown(data['total_tva']!, _totalTvaMeta),
      );
    }
    if (data.containsKey('total_ttc')) {
      context.handle(
        _totalTtcMeta,
        totalTtc.isAcceptableOrUnknown(data['total_ttc']!, _totalTtcMeta),
      );
    }
    if (data.containsKey('fk_mode_reglement')) {
      context.handle(
        _fkModeReglementMeta,
        fkModeReglement.isAcceptableOrUnknown(
          data['fk_mode_reglement']!,
          _fkModeReglementMeta,
        ),
      );
    }
    if (data.containsKey('fk_cond_reglement')) {
      context.handle(
        _fkCondReglementMeta,
        fkCondReglement.isAcceptableOrUnknown(
          data['fk_cond_reglement']!,
          _fkCondReglementMeta,
        ),
      );
    }
    if (data.containsKey('note_public')) {
      context.handle(
        _notePublicMeta,
        notePublic.isAcceptableOrUnknown(data['note_public']!, _notePublicMeta),
      );
    }
    if (data.containsKey('note_private')) {
      context.handle(
        _notePrivateMeta,
        notePrivate.isAcceptableOrUnknown(
          data['note_private']!,
          _notePrivateMeta,
        ),
      );
    }
    if (data.containsKey('extrafields')) {
      context.handle(
        _extrafieldsMeta,
        extrafields.isAcceptableOrUnknown(
          data['extrafields']!,
          _extrafieldsMeta,
        ),
      );
    }
    if (data.containsKey('raw_json')) {
      context.handle(
        _rawJsonMeta,
        rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta),
      );
    }
    if (data.containsKey('tms')) {
      context.handle(
        _tmsMeta,
        tms.isAcceptableOrUnknown(data['tms']!, _tmsMeta),
      );
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InvoiceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvoiceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remote_id'],
      ),
      socidRemote: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}socid_remote'],
      ),
      socidLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}socid_local'],
      ),
      ref: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref'],
      ),
      refClient: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref_client'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      paye: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paye'],
      )!,
      dateInvoice: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_invoice'],
      ),
      dateDue: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_due'],
      ),
      totalHt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}total_ht'],
      ),
      totalTva: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}total_tva'],
      ),
      totalTtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}total_ttc'],
      ),
      fkModeReglement: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fk_mode_reglement'],
      ),
      fkCondReglement: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fk_cond_reglement'],
      ),
      notePublic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_public'],
      ),
      notePrivate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_private'],
      ),
      extrafields: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extrafields'],
      )!,
      rawJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_json'],
      ),
      tms: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}tms'],
      ),
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}local_updated_at'],
      )!,
      syncStatus: $InvoicesTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
    );
  }

  @override
  $InvoicesTable createAlias(String alias) {
    return $InvoicesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class InvoiceRow extends DataClass implements Insertable<InvoiceRow> {
  final int id;
  final int? remoteId;

  /// `socid` côté Dolibarr — tiers (client) facturé.
  final int? socidRemote;
  final int? socidLocal;

  /// Référence Dolibarr (ex : `FA2026-0042`). Générée au passage à
  /// l'état validé.
  final String? ref;

  /// Référence interne client (saisie libre).
  final String? refClient;

  /// Type Dolibarr : 0=standard, 1=replacement, 2=credit_note,
  /// 3=deposit, 4=proforma, 5=situation.
  final int type;

  /// Statut Dolibarr : 0=brouillon, 1=validée, 2=payée, 3=abandonnée.
  final int status;

  /// Flag payé : 0=impayée, 1=payée.
  final int paye;

  /// Date facture (création comptable).
  final DateTime? dateInvoice;

  /// Date d'échéance.
  final DateTime? dateDue;
  final String? totalHt;
  final String? totalTva;
  final String? totalTtc;
  final int? fkModeReglement;
  final int? fkCondReglement;
  final String? notePublic;
  final String? notePrivate;
  final String extrafields;
  final String? rawJson;
  final DateTime? tms;
  final DateTime localUpdatedAt;
  final SyncStatus syncStatus;
  const InvoiceRow({
    required this.id,
    this.remoteId,
    this.socidRemote,
    this.socidLocal,
    this.ref,
    this.refClient,
    required this.type,
    required this.status,
    required this.paye,
    this.dateInvoice,
    this.dateDue,
    this.totalHt,
    this.totalTva,
    this.totalTtc,
    this.fkModeReglement,
    this.fkCondReglement,
    this.notePublic,
    this.notePrivate,
    required this.extrafields,
    this.rawJson,
    this.tms,
    required this.localUpdatedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<int>(remoteId);
    }
    if (!nullToAbsent || socidRemote != null) {
      map['socid_remote'] = Variable<int>(socidRemote);
    }
    if (!nullToAbsent || socidLocal != null) {
      map['socid_local'] = Variable<int>(socidLocal);
    }
    if (!nullToAbsent || ref != null) {
      map['ref'] = Variable<String>(ref);
    }
    if (!nullToAbsent || refClient != null) {
      map['ref_client'] = Variable<String>(refClient);
    }
    map['type'] = Variable<int>(type);
    map['status'] = Variable<int>(status);
    map['paye'] = Variable<int>(paye);
    if (!nullToAbsent || dateInvoice != null) {
      map['date_invoice'] = Variable<DateTime>(dateInvoice);
    }
    if (!nullToAbsent || dateDue != null) {
      map['date_due'] = Variable<DateTime>(dateDue);
    }
    if (!nullToAbsent || totalHt != null) {
      map['total_ht'] = Variable<String>(totalHt);
    }
    if (!nullToAbsent || totalTva != null) {
      map['total_tva'] = Variable<String>(totalTva);
    }
    if (!nullToAbsent || totalTtc != null) {
      map['total_ttc'] = Variable<String>(totalTtc);
    }
    if (!nullToAbsent || fkModeReglement != null) {
      map['fk_mode_reglement'] = Variable<int>(fkModeReglement);
    }
    if (!nullToAbsent || fkCondReglement != null) {
      map['fk_cond_reglement'] = Variable<int>(fkCondReglement);
    }
    if (!nullToAbsent || notePublic != null) {
      map['note_public'] = Variable<String>(notePublic);
    }
    if (!nullToAbsent || notePrivate != null) {
      map['note_private'] = Variable<String>(notePrivate);
    }
    map['extrafields'] = Variable<String>(extrafields);
    if (!nullToAbsent || rawJson != null) {
      map['raw_json'] = Variable<String>(rawJson);
    }
    if (!nullToAbsent || tms != null) {
      map['tms'] = Variable<DateTime>(tms);
    }
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    {
      map['sync_status'] = Variable<int>(
        $InvoicesTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    return map;
  }

  InvoicesCompanion toCompanion(bool nullToAbsent) {
    return InvoicesCompanion(
      id: Value(id),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      socidRemote: socidRemote == null && nullToAbsent
          ? const Value.absent()
          : Value(socidRemote),
      socidLocal: socidLocal == null && nullToAbsent
          ? const Value.absent()
          : Value(socidLocal),
      ref: ref == null && nullToAbsent ? const Value.absent() : Value(ref),
      refClient: refClient == null && nullToAbsent
          ? const Value.absent()
          : Value(refClient),
      type: Value(type),
      status: Value(status),
      paye: Value(paye),
      dateInvoice: dateInvoice == null && nullToAbsent
          ? const Value.absent()
          : Value(dateInvoice),
      dateDue: dateDue == null && nullToAbsent
          ? const Value.absent()
          : Value(dateDue),
      totalHt: totalHt == null && nullToAbsent
          ? const Value.absent()
          : Value(totalHt),
      totalTva: totalTva == null && nullToAbsent
          ? const Value.absent()
          : Value(totalTva),
      totalTtc: totalTtc == null && nullToAbsent
          ? const Value.absent()
          : Value(totalTtc),
      fkModeReglement: fkModeReglement == null && nullToAbsent
          ? const Value.absent()
          : Value(fkModeReglement),
      fkCondReglement: fkCondReglement == null && nullToAbsent
          ? const Value.absent()
          : Value(fkCondReglement),
      notePublic: notePublic == null && nullToAbsent
          ? const Value.absent()
          : Value(notePublic),
      notePrivate: notePrivate == null && nullToAbsent
          ? const Value.absent()
          : Value(notePrivate),
      extrafields: Value(extrafields),
      rawJson: rawJson == null && nullToAbsent
          ? const Value.absent()
          : Value(rawJson),
      tms: tms == null && nullToAbsent ? const Value.absent() : Value(tms),
      localUpdatedAt: Value(localUpdatedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory InvoiceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvoiceRow(
      id: serializer.fromJson<int>(json['id']),
      remoteId: serializer.fromJson<int?>(json['remoteId']),
      socidRemote: serializer.fromJson<int?>(json['socidRemote']),
      socidLocal: serializer.fromJson<int?>(json['socidLocal']),
      ref: serializer.fromJson<String?>(json['ref']),
      refClient: serializer.fromJson<String?>(json['refClient']),
      type: serializer.fromJson<int>(json['type']),
      status: serializer.fromJson<int>(json['status']),
      paye: serializer.fromJson<int>(json['paye']),
      dateInvoice: serializer.fromJson<DateTime?>(json['dateInvoice']),
      dateDue: serializer.fromJson<DateTime?>(json['dateDue']),
      totalHt: serializer.fromJson<String?>(json['totalHt']),
      totalTva: serializer.fromJson<String?>(json['totalTva']),
      totalTtc: serializer.fromJson<String?>(json['totalTtc']),
      fkModeReglement: serializer.fromJson<int?>(json['fkModeReglement']),
      fkCondReglement: serializer.fromJson<int?>(json['fkCondReglement']),
      notePublic: serializer.fromJson<String?>(json['notePublic']),
      notePrivate: serializer.fromJson<String?>(json['notePrivate']),
      extrafields: serializer.fromJson<String>(json['extrafields']),
      rawJson: serializer.fromJson<String?>(json['rawJson']),
      tms: serializer.fromJson<DateTime?>(json['tms']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      syncStatus: $InvoicesTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'remoteId': serializer.toJson<int?>(remoteId),
      'socidRemote': serializer.toJson<int?>(socidRemote),
      'socidLocal': serializer.toJson<int?>(socidLocal),
      'ref': serializer.toJson<String?>(ref),
      'refClient': serializer.toJson<String?>(refClient),
      'type': serializer.toJson<int>(type),
      'status': serializer.toJson<int>(status),
      'paye': serializer.toJson<int>(paye),
      'dateInvoice': serializer.toJson<DateTime?>(dateInvoice),
      'dateDue': serializer.toJson<DateTime?>(dateDue),
      'totalHt': serializer.toJson<String?>(totalHt),
      'totalTva': serializer.toJson<String?>(totalTva),
      'totalTtc': serializer.toJson<String?>(totalTtc),
      'fkModeReglement': serializer.toJson<int?>(fkModeReglement),
      'fkCondReglement': serializer.toJson<int?>(fkCondReglement),
      'notePublic': serializer.toJson<String?>(notePublic),
      'notePrivate': serializer.toJson<String?>(notePrivate),
      'extrafields': serializer.toJson<String>(extrafields),
      'rawJson': serializer.toJson<String?>(rawJson),
      'tms': serializer.toJson<DateTime?>(tms),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'syncStatus': serializer.toJson<int>(
        $InvoicesTable.$convertersyncStatus.toJson(syncStatus),
      ),
    };
  }

  InvoiceRow copyWith({
    int? id,
    Value<int?> remoteId = const Value.absent(),
    Value<int?> socidRemote = const Value.absent(),
    Value<int?> socidLocal = const Value.absent(),
    Value<String?> ref = const Value.absent(),
    Value<String?> refClient = const Value.absent(),
    int? type,
    int? status,
    int? paye,
    Value<DateTime?> dateInvoice = const Value.absent(),
    Value<DateTime?> dateDue = const Value.absent(),
    Value<String?> totalHt = const Value.absent(),
    Value<String?> totalTva = const Value.absent(),
    Value<String?> totalTtc = const Value.absent(),
    Value<int?> fkModeReglement = const Value.absent(),
    Value<int?> fkCondReglement = const Value.absent(),
    Value<String?> notePublic = const Value.absent(),
    Value<String?> notePrivate = const Value.absent(),
    String? extrafields,
    Value<String?> rawJson = const Value.absent(),
    Value<DateTime?> tms = const Value.absent(),
    DateTime? localUpdatedAt,
    SyncStatus? syncStatus,
  }) => InvoiceRow(
    id: id ?? this.id,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    socidRemote: socidRemote.present ? socidRemote.value : this.socidRemote,
    socidLocal: socidLocal.present ? socidLocal.value : this.socidLocal,
    ref: ref.present ? ref.value : this.ref,
    refClient: refClient.present ? refClient.value : this.refClient,
    type: type ?? this.type,
    status: status ?? this.status,
    paye: paye ?? this.paye,
    dateInvoice: dateInvoice.present ? dateInvoice.value : this.dateInvoice,
    dateDue: dateDue.present ? dateDue.value : this.dateDue,
    totalHt: totalHt.present ? totalHt.value : this.totalHt,
    totalTva: totalTva.present ? totalTva.value : this.totalTva,
    totalTtc: totalTtc.present ? totalTtc.value : this.totalTtc,
    fkModeReglement: fkModeReglement.present
        ? fkModeReglement.value
        : this.fkModeReglement,
    fkCondReglement: fkCondReglement.present
        ? fkCondReglement.value
        : this.fkCondReglement,
    notePublic: notePublic.present ? notePublic.value : this.notePublic,
    notePrivate: notePrivate.present ? notePrivate.value : this.notePrivate,
    extrafields: extrafields ?? this.extrafields,
    rawJson: rawJson.present ? rawJson.value : this.rawJson,
    tms: tms.present ? tms.value : this.tms,
    localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  InvoiceRow copyWithCompanion(InvoicesCompanion data) {
    return InvoiceRow(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      socidRemote: data.socidRemote.present
          ? data.socidRemote.value
          : this.socidRemote,
      socidLocal: data.socidLocal.present
          ? data.socidLocal.value
          : this.socidLocal,
      ref: data.ref.present ? data.ref.value : this.ref,
      refClient: data.refClient.present ? data.refClient.value : this.refClient,
      type: data.type.present ? data.type.value : this.type,
      status: data.status.present ? data.status.value : this.status,
      paye: data.paye.present ? data.paye.value : this.paye,
      dateInvoice: data.dateInvoice.present
          ? data.dateInvoice.value
          : this.dateInvoice,
      dateDue: data.dateDue.present ? data.dateDue.value : this.dateDue,
      totalHt: data.totalHt.present ? data.totalHt.value : this.totalHt,
      totalTva: data.totalTva.present ? data.totalTva.value : this.totalTva,
      totalTtc: data.totalTtc.present ? data.totalTtc.value : this.totalTtc,
      fkModeReglement: data.fkModeReglement.present
          ? data.fkModeReglement.value
          : this.fkModeReglement,
      fkCondReglement: data.fkCondReglement.present
          ? data.fkCondReglement.value
          : this.fkCondReglement,
      notePublic: data.notePublic.present
          ? data.notePublic.value
          : this.notePublic,
      notePrivate: data.notePrivate.present
          ? data.notePrivate.value
          : this.notePrivate,
      extrafields: data.extrafields.present
          ? data.extrafields.value
          : this.extrafields,
      rawJson: data.rawJson.present ? data.rawJson.value : this.rawJson,
      tms: data.tms.present ? data.tms.value : this.tms,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceRow(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('socidRemote: $socidRemote, ')
          ..write('socidLocal: $socidLocal, ')
          ..write('ref: $ref, ')
          ..write('refClient: $refClient, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('paye: $paye, ')
          ..write('dateInvoice: $dateInvoice, ')
          ..write('dateDue: $dateDue, ')
          ..write('totalHt: $totalHt, ')
          ..write('totalTva: $totalTva, ')
          ..write('totalTtc: $totalTtc, ')
          ..write('fkModeReglement: $fkModeReglement, ')
          ..write('fkCondReglement: $fkCondReglement, ')
          ..write('notePublic: $notePublic, ')
          ..write('notePrivate: $notePrivate, ')
          ..write('extrafields: $extrafields, ')
          ..write('rawJson: $rawJson, ')
          ..write('tms: $tms, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    remoteId,
    socidRemote,
    socidLocal,
    ref,
    refClient,
    type,
    status,
    paye,
    dateInvoice,
    dateDue,
    totalHt,
    totalTva,
    totalTtc,
    fkModeReglement,
    fkCondReglement,
    notePublic,
    notePrivate,
    extrafields,
    rawJson,
    tms,
    localUpdatedAt,
    syncStatus,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvoiceRow &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.socidRemote == this.socidRemote &&
          other.socidLocal == this.socidLocal &&
          other.ref == this.ref &&
          other.refClient == this.refClient &&
          other.type == this.type &&
          other.status == this.status &&
          other.paye == this.paye &&
          other.dateInvoice == this.dateInvoice &&
          other.dateDue == this.dateDue &&
          other.totalHt == this.totalHt &&
          other.totalTva == this.totalTva &&
          other.totalTtc == this.totalTtc &&
          other.fkModeReglement == this.fkModeReglement &&
          other.fkCondReglement == this.fkCondReglement &&
          other.notePublic == this.notePublic &&
          other.notePrivate == this.notePrivate &&
          other.extrafields == this.extrafields &&
          other.rawJson == this.rawJson &&
          other.tms == this.tms &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.syncStatus == this.syncStatus);
}

class InvoicesCompanion extends UpdateCompanion<InvoiceRow> {
  final Value<int> id;
  final Value<int?> remoteId;
  final Value<int?> socidRemote;
  final Value<int?> socidLocal;
  final Value<String?> ref;
  final Value<String?> refClient;
  final Value<int> type;
  final Value<int> status;
  final Value<int> paye;
  final Value<DateTime?> dateInvoice;
  final Value<DateTime?> dateDue;
  final Value<String?> totalHt;
  final Value<String?> totalTva;
  final Value<String?> totalTtc;
  final Value<int?> fkModeReglement;
  final Value<int?> fkCondReglement;
  final Value<String?> notePublic;
  final Value<String?> notePrivate;
  final Value<String> extrafields;
  final Value<String?> rawJson;
  final Value<DateTime?> tms;
  final Value<DateTime> localUpdatedAt;
  final Value<SyncStatus> syncStatus;
  const InvoicesCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.socidRemote = const Value.absent(),
    this.socidLocal = const Value.absent(),
    this.ref = const Value.absent(),
    this.refClient = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.paye = const Value.absent(),
    this.dateInvoice = const Value.absent(),
    this.dateDue = const Value.absent(),
    this.totalHt = const Value.absent(),
    this.totalTva = const Value.absent(),
    this.totalTtc = const Value.absent(),
    this.fkModeReglement = const Value.absent(),
    this.fkCondReglement = const Value.absent(),
    this.notePublic = const Value.absent(),
    this.notePrivate = const Value.absent(),
    this.extrafields = const Value.absent(),
    this.rawJson = const Value.absent(),
    this.tms = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
  });
  InvoicesCompanion.insert({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.socidRemote = const Value.absent(),
    this.socidLocal = const Value.absent(),
    this.ref = const Value.absent(),
    this.refClient = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.paye = const Value.absent(),
    this.dateInvoice = const Value.absent(),
    this.dateDue = const Value.absent(),
    this.totalHt = const Value.absent(),
    this.totalTva = const Value.absent(),
    this.totalTtc = const Value.absent(),
    this.fkModeReglement = const Value.absent(),
    this.fkCondReglement = const Value.absent(),
    this.notePublic = const Value.absent(),
    this.notePrivate = const Value.absent(),
    this.extrafields = const Value.absent(),
    this.rawJson = const Value.absent(),
    this.tms = const Value.absent(),
    required DateTime localUpdatedAt,
    this.syncStatus = const Value.absent(),
  }) : localUpdatedAt = Value(localUpdatedAt);
  static Insertable<InvoiceRow> custom({
    Expression<int>? id,
    Expression<int>? remoteId,
    Expression<int>? socidRemote,
    Expression<int>? socidLocal,
    Expression<String>? ref,
    Expression<String>? refClient,
    Expression<int>? type,
    Expression<int>? status,
    Expression<int>? paye,
    Expression<DateTime>? dateInvoice,
    Expression<DateTime>? dateDue,
    Expression<String>? totalHt,
    Expression<String>? totalTva,
    Expression<String>? totalTtc,
    Expression<int>? fkModeReglement,
    Expression<int>? fkCondReglement,
    Expression<String>? notePublic,
    Expression<String>? notePrivate,
    Expression<String>? extrafields,
    Expression<String>? rawJson,
    Expression<DateTime>? tms,
    Expression<DateTime>? localUpdatedAt,
    Expression<int>? syncStatus,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (socidRemote != null) 'socid_remote': socidRemote,
      if (socidLocal != null) 'socid_local': socidLocal,
      if (ref != null) 'ref': ref,
      if (refClient != null) 'ref_client': refClient,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (paye != null) 'paye': paye,
      if (dateInvoice != null) 'date_invoice': dateInvoice,
      if (dateDue != null) 'date_due': dateDue,
      if (totalHt != null) 'total_ht': totalHt,
      if (totalTva != null) 'total_tva': totalTva,
      if (totalTtc != null) 'total_ttc': totalTtc,
      if (fkModeReglement != null) 'fk_mode_reglement': fkModeReglement,
      if (fkCondReglement != null) 'fk_cond_reglement': fkCondReglement,
      if (notePublic != null) 'note_public': notePublic,
      if (notePrivate != null) 'note_private': notePrivate,
      if (extrafields != null) 'extrafields': extrafields,
      if (rawJson != null) 'raw_json': rawJson,
      if (tms != null) 'tms': tms,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
    });
  }

  InvoicesCompanion copyWith({
    Value<int>? id,
    Value<int?>? remoteId,
    Value<int?>? socidRemote,
    Value<int?>? socidLocal,
    Value<String?>? ref,
    Value<String?>? refClient,
    Value<int>? type,
    Value<int>? status,
    Value<int>? paye,
    Value<DateTime?>? dateInvoice,
    Value<DateTime?>? dateDue,
    Value<String?>? totalHt,
    Value<String?>? totalTva,
    Value<String?>? totalTtc,
    Value<int?>? fkModeReglement,
    Value<int?>? fkCondReglement,
    Value<String?>? notePublic,
    Value<String?>? notePrivate,
    Value<String>? extrafields,
    Value<String?>? rawJson,
    Value<DateTime?>? tms,
    Value<DateTime>? localUpdatedAt,
    Value<SyncStatus>? syncStatus,
  }) {
    return InvoicesCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      socidRemote: socidRemote ?? this.socidRemote,
      socidLocal: socidLocal ?? this.socidLocal,
      ref: ref ?? this.ref,
      refClient: refClient ?? this.refClient,
      type: type ?? this.type,
      status: status ?? this.status,
      paye: paye ?? this.paye,
      dateInvoice: dateInvoice ?? this.dateInvoice,
      dateDue: dateDue ?? this.dateDue,
      totalHt: totalHt ?? this.totalHt,
      totalTva: totalTva ?? this.totalTva,
      totalTtc: totalTtc ?? this.totalTtc,
      fkModeReglement: fkModeReglement ?? this.fkModeReglement,
      fkCondReglement: fkCondReglement ?? this.fkCondReglement,
      notePublic: notePublic ?? this.notePublic,
      notePrivate: notePrivate ?? this.notePrivate,
      extrafields: extrafields ?? this.extrafields,
      rawJson: rawJson ?? this.rawJson,
      tms: tms ?? this.tms,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<int>(remoteId.value);
    }
    if (socidRemote.present) {
      map['socid_remote'] = Variable<int>(socidRemote.value);
    }
    if (socidLocal.present) {
      map['socid_local'] = Variable<int>(socidLocal.value);
    }
    if (ref.present) {
      map['ref'] = Variable<String>(ref.value);
    }
    if (refClient.present) {
      map['ref_client'] = Variable<String>(refClient.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (paye.present) {
      map['paye'] = Variable<int>(paye.value);
    }
    if (dateInvoice.present) {
      map['date_invoice'] = Variable<DateTime>(dateInvoice.value);
    }
    if (dateDue.present) {
      map['date_due'] = Variable<DateTime>(dateDue.value);
    }
    if (totalHt.present) {
      map['total_ht'] = Variable<String>(totalHt.value);
    }
    if (totalTva.present) {
      map['total_tva'] = Variable<String>(totalTva.value);
    }
    if (totalTtc.present) {
      map['total_ttc'] = Variable<String>(totalTtc.value);
    }
    if (fkModeReglement.present) {
      map['fk_mode_reglement'] = Variable<int>(fkModeReglement.value);
    }
    if (fkCondReglement.present) {
      map['fk_cond_reglement'] = Variable<int>(fkCondReglement.value);
    }
    if (notePublic.present) {
      map['note_public'] = Variable<String>(notePublic.value);
    }
    if (notePrivate.present) {
      map['note_private'] = Variable<String>(notePrivate.value);
    }
    if (extrafields.present) {
      map['extrafields'] = Variable<String>(extrafields.value);
    }
    if (rawJson.present) {
      map['raw_json'] = Variable<String>(rawJson.value);
    }
    if (tms.present) {
      map['tms'] = Variable<DateTime>(tms.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $InvoicesTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoicesCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('socidRemote: $socidRemote, ')
          ..write('socidLocal: $socidLocal, ')
          ..write('ref: $ref, ')
          ..write('refClient: $refClient, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('paye: $paye, ')
          ..write('dateInvoice: $dateInvoice, ')
          ..write('dateDue: $dateDue, ')
          ..write('totalHt: $totalHt, ')
          ..write('totalTva: $totalTva, ')
          ..write('totalTtc: $totalTtc, ')
          ..write('fkModeReglement: $fkModeReglement, ')
          ..write('fkCondReglement: $fkCondReglement, ')
          ..write('notePublic: $notePublic, ')
          ..write('notePrivate: $notePrivate, ')
          ..write('extrafields: $extrafields, ')
          ..write('rawJson: $rawJson, ')
          ..write('tms: $tms, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }
}

class $PendingOperationsTable extends PendingOperations
    with TableInfo<$PendingOperationsTable, PendingOperationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingOperationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<PendingOpType, int> opType =
      GeneratedColumn<int>(
        'op_type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<PendingOpType>($PendingOperationsTable.$converteropType);
  @override
  late final GeneratedColumnWithTypeConverter<PendingOpEntity, int> entityType =
      GeneratedColumn<int>(
        'entity_type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<PendingOpEntity>(
        $PendingOperationsTable.$converterentityType,
      );
  static const VerificationMeta _targetRemoteIdMeta = const VerificationMeta(
    'targetRemoteId',
  );
  @override
  late final GeneratedColumn<int> targetRemoteId = GeneratedColumn<int>(
    'target_remote_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetLocalIdMeta = const VerificationMeta(
    'targetLocalId',
  );
  @override
  late final GeneratedColumn<int> targetLocalId = GeneratedColumn<int>(
    'target_local_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _expectedTmsMeta = const VerificationMeta(
    'expectedTms',
  );
  @override
  late final GeneratedColumn<DateTime> expectedTms = GeneratedColumn<DateTime>(
    'expected_tms',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dependsOnLocalIdMeta = const VerificationMeta(
    'dependsOnLocalId',
  );
  @override
  late final GeneratedColumn<int> dependsOnLocalId = GeneratedColumn<int>(
    'depends_on_local_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastAttemptAtMeta = const VerificationMeta(
    'lastAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAttemptAt =
      GeneratedColumn<DateTime>(
        'last_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextRetryAtMeta = const VerificationMeta(
    'nextRetryAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextRetryAt = GeneratedColumn<DateTime>(
    'next_retry_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PendingOpStatus, int> status =
      GeneratedColumn<int>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: Constant(PendingOpStatus.queued.index),
      ).withConverter<PendingOpStatus>(
        $PendingOperationsTable.$converterstatus,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    opType,
    entityType,
    targetRemoteId,
    targetLocalId,
    payload,
    expectedTms,
    dependsOnLocalId,
    attempts,
    lastAttemptAt,
    lastError,
    nextRetryAt,
    createdAt,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_operations';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingOperationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('target_remote_id')) {
      context.handle(
        _targetRemoteIdMeta,
        targetRemoteId.isAcceptableOrUnknown(
          data['target_remote_id']!,
          _targetRemoteIdMeta,
        ),
      );
    }
    if (data.containsKey('target_local_id')) {
      context.handle(
        _targetLocalIdMeta,
        targetLocalId.isAcceptableOrUnknown(
          data['target_local_id']!,
          _targetLocalIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetLocalIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    }
    if (data.containsKey('expected_tms')) {
      context.handle(
        _expectedTmsMeta,
        expectedTms.isAcceptableOrUnknown(
          data['expected_tms']!,
          _expectedTmsMeta,
        ),
      );
    }
    if (data.containsKey('depends_on_local_id')) {
      context.handle(
        _dependsOnLocalIdMeta,
        dependsOnLocalId.isAcceptableOrUnknown(
          data['depends_on_local_id']!,
          _dependsOnLocalIdMeta,
        ),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
        _lastAttemptAtMeta,
        lastAttemptAt.isAcceptableOrUnknown(
          data['last_attempt_at']!,
          _lastAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('next_retry_at')) {
      context.handle(
        _nextRetryAtMeta,
        nextRetryAt.isAcceptableOrUnknown(
          data['next_retry_at']!,
          _nextRetryAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingOperationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingOperationRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      opType: $PendingOperationsTable.$converteropType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}op_type'],
        )!,
      ),
      entityType: $PendingOperationsTable.$converterentityType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}entity_type'],
        )!,
      ),
      targetRemoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_remote_id'],
      ),
      targetLocalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_local_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      expectedTms: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expected_tms'],
      ),
      dependsOnLocalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}depends_on_local_id'],
      ),
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_attempt_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      nextRetryAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_retry_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      status: $PendingOperationsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}status'],
        )!,
      ),
    );
  }

  @override
  $PendingOperationsTable createAlias(String alias) {
    return $PendingOperationsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PendingOpType, int, int> $converteropType =
      const EnumIndexConverter<PendingOpType>(PendingOpType.values);
  static JsonTypeConverter2<PendingOpEntity, int, int> $converterentityType =
      const EnumIndexConverter<PendingOpEntity>(PendingOpEntity.values);
  static JsonTypeConverter2<PendingOpStatus, int, int> $converterstatus =
      const EnumIndexConverter<PendingOpStatus>(PendingOpStatus.values);
}

class PendingOperationRow extends DataClass
    implements Insertable<PendingOperationRow> {
  final int id;
  final PendingOpType opType;
  final PendingOpEntity entityType;

  /// `rowid` Dolibarr cible (null pour un create local non poussé).
  final int? targetRemoteId;

  /// PK locale Drift de l'entité ciblée (toujours présente).
  final int targetLocalId;

  /// Payload JSON sérialisé prêt à être envoyé.
  final String payload;

  /// `tms` attendu pour la détection de conflit (update / delete).
  final DateTime? expectedTms;

  /// FK locale d'une autre PendingOperation dont il faut attendre la
  /// résolution (cascade — ex: contact qui dépend du tiers parent).
  final int? dependsOnLocalId;
  final int attempts;
  final DateTime? lastAttemptAt;
  final String? lastError;
  final DateTime? nextRetryAt;
  final DateTime createdAt;
  final PendingOpStatus status;
  const PendingOperationRow({
    required this.id,
    required this.opType,
    required this.entityType,
    this.targetRemoteId,
    required this.targetLocalId,
    required this.payload,
    this.expectedTms,
    this.dependsOnLocalId,
    required this.attempts,
    this.lastAttemptAt,
    this.lastError,
    this.nextRetryAt,
    required this.createdAt,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['op_type'] = Variable<int>(
        $PendingOperationsTable.$converteropType.toSql(opType),
      );
    }
    {
      map['entity_type'] = Variable<int>(
        $PendingOperationsTable.$converterentityType.toSql(entityType),
      );
    }
    if (!nullToAbsent || targetRemoteId != null) {
      map['target_remote_id'] = Variable<int>(targetRemoteId);
    }
    map['target_local_id'] = Variable<int>(targetLocalId);
    map['payload'] = Variable<String>(payload);
    if (!nullToAbsent || expectedTms != null) {
      map['expected_tms'] = Variable<DateTime>(expectedTms);
    }
    if (!nullToAbsent || dependsOnLocalId != null) {
      map['depends_on_local_id'] = Variable<int>(dependsOnLocalId);
    }
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    if (!nullToAbsent || nextRetryAt != null) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    {
      map['status'] = Variable<int>(
        $PendingOperationsTable.$converterstatus.toSql(status),
      );
    }
    return map;
  }

  PendingOperationsCompanion toCompanion(bool nullToAbsent) {
    return PendingOperationsCompanion(
      id: Value(id),
      opType: Value(opType),
      entityType: Value(entityType),
      targetRemoteId: targetRemoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(targetRemoteId),
      targetLocalId: Value(targetLocalId),
      payload: Value(payload),
      expectedTms: expectedTms == null && nullToAbsent
          ? const Value.absent()
          : Value(expectedTms),
      dependsOnLocalId: dependsOnLocalId == null && nullToAbsent
          ? const Value.absent()
          : Value(dependsOnLocalId),
      attempts: Value(attempts),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      nextRetryAt: nextRetryAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextRetryAt),
      createdAt: Value(createdAt),
      status: Value(status),
    );
  }

  factory PendingOperationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingOperationRow(
      id: serializer.fromJson<int>(json['id']),
      opType: $PendingOperationsTable.$converteropType.fromJson(
        serializer.fromJson<int>(json['opType']),
      ),
      entityType: $PendingOperationsTable.$converterentityType.fromJson(
        serializer.fromJson<int>(json['entityType']),
      ),
      targetRemoteId: serializer.fromJson<int?>(json['targetRemoteId']),
      targetLocalId: serializer.fromJson<int>(json['targetLocalId']),
      payload: serializer.fromJson<String>(json['payload']),
      expectedTms: serializer.fromJson<DateTime?>(json['expectedTms']),
      dependsOnLocalId: serializer.fromJson<int?>(json['dependsOnLocalId']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastAttemptAt: serializer.fromJson<DateTime?>(json['lastAttemptAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      nextRetryAt: serializer.fromJson<DateTime?>(json['nextRetryAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      status: $PendingOperationsTable.$converterstatus.fromJson(
        serializer.fromJson<int>(json['status']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'opType': serializer.toJson<int>(
        $PendingOperationsTable.$converteropType.toJson(opType),
      ),
      'entityType': serializer.toJson<int>(
        $PendingOperationsTable.$converterentityType.toJson(entityType),
      ),
      'targetRemoteId': serializer.toJson<int?>(targetRemoteId),
      'targetLocalId': serializer.toJson<int>(targetLocalId),
      'payload': serializer.toJson<String>(payload),
      'expectedTms': serializer.toJson<DateTime?>(expectedTms),
      'dependsOnLocalId': serializer.toJson<int?>(dependsOnLocalId),
      'attempts': serializer.toJson<int>(attempts),
      'lastAttemptAt': serializer.toJson<DateTime?>(lastAttemptAt),
      'lastError': serializer.toJson<String?>(lastError),
      'nextRetryAt': serializer.toJson<DateTime?>(nextRetryAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'status': serializer.toJson<int>(
        $PendingOperationsTable.$converterstatus.toJson(status),
      ),
    };
  }

  PendingOperationRow copyWith({
    int? id,
    PendingOpType? opType,
    PendingOpEntity? entityType,
    Value<int?> targetRemoteId = const Value.absent(),
    int? targetLocalId,
    String? payload,
    Value<DateTime?> expectedTms = const Value.absent(),
    Value<int?> dependsOnLocalId = const Value.absent(),
    int? attempts,
    Value<DateTime?> lastAttemptAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    Value<DateTime?> nextRetryAt = const Value.absent(),
    DateTime? createdAt,
    PendingOpStatus? status,
  }) => PendingOperationRow(
    id: id ?? this.id,
    opType: opType ?? this.opType,
    entityType: entityType ?? this.entityType,
    targetRemoteId: targetRemoteId.present
        ? targetRemoteId.value
        : this.targetRemoteId,
    targetLocalId: targetLocalId ?? this.targetLocalId,
    payload: payload ?? this.payload,
    expectedTms: expectedTms.present ? expectedTms.value : this.expectedTms,
    dependsOnLocalId: dependsOnLocalId.present
        ? dependsOnLocalId.value
        : this.dependsOnLocalId,
    attempts: attempts ?? this.attempts,
    lastAttemptAt: lastAttemptAt.present
        ? lastAttemptAt.value
        : this.lastAttemptAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    nextRetryAt: nextRetryAt.present ? nextRetryAt.value : this.nextRetryAt,
    createdAt: createdAt ?? this.createdAt,
    status: status ?? this.status,
  );
  PendingOperationRow copyWithCompanion(PendingOperationsCompanion data) {
    return PendingOperationRow(
      id: data.id.present ? data.id.value : this.id,
      opType: data.opType.present ? data.opType.value : this.opType,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      targetRemoteId: data.targetRemoteId.present
          ? data.targetRemoteId.value
          : this.targetRemoteId,
      targetLocalId: data.targetLocalId.present
          ? data.targetLocalId.value
          : this.targetLocalId,
      payload: data.payload.present ? data.payload.value : this.payload,
      expectedTms: data.expectedTms.present
          ? data.expectedTms.value
          : this.expectedTms,
      dependsOnLocalId: data.dependsOnLocalId.present
          ? data.dependsOnLocalId.value
          : this.dependsOnLocalId,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      nextRetryAt: data.nextRetryAt.present
          ? data.nextRetryAt.value
          : this.nextRetryAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingOperationRow(')
          ..write('id: $id, ')
          ..write('opType: $opType, ')
          ..write('entityType: $entityType, ')
          ..write('targetRemoteId: $targetRemoteId, ')
          ..write('targetLocalId: $targetLocalId, ')
          ..write('payload: $payload, ')
          ..write('expectedTms: $expectedTms, ')
          ..write('dependsOnLocalId: $dependsOnLocalId, ')
          ..write('attempts: $attempts, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('lastError: $lastError, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    opType,
    entityType,
    targetRemoteId,
    targetLocalId,
    payload,
    expectedTms,
    dependsOnLocalId,
    attempts,
    lastAttemptAt,
    lastError,
    nextRetryAt,
    createdAt,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingOperationRow &&
          other.id == this.id &&
          other.opType == this.opType &&
          other.entityType == this.entityType &&
          other.targetRemoteId == this.targetRemoteId &&
          other.targetLocalId == this.targetLocalId &&
          other.payload == this.payload &&
          other.expectedTms == this.expectedTms &&
          other.dependsOnLocalId == this.dependsOnLocalId &&
          other.attempts == this.attempts &&
          other.lastAttemptAt == this.lastAttemptAt &&
          other.lastError == this.lastError &&
          other.nextRetryAt == this.nextRetryAt &&
          other.createdAt == this.createdAt &&
          other.status == this.status);
}

class PendingOperationsCompanion extends UpdateCompanion<PendingOperationRow> {
  final Value<int> id;
  final Value<PendingOpType> opType;
  final Value<PendingOpEntity> entityType;
  final Value<int?> targetRemoteId;
  final Value<int> targetLocalId;
  final Value<String> payload;
  final Value<DateTime?> expectedTms;
  final Value<int?> dependsOnLocalId;
  final Value<int> attempts;
  final Value<DateTime?> lastAttemptAt;
  final Value<String?> lastError;
  final Value<DateTime?> nextRetryAt;
  final Value<DateTime> createdAt;
  final Value<PendingOpStatus> status;
  const PendingOperationsCompanion({
    this.id = const Value.absent(),
    this.opType = const Value.absent(),
    this.entityType = const Value.absent(),
    this.targetRemoteId = const Value.absent(),
    this.targetLocalId = const Value.absent(),
    this.payload = const Value.absent(),
    this.expectedTms = const Value.absent(),
    this.dependsOnLocalId = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.status = const Value.absent(),
  });
  PendingOperationsCompanion.insert({
    this.id = const Value.absent(),
    required PendingOpType opType,
    required PendingOpEntity entityType,
    this.targetRemoteId = const Value.absent(),
    required int targetLocalId,
    this.payload = const Value.absent(),
    this.expectedTms = const Value.absent(),
    this.dependsOnLocalId = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    required DateTime createdAt,
    this.status = const Value.absent(),
  }) : opType = Value(opType),
       entityType = Value(entityType),
       targetLocalId = Value(targetLocalId),
       createdAt = Value(createdAt);
  static Insertable<PendingOperationRow> custom({
    Expression<int>? id,
    Expression<int>? opType,
    Expression<int>? entityType,
    Expression<int>? targetRemoteId,
    Expression<int>? targetLocalId,
    Expression<String>? payload,
    Expression<DateTime>? expectedTms,
    Expression<int>? dependsOnLocalId,
    Expression<int>? attempts,
    Expression<DateTime>? lastAttemptAt,
    Expression<String>? lastError,
    Expression<DateTime>? nextRetryAt,
    Expression<DateTime>? createdAt,
    Expression<int>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (opType != null) 'op_type': opType,
      if (entityType != null) 'entity_type': entityType,
      if (targetRemoteId != null) 'target_remote_id': targetRemoteId,
      if (targetLocalId != null) 'target_local_id': targetLocalId,
      if (payload != null) 'payload': payload,
      if (expectedTms != null) 'expected_tms': expectedTms,
      if (dependsOnLocalId != null) 'depends_on_local_id': dependsOnLocalId,
      if (attempts != null) 'attempts': attempts,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (lastError != null) 'last_error': lastError,
      if (nextRetryAt != null) 'next_retry_at': nextRetryAt,
      if (createdAt != null) 'created_at': createdAt,
      if (status != null) 'status': status,
    });
  }

  PendingOperationsCompanion copyWith({
    Value<int>? id,
    Value<PendingOpType>? opType,
    Value<PendingOpEntity>? entityType,
    Value<int?>? targetRemoteId,
    Value<int>? targetLocalId,
    Value<String>? payload,
    Value<DateTime?>? expectedTms,
    Value<int?>? dependsOnLocalId,
    Value<int>? attempts,
    Value<DateTime?>? lastAttemptAt,
    Value<String?>? lastError,
    Value<DateTime?>? nextRetryAt,
    Value<DateTime>? createdAt,
    Value<PendingOpStatus>? status,
  }) {
    return PendingOperationsCompanion(
      id: id ?? this.id,
      opType: opType ?? this.opType,
      entityType: entityType ?? this.entityType,
      targetRemoteId: targetRemoteId ?? this.targetRemoteId,
      targetLocalId: targetLocalId ?? this.targetLocalId,
      payload: payload ?? this.payload,
      expectedTms: expectedTms ?? this.expectedTms,
      dependsOnLocalId: dependsOnLocalId ?? this.dependsOnLocalId,
      attempts: attempts ?? this.attempts,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      lastError: lastError ?? this.lastError,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (opType.present) {
      map['op_type'] = Variable<int>(
        $PendingOperationsTable.$converteropType.toSql(opType.value),
      );
    }
    if (entityType.present) {
      map['entity_type'] = Variable<int>(
        $PendingOperationsTable.$converterentityType.toSql(entityType.value),
      );
    }
    if (targetRemoteId.present) {
      map['target_remote_id'] = Variable<int>(targetRemoteId.value);
    }
    if (targetLocalId.present) {
      map['target_local_id'] = Variable<int>(targetLocalId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (expectedTms.present) {
      map['expected_tms'] = Variable<DateTime>(expectedTms.value);
    }
    if (dependsOnLocalId.present) {
      map['depends_on_local_id'] = Variable<int>(dependsOnLocalId.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (nextRetryAt.present) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(
        $PendingOperationsTable.$converterstatus.toSql(status.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingOperationsCompanion(')
          ..write('id: $id, ')
          ..write('opType: $opType, ')
          ..write('entityType: $entityType, ')
          ..write('targetRemoteId: $targetRemoteId, ')
          ..write('targetLocalId: $targetLocalId, ')
          ..write('payload: $payload, ')
          ..write('expectedTms: $expectedTms, ')
          ..write('dependsOnLocalId: $dependsOnLocalId, ')
          ..write('attempts: $attempts, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('lastError: $lastError, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $ProjectsTable extends Projects
    with TableInfo<$ProjectsTable, ProjectRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<int> remoteId = GeneratedColumn<int>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _socidRemoteMeta = const VerificationMeta(
    'socidRemote',
  );
  @override
  late final GeneratedColumn<int> socidRemote = GeneratedColumn<int>(
    'socid_remote',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _socidLocalMeta = const VerificationMeta(
    'socidLocal',
  );
  @override
  late final GeneratedColumn<int> socidLocal = GeneratedColumn<int>(
    'socid_local',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _refMeta = const VerificationMeta('ref');
  @override
  late final GeneratedColumn<String> ref = GeneratedColumn<String>(
    'ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _publicLevelMeta = const VerificationMeta(
    'publicLevel',
  );
  @override
  late final GeneratedColumn<int> publicLevel = GeneratedColumn<int>(
    'public_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _fkUserRespMeta = const VerificationMeta(
    'fkUserResp',
  );
  @override
  late final GeneratedColumn<int> fkUserResp = GeneratedColumn<int>(
    'fk_user_resp',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateStartMeta = const VerificationMeta(
    'dateStart',
  );
  @override
  late final GeneratedColumn<DateTime> dateStart = GeneratedColumn<DateTime>(
    'date_start',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateEndMeta = const VerificationMeta(
    'dateEnd',
  );
  @override
  late final GeneratedColumn<DateTime> dateEnd = GeneratedColumn<DateTime>(
    'date_end',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _budgetAmountMeta = const VerificationMeta(
    'budgetAmount',
  );
  @override
  late final GeneratedColumn<String> budgetAmount = GeneratedColumn<String>(
    'budget_amount',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _oppStatusMeta = const VerificationMeta(
    'oppStatus',
  );
  @override
  late final GeneratedColumn<int> oppStatus = GeneratedColumn<int>(
    'opp_status',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _oppAmountMeta = const VerificationMeta(
    'oppAmount',
  );
  @override
  late final GeneratedColumn<String> oppAmount = GeneratedColumn<String>(
    'opp_amount',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _oppPercentMeta = const VerificationMeta(
    'oppPercent',
  );
  @override
  late final GeneratedColumn<double> oppPercent = GeneratedColumn<double>(
    'opp_percent',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _extrafieldsMeta = const VerificationMeta(
    'extrafields',
  );
  @override
  late final GeneratedColumn<String> extrafields = GeneratedColumn<String>(
    'extrafields',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _rawJsonMeta = const VerificationMeta(
    'rawJson',
  );
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
    'raw_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tmsMeta = const VerificationMeta('tms');
  @override
  late final GeneratedColumn<DateTime> tms = GeneratedColumn<DateTime>(
    'tms',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>(
        'local_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: Constant(SyncStatus.synced.index),
      ).withConverter<SyncStatus>($ProjectsTable.$convertersyncStatus);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    remoteId,
    socidRemote,
    socidLocal,
    ref,
    title,
    description,
    status,
    publicLevel,
    fkUserResp,
    dateStart,
    dateEnd,
    budgetAmount,
    oppStatus,
    oppAmount,
    oppPercent,
    extrafields,
    rawJson,
    tms,
    localUpdatedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProjectRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('socid_remote')) {
      context.handle(
        _socidRemoteMeta,
        socidRemote.isAcceptableOrUnknown(
          data['socid_remote']!,
          _socidRemoteMeta,
        ),
      );
    }
    if (data.containsKey('socid_local')) {
      context.handle(
        _socidLocalMeta,
        socidLocal.isAcceptableOrUnknown(data['socid_local']!, _socidLocalMeta),
      );
    }
    if (data.containsKey('ref')) {
      context.handle(
        _refMeta,
        ref.isAcceptableOrUnknown(data['ref']!, _refMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('public_level')) {
      context.handle(
        _publicLevelMeta,
        publicLevel.isAcceptableOrUnknown(
          data['public_level']!,
          _publicLevelMeta,
        ),
      );
    }
    if (data.containsKey('fk_user_resp')) {
      context.handle(
        _fkUserRespMeta,
        fkUserResp.isAcceptableOrUnknown(
          data['fk_user_resp']!,
          _fkUserRespMeta,
        ),
      );
    }
    if (data.containsKey('date_start')) {
      context.handle(
        _dateStartMeta,
        dateStart.isAcceptableOrUnknown(data['date_start']!, _dateStartMeta),
      );
    }
    if (data.containsKey('date_end')) {
      context.handle(
        _dateEndMeta,
        dateEnd.isAcceptableOrUnknown(data['date_end']!, _dateEndMeta),
      );
    }
    if (data.containsKey('budget_amount')) {
      context.handle(
        _budgetAmountMeta,
        budgetAmount.isAcceptableOrUnknown(
          data['budget_amount']!,
          _budgetAmountMeta,
        ),
      );
    }
    if (data.containsKey('opp_status')) {
      context.handle(
        _oppStatusMeta,
        oppStatus.isAcceptableOrUnknown(data['opp_status']!, _oppStatusMeta),
      );
    }
    if (data.containsKey('opp_amount')) {
      context.handle(
        _oppAmountMeta,
        oppAmount.isAcceptableOrUnknown(data['opp_amount']!, _oppAmountMeta),
      );
    }
    if (data.containsKey('opp_percent')) {
      context.handle(
        _oppPercentMeta,
        oppPercent.isAcceptableOrUnknown(data['opp_percent']!, _oppPercentMeta),
      );
    }
    if (data.containsKey('extrafields')) {
      context.handle(
        _extrafieldsMeta,
        extrafields.isAcceptableOrUnknown(
          data['extrafields']!,
          _extrafieldsMeta,
        ),
      );
    }
    if (data.containsKey('raw_json')) {
      context.handle(
        _rawJsonMeta,
        rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta),
      );
    }
    if (data.containsKey('tms')) {
      context.handle(
        _tmsMeta,
        tms.isAcceptableOrUnknown(data['tms']!, _tmsMeta),
      );
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProjectRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remote_id'],
      ),
      socidRemote: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}socid_remote'],
      ),
      socidLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}socid_local'],
      ),
      ref: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      publicLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}public_level'],
      )!,
      fkUserResp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fk_user_resp'],
      ),
      dateStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_start'],
      ),
      dateEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_end'],
      ),
      budgetAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}budget_amount'],
      ),
      oppStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opp_status'],
      ),
      oppAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}opp_amount'],
      ),
      oppPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}opp_percent'],
      ),
      extrafields: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extrafields'],
      )!,
      rawJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_json'],
      ),
      tms: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}tms'],
      ),
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}local_updated_at'],
      )!,
      syncStatus: $ProjectsTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
    );
  }

  @override
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class ProjectRow extends DataClass implements Insertable<ProjectRow> {
  final int id;
  final int? remoteId;

  /// `socid` côté Dolibarr — id du tiers parent (`remoteId` ThirdParty).
  final int? socidRemote;

  /// FK locale vers ThirdParties.id quand le parent est encore en
  /// pendingCreate (cascade Outbox). Patché par le SyncEngine après
  /// push du parent.
  final int? socidLocal;

  /// Référence Dolibarr (ex : `PJ2026-001`). Générée côté serveur à
  /// la validation, peut être nulle en pendingCreate.
  final String? ref;
  final String title;
  final String? description;

  /// Statut Dolibarr : 0=brouillon, 1=ouvert, 2=fermé.
  final int status;

  /// 0 = privé (visible auteur seulement), 1 = public projet.
  final int publicLevel;

  /// Utilisateur responsable côté Dolibarr.
  final int? fkUserResp;
  final DateTime? dateStart;
  final DateTime? dateEnd;

  /// Budget alloué (HT). Stocké en string pour préserver la précision.
  final String? budgetAmount;

  /// Statut d'opportunité (lead/proposition/won/lost). Cf table
  /// llx_c_lead_status côté Dolibarr.
  final int? oppStatus;
  final String? oppAmount;
  final double? oppPercent;
  final String extrafields;
  final String? rawJson;
  final DateTime? tms;
  final DateTime localUpdatedAt;
  final SyncStatus syncStatus;
  const ProjectRow({
    required this.id,
    this.remoteId,
    this.socidRemote,
    this.socidLocal,
    this.ref,
    required this.title,
    this.description,
    required this.status,
    required this.publicLevel,
    this.fkUserResp,
    this.dateStart,
    this.dateEnd,
    this.budgetAmount,
    this.oppStatus,
    this.oppAmount,
    this.oppPercent,
    required this.extrafields,
    this.rawJson,
    this.tms,
    required this.localUpdatedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<int>(remoteId);
    }
    if (!nullToAbsent || socidRemote != null) {
      map['socid_remote'] = Variable<int>(socidRemote);
    }
    if (!nullToAbsent || socidLocal != null) {
      map['socid_local'] = Variable<int>(socidLocal);
    }
    if (!nullToAbsent || ref != null) {
      map['ref'] = Variable<String>(ref);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['status'] = Variable<int>(status);
    map['public_level'] = Variable<int>(publicLevel);
    if (!nullToAbsent || fkUserResp != null) {
      map['fk_user_resp'] = Variable<int>(fkUserResp);
    }
    if (!nullToAbsent || dateStart != null) {
      map['date_start'] = Variable<DateTime>(dateStart);
    }
    if (!nullToAbsent || dateEnd != null) {
      map['date_end'] = Variable<DateTime>(dateEnd);
    }
    if (!nullToAbsent || budgetAmount != null) {
      map['budget_amount'] = Variable<String>(budgetAmount);
    }
    if (!nullToAbsent || oppStatus != null) {
      map['opp_status'] = Variable<int>(oppStatus);
    }
    if (!nullToAbsent || oppAmount != null) {
      map['opp_amount'] = Variable<String>(oppAmount);
    }
    if (!nullToAbsent || oppPercent != null) {
      map['opp_percent'] = Variable<double>(oppPercent);
    }
    map['extrafields'] = Variable<String>(extrafields);
    if (!nullToAbsent || rawJson != null) {
      map['raw_json'] = Variable<String>(rawJson);
    }
    if (!nullToAbsent || tms != null) {
      map['tms'] = Variable<DateTime>(tms);
    }
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    {
      map['sync_status'] = Variable<int>(
        $ProjectsTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      socidRemote: socidRemote == null && nullToAbsent
          ? const Value.absent()
          : Value(socidRemote),
      socidLocal: socidLocal == null && nullToAbsent
          ? const Value.absent()
          : Value(socidLocal),
      ref: ref == null && nullToAbsent ? const Value.absent() : Value(ref),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      status: Value(status),
      publicLevel: Value(publicLevel),
      fkUserResp: fkUserResp == null && nullToAbsent
          ? const Value.absent()
          : Value(fkUserResp),
      dateStart: dateStart == null && nullToAbsent
          ? const Value.absent()
          : Value(dateStart),
      dateEnd: dateEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(dateEnd),
      budgetAmount: budgetAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(budgetAmount),
      oppStatus: oppStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(oppStatus),
      oppAmount: oppAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(oppAmount),
      oppPercent: oppPercent == null && nullToAbsent
          ? const Value.absent()
          : Value(oppPercent),
      extrafields: Value(extrafields),
      rawJson: rawJson == null && nullToAbsent
          ? const Value.absent()
          : Value(rawJson),
      tms: tms == null && nullToAbsent ? const Value.absent() : Value(tms),
      localUpdatedAt: Value(localUpdatedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory ProjectRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectRow(
      id: serializer.fromJson<int>(json['id']),
      remoteId: serializer.fromJson<int?>(json['remoteId']),
      socidRemote: serializer.fromJson<int?>(json['socidRemote']),
      socidLocal: serializer.fromJson<int?>(json['socidLocal']),
      ref: serializer.fromJson<String?>(json['ref']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      status: serializer.fromJson<int>(json['status']),
      publicLevel: serializer.fromJson<int>(json['publicLevel']),
      fkUserResp: serializer.fromJson<int?>(json['fkUserResp']),
      dateStart: serializer.fromJson<DateTime?>(json['dateStart']),
      dateEnd: serializer.fromJson<DateTime?>(json['dateEnd']),
      budgetAmount: serializer.fromJson<String?>(json['budgetAmount']),
      oppStatus: serializer.fromJson<int?>(json['oppStatus']),
      oppAmount: serializer.fromJson<String?>(json['oppAmount']),
      oppPercent: serializer.fromJson<double?>(json['oppPercent']),
      extrafields: serializer.fromJson<String>(json['extrafields']),
      rawJson: serializer.fromJson<String?>(json['rawJson']),
      tms: serializer.fromJson<DateTime?>(json['tms']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      syncStatus: $ProjectsTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'remoteId': serializer.toJson<int?>(remoteId),
      'socidRemote': serializer.toJson<int?>(socidRemote),
      'socidLocal': serializer.toJson<int?>(socidLocal),
      'ref': serializer.toJson<String?>(ref),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'status': serializer.toJson<int>(status),
      'publicLevel': serializer.toJson<int>(publicLevel),
      'fkUserResp': serializer.toJson<int?>(fkUserResp),
      'dateStart': serializer.toJson<DateTime?>(dateStart),
      'dateEnd': serializer.toJson<DateTime?>(dateEnd),
      'budgetAmount': serializer.toJson<String?>(budgetAmount),
      'oppStatus': serializer.toJson<int?>(oppStatus),
      'oppAmount': serializer.toJson<String?>(oppAmount),
      'oppPercent': serializer.toJson<double?>(oppPercent),
      'extrafields': serializer.toJson<String>(extrafields),
      'rawJson': serializer.toJson<String?>(rawJson),
      'tms': serializer.toJson<DateTime?>(tms),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'syncStatus': serializer.toJson<int>(
        $ProjectsTable.$convertersyncStatus.toJson(syncStatus),
      ),
    };
  }

  ProjectRow copyWith({
    int? id,
    Value<int?> remoteId = const Value.absent(),
    Value<int?> socidRemote = const Value.absent(),
    Value<int?> socidLocal = const Value.absent(),
    Value<String?> ref = const Value.absent(),
    String? title,
    Value<String?> description = const Value.absent(),
    int? status,
    int? publicLevel,
    Value<int?> fkUserResp = const Value.absent(),
    Value<DateTime?> dateStart = const Value.absent(),
    Value<DateTime?> dateEnd = const Value.absent(),
    Value<String?> budgetAmount = const Value.absent(),
    Value<int?> oppStatus = const Value.absent(),
    Value<String?> oppAmount = const Value.absent(),
    Value<double?> oppPercent = const Value.absent(),
    String? extrafields,
    Value<String?> rawJson = const Value.absent(),
    Value<DateTime?> tms = const Value.absent(),
    DateTime? localUpdatedAt,
    SyncStatus? syncStatus,
  }) => ProjectRow(
    id: id ?? this.id,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    socidRemote: socidRemote.present ? socidRemote.value : this.socidRemote,
    socidLocal: socidLocal.present ? socidLocal.value : this.socidLocal,
    ref: ref.present ? ref.value : this.ref,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    status: status ?? this.status,
    publicLevel: publicLevel ?? this.publicLevel,
    fkUserResp: fkUserResp.present ? fkUserResp.value : this.fkUserResp,
    dateStart: dateStart.present ? dateStart.value : this.dateStart,
    dateEnd: dateEnd.present ? dateEnd.value : this.dateEnd,
    budgetAmount: budgetAmount.present ? budgetAmount.value : this.budgetAmount,
    oppStatus: oppStatus.present ? oppStatus.value : this.oppStatus,
    oppAmount: oppAmount.present ? oppAmount.value : this.oppAmount,
    oppPercent: oppPercent.present ? oppPercent.value : this.oppPercent,
    extrafields: extrafields ?? this.extrafields,
    rawJson: rawJson.present ? rawJson.value : this.rawJson,
    tms: tms.present ? tms.value : this.tms,
    localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  ProjectRow copyWithCompanion(ProjectsCompanion data) {
    return ProjectRow(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      socidRemote: data.socidRemote.present
          ? data.socidRemote.value
          : this.socidRemote,
      socidLocal: data.socidLocal.present
          ? data.socidLocal.value
          : this.socidLocal,
      ref: data.ref.present ? data.ref.value : this.ref,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      status: data.status.present ? data.status.value : this.status,
      publicLevel: data.publicLevel.present
          ? data.publicLevel.value
          : this.publicLevel,
      fkUserResp: data.fkUserResp.present
          ? data.fkUserResp.value
          : this.fkUserResp,
      dateStart: data.dateStart.present ? data.dateStart.value : this.dateStart,
      dateEnd: data.dateEnd.present ? data.dateEnd.value : this.dateEnd,
      budgetAmount: data.budgetAmount.present
          ? data.budgetAmount.value
          : this.budgetAmount,
      oppStatus: data.oppStatus.present ? data.oppStatus.value : this.oppStatus,
      oppAmount: data.oppAmount.present ? data.oppAmount.value : this.oppAmount,
      oppPercent: data.oppPercent.present
          ? data.oppPercent.value
          : this.oppPercent,
      extrafields: data.extrafields.present
          ? data.extrafields.value
          : this.extrafields,
      rawJson: data.rawJson.present ? data.rawJson.value : this.rawJson,
      tms: data.tms.present ? data.tms.value : this.tms,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectRow(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('socidRemote: $socidRemote, ')
          ..write('socidLocal: $socidLocal, ')
          ..write('ref: $ref, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('publicLevel: $publicLevel, ')
          ..write('fkUserResp: $fkUserResp, ')
          ..write('dateStart: $dateStart, ')
          ..write('dateEnd: $dateEnd, ')
          ..write('budgetAmount: $budgetAmount, ')
          ..write('oppStatus: $oppStatus, ')
          ..write('oppAmount: $oppAmount, ')
          ..write('oppPercent: $oppPercent, ')
          ..write('extrafields: $extrafields, ')
          ..write('rawJson: $rawJson, ')
          ..write('tms: $tms, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    remoteId,
    socidRemote,
    socidLocal,
    ref,
    title,
    description,
    status,
    publicLevel,
    fkUserResp,
    dateStart,
    dateEnd,
    budgetAmount,
    oppStatus,
    oppAmount,
    oppPercent,
    extrafields,
    rawJson,
    tms,
    localUpdatedAt,
    syncStatus,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectRow &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.socidRemote == this.socidRemote &&
          other.socidLocal == this.socidLocal &&
          other.ref == this.ref &&
          other.title == this.title &&
          other.description == this.description &&
          other.status == this.status &&
          other.publicLevel == this.publicLevel &&
          other.fkUserResp == this.fkUserResp &&
          other.dateStart == this.dateStart &&
          other.dateEnd == this.dateEnd &&
          other.budgetAmount == this.budgetAmount &&
          other.oppStatus == this.oppStatus &&
          other.oppAmount == this.oppAmount &&
          other.oppPercent == this.oppPercent &&
          other.extrafields == this.extrafields &&
          other.rawJson == this.rawJson &&
          other.tms == this.tms &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.syncStatus == this.syncStatus);
}

class ProjectsCompanion extends UpdateCompanion<ProjectRow> {
  final Value<int> id;
  final Value<int?> remoteId;
  final Value<int?> socidRemote;
  final Value<int?> socidLocal;
  final Value<String?> ref;
  final Value<String> title;
  final Value<String?> description;
  final Value<int> status;
  final Value<int> publicLevel;
  final Value<int?> fkUserResp;
  final Value<DateTime?> dateStart;
  final Value<DateTime?> dateEnd;
  final Value<String?> budgetAmount;
  final Value<int?> oppStatus;
  final Value<String?> oppAmount;
  final Value<double?> oppPercent;
  final Value<String> extrafields;
  final Value<String?> rawJson;
  final Value<DateTime?> tms;
  final Value<DateTime> localUpdatedAt;
  final Value<SyncStatus> syncStatus;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.socidRemote = const Value.absent(),
    this.socidLocal = const Value.absent(),
    this.ref = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.publicLevel = const Value.absent(),
    this.fkUserResp = const Value.absent(),
    this.dateStart = const Value.absent(),
    this.dateEnd = const Value.absent(),
    this.budgetAmount = const Value.absent(),
    this.oppStatus = const Value.absent(),
    this.oppAmount = const Value.absent(),
    this.oppPercent = const Value.absent(),
    this.extrafields = const Value.absent(),
    this.rawJson = const Value.absent(),
    this.tms = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
  });
  ProjectsCompanion.insert({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.socidRemote = const Value.absent(),
    this.socidLocal = const Value.absent(),
    this.ref = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.publicLevel = const Value.absent(),
    this.fkUserResp = const Value.absent(),
    this.dateStart = const Value.absent(),
    this.dateEnd = const Value.absent(),
    this.budgetAmount = const Value.absent(),
    this.oppStatus = const Value.absent(),
    this.oppAmount = const Value.absent(),
    this.oppPercent = const Value.absent(),
    this.extrafields = const Value.absent(),
    this.rawJson = const Value.absent(),
    this.tms = const Value.absent(),
    required DateTime localUpdatedAt,
    this.syncStatus = const Value.absent(),
  }) : localUpdatedAt = Value(localUpdatedAt);
  static Insertable<ProjectRow> custom({
    Expression<int>? id,
    Expression<int>? remoteId,
    Expression<int>? socidRemote,
    Expression<int>? socidLocal,
    Expression<String>? ref,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? status,
    Expression<int>? publicLevel,
    Expression<int>? fkUserResp,
    Expression<DateTime>? dateStart,
    Expression<DateTime>? dateEnd,
    Expression<String>? budgetAmount,
    Expression<int>? oppStatus,
    Expression<String>? oppAmount,
    Expression<double>? oppPercent,
    Expression<String>? extrafields,
    Expression<String>? rawJson,
    Expression<DateTime>? tms,
    Expression<DateTime>? localUpdatedAt,
    Expression<int>? syncStatus,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (socidRemote != null) 'socid_remote': socidRemote,
      if (socidLocal != null) 'socid_local': socidLocal,
      if (ref != null) 'ref': ref,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (publicLevel != null) 'public_level': publicLevel,
      if (fkUserResp != null) 'fk_user_resp': fkUserResp,
      if (dateStart != null) 'date_start': dateStart,
      if (dateEnd != null) 'date_end': dateEnd,
      if (budgetAmount != null) 'budget_amount': budgetAmount,
      if (oppStatus != null) 'opp_status': oppStatus,
      if (oppAmount != null) 'opp_amount': oppAmount,
      if (oppPercent != null) 'opp_percent': oppPercent,
      if (extrafields != null) 'extrafields': extrafields,
      if (rawJson != null) 'raw_json': rawJson,
      if (tms != null) 'tms': tms,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
    });
  }

  ProjectsCompanion copyWith({
    Value<int>? id,
    Value<int?>? remoteId,
    Value<int?>? socidRemote,
    Value<int?>? socidLocal,
    Value<String?>? ref,
    Value<String>? title,
    Value<String?>? description,
    Value<int>? status,
    Value<int>? publicLevel,
    Value<int?>? fkUserResp,
    Value<DateTime?>? dateStart,
    Value<DateTime?>? dateEnd,
    Value<String?>? budgetAmount,
    Value<int?>? oppStatus,
    Value<String?>? oppAmount,
    Value<double?>? oppPercent,
    Value<String>? extrafields,
    Value<String?>? rawJson,
    Value<DateTime?>? tms,
    Value<DateTime>? localUpdatedAt,
    Value<SyncStatus>? syncStatus,
  }) {
    return ProjectsCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      socidRemote: socidRemote ?? this.socidRemote,
      socidLocal: socidLocal ?? this.socidLocal,
      ref: ref ?? this.ref,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      publicLevel: publicLevel ?? this.publicLevel,
      fkUserResp: fkUserResp ?? this.fkUserResp,
      dateStart: dateStart ?? this.dateStart,
      dateEnd: dateEnd ?? this.dateEnd,
      budgetAmount: budgetAmount ?? this.budgetAmount,
      oppStatus: oppStatus ?? this.oppStatus,
      oppAmount: oppAmount ?? this.oppAmount,
      oppPercent: oppPercent ?? this.oppPercent,
      extrafields: extrafields ?? this.extrafields,
      rawJson: rawJson ?? this.rawJson,
      tms: tms ?? this.tms,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<int>(remoteId.value);
    }
    if (socidRemote.present) {
      map['socid_remote'] = Variable<int>(socidRemote.value);
    }
    if (socidLocal.present) {
      map['socid_local'] = Variable<int>(socidLocal.value);
    }
    if (ref.present) {
      map['ref'] = Variable<String>(ref.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (publicLevel.present) {
      map['public_level'] = Variable<int>(publicLevel.value);
    }
    if (fkUserResp.present) {
      map['fk_user_resp'] = Variable<int>(fkUserResp.value);
    }
    if (dateStart.present) {
      map['date_start'] = Variable<DateTime>(dateStart.value);
    }
    if (dateEnd.present) {
      map['date_end'] = Variable<DateTime>(dateEnd.value);
    }
    if (budgetAmount.present) {
      map['budget_amount'] = Variable<String>(budgetAmount.value);
    }
    if (oppStatus.present) {
      map['opp_status'] = Variable<int>(oppStatus.value);
    }
    if (oppAmount.present) {
      map['opp_amount'] = Variable<String>(oppAmount.value);
    }
    if (oppPercent.present) {
      map['opp_percent'] = Variable<double>(oppPercent.value);
    }
    if (extrafields.present) {
      map['extrafields'] = Variable<String>(extrafields.value);
    }
    if (rawJson.present) {
      map['raw_json'] = Variable<String>(rawJson.value);
    }
    if (tms.present) {
      map['tms'] = Variable<DateTime>(tms.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $ProjectsTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('socidRemote: $socidRemote, ')
          ..write('socidLocal: $socidLocal, ')
          ..write('ref: $ref, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('publicLevel: $publicLevel, ')
          ..write('fkUserResp: $fkUserResp, ')
          ..write('dateStart: $dateStart, ')
          ..write('dateEnd: $dateEnd, ')
          ..write('budgetAmount: $budgetAmount, ')
          ..write('oppStatus: $oppStatus, ')
          ..write('oppAmount: $oppAmount, ')
          ..write('oppPercent: $oppPercent, ')
          ..write('extrafields: $extrafields, ')
          ..write('rawJson: $rawJson, ')
          ..write('tms: $tms, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }
}

class $SyncMetadataTable extends SyncMetadata
    with TableInfo<$SyncMetadataTable, SyncMetadataRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _lastFullSyncAtMeta = const VerificationMeta(
    'lastFullSyncAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastFullSyncAt =
      GeneratedColumn<DateTime>(
        'last_full_sync_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastDeltaSyncAtMeta = const VerificationMeta(
    'lastDeltaSyncAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastDeltaSyncAt =
      GeneratedColumn<DateTime>(
        'last_delta_sync_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _apiVersionMeta = const VerificationMeta(
    'apiVersion',
  );
  @override
  late final GeneratedColumn<String> apiVersion = GeneratedColumn<String>(
    'api_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lastFullSyncAt,
    lastDeltaSyncAt,
    apiVersion,
    schemaVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetadataRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('last_full_sync_at')) {
      context.handle(
        _lastFullSyncAtMeta,
        lastFullSyncAt.isAcceptableOrUnknown(
          data['last_full_sync_at']!,
          _lastFullSyncAtMeta,
        ),
      );
    }
    if (data.containsKey('last_delta_sync_at')) {
      context.handle(
        _lastDeltaSyncAtMeta,
        lastDeltaSyncAt.isAcceptableOrUnknown(
          data['last_delta_sync_at']!,
          _lastDeltaSyncAtMeta,
        ),
      );
    }
    if (data.containsKey('api_version')) {
      context.handle(
        _apiVersionMeta,
        apiVersion.isAcceptableOrUnknown(data['api_version']!, _apiVersionMeta),
      );
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncMetadataRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetadataRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      lastFullSyncAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_full_sync_at'],
      ),
      lastDeltaSyncAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_delta_sync_at'],
      ),
      apiVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}api_version'],
      ),
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_version'],
      )!,
    );
  }

  @override
  $SyncMetadataTable createAlias(String alias) {
    return $SyncMetadataTable(attachedDatabase, alias);
  }
}

class SyncMetadataRow extends DataClass implements Insertable<SyncMetadataRow> {
  final int id;
  final DateTime? lastFullSyncAt;
  final DateTime? lastDeltaSyncAt;
  final String? apiVersion;
  final int schemaVersion;
  const SyncMetadataRow({
    required this.id,
    this.lastFullSyncAt,
    this.lastDeltaSyncAt,
    this.apiVersion,
    required this.schemaVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || lastFullSyncAt != null) {
      map['last_full_sync_at'] = Variable<DateTime>(lastFullSyncAt);
    }
    if (!nullToAbsent || lastDeltaSyncAt != null) {
      map['last_delta_sync_at'] = Variable<DateTime>(lastDeltaSyncAt);
    }
    if (!nullToAbsent || apiVersion != null) {
      map['api_version'] = Variable<String>(apiVersion);
    }
    map['schema_version'] = Variable<int>(schemaVersion);
    return map;
  }

  SyncMetadataCompanion toCompanion(bool nullToAbsent) {
    return SyncMetadataCompanion(
      id: Value(id),
      lastFullSyncAt: lastFullSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastFullSyncAt),
      lastDeltaSyncAt: lastDeltaSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastDeltaSyncAt),
      apiVersion: apiVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(apiVersion),
      schemaVersion: Value(schemaVersion),
    );
  }

  factory SyncMetadataRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetadataRow(
      id: serializer.fromJson<int>(json['id']),
      lastFullSyncAt: serializer.fromJson<DateTime?>(json['lastFullSyncAt']),
      lastDeltaSyncAt: serializer.fromJson<DateTime?>(json['lastDeltaSyncAt']),
      apiVersion: serializer.fromJson<String?>(json['apiVersion']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lastFullSyncAt': serializer.toJson<DateTime?>(lastFullSyncAt),
      'lastDeltaSyncAt': serializer.toJson<DateTime?>(lastDeltaSyncAt),
      'apiVersion': serializer.toJson<String?>(apiVersion),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
    };
  }

  SyncMetadataRow copyWith({
    int? id,
    Value<DateTime?> lastFullSyncAt = const Value.absent(),
    Value<DateTime?> lastDeltaSyncAt = const Value.absent(),
    Value<String?> apiVersion = const Value.absent(),
    int? schemaVersion,
  }) => SyncMetadataRow(
    id: id ?? this.id,
    lastFullSyncAt: lastFullSyncAt.present
        ? lastFullSyncAt.value
        : this.lastFullSyncAt,
    lastDeltaSyncAt: lastDeltaSyncAt.present
        ? lastDeltaSyncAt.value
        : this.lastDeltaSyncAt,
    apiVersion: apiVersion.present ? apiVersion.value : this.apiVersion,
    schemaVersion: schemaVersion ?? this.schemaVersion,
  );
  SyncMetadataRow copyWithCompanion(SyncMetadataCompanion data) {
    return SyncMetadataRow(
      id: data.id.present ? data.id.value : this.id,
      lastFullSyncAt: data.lastFullSyncAt.present
          ? data.lastFullSyncAt.value
          : this.lastFullSyncAt,
      lastDeltaSyncAt: data.lastDeltaSyncAt.present
          ? data.lastDeltaSyncAt.value
          : this.lastDeltaSyncAt,
      apiVersion: data.apiVersion.present
          ? data.apiVersion.value
          : this.apiVersion,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataRow(')
          ..write('id: $id, ')
          ..write('lastFullSyncAt: $lastFullSyncAt, ')
          ..write('lastDeltaSyncAt: $lastDeltaSyncAt, ')
          ..write('apiVersion: $apiVersion, ')
          ..write('schemaVersion: $schemaVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    lastFullSyncAt,
    lastDeltaSyncAt,
    apiVersion,
    schemaVersion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetadataRow &&
          other.id == this.id &&
          other.lastFullSyncAt == this.lastFullSyncAt &&
          other.lastDeltaSyncAt == this.lastDeltaSyncAt &&
          other.apiVersion == this.apiVersion &&
          other.schemaVersion == this.schemaVersion);
}

class SyncMetadataCompanion extends UpdateCompanion<SyncMetadataRow> {
  final Value<int> id;
  final Value<DateTime?> lastFullSyncAt;
  final Value<DateTime?> lastDeltaSyncAt;
  final Value<String?> apiVersion;
  final Value<int> schemaVersion;
  const SyncMetadataCompanion({
    this.id = const Value.absent(),
    this.lastFullSyncAt = const Value.absent(),
    this.lastDeltaSyncAt = const Value.absent(),
    this.apiVersion = const Value.absent(),
    this.schemaVersion = const Value.absent(),
  });
  SyncMetadataCompanion.insert({
    this.id = const Value.absent(),
    this.lastFullSyncAt = const Value.absent(),
    this.lastDeltaSyncAt = const Value.absent(),
    this.apiVersion = const Value.absent(),
    this.schemaVersion = const Value.absent(),
  });
  static Insertable<SyncMetadataRow> custom({
    Expression<int>? id,
    Expression<DateTime>? lastFullSyncAt,
    Expression<DateTime>? lastDeltaSyncAt,
    Expression<String>? apiVersion,
    Expression<int>? schemaVersion,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lastFullSyncAt != null) 'last_full_sync_at': lastFullSyncAt,
      if (lastDeltaSyncAt != null) 'last_delta_sync_at': lastDeltaSyncAt,
      if (apiVersion != null) 'api_version': apiVersion,
      if (schemaVersion != null) 'schema_version': schemaVersion,
    });
  }

  SyncMetadataCompanion copyWith({
    Value<int>? id,
    Value<DateTime?>? lastFullSyncAt,
    Value<DateTime?>? lastDeltaSyncAt,
    Value<String?>? apiVersion,
    Value<int>? schemaVersion,
  }) {
    return SyncMetadataCompanion(
      id: id ?? this.id,
      lastFullSyncAt: lastFullSyncAt ?? this.lastFullSyncAt,
      lastDeltaSyncAt: lastDeltaSyncAt ?? this.lastDeltaSyncAt,
      apiVersion: apiVersion ?? this.apiVersion,
      schemaVersion: schemaVersion ?? this.schemaVersion,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lastFullSyncAt.present) {
      map['last_full_sync_at'] = Variable<DateTime>(lastFullSyncAt.value);
    }
    if (lastDeltaSyncAt.present) {
      map['last_delta_sync_at'] = Variable<DateTime>(lastDeltaSyncAt.value);
    }
    if (apiVersion.present) {
      map['api_version'] = Variable<String>(apiVersion.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataCompanion(')
          ..write('id: $id, ')
          ..write('lastFullSyncAt: $lastFullSyncAt, ')
          ..write('lastDeltaSyncAt: $lastDeltaSyncAt, ')
          ..write('apiVersion: $apiVersion, ')
          ..write('schemaVersion: $schemaVersion')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, TaskRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<int> remoteId = GeneratedColumn<int>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _projectRemoteMeta = const VerificationMeta(
    'projectRemote',
  );
  @override
  late final GeneratedColumn<int> projectRemote = GeneratedColumn<int>(
    'project_remote',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _projectLocalMeta = const VerificationMeta(
    'projectLocal',
  );
  @override
  late final GeneratedColumn<int> projectLocal = GeneratedColumn<int>(
    'project_local',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _refMeta = const VerificationMeta('ref');
  @override
  late final GeneratedColumn<String> ref = GeneratedColumn<String>(
    'ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _progressMeta = const VerificationMeta(
    'progress',
  );
  @override
  late final GeneratedColumn<int> progress = GeneratedColumn<int>(
    'progress',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _plannedHoursMeta = const VerificationMeta(
    'plannedHours',
  );
  @override
  late final GeneratedColumn<String> plannedHours = GeneratedColumn<String>(
    'planned_hours',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fkUserMeta = const VerificationMeta('fkUser');
  @override
  late final GeneratedColumn<int> fkUser = GeneratedColumn<int>(
    'fk_user',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateStartMeta = const VerificationMeta(
    'dateStart',
  );
  @override
  late final GeneratedColumn<DateTime> dateStart = GeneratedColumn<DateTime>(
    'date_start',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateEndMeta = const VerificationMeta(
    'dateEnd',
  );
  @override
  late final GeneratedColumn<DateTime> dateEnd = GeneratedColumn<DateTime>(
    'date_end',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _extrafieldsMeta = const VerificationMeta(
    'extrafields',
  );
  @override
  late final GeneratedColumn<String> extrafields = GeneratedColumn<String>(
    'extrafields',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _rawJsonMeta = const VerificationMeta(
    'rawJson',
  );
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
    'raw_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tmsMeta = const VerificationMeta('tms');
  @override
  late final GeneratedColumn<DateTime> tms = GeneratedColumn<DateTime>(
    'tms',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>(
        'local_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: Constant(SyncStatus.synced.index),
      ).withConverter<SyncStatus>($TasksTable.$convertersyncStatus);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    remoteId,
    projectRemote,
    projectLocal,
    ref,
    label,
    description,
    status,
    progress,
    plannedHours,
    fkUser,
    dateStart,
    dateEnd,
    extrafields,
    rawJson,
    tms,
    localUpdatedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('project_remote')) {
      context.handle(
        _projectRemoteMeta,
        projectRemote.isAcceptableOrUnknown(
          data['project_remote']!,
          _projectRemoteMeta,
        ),
      );
    }
    if (data.containsKey('project_local')) {
      context.handle(
        _projectLocalMeta,
        projectLocal.isAcceptableOrUnknown(
          data['project_local']!,
          _projectLocalMeta,
        ),
      );
    }
    if (data.containsKey('ref')) {
      context.handle(
        _refMeta,
        ref.isAcceptableOrUnknown(data['ref']!, _refMeta),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('progress')) {
      context.handle(
        _progressMeta,
        progress.isAcceptableOrUnknown(data['progress']!, _progressMeta),
      );
    }
    if (data.containsKey('planned_hours')) {
      context.handle(
        _plannedHoursMeta,
        plannedHours.isAcceptableOrUnknown(
          data['planned_hours']!,
          _plannedHoursMeta,
        ),
      );
    }
    if (data.containsKey('fk_user')) {
      context.handle(
        _fkUserMeta,
        fkUser.isAcceptableOrUnknown(data['fk_user']!, _fkUserMeta),
      );
    }
    if (data.containsKey('date_start')) {
      context.handle(
        _dateStartMeta,
        dateStart.isAcceptableOrUnknown(data['date_start']!, _dateStartMeta),
      );
    }
    if (data.containsKey('date_end')) {
      context.handle(
        _dateEndMeta,
        dateEnd.isAcceptableOrUnknown(data['date_end']!, _dateEndMeta),
      );
    }
    if (data.containsKey('extrafields')) {
      context.handle(
        _extrafieldsMeta,
        extrafields.isAcceptableOrUnknown(
          data['extrafields']!,
          _extrafieldsMeta,
        ),
      );
    }
    if (data.containsKey('raw_json')) {
      context.handle(
        _rawJsonMeta,
        rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta),
      );
    }
    if (data.containsKey('tms')) {
      context.handle(
        _tmsMeta,
        tms.isAcceptableOrUnknown(data['tms']!, _tmsMeta),
      );
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remote_id'],
      ),
      projectRemote: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}project_remote'],
      ),
      projectLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}project_local'],
      ),
      ref: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref'],
      ),
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      progress: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}progress'],
      )!,
      plannedHours: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}planned_hours'],
      ),
      fkUser: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fk_user'],
      ),
      dateStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_start'],
      ),
      dateEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_end'],
      ),
      extrafields: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extrafields'],
      )!,
      rawJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_json'],
      ),
      tms: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}tms'],
      ),
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}local_updated_at'],
      )!,
      syncStatus: $TasksTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class TaskRow extends DataClass implements Insertable<TaskRow> {
  final int id;
  final int? remoteId;

  /// `fk_projet` côté Dolibarr — id du projet parent
  /// (`remoteId` Project).
  final int? projectRemote;

  /// FK locale vers Projects.id quand le projet parent est encore en
  /// pendingCreate (cascade Outbox 2ᵉ niveau). Patché par le SyncEngine
  /// après push du projet parent.
  final int? projectLocal;
  final String? ref;
  final String label;
  final String? description;

  /// Statut Dolibarr d'une tâche (0=en cours, 1=terminée).
  final int status;

  /// Avancement en pourcent (0..100).
  final int progress;

  /// Heures prévues (string pour préserver la précision).
  final String? plannedHours;

  /// Utilisateur principal de la tâche.
  final int? fkUser;
  final DateTime? dateStart;
  final DateTime? dateEnd;
  final String extrafields;
  final String? rawJson;
  final DateTime? tms;
  final DateTime localUpdatedAt;
  final SyncStatus syncStatus;
  const TaskRow({
    required this.id,
    this.remoteId,
    this.projectRemote,
    this.projectLocal,
    this.ref,
    required this.label,
    this.description,
    required this.status,
    required this.progress,
    this.plannedHours,
    this.fkUser,
    this.dateStart,
    this.dateEnd,
    required this.extrafields,
    this.rawJson,
    this.tms,
    required this.localUpdatedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<int>(remoteId);
    }
    if (!nullToAbsent || projectRemote != null) {
      map['project_remote'] = Variable<int>(projectRemote);
    }
    if (!nullToAbsent || projectLocal != null) {
      map['project_local'] = Variable<int>(projectLocal);
    }
    if (!nullToAbsent || ref != null) {
      map['ref'] = Variable<String>(ref);
    }
    map['label'] = Variable<String>(label);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['status'] = Variable<int>(status);
    map['progress'] = Variable<int>(progress);
    if (!nullToAbsent || plannedHours != null) {
      map['planned_hours'] = Variable<String>(plannedHours);
    }
    if (!nullToAbsent || fkUser != null) {
      map['fk_user'] = Variable<int>(fkUser);
    }
    if (!nullToAbsent || dateStart != null) {
      map['date_start'] = Variable<DateTime>(dateStart);
    }
    if (!nullToAbsent || dateEnd != null) {
      map['date_end'] = Variable<DateTime>(dateEnd);
    }
    map['extrafields'] = Variable<String>(extrafields);
    if (!nullToAbsent || rawJson != null) {
      map['raw_json'] = Variable<String>(rawJson);
    }
    if (!nullToAbsent || tms != null) {
      map['tms'] = Variable<DateTime>(tms);
    }
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    {
      map['sync_status'] = Variable<int>(
        $TasksTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      projectRemote: projectRemote == null && nullToAbsent
          ? const Value.absent()
          : Value(projectRemote),
      projectLocal: projectLocal == null && nullToAbsent
          ? const Value.absent()
          : Value(projectLocal),
      ref: ref == null && nullToAbsent ? const Value.absent() : Value(ref),
      label: Value(label),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      status: Value(status),
      progress: Value(progress),
      plannedHours: plannedHours == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedHours),
      fkUser: fkUser == null && nullToAbsent
          ? const Value.absent()
          : Value(fkUser),
      dateStart: dateStart == null && nullToAbsent
          ? const Value.absent()
          : Value(dateStart),
      dateEnd: dateEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(dateEnd),
      extrafields: Value(extrafields),
      rawJson: rawJson == null && nullToAbsent
          ? const Value.absent()
          : Value(rawJson),
      tms: tms == null && nullToAbsent ? const Value.absent() : Value(tms),
      localUpdatedAt: Value(localUpdatedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory TaskRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskRow(
      id: serializer.fromJson<int>(json['id']),
      remoteId: serializer.fromJson<int?>(json['remoteId']),
      projectRemote: serializer.fromJson<int?>(json['projectRemote']),
      projectLocal: serializer.fromJson<int?>(json['projectLocal']),
      ref: serializer.fromJson<String?>(json['ref']),
      label: serializer.fromJson<String>(json['label']),
      description: serializer.fromJson<String?>(json['description']),
      status: serializer.fromJson<int>(json['status']),
      progress: serializer.fromJson<int>(json['progress']),
      plannedHours: serializer.fromJson<String?>(json['plannedHours']),
      fkUser: serializer.fromJson<int?>(json['fkUser']),
      dateStart: serializer.fromJson<DateTime?>(json['dateStart']),
      dateEnd: serializer.fromJson<DateTime?>(json['dateEnd']),
      extrafields: serializer.fromJson<String>(json['extrafields']),
      rawJson: serializer.fromJson<String?>(json['rawJson']),
      tms: serializer.fromJson<DateTime?>(json['tms']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      syncStatus: $TasksTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'remoteId': serializer.toJson<int?>(remoteId),
      'projectRemote': serializer.toJson<int?>(projectRemote),
      'projectLocal': serializer.toJson<int?>(projectLocal),
      'ref': serializer.toJson<String?>(ref),
      'label': serializer.toJson<String>(label),
      'description': serializer.toJson<String?>(description),
      'status': serializer.toJson<int>(status),
      'progress': serializer.toJson<int>(progress),
      'plannedHours': serializer.toJson<String?>(plannedHours),
      'fkUser': serializer.toJson<int?>(fkUser),
      'dateStart': serializer.toJson<DateTime?>(dateStart),
      'dateEnd': serializer.toJson<DateTime?>(dateEnd),
      'extrafields': serializer.toJson<String>(extrafields),
      'rawJson': serializer.toJson<String?>(rawJson),
      'tms': serializer.toJson<DateTime?>(tms),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'syncStatus': serializer.toJson<int>(
        $TasksTable.$convertersyncStatus.toJson(syncStatus),
      ),
    };
  }

  TaskRow copyWith({
    int? id,
    Value<int?> remoteId = const Value.absent(),
    Value<int?> projectRemote = const Value.absent(),
    Value<int?> projectLocal = const Value.absent(),
    Value<String?> ref = const Value.absent(),
    String? label,
    Value<String?> description = const Value.absent(),
    int? status,
    int? progress,
    Value<String?> plannedHours = const Value.absent(),
    Value<int?> fkUser = const Value.absent(),
    Value<DateTime?> dateStart = const Value.absent(),
    Value<DateTime?> dateEnd = const Value.absent(),
    String? extrafields,
    Value<String?> rawJson = const Value.absent(),
    Value<DateTime?> tms = const Value.absent(),
    DateTime? localUpdatedAt,
    SyncStatus? syncStatus,
  }) => TaskRow(
    id: id ?? this.id,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    projectRemote: projectRemote.present
        ? projectRemote.value
        : this.projectRemote,
    projectLocal: projectLocal.present ? projectLocal.value : this.projectLocal,
    ref: ref.present ? ref.value : this.ref,
    label: label ?? this.label,
    description: description.present ? description.value : this.description,
    status: status ?? this.status,
    progress: progress ?? this.progress,
    plannedHours: plannedHours.present ? plannedHours.value : this.plannedHours,
    fkUser: fkUser.present ? fkUser.value : this.fkUser,
    dateStart: dateStart.present ? dateStart.value : this.dateStart,
    dateEnd: dateEnd.present ? dateEnd.value : this.dateEnd,
    extrafields: extrafields ?? this.extrafields,
    rawJson: rawJson.present ? rawJson.value : this.rawJson,
    tms: tms.present ? tms.value : this.tms,
    localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  TaskRow copyWithCompanion(TasksCompanion data) {
    return TaskRow(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      projectRemote: data.projectRemote.present
          ? data.projectRemote.value
          : this.projectRemote,
      projectLocal: data.projectLocal.present
          ? data.projectLocal.value
          : this.projectLocal,
      ref: data.ref.present ? data.ref.value : this.ref,
      label: data.label.present ? data.label.value : this.label,
      description: data.description.present
          ? data.description.value
          : this.description,
      status: data.status.present ? data.status.value : this.status,
      progress: data.progress.present ? data.progress.value : this.progress,
      plannedHours: data.plannedHours.present
          ? data.plannedHours.value
          : this.plannedHours,
      fkUser: data.fkUser.present ? data.fkUser.value : this.fkUser,
      dateStart: data.dateStart.present ? data.dateStart.value : this.dateStart,
      dateEnd: data.dateEnd.present ? data.dateEnd.value : this.dateEnd,
      extrafields: data.extrafields.present
          ? data.extrafields.value
          : this.extrafields,
      rawJson: data.rawJson.present ? data.rawJson.value : this.rawJson,
      tms: data.tms.present ? data.tms.value : this.tms,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskRow(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('projectRemote: $projectRemote, ')
          ..write('projectLocal: $projectLocal, ')
          ..write('ref: $ref, ')
          ..write('label: $label, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('progress: $progress, ')
          ..write('plannedHours: $plannedHours, ')
          ..write('fkUser: $fkUser, ')
          ..write('dateStart: $dateStart, ')
          ..write('dateEnd: $dateEnd, ')
          ..write('extrafields: $extrafields, ')
          ..write('rawJson: $rawJson, ')
          ..write('tms: $tms, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    remoteId,
    projectRemote,
    projectLocal,
    ref,
    label,
    description,
    status,
    progress,
    plannedHours,
    fkUser,
    dateStart,
    dateEnd,
    extrafields,
    rawJson,
    tms,
    localUpdatedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskRow &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.projectRemote == this.projectRemote &&
          other.projectLocal == this.projectLocal &&
          other.ref == this.ref &&
          other.label == this.label &&
          other.description == this.description &&
          other.status == this.status &&
          other.progress == this.progress &&
          other.plannedHours == this.plannedHours &&
          other.fkUser == this.fkUser &&
          other.dateStart == this.dateStart &&
          other.dateEnd == this.dateEnd &&
          other.extrafields == this.extrafields &&
          other.rawJson == this.rawJson &&
          other.tms == this.tms &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.syncStatus == this.syncStatus);
}

class TasksCompanion extends UpdateCompanion<TaskRow> {
  final Value<int> id;
  final Value<int?> remoteId;
  final Value<int?> projectRemote;
  final Value<int?> projectLocal;
  final Value<String?> ref;
  final Value<String> label;
  final Value<String?> description;
  final Value<int> status;
  final Value<int> progress;
  final Value<String?> plannedHours;
  final Value<int?> fkUser;
  final Value<DateTime?> dateStart;
  final Value<DateTime?> dateEnd;
  final Value<String> extrafields;
  final Value<String?> rawJson;
  final Value<DateTime?> tms;
  final Value<DateTime> localUpdatedAt;
  final Value<SyncStatus> syncStatus;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.projectRemote = const Value.absent(),
    this.projectLocal = const Value.absent(),
    this.ref = const Value.absent(),
    this.label = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.progress = const Value.absent(),
    this.plannedHours = const Value.absent(),
    this.fkUser = const Value.absent(),
    this.dateStart = const Value.absent(),
    this.dateEnd = const Value.absent(),
    this.extrafields = const Value.absent(),
    this.rawJson = const Value.absent(),
    this.tms = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
  });
  TasksCompanion.insert({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.projectRemote = const Value.absent(),
    this.projectLocal = const Value.absent(),
    this.ref = const Value.absent(),
    this.label = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.progress = const Value.absent(),
    this.plannedHours = const Value.absent(),
    this.fkUser = const Value.absent(),
    this.dateStart = const Value.absent(),
    this.dateEnd = const Value.absent(),
    this.extrafields = const Value.absent(),
    this.rawJson = const Value.absent(),
    this.tms = const Value.absent(),
    required DateTime localUpdatedAt,
    this.syncStatus = const Value.absent(),
  }) : localUpdatedAt = Value(localUpdatedAt);
  static Insertable<TaskRow> custom({
    Expression<int>? id,
    Expression<int>? remoteId,
    Expression<int>? projectRemote,
    Expression<int>? projectLocal,
    Expression<String>? ref,
    Expression<String>? label,
    Expression<String>? description,
    Expression<int>? status,
    Expression<int>? progress,
    Expression<String>? plannedHours,
    Expression<int>? fkUser,
    Expression<DateTime>? dateStart,
    Expression<DateTime>? dateEnd,
    Expression<String>? extrafields,
    Expression<String>? rawJson,
    Expression<DateTime>? tms,
    Expression<DateTime>? localUpdatedAt,
    Expression<int>? syncStatus,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (projectRemote != null) 'project_remote': projectRemote,
      if (projectLocal != null) 'project_local': projectLocal,
      if (ref != null) 'ref': ref,
      if (label != null) 'label': label,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (progress != null) 'progress': progress,
      if (plannedHours != null) 'planned_hours': plannedHours,
      if (fkUser != null) 'fk_user': fkUser,
      if (dateStart != null) 'date_start': dateStart,
      if (dateEnd != null) 'date_end': dateEnd,
      if (extrafields != null) 'extrafields': extrafields,
      if (rawJson != null) 'raw_json': rawJson,
      if (tms != null) 'tms': tms,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
    });
  }

  TasksCompanion copyWith({
    Value<int>? id,
    Value<int?>? remoteId,
    Value<int?>? projectRemote,
    Value<int?>? projectLocal,
    Value<String?>? ref,
    Value<String>? label,
    Value<String?>? description,
    Value<int>? status,
    Value<int>? progress,
    Value<String?>? plannedHours,
    Value<int?>? fkUser,
    Value<DateTime?>? dateStart,
    Value<DateTime?>? dateEnd,
    Value<String>? extrafields,
    Value<String?>? rawJson,
    Value<DateTime?>? tms,
    Value<DateTime>? localUpdatedAt,
    Value<SyncStatus>? syncStatus,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      projectRemote: projectRemote ?? this.projectRemote,
      projectLocal: projectLocal ?? this.projectLocal,
      ref: ref ?? this.ref,
      label: label ?? this.label,
      description: description ?? this.description,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      plannedHours: plannedHours ?? this.plannedHours,
      fkUser: fkUser ?? this.fkUser,
      dateStart: dateStart ?? this.dateStart,
      dateEnd: dateEnd ?? this.dateEnd,
      extrafields: extrafields ?? this.extrafields,
      rawJson: rawJson ?? this.rawJson,
      tms: tms ?? this.tms,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<int>(remoteId.value);
    }
    if (projectRemote.present) {
      map['project_remote'] = Variable<int>(projectRemote.value);
    }
    if (projectLocal.present) {
      map['project_local'] = Variable<int>(projectLocal.value);
    }
    if (ref.present) {
      map['ref'] = Variable<String>(ref.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (progress.present) {
      map['progress'] = Variable<int>(progress.value);
    }
    if (plannedHours.present) {
      map['planned_hours'] = Variable<String>(plannedHours.value);
    }
    if (fkUser.present) {
      map['fk_user'] = Variable<int>(fkUser.value);
    }
    if (dateStart.present) {
      map['date_start'] = Variable<DateTime>(dateStart.value);
    }
    if (dateEnd.present) {
      map['date_end'] = Variable<DateTime>(dateEnd.value);
    }
    if (extrafields.present) {
      map['extrafields'] = Variable<String>(extrafields.value);
    }
    if (rawJson.present) {
      map['raw_json'] = Variable<String>(rawJson.value);
    }
    if (tms.present) {
      map['tms'] = Variable<DateTime>(tms.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $TasksTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('projectRemote: $projectRemote, ')
          ..write('projectLocal: $projectLocal, ')
          ..write('ref: $ref, ')
          ..write('label: $label, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('progress: $progress, ')
          ..write('plannedHours: $plannedHours, ')
          ..write('fkUser: $fkUser, ')
          ..write('dateStart: $dateStart, ')
          ..write('dateEnd: $dateEnd, ')
          ..write('extrafields: $extrafields, ')
          ..write('rawJson: $rawJson, ')
          ..write('tms: $tms, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ThirdPartiesTable thirdParties = $ThirdPartiesTable(this);
  late final $ContactsTable contacts = $ContactsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $DraftsTable drafts = $DraftsTable(this);
  late final $ExtrafieldDefinitionsTable extrafieldDefinitions =
      $ExtrafieldDefinitionsTable(this);
  late final $InvoiceLinesTable invoiceLines = $InvoiceLinesTable(this);
  late final $InvoicesTable invoices = $InvoicesTable(this);
  late final $PendingOperationsTable pendingOperations =
      $PendingOperationsTable(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $SyncMetadataTable syncMetadata = $SyncMetadataTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    thirdParties,
    contacts,
    categories,
    drafts,
    extrafieldDefinitions,
    invoiceLines,
    invoices,
    pendingOperations,
    projects,
    syncMetadata,
    tasks,
  ];
}

typedef $$ThirdPartiesTableCreateCompanionBuilder =
    ThirdPartiesCompanion Function({
      Value<int> id,
      Value<int?> remoteId,
      Value<String> name,
      Value<String?> codeClient,
      Value<String?> codeFournisseur,
      Value<int> clientType,
      Value<int> fournisseur,
      Value<int> status,
      Value<String?> address,
      Value<String?> zip,
      Value<String?> town,
      Value<String?> countryCode,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> url,
      Value<String?> siren,
      Value<String?> siret,
      Value<String?> tvaIntra,
      Value<String?> notePublic,
      Value<String?> notePrivate,
      Value<String> categoriesJson,
      Value<String> extrafields,
      Value<String?> rawJson,
      Value<DateTime?> tms,
      required DateTime localUpdatedAt,
      Value<SyncStatus> syncStatus,
    });
typedef $$ThirdPartiesTableUpdateCompanionBuilder =
    ThirdPartiesCompanion Function({
      Value<int> id,
      Value<int?> remoteId,
      Value<String> name,
      Value<String?> codeClient,
      Value<String?> codeFournisseur,
      Value<int> clientType,
      Value<int> fournisseur,
      Value<int> status,
      Value<String?> address,
      Value<String?> zip,
      Value<String?> town,
      Value<String?> countryCode,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> url,
      Value<String?> siren,
      Value<String?> siret,
      Value<String?> tvaIntra,
      Value<String?> notePublic,
      Value<String?> notePrivate,
      Value<String> categoriesJson,
      Value<String> extrafields,
      Value<String?> rawJson,
      Value<DateTime?> tms,
      Value<DateTime> localUpdatedAt,
      Value<SyncStatus> syncStatus,
    });

class $$ThirdPartiesTableFilterComposer
    extends Composer<_$AppDatabase, $ThirdPartiesTable> {
  $$ThirdPartiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codeClient => $composableBuilder(
    column: $table.codeClient,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codeFournisseur => $composableBuilder(
    column: $table.codeFournisseur,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get clientType => $composableBuilder(
    column: $table.clientType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fournisseur => $composableBuilder(
    column: $table.fournisseur,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get zip => $composableBuilder(
    column: $table.zip,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get town => $composableBuilder(
    column: $table.town,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get siren => $composableBuilder(
    column: $table.siren,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get siret => $composableBuilder(
    column: $table.siret,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tvaIntra => $composableBuilder(
    column: $table.tvaIntra,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notePublic => $composableBuilder(
    column: $table.notePublic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notePrivate => $composableBuilder(
    column: $table.notePrivate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoriesJson => $composableBuilder(
    column: $table.categoriesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extrafields => $composableBuilder(
    column: $table.extrafields,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get tms => $composableBuilder(
    column: $table.tms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$ThirdPartiesTableOrderingComposer
    extends Composer<_$AppDatabase, $ThirdPartiesTable> {
  $$ThirdPartiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codeClient => $composableBuilder(
    column: $table.codeClient,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codeFournisseur => $composableBuilder(
    column: $table.codeFournisseur,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get clientType => $composableBuilder(
    column: $table.clientType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fournisseur => $composableBuilder(
    column: $table.fournisseur,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get zip => $composableBuilder(
    column: $table.zip,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get town => $composableBuilder(
    column: $table.town,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get siren => $composableBuilder(
    column: $table.siren,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get siret => $composableBuilder(
    column: $table.siret,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tvaIntra => $composableBuilder(
    column: $table.tvaIntra,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notePublic => $composableBuilder(
    column: $table.notePublic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notePrivate => $composableBuilder(
    column: $table.notePrivate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoriesJson => $composableBuilder(
    column: $table.categoriesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extrafields => $composableBuilder(
    column: $table.extrafields,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get tms => $composableBuilder(
    column: $table.tms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ThirdPartiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ThirdPartiesTable> {
  $$ThirdPartiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get codeClient => $composableBuilder(
    column: $table.codeClient,
    builder: (column) => column,
  );

  GeneratedColumn<String> get codeFournisseur => $composableBuilder(
    column: $table.codeFournisseur,
    builder: (column) => column,
  );

  GeneratedColumn<int> get clientType => $composableBuilder(
    column: $table.clientType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fournisseur => $composableBuilder(
    column: $table.fournisseur,
    builder: (column) => column,
  );

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get zip =>
      $composableBuilder(column: $table.zip, builder: (column) => column);

  GeneratedColumn<String> get town =>
      $composableBuilder(column: $table.town, builder: (column) => column);

  GeneratedColumn<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get siren =>
      $composableBuilder(column: $table.siren, builder: (column) => column);

  GeneratedColumn<String> get siret =>
      $composableBuilder(column: $table.siret, builder: (column) => column);

  GeneratedColumn<String> get tvaIntra =>
      $composableBuilder(column: $table.tvaIntra, builder: (column) => column);

  GeneratedColumn<String> get notePublic => $composableBuilder(
    column: $table.notePublic,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notePrivate => $composableBuilder(
    column: $table.notePrivate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoriesJson => $composableBuilder(
    column: $table.categoriesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get extrafields => $composableBuilder(
    column: $table.extrafields,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawJson =>
      $composableBuilder(column: $table.rawJson, builder: (column) => column);

  GeneratedColumn<DateTime> get tms =>
      $composableBuilder(column: $table.tms, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );
}

class $$ThirdPartiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ThirdPartiesTable,
          ThirdPartyRow,
          $$ThirdPartiesTableFilterComposer,
          $$ThirdPartiesTableOrderingComposer,
          $$ThirdPartiesTableAnnotationComposer,
          $$ThirdPartiesTableCreateCompanionBuilder,
          $$ThirdPartiesTableUpdateCompanionBuilder,
          (
            ThirdPartyRow,
            BaseReferences<_$AppDatabase, $ThirdPartiesTable, ThirdPartyRow>,
          ),
          ThirdPartyRow,
          PrefetchHooks Function()
        > {
  $$ThirdPartiesTableTableManager(_$AppDatabase db, $ThirdPartiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ThirdPartiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ThirdPartiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ThirdPartiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> remoteId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> codeClient = const Value.absent(),
                Value<String?> codeFournisseur = const Value.absent(),
                Value<int> clientType = const Value.absent(),
                Value<int> fournisseur = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> zip = const Value.absent(),
                Value<String?> town = const Value.absent(),
                Value<String?> countryCode = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<String?> siren = const Value.absent(),
                Value<String?> siret = const Value.absent(),
                Value<String?> tvaIntra = const Value.absent(),
                Value<String?> notePublic = const Value.absent(),
                Value<String?> notePrivate = const Value.absent(),
                Value<String> categoriesJson = const Value.absent(),
                Value<String> extrafields = const Value.absent(),
                Value<String?> rawJson = const Value.absent(),
                Value<DateTime?> tms = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
              }) => ThirdPartiesCompanion(
                id: id,
                remoteId: remoteId,
                name: name,
                codeClient: codeClient,
                codeFournisseur: codeFournisseur,
                clientType: clientType,
                fournisseur: fournisseur,
                status: status,
                address: address,
                zip: zip,
                town: town,
                countryCode: countryCode,
                phone: phone,
                email: email,
                url: url,
                siren: siren,
                siret: siret,
                tvaIntra: tvaIntra,
                notePublic: notePublic,
                notePrivate: notePrivate,
                categoriesJson: categoriesJson,
                extrafields: extrafields,
                rawJson: rawJson,
                tms: tms,
                localUpdatedAt: localUpdatedAt,
                syncStatus: syncStatus,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> remoteId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> codeClient = const Value.absent(),
                Value<String?> codeFournisseur = const Value.absent(),
                Value<int> clientType = const Value.absent(),
                Value<int> fournisseur = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> zip = const Value.absent(),
                Value<String?> town = const Value.absent(),
                Value<String?> countryCode = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<String?> siren = const Value.absent(),
                Value<String?> siret = const Value.absent(),
                Value<String?> tvaIntra = const Value.absent(),
                Value<String?> notePublic = const Value.absent(),
                Value<String?> notePrivate = const Value.absent(),
                Value<String> categoriesJson = const Value.absent(),
                Value<String> extrafields = const Value.absent(),
                Value<String?> rawJson = const Value.absent(),
                Value<DateTime?> tms = const Value.absent(),
                required DateTime localUpdatedAt,
                Value<SyncStatus> syncStatus = const Value.absent(),
              }) => ThirdPartiesCompanion.insert(
                id: id,
                remoteId: remoteId,
                name: name,
                codeClient: codeClient,
                codeFournisseur: codeFournisseur,
                clientType: clientType,
                fournisseur: fournisseur,
                status: status,
                address: address,
                zip: zip,
                town: town,
                countryCode: countryCode,
                phone: phone,
                email: email,
                url: url,
                siren: siren,
                siret: siret,
                tvaIntra: tvaIntra,
                notePublic: notePublic,
                notePrivate: notePrivate,
                categoriesJson: categoriesJson,
                extrafields: extrafields,
                rawJson: rawJson,
                tms: tms,
                localUpdatedAt: localUpdatedAt,
                syncStatus: syncStatus,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ThirdPartiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ThirdPartiesTable,
      ThirdPartyRow,
      $$ThirdPartiesTableFilterComposer,
      $$ThirdPartiesTableOrderingComposer,
      $$ThirdPartiesTableAnnotationComposer,
      $$ThirdPartiesTableCreateCompanionBuilder,
      $$ThirdPartiesTableUpdateCompanionBuilder,
      (
        ThirdPartyRow,
        BaseReferences<_$AppDatabase, $ThirdPartiesTable, ThirdPartyRow>,
      ),
      ThirdPartyRow,
      PrefetchHooks Function()
    >;
typedef $$ContactsTableCreateCompanionBuilder =
    ContactsCompanion Function({
      Value<int> id,
      Value<int?> remoteId,
      Value<int?> socidRemote,
      Value<int?> socidLocal,
      Value<String?> firstname,
      Value<String?> lastname,
      Value<String?> poste,
      Value<String?> phonePro,
      Value<String?> phoneMobile,
      Value<String?> email,
      Value<String?> address,
      Value<String?> zip,
      Value<String?> town,
      Value<String> extrafields,
      Value<String?> rawJson,
      Value<DateTime?> tms,
      required DateTime localUpdatedAt,
      Value<SyncStatus> syncStatus,
    });
typedef $$ContactsTableUpdateCompanionBuilder =
    ContactsCompanion Function({
      Value<int> id,
      Value<int?> remoteId,
      Value<int?> socidRemote,
      Value<int?> socidLocal,
      Value<String?> firstname,
      Value<String?> lastname,
      Value<String?> poste,
      Value<String?> phonePro,
      Value<String?> phoneMobile,
      Value<String?> email,
      Value<String?> address,
      Value<String?> zip,
      Value<String?> town,
      Value<String> extrafields,
      Value<String?> rawJson,
      Value<DateTime?> tms,
      Value<DateTime> localUpdatedAt,
      Value<SyncStatus> syncStatus,
    });

class $$ContactsTableFilterComposer
    extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get socidRemote => $composableBuilder(
    column: $table.socidRemote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get socidLocal => $composableBuilder(
    column: $table.socidLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstname => $composableBuilder(
    column: $table.firstname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastname => $composableBuilder(
    column: $table.lastname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get poste => $composableBuilder(
    column: $table.poste,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phonePro => $composableBuilder(
    column: $table.phonePro,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneMobile => $composableBuilder(
    column: $table.phoneMobile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get zip => $composableBuilder(
    column: $table.zip,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get town => $composableBuilder(
    column: $table.town,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extrafields => $composableBuilder(
    column: $table.extrafields,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get tms => $composableBuilder(
    column: $table.tms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$ContactsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get socidRemote => $composableBuilder(
    column: $table.socidRemote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get socidLocal => $composableBuilder(
    column: $table.socidLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstname => $composableBuilder(
    column: $table.firstname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastname => $composableBuilder(
    column: $table.lastname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get poste => $composableBuilder(
    column: $table.poste,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phonePro => $composableBuilder(
    column: $table.phonePro,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneMobile => $composableBuilder(
    column: $table.phoneMobile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get zip => $composableBuilder(
    column: $table.zip,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get town => $composableBuilder(
    column: $table.town,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extrafields => $composableBuilder(
    column: $table.extrafields,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get tms => $composableBuilder(
    column: $table.tms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContactsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<int> get socidRemote => $composableBuilder(
    column: $table.socidRemote,
    builder: (column) => column,
  );

  GeneratedColumn<int> get socidLocal => $composableBuilder(
    column: $table.socidLocal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get firstname =>
      $composableBuilder(column: $table.firstname, builder: (column) => column);

  GeneratedColumn<String> get lastname =>
      $composableBuilder(column: $table.lastname, builder: (column) => column);

  GeneratedColumn<String> get poste =>
      $composableBuilder(column: $table.poste, builder: (column) => column);

  GeneratedColumn<String> get phonePro =>
      $composableBuilder(column: $table.phonePro, builder: (column) => column);

  GeneratedColumn<String> get phoneMobile => $composableBuilder(
    column: $table.phoneMobile,
    builder: (column) => column,
  );

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get zip =>
      $composableBuilder(column: $table.zip, builder: (column) => column);

  GeneratedColumn<String> get town =>
      $composableBuilder(column: $table.town, builder: (column) => column);

  GeneratedColumn<String> get extrafields => $composableBuilder(
    column: $table.extrafields,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawJson =>
      $composableBuilder(column: $table.rawJson, builder: (column) => column);

  GeneratedColumn<DateTime> get tms =>
      $composableBuilder(column: $table.tms, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );
}

class $$ContactsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContactsTable,
          ContactRow,
          $$ContactsTableFilterComposer,
          $$ContactsTableOrderingComposer,
          $$ContactsTableAnnotationComposer,
          $$ContactsTableCreateCompanionBuilder,
          $$ContactsTableUpdateCompanionBuilder,
          (
            ContactRow,
            BaseReferences<_$AppDatabase, $ContactsTable, ContactRow>,
          ),
          ContactRow,
          PrefetchHooks Function()
        > {
  $$ContactsTableTableManager(_$AppDatabase db, $ContactsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContactsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContactsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContactsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> remoteId = const Value.absent(),
                Value<int?> socidRemote = const Value.absent(),
                Value<int?> socidLocal = const Value.absent(),
                Value<String?> firstname = const Value.absent(),
                Value<String?> lastname = const Value.absent(),
                Value<String?> poste = const Value.absent(),
                Value<String?> phonePro = const Value.absent(),
                Value<String?> phoneMobile = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> zip = const Value.absent(),
                Value<String?> town = const Value.absent(),
                Value<String> extrafields = const Value.absent(),
                Value<String?> rawJson = const Value.absent(),
                Value<DateTime?> tms = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
              }) => ContactsCompanion(
                id: id,
                remoteId: remoteId,
                socidRemote: socidRemote,
                socidLocal: socidLocal,
                firstname: firstname,
                lastname: lastname,
                poste: poste,
                phonePro: phonePro,
                phoneMobile: phoneMobile,
                email: email,
                address: address,
                zip: zip,
                town: town,
                extrafields: extrafields,
                rawJson: rawJson,
                tms: tms,
                localUpdatedAt: localUpdatedAt,
                syncStatus: syncStatus,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> remoteId = const Value.absent(),
                Value<int?> socidRemote = const Value.absent(),
                Value<int?> socidLocal = const Value.absent(),
                Value<String?> firstname = const Value.absent(),
                Value<String?> lastname = const Value.absent(),
                Value<String?> poste = const Value.absent(),
                Value<String?> phonePro = const Value.absent(),
                Value<String?> phoneMobile = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> zip = const Value.absent(),
                Value<String?> town = const Value.absent(),
                Value<String> extrafields = const Value.absent(),
                Value<String?> rawJson = const Value.absent(),
                Value<DateTime?> tms = const Value.absent(),
                required DateTime localUpdatedAt,
                Value<SyncStatus> syncStatus = const Value.absent(),
              }) => ContactsCompanion.insert(
                id: id,
                remoteId: remoteId,
                socidRemote: socidRemote,
                socidLocal: socidLocal,
                firstname: firstname,
                lastname: lastname,
                poste: poste,
                phonePro: phonePro,
                phoneMobile: phoneMobile,
                email: email,
                address: address,
                zip: zip,
                town: town,
                extrafields: extrafields,
                rawJson: rawJson,
                tms: tms,
                localUpdatedAt: localUpdatedAt,
                syncStatus: syncStatus,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContactsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContactsTable,
      ContactRow,
      $$ContactsTableFilterComposer,
      $$ContactsTableOrderingComposer,
      $$ContactsTableAnnotationComposer,
      $$ContactsTableCreateCompanionBuilder,
      $$ContactsTableUpdateCompanionBuilder,
      (ContactRow, BaseReferences<_$AppDatabase, $ContactsTable, ContactRow>),
      ContactRow,
      PrefetchHooks Function()
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      required int remoteId,
      required String label,
      required String type,
      Value<int?> parentRemoteId,
      Value<String?> color,
      required DateTime fetchedAt,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      Value<int> remoteId,
      Value<String> label,
      Value<String> type,
      Value<int?> parentRemoteId,
      Value<String?> color,
      Value<DateTime> fetchedAt,
    });

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parentRemoteId => $composableBuilder(
    column: $table.parentRemoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parentRemoteId => $composableBuilder(
    column: $table.parentRemoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get parentRemoteId => $composableBuilder(
    column: $table.parentRemoteId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          CategoryRow,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (
            CategoryRow,
            BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow>,
          ),
          CategoryRow,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> remoteId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int?> parentRemoteId = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                remoteId: remoteId,
                label: label,
                type: type,
                parentRemoteId: parentRemoteId,
                color: color,
                fetchedAt: fetchedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int remoteId,
                required String label,
                required String type,
                Value<int?> parentRemoteId = const Value.absent(),
                Value<String?> color = const Value.absent(),
                required DateTime fetchedAt,
              }) => CategoriesCompanion.insert(
                id: id,
                remoteId: remoteId,
                label: label,
                type: type,
                parentRemoteId: parentRemoteId,
                color: color,
                fetchedAt: fetchedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      CategoryRow,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (
        CategoryRow,
        BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow>,
      ),
      CategoryRow,
      PrefetchHooks Function()
    >;
typedef $$DraftsTableCreateCompanionBuilder =
    DraftsCompanion Function({
      Value<int> id,
      required String entityType,
      Value<int?> refLocalId,
      Value<String> fieldsJson,
      required DateTime updatedAt,
    });
typedef $$DraftsTableUpdateCompanionBuilder =
    DraftsCompanion Function({
      Value<int> id,
      Value<String> entityType,
      Value<int?> refLocalId,
      Value<String> fieldsJson,
      Value<DateTime> updatedAt,
    });

class $$DraftsTableFilterComposer
    extends Composer<_$AppDatabase, $DraftsTable> {
  $$DraftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get refLocalId => $composableBuilder(
    column: $table.refLocalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fieldsJson => $composableBuilder(
    column: $table.fieldsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DraftsTableOrderingComposer
    extends Composer<_$AppDatabase, $DraftsTable> {
  $$DraftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get refLocalId => $composableBuilder(
    column: $table.refLocalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldsJson => $composableBuilder(
    column: $table.fieldsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DraftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DraftsTable> {
  $$DraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get refLocalId => $composableBuilder(
    column: $table.refLocalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fieldsJson => $composableBuilder(
    column: $table.fieldsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DraftsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DraftsTable,
          DraftRow,
          $$DraftsTableFilterComposer,
          $$DraftsTableOrderingComposer,
          $$DraftsTableAnnotationComposer,
          $$DraftsTableCreateCompanionBuilder,
          $$DraftsTableUpdateCompanionBuilder,
          (DraftRow, BaseReferences<_$AppDatabase, $DraftsTable, DraftRow>),
          DraftRow,
          PrefetchHooks Function()
        > {
  $$DraftsTableTableManager(_$AppDatabase db, $DraftsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DraftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DraftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<int?> refLocalId = const Value.absent(),
                Value<String> fieldsJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => DraftsCompanion(
                id: id,
                entityType: entityType,
                refLocalId: refLocalId,
                fieldsJson: fieldsJson,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entityType,
                Value<int?> refLocalId = const Value.absent(),
                Value<String> fieldsJson = const Value.absent(),
                required DateTime updatedAt,
              }) => DraftsCompanion.insert(
                id: id,
                entityType: entityType,
                refLocalId: refLocalId,
                fieldsJson: fieldsJson,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DraftsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DraftsTable,
      DraftRow,
      $$DraftsTableFilterComposer,
      $$DraftsTableOrderingComposer,
      $$DraftsTableAnnotationComposer,
      $$DraftsTableCreateCompanionBuilder,
      $$DraftsTableUpdateCompanionBuilder,
      (DraftRow, BaseReferences<_$AppDatabase, $DraftsTable, DraftRow>),
      DraftRow,
      PrefetchHooks Function()
    >;
typedef $$ExtrafieldDefinitionsTableCreateCompanionBuilder =
    ExtrafieldDefinitionsCompanion Function({
      Value<int> id,
      required String entityType,
      required String fieldName,
      required String label,
      required String type,
      Value<bool> required,
      Value<String?> options,
      Value<int> position,
      required DateTime fetchedAt,
    });
typedef $$ExtrafieldDefinitionsTableUpdateCompanionBuilder =
    ExtrafieldDefinitionsCompanion Function({
      Value<int> id,
      Value<String> entityType,
      Value<String> fieldName,
      Value<String> label,
      Value<String> type,
      Value<bool> required,
      Value<String?> options,
      Value<int> position,
      Value<DateTime> fetchedAt,
    });

class $$ExtrafieldDefinitionsTableFilterComposer
    extends Composer<_$AppDatabase, $ExtrafieldDefinitionsTable> {
  $$ExtrafieldDefinitionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fieldName => $composableBuilder(
    column: $table.fieldName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get required => $composableBuilder(
    column: $table.required,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get options => $composableBuilder(
    column: $table.options,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExtrafieldDefinitionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExtrafieldDefinitionsTable> {
  $$ExtrafieldDefinitionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldName => $composableBuilder(
    column: $table.fieldName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get required => $composableBuilder(
    column: $table.required,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get options => $composableBuilder(
    column: $table.options,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExtrafieldDefinitionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExtrafieldDefinitionsTable> {
  $$ExtrafieldDefinitionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fieldName =>
      $composableBuilder(column: $table.fieldName, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get required =>
      $composableBuilder(column: $table.required, builder: (column) => column);

  GeneratedColumn<String> get options =>
      $composableBuilder(column: $table.options, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$ExtrafieldDefinitionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExtrafieldDefinitionsTable,
          ExtrafieldDefinitionRow,
          $$ExtrafieldDefinitionsTableFilterComposer,
          $$ExtrafieldDefinitionsTableOrderingComposer,
          $$ExtrafieldDefinitionsTableAnnotationComposer,
          $$ExtrafieldDefinitionsTableCreateCompanionBuilder,
          $$ExtrafieldDefinitionsTableUpdateCompanionBuilder,
          (
            ExtrafieldDefinitionRow,
            BaseReferences<
              _$AppDatabase,
              $ExtrafieldDefinitionsTable,
              ExtrafieldDefinitionRow
            >,
          ),
          ExtrafieldDefinitionRow,
          PrefetchHooks Function()
        > {
  $$ExtrafieldDefinitionsTableTableManager(
    _$AppDatabase db,
    $ExtrafieldDefinitionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExtrafieldDefinitionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ExtrafieldDefinitionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ExtrafieldDefinitionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> fieldName = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<bool> required = const Value.absent(),
                Value<String?> options = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
              }) => ExtrafieldDefinitionsCompanion(
                id: id,
                entityType: entityType,
                fieldName: fieldName,
                label: label,
                type: type,
                required: required,
                options: options,
                position: position,
                fetchedAt: fetchedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entityType,
                required String fieldName,
                required String label,
                required String type,
                Value<bool> required = const Value.absent(),
                Value<String?> options = const Value.absent(),
                Value<int> position = const Value.absent(),
                required DateTime fetchedAt,
              }) => ExtrafieldDefinitionsCompanion.insert(
                id: id,
                entityType: entityType,
                fieldName: fieldName,
                label: label,
                type: type,
                required: required,
                options: options,
                position: position,
                fetchedAt: fetchedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExtrafieldDefinitionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExtrafieldDefinitionsTable,
      ExtrafieldDefinitionRow,
      $$ExtrafieldDefinitionsTableFilterComposer,
      $$ExtrafieldDefinitionsTableOrderingComposer,
      $$ExtrafieldDefinitionsTableAnnotationComposer,
      $$ExtrafieldDefinitionsTableCreateCompanionBuilder,
      $$ExtrafieldDefinitionsTableUpdateCompanionBuilder,
      (
        ExtrafieldDefinitionRow,
        BaseReferences<
          _$AppDatabase,
          $ExtrafieldDefinitionsTable,
          ExtrafieldDefinitionRow
        >,
      ),
      ExtrafieldDefinitionRow,
      PrefetchHooks Function()
    >;
typedef $$InvoiceLinesTableCreateCompanionBuilder =
    InvoiceLinesCompanion Function({
      Value<int> id,
      Value<int?> remoteId,
      Value<int?> invoiceRemote,
      Value<int?> invoiceLocal,
      Value<int?> fkProduct,
      Value<String?> label,
      Value<String?> description,
      Value<int> productType,
      Value<String> qty,
      Value<String?> subprice,
      Value<String?> tvaTx,
      Value<String?> remisePercent,
      Value<String?> totalHt,
      Value<String?> totalTva,
      Value<String?> totalTtc,
      Value<int> rang,
      Value<String> extrafields,
      Value<DateTime?> tms,
      required DateTime localUpdatedAt,
      Value<SyncStatus> syncStatus,
    });
typedef $$InvoiceLinesTableUpdateCompanionBuilder =
    InvoiceLinesCompanion Function({
      Value<int> id,
      Value<int?> remoteId,
      Value<int?> invoiceRemote,
      Value<int?> invoiceLocal,
      Value<int?> fkProduct,
      Value<String?> label,
      Value<String?> description,
      Value<int> productType,
      Value<String> qty,
      Value<String?> subprice,
      Value<String?> tvaTx,
      Value<String?> remisePercent,
      Value<String?> totalHt,
      Value<String?> totalTva,
      Value<String?> totalTtc,
      Value<int> rang,
      Value<String> extrafields,
      Value<DateTime?> tms,
      Value<DateTime> localUpdatedAt,
      Value<SyncStatus> syncStatus,
    });

class $$InvoiceLinesTableFilterComposer
    extends Composer<_$AppDatabase, $InvoiceLinesTable> {
  $$InvoiceLinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get invoiceRemote => $composableBuilder(
    column: $table.invoiceRemote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get invoiceLocal => $composableBuilder(
    column: $table.invoiceLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fkProduct => $composableBuilder(
    column: $table.fkProduct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get productType => $composableBuilder(
    column: $table.productType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subprice => $composableBuilder(
    column: $table.subprice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tvaTx => $composableBuilder(
    column: $table.tvaTx,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remisePercent => $composableBuilder(
    column: $table.remisePercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get totalHt => $composableBuilder(
    column: $table.totalHt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get totalTva => $composableBuilder(
    column: $table.totalTva,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get totalTtc => $composableBuilder(
    column: $table.totalTtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rang => $composableBuilder(
    column: $table.rang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extrafields => $composableBuilder(
    column: $table.extrafields,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get tms => $composableBuilder(
    column: $table.tms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$InvoiceLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $InvoiceLinesTable> {
  $$InvoiceLinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get invoiceRemote => $composableBuilder(
    column: $table.invoiceRemote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get invoiceLocal => $composableBuilder(
    column: $table.invoiceLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fkProduct => $composableBuilder(
    column: $table.fkProduct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get productType => $composableBuilder(
    column: $table.productType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subprice => $composableBuilder(
    column: $table.subprice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tvaTx => $composableBuilder(
    column: $table.tvaTx,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remisePercent => $composableBuilder(
    column: $table.remisePercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get totalHt => $composableBuilder(
    column: $table.totalHt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get totalTva => $composableBuilder(
    column: $table.totalTva,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get totalTtc => $composableBuilder(
    column: $table.totalTtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rang => $composableBuilder(
    column: $table.rang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extrafields => $composableBuilder(
    column: $table.extrafields,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get tms => $composableBuilder(
    column: $table.tms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InvoiceLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvoiceLinesTable> {
  $$InvoiceLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<int> get invoiceRemote => $composableBuilder(
    column: $table.invoiceRemote,
    builder: (column) => column,
  );

  GeneratedColumn<int> get invoiceLocal => $composableBuilder(
    column: $table.invoiceLocal,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fkProduct =>
      $composableBuilder(column: $table.fkProduct, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get productType => $composableBuilder(
    column: $table.productType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get qty =>
      $composableBuilder(column: $table.qty, builder: (column) => column);

  GeneratedColumn<String> get subprice =>
      $composableBuilder(column: $table.subprice, builder: (column) => column);

  GeneratedColumn<String> get tvaTx =>
      $composableBuilder(column: $table.tvaTx, builder: (column) => column);

  GeneratedColumn<String> get remisePercent => $composableBuilder(
    column: $table.remisePercent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get totalHt =>
      $composableBuilder(column: $table.totalHt, builder: (column) => column);

  GeneratedColumn<String> get totalTva =>
      $composableBuilder(column: $table.totalTva, builder: (column) => column);

  GeneratedColumn<String> get totalTtc =>
      $composableBuilder(column: $table.totalTtc, builder: (column) => column);

  GeneratedColumn<int> get rang =>
      $composableBuilder(column: $table.rang, builder: (column) => column);

  GeneratedColumn<String> get extrafields => $composableBuilder(
    column: $table.extrafields,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get tms =>
      $composableBuilder(column: $table.tms, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );
}

class $$InvoiceLinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InvoiceLinesTable,
          InvoiceLineRow,
          $$InvoiceLinesTableFilterComposer,
          $$InvoiceLinesTableOrderingComposer,
          $$InvoiceLinesTableAnnotationComposer,
          $$InvoiceLinesTableCreateCompanionBuilder,
          $$InvoiceLinesTableUpdateCompanionBuilder,
          (
            InvoiceLineRow,
            BaseReferences<_$AppDatabase, $InvoiceLinesTable, InvoiceLineRow>,
          ),
          InvoiceLineRow,
          PrefetchHooks Function()
        > {
  $$InvoiceLinesTableTableManager(_$AppDatabase db, $InvoiceLinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoiceLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvoiceLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvoiceLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> remoteId = const Value.absent(),
                Value<int?> invoiceRemote = const Value.absent(),
                Value<int?> invoiceLocal = const Value.absent(),
                Value<int?> fkProduct = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> productType = const Value.absent(),
                Value<String> qty = const Value.absent(),
                Value<String?> subprice = const Value.absent(),
                Value<String?> tvaTx = const Value.absent(),
                Value<String?> remisePercent = const Value.absent(),
                Value<String?> totalHt = const Value.absent(),
                Value<String?> totalTva = const Value.absent(),
                Value<String?> totalTtc = const Value.absent(),
                Value<int> rang = const Value.absent(),
                Value<String> extrafields = const Value.absent(),
                Value<DateTime?> tms = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
              }) => InvoiceLinesCompanion(
                id: id,
                remoteId: remoteId,
                invoiceRemote: invoiceRemote,
                invoiceLocal: invoiceLocal,
                fkProduct: fkProduct,
                label: label,
                description: description,
                productType: productType,
                qty: qty,
                subprice: subprice,
                tvaTx: tvaTx,
                remisePercent: remisePercent,
                totalHt: totalHt,
                totalTva: totalTva,
                totalTtc: totalTtc,
                rang: rang,
                extrafields: extrafields,
                tms: tms,
                localUpdatedAt: localUpdatedAt,
                syncStatus: syncStatus,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> remoteId = const Value.absent(),
                Value<int?> invoiceRemote = const Value.absent(),
                Value<int?> invoiceLocal = const Value.absent(),
                Value<int?> fkProduct = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> productType = const Value.absent(),
                Value<String> qty = const Value.absent(),
                Value<String?> subprice = const Value.absent(),
                Value<String?> tvaTx = const Value.absent(),
                Value<String?> remisePercent = const Value.absent(),
                Value<String?> totalHt = const Value.absent(),
                Value<String?> totalTva = const Value.absent(),
                Value<String?> totalTtc = const Value.absent(),
                Value<int> rang = const Value.absent(),
                Value<String> extrafields = const Value.absent(),
                Value<DateTime?> tms = const Value.absent(),
                required DateTime localUpdatedAt,
                Value<SyncStatus> syncStatus = const Value.absent(),
              }) => InvoiceLinesCompanion.insert(
                id: id,
                remoteId: remoteId,
                invoiceRemote: invoiceRemote,
                invoiceLocal: invoiceLocal,
                fkProduct: fkProduct,
                label: label,
                description: description,
                productType: productType,
                qty: qty,
                subprice: subprice,
                tvaTx: tvaTx,
                remisePercent: remisePercent,
                totalHt: totalHt,
                totalTva: totalTva,
                totalTtc: totalTtc,
                rang: rang,
                extrafields: extrafields,
                tms: tms,
                localUpdatedAt: localUpdatedAt,
                syncStatus: syncStatus,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InvoiceLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InvoiceLinesTable,
      InvoiceLineRow,
      $$InvoiceLinesTableFilterComposer,
      $$InvoiceLinesTableOrderingComposer,
      $$InvoiceLinesTableAnnotationComposer,
      $$InvoiceLinesTableCreateCompanionBuilder,
      $$InvoiceLinesTableUpdateCompanionBuilder,
      (
        InvoiceLineRow,
        BaseReferences<_$AppDatabase, $InvoiceLinesTable, InvoiceLineRow>,
      ),
      InvoiceLineRow,
      PrefetchHooks Function()
    >;
typedef $$InvoicesTableCreateCompanionBuilder =
    InvoicesCompanion Function({
      Value<int> id,
      Value<int?> remoteId,
      Value<int?> socidRemote,
      Value<int?> socidLocal,
      Value<String?> ref,
      Value<String?> refClient,
      Value<int> type,
      Value<int> status,
      Value<int> paye,
      Value<DateTime?> dateInvoice,
      Value<DateTime?> dateDue,
      Value<String?> totalHt,
      Value<String?> totalTva,
      Value<String?> totalTtc,
      Value<int?> fkModeReglement,
      Value<int?> fkCondReglement,
      Value<String?> notePublic,
      Value<String?> notePrivate,
      Value<String> extrafields,
      Value<String?> rawJson,
      Value<DateTime?> tms,
      required DateTime localUpdatedAt,
      Value<SyncStatus> syncStatus,
    });
typedef $$InvoicesTableUpdateCompanionBuilder =
    InvoicesCompanion Function({
      Value<int> id,
      Value<int?> remoteId,
      Value<int?> socidRemote,
      Value<int?> socidLocal,
      Value<String?> ref,
      Value<String?> refClient,
      Value<int> type,
      Value<int> status,
      Value<int> paye,
      Value<DateTime?> dateInvoice,
      Value<DateTime?> dateDue,
      Value<String?> totalHt,
      Value<String?> totalTva,
      Value<String?> totalTtc,
      Value<int?> fkModeReglement,
      Value<int?> fkCondReglement,
      Value<String?> notePublic,
      Value<String?> notePrivate,
      Value<String> extrafields,
      Value<String?> rawJson,
      Value<DateTime?> tms,
      Value<DateTime> localUpdatedAt,
      Value<SyncStatus> syncStatus,
    });

class $$InvoicesTableFilterComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get socidRemote => $composableBuilder(
    column: $table.socidRemote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get socidLocal => $composableBuilder(
    column: $table.socidLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ref => $composableBuilder(
    column: $table.ref,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refClient => $composableBuilder(
    column: $table.refClient,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paye => $composableBuilder(
    column: $table.paye,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateInvoice => $composableBuilder(
    column: $table.dateInvoice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateDue => $composableBuilder(
    column: $table.dateDue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get totalHt => $composableBuilder(
    column: $table.totalHt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get totalTva => $composableBuilder(
    column: $table.totalTva,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get totalTtc => $composableBuilder(
    column: $table.totalTtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fkModeReglement => $composableBuilder(
    column: $table.fkModeReglement,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fkCondReglement => $composableBuilder(
    column: $table.fkCondReglement,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notePublic => $composableBuilder(
    column: $table.notePublic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notePrivate => $composableBuilder(
    column: $table.notePrivate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extrafields => $composableBuilder(
    column: $table.extrafields,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get tms => $composableBuilder(
    column: $table.tms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$InvoicesTableOrderingComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get socidRemote => $composableBuilder(
    column: $table.socidRemote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get socidLocal => $composableBuilder(
    column: $table.socidLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ref => $composableBuilder(
    column: $table.ref,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refClient => $composableBuilder(
    column: $table.refClient,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paye => $composableBuilder(
    column: $table.paye,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateInvoice => $composableBuilder(
    column: $table.dateInvoice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateDue => $composableBuilder(
    column: $table.dateDue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get totalHt => $composableBuilder(
    column: $table.totalHt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get totalTva => $composableBuilder(
    column: $table.totalTva,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get totalTtc => $composableBuilder(
    column: $table.totalTtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fkModeReglement => $composableBuilder(
    column: $table.fkModeReglement,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fkCondReglement => $composableBuilder(
    column: $table.fkCondReglement,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notePublic => $composableBuilder(
    column: $table.notePublic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notePrivate => $composableBuilder(
    column: $table.notePrivate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extrafields => $composableBuilder(
    column: $table.extrafields,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get tms => $composableBuilder(
    column: $table.tms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InvoicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<int> get socidRemote => $composableBuilder(
    column: $table.socidRemote,
    builder: (column) => column,
  );

  GeneratedColumn<int> get socidLocal => $composableBuilder(
    column: $table.socidLocal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ref =>
      $composableBuilder(column: $table.ref, builder: (column) => column);

  GeneratedColumn<String> get refClient =>
      $composableBuilder(column: $table.refClient, builder: (column) => column);

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get paye =>
      $composableBuilder(column: $table.paye, builder: (column) => column);

  GeneratedColumn<DateTime> get dateInvoice => $composableBuilder(
    column: $table.dateInvoice,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateDue =>
      $composableBuilder(column: $table.dateDue, builder: (column) => column);

  GeneratedColumn<String> get totalHt =>
      $composableBuilder(column: $table.totalHt, builder: (column) => column);

  GeneratedColumn<String> get totalTva =>
      $composableBuilder(column: $table.totalTva, builder: (column) => column);

  GeneratedColumn<String> get totalTtc =>
      $composableBuilder(column: $table.totalTtc, builder: (column) => column);

  GeneratedColumn<int> get fkModeReglement => $composableBuilder(
    column: $table.fkModeReglement,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fkCondReglement => $composableBuilder(
    column: $table.fkCondReglement,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notePublic => $composableBuilder(
    column: $table.notePublic,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notePrivate => $composableBuilder(
    column: $table.notePrivate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get extrafields => $composableBuilder(
    column: $table.extrafields,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawJson =>
      $composableBuilder(column: $table.rawJson, builder: (column) => column);

  GeneratedColumn<DateTime> get tms =>
      $composableBuilder(column: $table.tms, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );
}

class $$InvoicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InvoicesTable,
          InvoiceRow,
          $$InvoicesTableFilterComposer,
          $$InvoicesTableOrderingComposer,
          $$InvoicesTableAnnotationComposer,
          $$InvoicesTableCreateCompanionBuilder,
          $$InvoicesTableUpdateCompanionBuilder,
          (
            InvoiceRow,
            BaseReferences<_$AppDatabase, $InvoicesTable, InvoiceRow>,
          ),
          InvoiceRow,
          PrefetchHooks Function()
        > {
  $$InvoicesTableTableManager(_$AppDatabase db, $InvoicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvoicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvoicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> remoteId = const Value.absent(),
                Value<int?> socidRemote = const Value.absent(),
                Value<int?> socidLocal = const Value.absent(),
                Value<String?> ref = const Value.absent(),
                Value<String?> refClient = const Value.absent(),
                Value<int> type = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<int> paye = const Value.absent(),
                Value<DateTime?> dateInvoice = const Value.absent(),
                Value<DateTime?> dateDue = const Value.absent(),
                Value<String?> totalHt = const Value.absent(),
                Value<String?> totalTva = const Value.absent(),
                Value<String?> totalTtc = const Value.absent(),
                Value<int?> fkModeReglement = const Value.absent(),
                Value<int?> fkCondReglement = const Value.absent(),
                Value<String?> notePublic = const Value.absent(),
                Value<String?> notePrivate = const Value.absent(),
                Value<String> extrafields = const Value.absent(),
                Value<String?> rawJson = const Value.absent(),
                Value<DateTime?> tms = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
              }) => InvoicesCompanion(
                id: id,
                remoteId: remoteId,
                socidRemote: socidRemote,
                socidLocal: socidLocal,
                ref: ref,
                refClient: refClient,
                type: type,
                status: status,
                paye: paye,
                dateInvoice: dateInvoice,
                dateDue: dateDue,
                totalHt: totalHt,
                totalTva: totalTva,
                totalTtc: totalTtc,
                fkModeReglement: fkModeReglement,
                fkCondReglement: fkCondReglement,
                notePublic: notePublic,
                notePrivate: notePrivate,
                extrafields: extrafields,
                rawJson: rawJson,
                tms: tms,
                localUpdatedAt: localUpdatedAt,
                syncStatus: syncStatus,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> remoteId = const Value.absent(),
                Value<int?> socidRemote = const Value.absent(),
                Value<int?> socidLocal = const Value.absent(),
                Value<String?> ref = const Value.absent(),
                Value<String?> refClient = const Value.absent(),
                Value<int> type = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<int> paye = const Value.absent(),
                Value<DateTime?> dateInvoice = const Value.absent(),
                Value<DateTime?> dateDue = const Value.absent(),
                Value<String?> totalHt = const Value.absent(),
                Value<String?> totalTva = const Value.absent(),
                Value<String?> totalTtc = const Value.absent(),
                Value<int?> fkModeReglement = const Value.absent(),
                Value<int?> fkCondReglement = const Value.absent(),
                Value<String?> notePublic = const Value.absent(),
                Value<String?> notePrivate = const Value.absent(),
                Value<String> extrafields = const Value.absent(),
                Value<String?> rawJson = const Value.absent(),
                Value<DateTime?> tms = const Value.absent(),
                required DateTime localUpdatedAt,
                Value<SyncStatus> syncStatus = const Value.absent(),
              }) => InvoicesCompanion.insert(
                id: id,
                remoteId: remoteId,
                socidRemote: socidRemote,
                socidLocal: socidLocal,
                ref: ref,
                refClient: refClient,
                type: type,
                status: status,
                paye: paye,
                dateInvoice: dateInvoice,
                dateDue: dateDue,
                totalHt: totalHt,
                totalTva: totalTva,
                totalTtc: totalTtc,
                fkModeReglement: fkModeReglement,
                fkCondReglement: fkCondReglement,
                notePublic: notePublic,
                notePrivate: notePrivate,
                extrafields: extrafields,
                rawJson: rawJson,
                tms: tms,
                localUpdatedAt: localUpdatedAt,
                syncStatus: syncStatus,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InvoicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InvoicesTable,
      InvoiceRow,
      $$InvoicesTableFilterComposer,
      $$InvoicesTableOrderingComposer,
      $$InvoicesTableAnnotationComposer,
      $$InvoicesTableCreateCompanionBuilder,
      $$InvoicesTableUpdateCompanionBuilder,
      (InvoiceRow, BaseReferences<_$AppDatabase, $InvoicesTable, InvoiceRow>),
      InvoiceRow,
      PrefetchHooks Function()
    >;
typedef $$PendingOperationsTableCreateCompanionBuilder =
    PendingOperationsCompanion Function({
      Value<int> id,
      required PendingOpType opType,
      required PendingOpEntity entityType,
      Value<int?> targetRemoteId,
      required int targetLocalId,
      Value<String> payload,
      Value<DateTime?> expectedTms,
      Value<int?> dependsOnLocalId,
      Value<int> attempts,
      Value<DateTime?> lastAttemptAt,
      Value<String?> lastError,
      Value<DateTime?> nextRetryAt,
      required DateTime createdAt,
      Value<PendingOpStatus> status,
    });
typedef $$PendingOperationsTableUpdateCompanionBuilder =
    PendingOperationsCompanion Function({
      Value<int> id,
      Value<PendingOpType> opType,
      Value<PendingOpEntity> entityType,
      Value<int?> targetRemoteId,
      Value<int> targetLocalId,
      Value<String> payload,
      Value<DateTime?> expectedTms,
      Value<int?> dependsOnLocalId,
      Value<int> attempts,
      Value<DateTime?> lastAttemptAt,
      Value<String?> lastError,
      Value<DateTime?> nextRetryAt,
      Value<DateTime> createdAt,
      Value<PendingOpStatus> status,
    });

class $$PendingOperationsTableFilterComposer
    extends Composer<_$AppDatabase, $PendingOperationsTable> {
  $$PendingOperationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PendingOpType, PendingOpType, int>
  get opType => $composableBuilder(
    column: $table.opType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<PendingOpEntity, PendingOpEntity, int>
  get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get targetRemoteId => $composableBuilder(
    column: $table.targetRemoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetLocalId => $composableBuilder(
    column: $table.targetLocalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expectedTms => $composableBuilder(
    column: $table.expectedTms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dependsOnLocalId => $composableBuilder(
    column: $table.dependsOnLocalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PendingOpStatus, PendingOpStatus, int>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$PendingOperationsTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingOperationsTable> {
  $$PendingOperationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get opType => $composableBuilder(
    column: $table.opType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetRemoteId => $composableBuilder(
    column: $table.targetRemoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetLocalId => $composableBuilder(
    column: $table.targetLocalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expectedTms => $composableBuilder(
    column: $table.expectedTms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dependsOnLocalId => $composableBuilder(
    column: $table.dependsOnLocalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingOperationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingOperationsTable> {
  $$PendingOperationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PendingOpType, int> get opType =>
      $composableBuilder(column: $table.opType, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PendingOpEntity, int> get entityType =>
      $composableBuilder(
        column: $table.entityType,
        builder: (column) => column,
      );

  GeneratedColumn<int> get targetRemoteId => $composableBuilder(
    column: $table.targetRemoteId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetLocalId => $composableBuilder(
    column: $table.targetLocalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get expectedTms => $composableBuilder(
    column: $table.expectedTms,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dependsOnLocalId => $composableBuilder(
    column: $table.dependsOnLocalId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PendingOpStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$PendingOperationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingOperationsTable,
          PendingOperationRow,
          $$PendingOperationsTableFilterComposer,
          $$PendingOperationsTableOrderingComposer,
          $$PendingOperationsTableAnnotationComposer,
          $$PendingOperationsTableCreateCompanionBuilder,
          $$PendingOperationsTableUpdateCompanionBuilder,
          (
            PendingOperationRow,
            BaseReferences<
              _$AppDatabase,
              $PendingOperationsTable,
              PendingOperationRow
            >,
          ),
          PendingOperationRow,
          PrefetchHooks Function()
        > {
  $$PendingOperationsTableTableManager(
    _$AppDatabase db,
    $PendingOperationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingOperationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingOperationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingOperationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<PendingOpType> opType = const Value.absent(),
                Value<PendingOpEntity> entityType = const Value.absent(),
                Value<int?> targetRemoteId = const Value.absent(),
                Value<int> targetLocalId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime?> expectedTms = const Value.absent(),
                Value<int?> dependsOnLocalId = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime?> nextRetryAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<PendingOpStatus> status = const Value.absent(),
              }) => PendingOperationsCompanion(
                id: id,
                opType: opType,
                entityType: entityType,
                targetRemoteId: targetRemoteId,
                targetLocalId: targetLocalId,
                payload: payload,
                expectedTms: expectedTms,
                dependsOnLocalId: dependsOnLocalId,
                attempts: attempts,
                lastAttemptAt: lastAttemptAt,
                lastError: lastError,
                nextRetryAt: nextRetryAt,
                createdAt: createdAt,
                status: status,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required PendingOpType opType,
                required PendingOpEntity entityType,
                Value<int?> targetRemoteId = const Value.absent(),
                required int targetLocalId,
                Value<String> payload = const Value.absent(),
                Value<DateTime?> expectedTms = const Value.absent(),
                Value<int?> dependsOnLocalId = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime?> nextRetryAt = const Value.absent(),
                required DateTime createdAt,
                Value<PendingOpStatus> status = const Value.absent(),
              }) => PendingOperationsCompanion.insert(
                id: id,
                opType: opType,
                entityType: entityType,
                targetRemoteId: targetRemoteId,
                targetLocalId: targetLocalId,
                payload: payload,
                expectedTms: expectedTms,
                dependsOnLocalId: dependsOnLocalId,
                attempts: attempts,
                lastAttemptAt: lastAttemptAt,
                lastError: lastError,
                nextRetryAt: nextRetryAt,
                createdAt: createdAt,
                status: status,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingOperationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingOperationsTable,
      PendingOperationRow,
      $$PendingOperationsTableFilterComposer,
      $$PendingOperationsTableOrderingComposer,
      $$PendingOperationsTableAnnotationComposer,
      $$PendingOperationsTableCreateCompanionBuilder,
      $$PendingOperationsTableUpdateCompanionBuilder,
      (
        PendingOperationRow,
        BaseReferences<
          _$AppDatabase,
          $PendingOperationsTable,
          PendingOperationRow
        >,
      ),
      PendingOperationRow,
      PrefetchHooks Function()
    >;
typedef $$ProjectsTableCreateCompanionBuilder =
    ProjectsCompanion Function({
      Value<int> id,
      Value<int?> remoteId,
      Value<int?> socidRemote,
      Value<int?> socidLocal,
      Value<String?> ref,
      Value<String> title,
      Value<String?> description,
      Value<int> status,
      Value<int> publicLevel,
      Value<int?> fkUserResp,
      Value<DateTime?> dateStart,
      Value<DateTime?> dateEnd,
      Value<String?> budgetAmount,
      Value<int?> oppStatus,
      Value<String?> oppAmount,
      Value<double?> oppPercent,
      Value<String> extrafields,
      Value<String?> rawJson,
      Value<DateTime?> tms,
      required DateTime localUpdatedAt,
      Value<SyncStatus> syncStatus,
    });
typedef $$ProjectsTableUpdateCompanionBuilder =
    ProjectsCompanion Function({
      Value<int> id,
      Value<int?> remoteId,
      Value<int?> socidRemote,
      Value<int?> socidLocal,
      Value<String?> ref,
      Value<String> title,
      Value<String?> description,
      Value<int> status,
      Value<int> publicLevel,
      Value<int?> fkUserResp,
      Value<DateTime?> dateStart,
      Value<DateTime?> dateEnd,
      Value<String?> budgetAmount,
      Value<int?> oppStatus,
      Value<String?> oppAmount,
      Value<double?> oppPercent,
      Value<String> extrafields,
      Value<String?> rawJson,
      Value<DateTime?> tms,
      Value<DateTime> localUpdatedAt,
      Value<SyncStatus> syncStatus,
    });

class $$ProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get socidRemote => $composableBuilder(
    column: $table.socidRemote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get socidLocal => $composableBuilder(
    column: $table.socidLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ref => $composableBuilder(
    column: $table.ref,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get publicLevel => $composableBuilder(
    column: $table.publicLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fkUserResp => $composableBuilder(
    column: $table.fkUserResp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateStart => $composableBuilder(
    column: $table.dateStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateEnd => $composableBuilder(
    column: $table.dateEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get budgetAmount => $composableBuilder(
    column: $table.budgetAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get oppStatus => $composableBuilder(
    column: $table.oppStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oppAmount => $composableBuilder(
    column: $table.oppAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get oppPercent => $composableBuilder(
    column: $table.oppPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extrafields => $composableBuilder(
    column: $table.extrafields,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get tms => $composableBuilder(
    column: $table.tms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$ProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get socidRemote => $composableBuilder(
    column: $table.socidRemote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get socidLocal => $composableBuilder(
    column: $table.socidLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ref => $composableBuilder(
    column: $table.ref,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get publicLevel => $composableBuilder(
    column: $table.publicLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fkUserResp => $composableBuilder(
    column: $table.fkUserResp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateStart => $composableBuilder(
    column: $table.dateStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateEnd => $composableBuilder(
    column: $table.dateEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get budgetAmount => $composableBuilder(
    column: $table.budgetAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get oppStatus => $composableBuilder(
    column: $table.oppStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oppAmount => $composableBuilder(
    column: $table.oppAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get oppPercent => $composableBuilder(
    column: $table.oppPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extrafields => $composableBuilder(
    column: $table.extrafields,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get tms => $composableBuilder(
    column: $table.tms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<int> get socidRemote => $composableBuilder(
    column: $table.socidRemote,
    builder: (column) => column,
  );

  GeneratedColumn<int> get socidLocal => $composableBuilder(
    column: $table.socidLocal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ref =>
      $composableBuilder(column: $table.ref, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get publicLevel => $composableBuilder(
    column: $table.publicLevel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fkUserResp => $composableBuilder(
    column: $table.fkUserResp,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateStart =>
      $composableBuilder(column: $table.dateStart, builder: (column) => column);

  GeneratedColumn<DateTime> get dateEnd =>
      $composableBuilder(column: $table.dateEnd, builder: (column) => column);

  GeneratedColumn<String> get budgetAmount => $composableBuilder(
    column: $table.budgetAmount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get oppStatus =>
      $composableBuilder(column: $table.oppStatus, builder: (column) => column);

  GeneratedColumn<String> get oppAmount =>
      $composableBuilder(column: $table.oppAmount, builder: (column) => column);

  GeneratedColumn<double> get oppPercent => $composableBuilder(
    column: $table.oppPercent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get extrafields => $composableBuilder(
    column: $table.extrafields,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawJson =>
      $composableBuilder(column: $table.rawJson, builder: (column) => column);

  GeneratedColumn<DateTime> get tms =>
      $composableBuilder(column: $table.tms, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );
}

class $$ProjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectsTable,
          ProjectRow,
          $$ProjectsTableFilterComposer,
          $$ProjectsTableOrderingComposer,
          $$ProjectsTableAnnotationComposer,
          $$ProjectsTableCreateCompanionBuilder,
          $$ProjectsTableUpdateCompanionBuilder,
          (
            ProjectRow,
            BaseReferences<_$AppDatabase, $ProjectsTable, ProjectRow>,
          ),
          ProjectRow,
          PrefetchHooks Function()
        > {
  $$ProjectsTableTableManager(_$AppDatabase db, $ProjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> remoteId = const Value.absent(),
                Value<int?> socidRemote = const Value.absent(),
                Value<int?> socidLocal = const Value.absent(),
                Value<String?> ref = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<int> publicLevel = const Value.absent(),
                Value<int?> fkUserResp = const Value.absent(),
                Value<DateTime?> dateStart = const Value.absent(),
                Value<DateTime?> dateEnd = const Value.absent(),
                Value<String?> budgetAmount = const Value.absent(),
                Value<int?> oppStatus = const Value.absent(),
                Value<String?> oppAmount = const Value.absent(),
                Value<double?> oppPercent = const Value.absent(),
                Value<String> extrafields = const Value.absent(),
                Value<String?> rawJson = const Value.absent(),
                Value<DateTime?> tms = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
              }) => ProjectsCompanion(
                id: id,
                remoteId: remoteId,
                socidRemote: socidRemote,
                socidLocal: socidLocal,
                ref: ref,
                title: title,
                description: description,
                status: status,
                publicLevel: publicLevel,
                fkUserResp: fkUserResp,
                dateStart: dateStart,
                dateEnd: dateEnd,
                budgetAmount: budgetAmount,
                oppStatus: oppStatus,
                oppAmount: oppAmount,
                oppPercent: oppPercent,
                extrafields: extrafields,
                rawJson: rawJson,
                tms: tms,
                localUpdatedAt: localUpdatedAt,
                syncStatus: syncStatus,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> remoteId = const Value.absent(),
                Value<int?> socidRemote = const Value.absent(),
                Value<int?> socidLocal = const Value.absent(),
                Value<String?> ref = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<int> publicLevel = const Value.absent(),
                Value<int?> fkUserResp = const Value.absent(),
                Value<DateTime?> dateStart = const Value.absent(),
                Value<DateTime?> dateEnd = const Value.absent(),
                Value<String?> budgetAmount = const Value.absent(),
                Value<int?> oppStatus = const Value.absent(),
                Value<String?> oppAmount = const Value.absent(),
                Value<double?> oppPercent = const Value.absent(),
                Value<String> extrafields = const Value.absent(),
                Value<String?> rawJson = const Value.absent(),
                Value<DateTime?> tms = const Value.absent(),
                required DateTime localUpdatedAt,
                Value<SyncStatus> syncStatus = const Value.absent(),
              }) => ProjectsCompanion.insert(
                id: id,
                remoteId: remoteId,
                socidRemote: socidRemote,
                socidLocal: socidLocal,
                ref: ref,
                title: title,
                description: description,
                status: status,
                publicLevel: publicLevel,
                fkUserResp: fkUserResp,
                dateStart: dateStart,
                dateEnd: dateEnd,
                budgetAmount: budgetAmount,
                oppStatus: oppStatus,
                oppAmount: oppAmount,
                oppPercent: oppPercent,
                extrafields: extrafields,
                rawJson: rawJson,
                tms: tms,
                localUpdatedAt: localUpdatedAt,
                syncStatus: syncStatus,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectsTable,
      ProjectRow,
      $$ProjectsTableFilterComposer,
      $$ProjectsTableOrderingComposer,
      $$ProjectsTableAnnotationComposer,
      $$ProjectsTableCreateCompanionBuilder,
      $$ProjectsTableUpdateCompanionBuilder,
      (ProjectRow, BaseReferences<_$AppDatabase, $ProjectsTable, ProjectRow>),
      ProjectRow,
      PrefetchHooks Function()
    >;
typedef $$SyncMetadataTableCreateCompanionBuilder =
    SyncMetadataCompanion Function({
      Value<int> id,
      Value<DateTime?> lastFullSyncAt,
      Value<DateTime?> lastDeltaSyncAt,
      Value<String?> apiVersion,
      Value<int> schemaVersion,
    });
typedef $$SyncMetadataTableUpdateCompanionBuilder =
    SyncMetadataCompanion Function({
      Value<int> id,
      Value<DateTime?> lastFullSyncAt,
      Value<DateTime?> lastDeltaSyncAt,
      Value<String?> apiVersion,
      Value<int> schemaVersion,
    });

class $$SyncMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastFullSyncAt => $composableBuilder(
    column: $table.lastFullSyncAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastDeltaSyncAt => $composableBuilder(
    column: $table.lastDeltaSyncAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get apiVersion => $composableBuilder(
    column: $table.apiVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastFullSyncAt => $composableBuilder(
    column: $table.lastFullSyncAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastDeltaSyncAt => $composableBuilder(
    column: $table.lastDeltaSyncAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get apiVersion => $composableBuilder(
    column: $table.apiVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get lastFullSyncAt => $composableBuilder(
    column: $table.lastFullSyncAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastDeltaSyncAt => $composableBuilder(
    column: $table.lastDeltaSyncAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get apiVersion => $composableBuilder(
    column: $table.apiVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );
}

class $$SyncMetadataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncMetadataTable,
          SyncMetadataRow,
          $$SyncMetadataTableFilterComposer,
          $$SyncMetadataTableOrderingComposer,
          $$SyncMetadataTableAnnotationComposer,
          $$SyncMetadataTableCreateCompanionBuilder,
          $$SyncMetadataTableUpdateCompanionBuilder,
          (
            SyncMetadataRow,
            BaseReferences<_$AppDatabase, $SyncMetadataTable, SyncMetadataRow>,
          ),
          SyncMetadataRow,
          PrefetchHooks Function()
        > {
  $$SyncMetadataTableTableManager(_$AppDatabase db, $SyncMetadataTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime?> lastFullSyncAt = const Value.absent(),
                Value<DateTime?> lastDeltaSyncAt = const Value.absent(),
                Value<String?> apiVersion = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
              }) => SyncMetadataCompanion(
                id: id,
                lastFullSyncAt: lastFullSyncAt,
                lastDeltaSyncAt: lastDeltaSyncAt,
                apiVersion: apiVersion,
                schemaVersion: schemaVersion,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime?> lastFullSyncAt = const Value.absent(),
                Value<DateTime?> lastDeltaSyncAt = const Value.absent(),
                Value<String?> apiVersion = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
              }) => SyncMetadataCompanion.insert(
                id: id,
                lastFullSyncAt: lastFullSyncAt,
                lastDeltaSyncAt: lastDeltaSyncAt,
                apiVersion: apiVersion,
                schemaVersion: schemaVersion,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncMetadataTable,
      SyncMetadataRow,
      $$SyncMetadataTableFilterComposer,
      $$SyncMetadataTableOrderingComposer,
      $$SyncMetadataTableAnnotationComposer,
      $$SyncMetadataTableCreateCompanionBuilder,
      $$SyncMetadataTableUpdateCompanionBuilder,
      (
        SyncMetadataRow,
        BaseReferences<_$AppDatabase, $SyncMetadataTable, SyncMetadataRow>,
      ),
      SyncMetadataRow,
      PrefetchHooks Function()
    >;
typedef $$TasksTableCreateCompanionBuilder =
    TasksCompanion Function({
      Value<int> id,
      Value<int?> remoteId,
      Value<int?> projectRemote,
      Value<int?> projectLocal,
      Value<String?> ref,
      Value<String> label,
      Value<String?> description,
      Value<int> status,
      Value<int> progress,
      Value<String?> plannedHours,
      Value<int?> fkUser,
      Value<DateTime?> dateStart,
      Value<DateTime?> dateEnd,
      Value<String> extrafields,
      Value<String?> rawJson,
      Value<DateTime?> tms,
      required DateTime localUpdatedAt,
      Value<SyncStatus> syncStatus,
    });
typedef $$TasksTableUpdateCompanionBuilder =
    TasksCompanion Function({
      Value<int> id,
      Value<int?> remoteId,
      Value<int?> projectRemote,
      Value<int?> projectLocal,
      Value<String?> ref,
      Value<String> label,
      Value<String?> description,
      Value<int> status,
      Value<int> progress,
      Value<String?> plannedHours,
      Value<int?> fkUser,
      Value<DateTime?> dateStart,
      Value<DateTime?> dateEnd,
      Value<String> extrafields,
      Value<String?> rawJson,
      Value<DateTime?> tms,
      Value<DateTime> localUpdatedAt,
      Value<SyncStatus> syncStatus,
    });

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get projectRemote => $composableBuilder(
    column: $table.projectRemote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get projectLocal => $composableBuilder(
    column: $table.projectLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ref => $composableBuilder(
    column: $table.ref,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plannedHours => $composableBuilder(
    column: $table.plannedHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fkUser => $composableBuilder(
    column: $table.fkUser,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateStart => $composableBuilder(
    column: $table.dateStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateEnd => $composableBuilder(
    column: $table.dateEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extrafields => $composableBuilder(
    column: $table.extrafields,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get tms => $composableBuilder(
    column: $table.tms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get projectRemote => $composableBuilder(
    column: $table.projectRemote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get projectLocal => $composableBuilder(
    column: $table.projectLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ref => $composableBuilder(
    column: $table.ref,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plannedHours => $composableBuilder(
    column: $table.plannedHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fkUser => $composableBuilder(
    column: $table.fkUser,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateStart => $composableBuilder(
    column: $table.dateStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateEnd => $composableBuilder(
    column: $table.dateEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extrafields => $composableBuilder(
    column: $table.extrafields,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get tms => $composableBuilder(
    column: $table.tms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<int> get projectRemote => $composableBuilder(
    column: $table.projectRemote,
    builder: (column) => column,
  );

  GeneratedColumn<int> get projectLocal => $composableBuilder(
    column: $table.projectLocal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ref =>
      $composableBuilder(column: $table.ref, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<String> get plannedHours => $composableBuilder(
    column: $table.plannedHours,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fkUser =>
      $composableBuilder(column: $table.fkUser, builder: (column) => column);

  GeneratedColumn<DateTime> get dateStart =>
      $composableBuilder(column: $table.dateStart, builder: (column) => column);

  GeneratedColumn<DateTime> get dateEnd =>
      $composableBuilder(column: $table.dateEnd, builder: (column) => column);

  GeneratedColumn<String> get extrafields => $composableBuilder(
    column: $table.extrafields,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawJson =>
      $composableBuilder(column: $table.rawJson, builder: (column) => column);

  GeneratedColumn<DateTime> get tms =>
      $composableBuilder(column: $table.tms, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          TaskRow,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (TaskRow, BaseReferences<_$AppDatabase, $TasksTable, TaskRow>),
          TaskRow,
          PrefetchHooks Function()
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> remoteId = const Value.absent(),
                Value<int?> projectRemote = const Value.absent(),
                Value<int?> projectLocal = const Value.absent(),
                Value<String?> ref = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<int> progress = const Value.absent(),
                Value<String?> plannedHours = const Value.absent(),
                Value<int?> fkUser = const Value.absent(),
                Value<DateTime?> dateStart = const Value.absent(),
                Value<DateTime?> dateEnd = const Value.absent(),
                Value<String> extrafields = const Value.absent(),
                Value<String?> rawJson = const Value.absent(),
                Value<DateTime?> tms = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                remoteId: remoteId,
                projectRemote: projectRemote,
                projectLocal: projectLocal,
                ref: ref,
                label: label,
                description: description,
                status: status,
                progress: progress,
                plannedHours: plannedHours,
                fkUser: fkUser,
                dateStart: dateStart,
                dateEnd: dateEnd,
                extrafields: extrafields,
                rawJson: rawJson,
                tms: tms,
                localUpdatedAt: localUpdatedAt,
                syncStatus: syncStatus,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> remoteId = const Value.absent(),
                Value<int?> projectRemote = const Value.absent(),
                Value<int?> projectLocal = const Value.absent(),
                Value<String?> ref = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<int> progress = const Value.absent(),
                Value<String?> plannedHours = const Value.absent(),
                Value<int?> fkUser = const Value.absent(),
                Value<DateTime?> dateStart = const Value.absent(),
                Value<DateTime?> dateEnd = const Value.absent(),
                Value<String> extrafields = const Value.absent(),
                Value<String?> rawJson = const Value.absent(),
                Value<DateTime?> tms = const Value.absent(),
                required DateTime localUpdatedAt,
                Value<SyncStatus> syncStatus = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                remoteId: remoteId,
                projectRemote: projectRemote,
                projectLocal: projectLocal,
                ref: ref,
                label: label,
                description: description,
                status: status,
                progress: progress,
                plannedHours: plannedHours,
                fkUser: fkUser,
                dateStart: dateStart,
                dateEnd: dateEnd,
                extrafields: extrafields,
                rawJson: rawJson,
                tms: tms,
                localUpdatedAt: localUpdatedAt,
                syncStatus: syncStatus,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      TaskRow,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (TaskRow, BaseReferences<_$AppDatabase, $TasksTable, TaskRow>),
      TaskRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ThirdPartiesTableTableManager get thirdParties =>
      $$ThirdPartiesTableTableManager(_db, _db.thirdParties);
  $$ContactsTableTableManager get contacts =>
      $$ContactsTableTableManager(_db, _db.contacts);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$DraftsTableTableManager get drafts =>
      $$DraftsTableTableManager(_db, _db.drafts);
  $$ExtrafieldDefinitionsTableTableManager get extrafieldDefinitions =>
      $$ExtrafieldDefinitionsTableTableManager(_db, _db.extrafieldDefinitions);
  $$InvoiceLinesTableTableManager get invoiceLines =>
      $$InvoiceLinesTableTableManager(_db, _db.invoiceLines);
  $$InvoicesTableTableManager get invoices =>
      $$InvoicesTableTableManager(_db, _db.invoices);
  $$PendingOperationsTableTableManager get pendingOperations =>
      $$PendingOperationsTableTableManager(_db, _db.pendingOperations);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$SyncMetadataTableTableManager get syncMetadata =>
      $$SyncMetadataTableTableManager(_db, _db.syncMetadata);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
}
