# Changelog

Format basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/).
Les versions suivent [SemVer](https://semver.org/spec/v2.0.0.html).

## [1.0.0-mvp] — 2026-05-09

Première version livrable du MVP. Couvre la consultation et l'édition
offline des **tiers** et **contacts** d'une instance Dolibarr 23
depuis Android, iOS et Web (PWA online-only).

### Étape 1 — Bootstrap projet

- Squelette Flutter cross-platform (`cloud.scinnova / dolibarr_mobile`).
- Pubspec verrouillé avec deps codegen (Riverpod 2, Drift, freezed,
  json_serializable, build_runner).
- Lints `very_good_analysis 6.0` strict (`No issues found` requis).
- Wrappers Docker `flutter` / `dart` sur container
  `ghcr.io/cirruslabs/flutter:stable`.

### Étape 2 — Couche `core/`

- Dio + 4 intercepteurs (api_key, retry, logging, error mapping).
- `flutter_secure_storage` pour la clé API.
- Drift 2.21 (`AppDatabase`) avec table `third_parties`,
  `contacts`, `categories`, `extrafield_definitions`,
  `pending_operations`, `sync_metadata`. ADR 0003.
- `NetworkInfo` via `connectivity_plus`.
- `Result<T>` sealed + hiérarchie `Failure` + `ErrorMapper`.
- `Logger` simple imprimé.

### Étape 3 — Authentification

- Login dual-mode clé API ou identifiants → token. ADR 0007.
- `auth_repository` + `auth_notifier` Riverpod.
- Flow `Splash → Onboarding → Login → Shell` avec `go_router`.
- 17 tests unitaires (repo + use-cases + endpoint mock).

### Étape 4 — Design system

- Direction visuelle B (bleu `#1E5AA8` + ambre `#E89B2C`).
  ADR 0002.
- Tokens centralisés (`AppTokens`).
- Widgets partagés (`AppCard`, `EntityAvatar`, `EmptyState`,
  `ErrorState`, `LoadingSkeleton`, `SearchField`, `NetworkBanner`,
  `BottomActionBar`, `QuickActionChip`, `ConfirmDialog`,
  `SyncStatusBadge`, `ExtrafieldsForm`).
- Galerie debug `lib/dev/components_gallery.dart`.
- Goldens `test/golden/widgets_golden_test.dart` clair + sombre.

### Étape 5 — Catégories & extrafields

- Endpoint lecture seule `/categories?type=...` et
  `/setup/extrafields`.
- `CategoryRepository` + `ExtrafieldRepository` SWR.
- `ExtrafieldsForm` dynamique (varchar, text, integer, double,
  date, datetime, boolean, select).

### Étape 6 — Tiers (lecture)

- `ThirdPartiesListPage` paginée + recherche debouncée +
  bottom-sheet filtres.
- `ThirdPartyDetailPage` avec sections collapsibles + map
  `flutter_map` + actions terrain (tel/email/itinéraire).
- Builder `sqlfilters` Dolibarr (status, client/fournisseur,
  fk_commercial, like).
- 16 tests (sqlfilters builder + UI golden).

### Étape 7 — Tiers (écriture + offline)

- `ThirdPartyFormPage` create + edit Material 3, autosave
  brouillon debouncé 500 ms vers la table `Drafts`. ADR 0004.
- Outbox `PendingOperationDao` (enqueue, watchPendingCount,
  deleteForLocal).
- Optimistic UI : `pendingCreate` / `pendingUpdate` /
  `pendingDelete` reflétés immédiatement via `SyncStatusBadge`.
- Routes `/app/thirdparties/{new,:id/edit}`.
- 7 tests writes mocktail + drafts.

### Étape 8 — Contacts (CRUD complet + cascade)

- Feature contacts complète (list, detail, form, providers).
- `ContactLocalDao.watchByThirdPartyLocal` joint sur
  `socidLocal` ou `socidRemote`.
- Cascade Outbox via `dependsOnLocalId` quand le tiers parent
  est encore en `pendingCreate`. ADR 0005.
- `ThirdPartyContactsSection` injectée dans la fiche tiers,
  bouton "Ajouter" pré-sélectionne le parent via query string
  `?parent=<localId>`.
- 16 tests (sqlfilters contact + writes incl. cascade).

### Étape 9 — Sync engine

- `SyncEngine` consomme la file Outbox vers l'API Dolibarr.
- Démarre/arrête automatiquement selon l'état d'auth via
  `syncBootstrapProvider` monté dans `app.dart`.
- Backoff exponentiel `60s × 2^attempts` clamp à 30 minutes,
  `kMaxAttempts = 5` puis `markDead`.
- Détection de conflits via comparaison `tms` (GET-then-PUT).
  ADR 0006.
- Cascade : à la création d'un tiers,
  `patchSocidRemoteByParent` met à jour les contacts orphelins
  + `completeAndUnblockChildren` (transaction Drift) débloque
  les ops enfants en clearant `dependsOnLocalId`.
- `PendingOperationsPage` (route `/app/sync`) liste les ops
  par statut, avec actions Réessayer / Discarder.
- Tile "Opérations en attente (N)" dans Settings avec badge
  réactif.
- 12 tests SyncEngine (succès cascade, network failed,
  épuisement, conflit, update no-conflict, contact cascade
  injecte socid, validation sans socid, delete idempotent,
  backoff curve).

### Étape 10 — Polish & release

- 8 ADRs documentant les décisions structurantes.
- Référence complète des endpoints Dolibarr utilisés
  (`docs/api/dolibarr-endpoints.md`).
- Suppression des placeholders devenus inutiles
  (`ThirdPartiesPlaceholderPage`).
- Renommage `placeholder_pages.dart` → `settings_page.dart`,
  `SettingsPlaceholderPage` → `SettingsPage`.
- Cleanup des `.gitkeep` des dossiers maintenant peuplés.
- README rafraîchi avec statut MVP, features livrées,
  matrice de support plateforme.

### Métriques au tag v1.0.0-mvp

- `flutter analyze` : `No issues found` (very_good_analysis 6.0).
- `flutter test` : **102/102 verts**.
- 31 fichiers Dart côté `lib/`, ~5 800 lignes hors
  `*.g.dart` / `*.freezed.dart`.
- 14 fichiers de test.
- 8 ADRs, 1 référence API endpoints.
