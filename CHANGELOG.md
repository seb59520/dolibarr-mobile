# Changelog

Format basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/).
Les versions suivent [SemVer](https://semver.org/spec/v2.0.0.html).

## [1.1.0] — 2026-05-09

Extension du périmètre : ajout des **projets** (avec tâches) et des
**factures** (avec lignes éditables, validation, paiements et
téléchargement PDF) en mode offline-first cohérent avec le MVP.
La cascade Outbox passe à 4 niveaux et 5 chaînes parallèles.

### Étape 11 — Projets (lecture)

- Domain `Project` (statut draft/opened/closed) + `ProjectFilters`.
- Drift v3, table `projects` + migration.
- Liste paginée + filtres bottom-sheet, fiche détail collapsibles,
  `ThirdPartyProjectsSection` injectée sur la fiche tiers.
- 5ᵉ tab pas encore (réservé v1.1.6 factures).
- 7 tests sqlfilters projets.

### Étape 12 — Projets (écriture + cascade)

- `ProjectRepository` étendu CRUD + drafts + cascade tiers→projet.
- `PendingOpEntity.project` + dispatch dans le SyncEngine.
- `ProjectFormPage` Material 3 avec autosave brouillon.
- 7 tests writes projet.

### Étape 13 — Tâches (CRUD + cascade triple)

- Domain `Task` + filters, Drift v4, table `tasks` + migration.
- `TaskRepository` full CRUD avec cascade projet→tâche.
- `PendingOpEntity.task` + dispatch SyncEngine.
- À la création d'un projet, cascade `taskDao.patchProjectRemote
  ByParent` qui patche `fk_projet` sur les tâches orphelines.
- `TaskFormPage` (slider progression auto-sync à 100% → terminée),
  `ProjectTasksSection` sur la fiche projet.
- 14 tests (sqlfilters + writes).

### Étape 14 — Factures (lecture)

- Domain `Invoice`, `InvoiceLine`, `InvoiceFilters` (statut combiné
  `fk_statut` + `paye`, range date `datef`).
- Drift v5, tables `invoices` + `invoice_lines` + migration.
- `InvoiceRemoteDataSource` avec sqlfilters builder spécifique au
  statut combiné (clauses OR sur fk_statut/paye).
- `InvoiceLocalDao` avec upsert transactionnel qui upsert aussi les
  lignes via `json['lines']` et nettoie les lignes serveur disparues.
- `InvoicesListPage`, `InvoiceDetailPage` (sections Dates / Lignes /
  Totaux / Notes), `ThirdPartyInvoicesSection`.
- 5ᵉ tab "Factures" dans le shell (icon receipt).
- 7 tests sqlfilters factures.

### Étape 15 — Factures (écriture header + lignes + cascade 4-niveau)

- Header CRUD + Lignes CRUD avec cascade interne facture→ligne.
- `PendingOpEntity.invoice` + `PendingOpEntity.invoiceLine`.
- `InvoiceFormPage` (header) + `InvoiceLineEditDialog` (lignes
  éditables depuis la fiche détail quand statut=draft, calcul live
  des totaux HT/TVA/TTC).
- À la création d'un tiers : cascade aussi vers `invoiceDao.patch
  SocidRemoteByParent` (4 niveaux : contacts + projets + factures).
- À la création d'une facture : cascade aussi vers `invoiceLineDao.
  patchInvoiceRemoteByParent` (cascade 2ᵉ niveau interne factures).
- 9 tests (header + lignes write).

### Étape 16 — Factures (workflow + paiements + PDF)

- Actions online-only : Valider (`POST /:id/validate`), Marquer
  payée (`POST /:id/markaspaid`), Ajouter paiement
  (`POST /:id/payments`), Télécharger PDF
  (`GET /documents/download` + base64 → fichier temp +
  `share_plus.shareXFiles`).
- `InvoicePayment` entity + `_PaymentEntryDialog` (montant pré-rempli
  `totalTtc`, datepicker, code mode VIR/CHQ/CB/LIQ/PRE, num,
  commentaire).
- `_WorkflowActions` row contextuel sur la fiche détail.
- `_PaymentsSection` qui FutureBuilder fetch les paiements (online).
- 6 tests workflow (validate, markAsPaid, downloadPdf base64
  decode + tolérance sauts de ligne, createPayment).

### Étape 17 — Polish v1.1

- ADR 0009 cascade multi-niveaux (formalise les 5 cascades).
- ADR 0010 workflow factures online-only (justifie pourquoi ces 4
  actions ne passent pas par l'Outbox).
- `docs/api/dolibarr-endpoints.md` enrichi (projets, tâches,
  factures, paiements, /documents/download).
- README mis à jour avec les nouvelles features.
- Bundle web rebuildé + redéployé sur
  `https://dolibarr-mobile.lab.scinnova-academy.cloud`.

### Métriques au tag v1.1.0

- `flutter analyze` : `No issues found`.
- `flutter test` : **153/153 verts**.
- 10 ADRs, référence API exhaustive.
- Drift v5, 11 tables.
- 6 entités métier (tiers, contact, catégorie, projet, tâche,
  facture), 7 chaînes Outbox (incl. ligne facture).

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
