import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:equatable/equatable.dart';

/// Tiers Dolibarr : client, prospect, et/ou fournisseur.
///
/// Le champ `client` Dolibarr est un bitfield (0=aucun, 1=client,
/// 2=prospect, 3=client+prospect). `fournisseur` est un booléen 0/1.
final class ThirdParty extends Equatable {
  const ThirdParty({
    required this.localId,
    required this.name,
    required this.localUpdatedAt,
    this.remoteId,
    this.codeClient,
    this.codeFournisseur,
    this.clientFlags = 0,
    this.fournisseur = false,
    this.status = 1,
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
    this.categories = const [],
    this.extrafields = const {},
    this.tms,
    this.syncStatus = SyncStatus.synced,
  });

  final int localId;
  final int? remoteId;
  final String name;
  final String? codeClient;
  final String? codeFournisseur;
  final int clientFlags;
  final bool fournisseur;
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

  final List<int> categories;
  final Map<String, Object?> extrafields;

  final DateTime? tms;
  final DateTime localUpdatedAt;
  final SyncStatus syncStatus;

  ThirdParty copyWithSync(SyncStatus status) => ThirdParty(
        localId: localId,
        remoteId: remoteId,
        name: name,
        codeClient: codeClient,
        codeFournisseur: codeFournisseur,
        clientFlags: clientFlags,
        fournisseur: fournisseur,
        status: this.status,
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
        categories: categories,
        extrafields: extrafields,
        tms: tms,
        localUpdatedAt: localUpdatedAt,
        syncStatus: status,
      );

  bool get isCustomer => (clientFlags & 1) != 0;
  bool get isProspect => (clientFlags & 2) != 0;
  bool get isSupplier => fournisseur;
  bool get isActive => status == 1;

  /// Texte composite ville + code postal (utile pour l'affichage carte).
  String get cityLine {
    final parts = [zip, town].where((s) => s != null && s.isNotEmpty);
    return parts.join(' ');
  }

  /// Adresse complète sur une ligne (pour ouvrir Maps).
  String get fullAddress {
    final parts = [address, zip, town, countryCode]
        .where((s) => s != null && s.isNotEmpty);
    return parts.join(', ');
  }

  @override
  List<Object?> get props => [
        localId,
        remoteId,
        name,
        codeClient,
        codeFournisseur,
        clientFlags,
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
        categories,
        extrafields,
        tms,
        localUpdatedAt,
        syncStatus,
      ];
}
