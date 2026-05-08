# Dolibarr Mobile

Application mobile cross-platform (Android / iOS / Web PWA) de
consultation et gestion des **tiers**, **contacts**, **projets**,
**tâches** et **factures** d'une instance
[Dolibarr ERP/CRM](https://www.dolibarr.org/) via son API REST native.

Cible : commerciaux et techniciens en mobilité. **Mode offline complet
obligatoire** sur Android / iOS. La PWA web est livrée **online-only**
en v1.0+ (cf. [ADR 0008](docs/adr/0008-web-online-only.md)).

> **Statut : v1.1.0** — voir [CHANGELOG](CHANGELOG.md).

## Sommaire

- [Stack](#stack)
- [Plateformes supportées](#plateformes-supportées)
- [Fonctionnalités livrées](#fonctionnalités-livrées)
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Lancement](#lancement)
- [Build](#build)
- [Tests](#tests)
- [Structure](#structure)
- [Architecture](#architecture)
- [Documentation](#documentation)
- [Licence](#licence)

## Stack

- Flutter 3.41+, Dart 3.11+
- Riverpod 2 (codegen) — gestion d'état réactive
- Dio — client HTTP avec 4 intercepteurs (api_key, retry, logging,
  error mapping)
- Drift 2.21 (SQLite typé Dart) — cache local et Outbox
  (cf. [ADR 0003](docs/adr/0003-local-db.md))
- `flutter_secure_storage` — clé API uniquement (le password n'est
  jamais persisté)
- `go_router` — auth guard intégré
- Material 3 / Material You — thèmes clair + sombre seedés sur
  `#1E5AA8` / `#E89B2C` (cf. [ADR 0002](docs/adr/0002-design-system.md))

Architecture **Clean Architecture par feature**
(`data` / `domain` / `presentation`) avec **Outbox + Optimistic UI**
pour les écritures et **Stale-While-Revalidate** pour les lectures.
Voir [ADR 0001](docs/adr/0001-architecture.md) et
[ADR 0004](docs/adr/0004-offline-first.md).

## Plateformes supportées

| Cible    | Min                | Statut MVP                |
| -------- | ------------------ | ------------------------- |
| Android  | API 23 (Android 6) | online + offline complet  |
| iOS      | iOS 14             | online + offline complet  |
| Web      | navigateurs evergreen | online-only en v1.0    |

L'offline complet sur le web est planifié pour v1.1
(cf. [ADR 0008](docs/adr/0008-web-online-only.md)).

## Fonctionnalités livrées

- **Authentification** dual-mode : clé API directe ou
  identifiants → token (cf. [ADR 0007](docs/adr/0007-auth-modes.md)).
- **Tiers** : liste paginée + recherche + filtres bottom-sheet
  (kinds, actifs, mes tiers, catégories), fiche détail (sections
  collapsibles, carte OSM, actions terrain), création / édition /
  suppression offline.
- **Contacts** : CRUD complet, lien tiers parent.
- **Projets** : CRUD complet (statuts brouillon/ouvert/clos, dates,
  budget, opportunité), section sur la fiche tiers, cascade
  tiers→projet.
- **Tâches projet** : CRUD complet (statut, progression slider 0-100%,
  charge prévue, dates), section sur la fiche projet, cascade
  triple tiers→projet→tâche.
- **Factures** : CRUD complet header + lignes éditables (calcul live
  HT/TVA/TTC), workflow Valider / Marquer payée / Ajouter paiement
  (online-only, cf. [ADR 0010](docs/adr/0010-invoice-workflow-online.md)),
  téléchargement PDF avec partage natif, cascade 4 niveaux
  tiers→facture→lignes (cf. [ADR 0009](docs/adr/0009-cascade-multi-level.md)).
- **Catégories** & **champs personnalisés** lecture seule, formulaire
  dynamique pour les extrafields (varchar, text, integer, double,
  date, datetime, boolean, select).
- **Brouillons** : autosave debouncé 500 ms par formulaire
  (création OU édition), restauration au reload, discard à la
  validation ou à l'abandon.
- **Sync engine** : drain de la file Outbox au retour réseau,
  backoff exponentiel borné, détection de conflits via comparaison
  `tms` (cf. [ADR 0006](docs/adr/0006-conflict-resolution.md)),
  cascade Outbox sur 5 chaînes (tiers→contact, tiers→projet,
  tiers→facture, projet→tâche, facture→ligne).
- **Page "Opérations en attente"** : visibilité sur la file Outbox,
  actions *Réessayer* et *Discarder* par op.
- **Onboarding** + **Splash** + **Settings** (compte, instance,
  pending ops, déconnexion).

## Prérequis

- Flutter SDK 3.41 ou supérieur
- Dart SDK 3.11 ou supérieur
- Android : Android Studio + Platform 34 + cmdline-tools
- iOS : Xcode 16+, CocoaPods, compte Apple Developer

Sur la VM de développement, Flutter tourne dans un container Docker
dédié (`/opt/docker/flutter-dev/`). Les wrappers
`/usr/local/bin/flutter` et `/usr/local/bin/dart` redirigent les
commandes dans le container.

## Installation

```bash
git clone <repo>
cd dolibarr_mobile
cp .env.example .env  # renseigner DEFAULT_DOLIBARR_URL si voulu
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

## Lancement

```bash
flutter devices
flutter run -d <device-id>
```

## Build

```bash
./scripts/build_android.sh   # APK + AAB en mode release
./scripts/build_ios.sh        # IPA (requiert macOS + Xcode)
flutter build web --release   # PWA online-only
```

## Tests

```bash
flutter analyze            # 0 issue (strict, very_good_analysis 6.0)
flutter test               # 153/153 verts au tag v1.1.0
flutter test --coverage
```

Les tests sont unitaires (mocktail) ou widgets / goldens
(`alchemist`). Pas de test d'intégration sur device en CI au MVP.

## Structure

```
lib/
├── core/          Infrastructure transverse
│   ├── config/        Env runtime
│   ├── constants/     Paths API
│   ├── di/            Providers Riverpod racine
│   ├── errors/        Failure + ErrorMapper
│   ├── i18n/          Localisations générées
│   ├── network/       Dio + intercepteurs + NetworkInfo
│   ├── routing/       go_router
│   ├── storage/       Drift (AppDatabase + collections + DAOs)
│   ├── sync/          SyncEngine + provider
│   ├── theme/         Tokens + ThemeData
│   └── utils/         Result<T>
├── features/      Features métier (Clean Architecture par feature)
│   ├── auth/
│   ├── thirdparties/
│   ├── contacts/
│   ├── categories/
│   ├── extrafields/
│   └── sync/
├── shared/        Widgets et extensions partagés
└── dev/           Galerie de composants (debug uniquement)
```

## Architecture

L'app applique trois patrons combinés (cf. ADRs) :

1. **Clean Architecture par feature** — `data` / `domain` /
   `presentation` séparés, repository côté domaine, datasources
   séparés remote / local côté data.
2. **Offline-first via Outbox + Optimistic UI + Drafts** — toute
   écriture s'applique immédiatement à Drift, enqueue une
   `PendingOperation`, et le `SyncEngine` la pousse au retour
   réseau. Brouillons persistés dans une table dédiée.
3. **Stale-While-Revalidate** — les lectures retournent le cache
   filtré localement immédiatement puis se mettent à jour en
   arrière-plan via les streams Drift réactifs.

## Documentation

- [Architecture Decision Records](docs/adr/) — 8 ADRs documentant
  les décisions structurantes.
- [Endpoints Dolibarr utilisés](docs/api/dolibarr-endpoints.md) —
  référence figée des appels REST consommés.
- [Captures d'écran](docs/screenshots/) — galerie clair + sombre.

## Licence

Propriétaire — Scinnova Academy / Sébastien Confrère.
