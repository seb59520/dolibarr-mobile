# Dolibarr Mobile

Application mobile cross-platform de consultation et gestion des **tiers** et
**contacts** d'une instance Dolibarr ERP/CRM via son API REST native.

Cible : commerciaux et techniciens en mobilité, **mode offline requis** sur
mobile (Android + iOS). Une déclinaison Web (PWA) est fournie en mode
online-only pour la v1.0.

> Statut : MVP en développement. Voir `docs/adr/` pour les décisions
> d'architecture et `docs/api/dolibarr-endpoints.md` pour les endpoints utilisés.

## Stack

- Flutter 3.41+, Dart 3.11+
- Riverpod 2 (codegen)
- Dio (HTTP) avec intercepteurs (clé API, retry, logging, mapping erreurs)
- Isar 3 (cache offline mobile)
- flutter_secure_storage (clé API uniquement)
- go_router (auth guard intégré)
- Material 3 / Material You, thèmes clair + sombre

Architecture : Clean Architecture par feature (`data` / `domain` / `presentation`)
+ Outbox & Optimistic UI pour les écritures + Stale-While-Revalidate pour les
lectures.

## Plateformes supportées

- Android (min API 23)
- iOS (min iOS 14)
- Web (PWA online-only en v1.0, full-offline prévu v1.1)

## Prérequis

- Flutter SDK 3.41 ou supérieur
- Dart SDK 3.11 ou supérieur
- Android : Android Studio + SDK Platform 34 + cmdline-tools
- iOS : Xcode 16+, CocoaPods, compte Apple Developer

Sur cette VM, Flutter tourne dans un container Docker dédié
(`/opt/docker/flutter-dev/`). Les wrappers `/usr/local/bin/flutter` et
`/usr/local/bin/dart` redirigent les commandes dans le container.

## Installation

```
git clone <repo>
cd dolibarr_mobile
cp .env.example .env
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

## Lancement

```
# Choisir un device
flutter devices
flutter run -d <device-id>
```

## Build

```
./scripts/build_android.sh   # APK + AAB en mode release
./scripts/build_ios.sh        # IPA (requiert macOS + Xcode)
flutter build web --release   # PWA
```

## Tests

```
flutter analyze
flutter test
flutter test --coverage
```

## Structure

```
lib/
├── core/          Infrastructure transverse (réseau, stockage, sync, theme, routing)
├── features/      Features métier (auth, thirdparties, contacts, …)
├── shared/        Widgets et extensions partagés
└── dev/           Galerie de composants (debug uniquement)
```

Voir `docs/UI_GUIDELINES.md` et `docs/adr/` pour le détail.

## Licence

Propriétaire — Scinnova Academy / Sébastien Confrère.
