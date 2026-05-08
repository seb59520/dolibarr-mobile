import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:equatable/equatable.dart';

/// Contact (socpeople) Dolibarr, rattaché à un tiers parent.
///
/// Le rattachement au tiers est dual :
/// - `socidRemote` : `socid` côté Dolibarr (présent dès que le tiers
///   parent est synchronisé) ;
/// - `socidLocal` : PK Drift du tiers parent quand celui-ci est encore
///   en `pendingCreate` (cascade Outbox via `dependsOnLocalId`).
final class Contact extends Equatable {
  const Contact({
    required this.localId,
    required this.localUpdatedAt,
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
    this.extrafields = const {},
    this.tms,
    this.syncStatus = SyncStatus.synced,
  });

  final int localId;
  final int? remoteId;

  final int? socidRemote;
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

  final Map<String, Object?> extrafields;
  final DateTime? tms;
  final DateTime localUpdatedAt;
  final SyncStatus syncStatus;

  /// Nom affiché : "Prénom Nom" ou fallback sur l'un ou l'autre,
  /// ou "(sans nom)" si tout est vide.
  String get displayName {
    final parts = [firstname, lastname]
        .where((s) => s != null && s.trim().isNotEmpty)
        .map((s) => s!.trim())
        .toList();
    if (parts.isEmpty) return '(sans nom)';
    return parts.join(' ');
  }

  String get cityLine {
    final parts = [zip, town].where((s) => s != null && s.isNotEmpty);
    return parts.join(' ');
  }

  String get fullAddress {
    final parts = [address, zip, town]
        .where((s) => s != null && s.isNotEmpty);
    return parts.join(', ');
  }

  Contact copyWithSync(SyncStatus status) => Contact(
        localId: localId,
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
        tms: tms,
        localUpdatedAt: localUpdatedAt,
        syncStatus: status,
      );

  @override
  List<Object?> get props => [
        localId,
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
        tms,
        localUpdatedAt,
        syncStatus,
      ];
}
