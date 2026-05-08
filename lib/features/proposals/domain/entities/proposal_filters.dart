import 'package:dolibarr_mobile/features/proposals/domain/entities/proposal.dart';
import 'package:equatable/equatable.dart';

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
  });

  final String search;
  final Set<ProposalStatus> statuses;
  final int? thirdPartyRemoteId;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  ProposalFilters copyWith({
    String? search,
    Set<ProposalStatus>? statuses,
    int? thirdPartyRemoteId,
    bool clearThirdParty = false,
    DateTime? dateFrom,
    bool clearDateFrom = false,
    DateTime? dateTo,
    bool clearDateTo = false,
  }) =>
      ProposalFilters(
        search: search ?? this.search,
        statuses: statuses ?? this.statuses,
        thirdPartyRemoteId: clearThirdParty
            ? null
            : (thirdPartyRemoteId ?? this.thirdPartyRemoteId),
        dateFrom: clearDateFrom ? null : (dateFrom ?? this.dateFrom),
        dateTo: clearDateTo ? null : (dateTo ?? this.dateTo),
      );

  @override
  List<Object?> get props => [
        search,
        statuses,
        thirdPartyRemoteId,
        dateFrom,
        dateTo,
      ];
}
