import 'package:equatable/equatable.dart';

/// Critères de recherche / filtrage de la liste des contacts.
final class ContactFilters extends Equatable {
  const ContactFilters({
    this.search = '',
    this.hasEmail = false,
    this.hasPhone = false,
    this.thirdPartyRemoteId,
  });

  /// Recherche libre (nom, prénom, email, ville).
  final String search;

  /// Limite aux contacts ayant un email renseigné.
  final bool hasEmail;

  /// Limite aux contacts ayant un téléphone (pro ou mobile).
  final bool hasPhone;

  /// Si défini, restreint à un tiers parent (côté serveur via socid).
  final int? thirdPartyRemoteId;

  ContactFilters copyWith({
    String? search,
    bool? hasEmail,
    bool? hasPhone,
    int? thirdPartyRemoteId,
    bool clearThirdParty = false,
  }) =>
      ContactFilters(
        search: search ?? this.search,
        hasEmail: hasEmail ?? this.hasEmail,
        hasPhone: hasPhone ?? this.hasPhone,
        thirdPartyRemoteId: clearThirdParty
            ? null
            : (thirdPartyRemoteId ?? this.thirdPartyRemoteId),
      );

  @override
  List<Object?> get props => [search, hasEmail, hasPhone, thirdPartyRemoteId];
}
