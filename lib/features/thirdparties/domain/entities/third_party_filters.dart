import 'package:equatable/equatable.dart';

/// Type de tiers, normalisé pour l'UI (les bits Dolibarr sont
/// transposés ici en valeurs distinctes pour faciliter le rendu de
/// chips de filtre).
enum ThirdPartyKind { customer, prospect, supplier }

/// Critères de recherche / filtrage de la liste des tiers.
///
/// Combinés en `sqlfilters` côté API et appliqués localement sur le
/// cache Drift en complément (recherche instantanée).
final class ThirdPartyFilters extends Equatable {
  const ThirdPartyFilters({
    this.search = '',
    this.kinds = const {},
    this.activeOnly = true,
    this.categoryIds = const {},
    this.myOnly = true,
  });

  /// Texte de recherche (nom, code, ville). Vide = tous.
  final String search;

  /// Sous-ensemble des types acceptés. Vide = tous.
  final Set<ThirdPartyKind> kinds;

  /// Limite aux tiers actifs (`status = 1`).
  final bool activeOnly;

  /// IDs Dolibarr des catégories acceptées. Vide = tous.
  final Set<int> categoryIds;

  /// Si vrai, filtre `t.fk_commercial = userId` côté API.
  /// Désactivable depuis Paramètres pour les admins.
  final bool myOnly;

  ThirdPartyFilters copyWith({
    String? search,
    Set<ThirdPartyKind>? kinds,
    bool? activeOnly,
    Set<int>? categoryIds,
    bool? myOnly,
  }) =>
      ThirdPartyFilters(
        search: search ?? this.search,
        kinds: kinds ?? this.kinds,
        activeOnly: activeOnly ?? this.activeOnly,
        categoryIds: categoryIds ?? this.categoryIds,
        myOnly: myOnly ?? this.myOnly,
      );

  @override
  List<Object?> get props =>
      [search, kinds, activeOnly, categoryIds, myOnly];
}
