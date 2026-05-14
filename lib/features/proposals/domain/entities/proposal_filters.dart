import 'package:dolibarr_mobile/features/proposals/domain/entities/proposal.dart';
import 'package:equatable/equatable.dart';

/// Critères de tri proposés à l'utilisateur sur la liste des devis.
enum ProposalSortBy {
  dateProposal('Date'),
  dateEnd('Validité');

  const ProposalSortBy(this.label);

  /// Libellé pour les chips de tri.
  final String label;
}

final class ProposalFilters extends Equatable {
  const ProposalFilters({
    this.search = '',
    this.statuses = const {
      ProposalStatus.draft,
      ProposalStatus.validated,
      ProposalStatus.signed,
    },
    this.thirdPartyRemoteId,
    this.dateFrom,
    this.dateTo,
    this.sortBy = ProposalSortBy.dateProposal,
    this.sortDescending = true,
  });

  final String search;
  final Set<ProposalStatus> statuses;
  final int? thirdPartyRemoteId;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  /// Critère de tri actif.
  final ProposalSortBy sortBy;

  /// `true` = décroissant (plus récent en haut).
  final bool sortDescending;

  ProposalFilters copyWith({
    String? search,
    Set<ProposalStatus>? statuses,
    int? thirdPartyRemoteId,
    bool clearThirdParty = false,
    DateTime? dateFrom,
    bool clearDateFrom = false,
    DateTime? dateTo,
    bool clearDateTo = false,
    ProposalSortBy? sortBy,
    bool? sortDescending,
  }) =>
      ProposalFilters(
        search: search ?? this.search,
        statuses: statuses ?? this.statuses,
        thirdPartyRemoteId: clearThirdParty
            ? null
            : (thirdPartyRemoteId ?? this.thirdPartyRemoteId),
        dateFrom: clearDateFrom ? null : (dateFrom ?? this.dateFrom),
        dateTo: clearDateTo ? null : (dateTo ?? this.dateTo),
        sortBy: sortBy ?? this.sortBy,
        sortDescending: sortDescending ?? this.sortDescending,
      );

  @override
  List<Object?> get props => [
        search,
        statuses,
        thirdPartyRemoteId,
        dateFrom,
        dateTo,
        sortBy,
        sortDescending,
      ];
}
