# ADR 0002 — Design System (Direction B)

Statut : accepté
Date : 2026-05-08

## Contexte

Trois directions visuelles ont été comparées en cadrage :

- A — Sobre / corporate (gris + bleu acier).
- B — Moderne coloré (bleu primaire `#1E5AA8` + ambre `#E89B2C`).
- C — Premium dense (palette sombre + accents or).

Le profil utilisateur cible (commerciaux et techniciens en mobilité)
demande une UI lisible en plein soleil et une hiérarchie visuelle
forte sur les CTAs. La direction B a été retenue.

## Décision

- Material 3 / Material You via `ThemeData.fromSeed` avec :
  - seed primary `AppTokens.primarySeed = #1E5AA8` ;
  - seed secondary `AppTokens.secondarySeed = #E89B2C` (CTAs).
- Thèmes clair + sombre suivant le système.
- Tokens centralisés dans `lib/core/theme/tokens.dart` (couleurs,
  espacements multiples de 4, rayons, élévations, animations). Aucune
  valeur visuelle codée en dur dans les widgets.
- Iconographie `lucide_icons` (cohérence cross-platform), 1.0 px stroke.
- Typographie système (SF Pro / Roboto) — pas de font custom au MVP.
- Couleurs sémantiques pour les états sync : `syncSynced` (vert),
  `syncPending` (ambre), `syncConflict` (rouge), `syncOffline` (gris).
- Galerie de composants `lib/dev/components_gallery.dart` accessible en
  debug-only (route /dev). Goldens dans `test/golden/`.

## Pourquoi pas la direction A

- Trop sobre : les commerciaux ont besoin d'un repère visuel fort
  pour distinguer les sections actives / synchronisées.

## Pourquoi pas la direction C

- Densité élevée non adaptée au mobile en mobilité.
- Palette sombre par défaut hors-norme côté ergonomie de saisie.

## Conséquences

- Le seed bleu pilote tout le ColorScheme — modifier `primarySeed`
  recompose automatiquement primary/onPrimary/primaryContainer/etc.
- Les tokens sont la SoT : tout PR qui hardcode une valeur visuelle
  doit pivoter vers les tokens existants ou en proposer un nouveau.
