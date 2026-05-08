# ADR 0003 — Base de données locale

Statut : accepté
Date : 2026-05-08

## Contexte

L'app doit fonctionner en offline complet sur mobile (Android + iOS) et
en online-only sur web (cf. ADR-0008). La couche de cache doit :

- supporter un schéma typé Dart (≥ 6 tables : tiers, contacts, catégories,
  extrafields, opérations en attente, métadonnées sync) ;
- être interrogeable via filtres composés (recherche locale par
  nom/code/ville) ;
- exposer des streams réactifs pour brancher Riverpod sur les listes ;
- gérer le multi-plateforme (mobile + web PWA en option A) sans
  duplication de code applicatif.

## Décision

Drift 2.x est retenu (`drift: ^2.21`, `drift_flutter: ^0.2.4`,
`drift_dev: ^2.21`).

Les tables sont déclarées dans `lib/core/storage/collections/`, la
classe agrégée `AppDatabase` dans `lib/core/storage/app_database.dart`.
La connexion par défaut passe par `drift_flutter.driftDatabase()` qui
encapsule :

- mobile : `sqlite3_flutter_libs` + bibliothèque native bundlée ;
- web : `sqlite3.wasm` chargée via service worker.

## Pourquoi pas Isar 3 (initialement prévu)

- Le générateur `isar_generator` est figé sur `analyzer <6.0.0` et
  `source_gen <2.0.0`, incompatibles avec `freezed: ^2.5`,
  `riverpod_generator: ^2.6` et tout l'écosystème codegen moderne.
- La fork communautaire `pub.isar-community.dev` retourne HTTP 500 au
  moment du bootstrap (08/05/2026), donc non utilisable même comme
  override.
- Isar 4 alpha n'a pas été publié en stable.

## Pourquoi pas Hive 4

- Pas de requêtes typées composées (filtres multi-clés sur tiers).
- Hive 4 reste en version alpha au 08/05/2026.
- Pas de stream réactif natif typé en sortie.

## Pourquoi pas SQLite via sqflite directement

- Boilerplate SQL par DAO important.
- Pas de classes typées générées : risque d'erreurs runtime.
- Pas de support web aussi propre que `drift_flutter`.

## Conséquences

- L'API d'écriture des features data est légèrement plus verbeuse
  qu'avec Isar (DAOs vs collections), mais la lisibilité gagne sur les
  filtres complexes et les jointures contacts ↔ tiers.
- Le codegen Drift tourne via `flutter pub run build_runner build` à
  chaque modification de schéma — déjà en place dans le pipeline avec
  `freezed` et `riverpod_generator`.
- Migrations gérées via `MigrationStrategy` ; v1 = create-all.
- Le clé API reste exclusivement dans `flutter_secure_storage` ;
  Drift ne stocke que des données métier (cf. règle absolue Étape 0).

## Suivi

- Étape 7 (thirdparties écriture) : ajouter les DAO `ThirdPartyDao` et
  `PendingOperationsDao` sur `AppDatabase`.
- Étape 9 (SyncEngine) : utiliser des transactions Drift pour la
  cohérence push + flag de status.
- Migration future : si Isar 4 stable revient avec un support analyzer
  6+ et l'écosystème codegen suit, l'ADR sera ré-évalué — la couche
  data isole `AppDatabase` derrière des repositories abstraits, le coût
  de migration reste contenu.
