# ADR 0001 — Architecture applicative

Statut : accepté
Date : 2026-05-08

## Contexte

L'app cible Android, iOS et Web (PWA). Elle parle à une API REST
Dolibarr 23, doit fonctionner offline complet sur mobile, et gérer un
domaine non trivial (tiers + contacts + catégories + extrafields) avec
des écritures différées et de la résolution de conflits.

Trois axes structurants à trancher :

1. la séparation des couches (où mettre quoi) ;
2. la gestion d'état réactive ;
3. la frontière entre les exceptions techniques et les erreurs métier.

## Décision

**Clean Architecture par feature** : chaque feature (`auth`,
`thirdparties`, `contacts`, `categories`, `extrafields`, `sync`) est
organisée en trois sous-dossiers :

- `domain/` : entités, interfaces de repository, use-cases ;
- `data/` : implémentations de repository, datasources (remote / local),
  modèles de mapping ;
- `presentation/` : pages, widgets, providers Riverpod.

Le code transverse (réseau, stockage, theme, routing, sync) vit dans
`lib/core/`. Les widgets partagés dans `lib/shared/widgets/`.

**Riverpod 2 avec codegen** (`riverpod_annotation`/`riverpod_generator`)
pour la gestion d'état. Pas de Bloc, pas de Provider 4. Choix dicté par
la composition fine, le code généré déclaratif et l'écosystème
hooks/family/autoDispose.

**Result<T> sealed class** comme retour de toute opération
`data → domain` qui peut échouer. Les exceptions Dio / Drift /
plateforme sont capturées dans la couche `data` et converties en
`Failure` (sealed class) avant traversée du domaine.

## Pourquoi pas Bloc

- Boilerplate plus lourd (états + events + bloc + builder).
- Riverpod 2 couvre les mêmes besoins avec moins de code et un
  meilleur support du codegen.

## Pourquoi pas une approche feature-flat

- Les écrans grossissent vite (formulaires, sections multiples).
- Sans la séparation `data / domain / presentation` les tests
  unitaires deviennent fragiles (couplage UI ↔ Dio).

## Pourquoi pas throw/catch jusqu'à l'UI

- L'UI doit pattern-matcher des `Failure` typées (`UnauthorizedFailure`,
  `ConflictFailure`, etc.), pas inspecter le type Dart d'une exception
  Dio.
- Les tests deviennent triviaux à écrire avec `Result`.

## Conséquences

- Chaque feature ajoute au moins 5–6 fichiers, mais la lecture est
  prévisible. Les `.gitkeep` des sous-dossiers de bootstrap ont été
  conservés tant que le dossier était vide.
- Le pipeline `build_runner` doit tourner après chaque modif d'entité
  freezed, schéma Drift ou provider annoté.
- Toutes les ops réseau sont centralisées via Dio + intercepteurs
  (api_key, retry, logging, error). Voir ADR 0007 pour l'auth.
