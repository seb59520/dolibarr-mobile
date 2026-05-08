import 'package:dolibarr_mobile/features/projects/domain/entities/project.dart';
import 'package:equatable/equatable.dart';

/// Critères de recherche / filtrage des projets.
final class ProjectFilters extends Equatable {
  const ProjectFilters({
    this.search = '',
    this.statuses = const {ProjectStatus.draft, ProjectStatus.opened},
    this.mineOnly = false,
    this.thirdPartyRemoteId,
  });

  /// Recherche libre (ref, title).
  final String search;

  /// Sous-ensemble des statuts acceptés. Vide = tous.
  /// Par défaut on cache les projets clos pour le confort visuel.
  final Set<ProjectStatus> statuses;

  /// Si vrai, filtre côté API sur `t.fk_user_resp = userId` (le user
  /// connecté est responsable du projet).
  final bool mineOnly;

  /// Si défini, restreint au tiers parent.
  final int? thirdPartyRemoteId;

  ProjectFilters copyWith({
    String? search,
    Set<ProjectStatus>? statuses,
    bool? mineOnly,
    int? thirdPartyRemoteId,
    bool clearThirdParty = false,
  }) =>
      ProjectFilters(
        search: search ?? this.search,
        statuses: statuses ?? this.statuses,
        mineOnly: mineOnly ?? this.mineOnly,
        thirdPartyRemoteId: clearThirdParty
            ? null
            : (thirdPartyRemoteId ?? this.thirdPartyRemoteId),
      );

  @override
  List<Object?> get props =>
      [search, statuses, mineOnly, thirdPartyRemoteId];
}
