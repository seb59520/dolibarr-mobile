import 'package:dolibarr_mobile/features/expenses/domain/entities/expense_report.dart';
import 'package:equatable/equatable.dart';

/// Critères de tri proposés sur la liste des notes de frais.
enum ExpenseSortBy {
  dateDebut('Début'),
  dateFin('Fin'),
  ref('Référence');

  const ExpenseSortBy(this.label);
  final String label;
}

/// Critères de filtrage / recherche pour la liste des notes de frais.
final class ExpenseFilters extends Equatable {
  const ExpenseFilters({
    this.search = '',
    this.statuses = const {
      ExpenseReportStatus.draft,
      ExpenseReportStatus.validated,
      ExpenseReportStatus.approved,
      ExpenseReportStatus.paid,
    },
    this.fkUserAuthor,
    this.dateFrom,
    this.dateTo,
    this.sortBy = ExpenseSortBy.dateDebut,
    this.sortDescending = true,
  });

  final String search;

  /// Statuts acceptés. Vide = aucun filtre statut (tous).
  final Set<ExpenseReportStatus> statuses;

  /// Si défini, restreint aux notes d'un auteur donné (`fk_user_author`).
  final int? fkUserAuthor;

  final DateTime? dateFrom;
  final DateTime? dateTo;

  final ExpenseSortBy sortBy;
  final bool sortDescending;

  ExpenseFilters copyWith({
    String? search,
    Set<ExpenseReportStatus>? statuses,
    int? fkUserAuthor,
    bool clearAuthor = false,
    DateTime? dateFrom,
    bool clearDateFrom = false,
    DateTime? dateTo,
    bool clearDateTo = false,
    ExpenseSortBy? sortBy,
    bool? sortDescending,
  }) =>
      ExpenseFilters(
        search: search ?? this.search,
        statuses: statuses ?? this.statuses,
        fkUserAuthor:
            clearAuthor ? null : (fkUserAuthor ?? this.fkUserAuthor),
        dateFrom: clearDateFrom ? null : (dateFrom ?? this.dateFrom),
        dateTo: clearDateTo ? null : (dateTo ?? this.dateTo),
        sortBy: sortBy ?? this.sortBy,
        sortDescending: sortDescending ?? this.sortDescending,
      );

  @override
  List<Object?> get props => [
        search,
        statuses,
        fkUserAuthor,
        dateFrom,
        dateTo,
        sortBy,
        sortDescending,
      ];
}
