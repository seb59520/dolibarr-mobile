import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice.dart';
import 'package:equatable/equatable.dart';

/// Critères de recherche / filtrage de la liste des factures.
final class InvoiceFilters extends Equatable {
  const InvoiceFilters({
    this.search = '',
    this.statuses = const {
      InvoiceStatus.draft,
      InvoiceStatus.validated,
      InvoiceStatus.paid,
    },
    this.thirdPartyRemoteId,
    this.dateFrom,
    this.dateTo,
    this.unpaidOnly = false,
  });

  /// Recherche libre (ref, ref_client).
  final String search;

  /// Statuts acceptés. Vide = tous.
  final Set<InvoiceStatus> statuses;

  /// Si défini, restreint aux factures du tiers parent.
  final int? thirdPartyRemoteId;

  /// Bornes optionnelles sur `datef`.
  final DateTime? dateFrom;
  final DateTime? dateTo;

  /// Si vrai, ne montre que les factures non payées (paye=0).
  final bool unpaidOnly;

  InvoiceFilters copyWith({
    String? search,
    Set<InvoiceStatus>? statuses,
    int? thirdPartyRemoteId,
    bool clearThirdParty = false,
    DateTime? dateFrom,
    bool clearDateFrom = false,
    DateTime? dateTo,
    bool clearDateTo = false,
    bool? unpaidOnly,
  }) =>
      InvoiceFilters(
        search: search ?? this.search,
        statuses: statuses ?? this.statuses,
        thirdPartyRemoteId: clearThirdParty
            ? null
            : (thirdPartyRemoteId ?? this.thirdPartyRemoteId),
        dateFrom: clearDateFrom ? null : (dateFrom ?? this.dateFrom),
        dateTo: clearDateTo ? null : (dateTo ?? this.dateTo),
        unpaidOnly: unpaidOnly ?? this.unpaidOnly,
      );

  @override
  List<Object?> get props => [
        search,
        statuses,
        thirdPartyRemoteId,
        dateFrom,
        dateTo,
        unpaidOnly,
      ];
}
