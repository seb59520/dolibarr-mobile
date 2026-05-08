# ADR 0004 — Offline-first via Outbox + Optimistic UI + Drafts

Statut : accepté
Date : 2026-05-08

## Contexte

Les utilisateurs cibles (commerciaux, techniciens) saisissent leurs
modifications en mobilité sur des connexions instables. Trois
exigences :

1. les écritures (création/édition/suppression d'un tiers ou contact)
   doivent réussir même offline et apparaître immédiatement à l'écran ;
2. la saisie en cours d'un formulaire doit survivre à une fermeture
   accidentelle de l'app ;
3. les lectures doivent être fluides, sans clignotement, dès que des
   données existent en cache.

## Décision

Trois patrons combinés.

### 1. Optimistic UI + Outbox

Toute écriture (`createLocal` / `updateLocal` / `deleteLocal`) :

- applique immédiatement le changement à la table Drift (entité
  marquée en `pendingCreate` / `pendingUpdate` / `pendingDelete`) ;
- enqueue une `PendingOperation` dans la table `pending_operations`.

Le `SyncEngine` (cf. ADR 0005, 0006) consomme cette file en
arrière-plan dès que le réseau revient. Les écrans observent les
streams Drift et voient le changement aussitôt.

### 2. Drafts persistés

Un dossier `Drafts` (table dédiée) stocke un brouillon par couple
`(entityType, refLocalId)`. Le formulaire :

- autosave debouncé à **500 ms** sur chaque modification ;
- à la réouverture, propose la reprise du brouillon (en édition) ou
  l'applique directement (en création) ;
- discard le brouillon au commit réussi ou à l'abandon.

Les brouillons survivent au kill app, à la déconnexion réseau et au
basculement vers une autre fiche.

### 3. Stale-While-Revalidate (SWR)

Les listes et fiches retournent immédiatement le cache filtré
localement (Drift `watch()` réactif) puis déclenchent un refresh API
en arrière-plan dont le résultat fusionne dans le cache (sans écraser
les entités encore en `pendingX` / `conflict`).

## Pourquoi pas un simple "online required" sur les écritures

- UX dégradée : un commercial qui saisit un tiers en train chez le
  client perd sa saisie au moindre changement de cellule réseau.
- Spec produit explicite : offline complet sur mobile.

## Pourquoi pas un `lastWriteWins` côté client

- Risque d'écraser une modification serveur effectuée par un autre
  utilisateur. Le pattern `expectedTms` + détection de conflit (voir
  ADR 0006) protège la donnée serveur.

## Pourquoi pas garder le brouillon en mémoire

- Survivait pas au kill app. Le besoin "retrouver mon formulaire après
  fermeture" est un cas usuel.

## Conséquences

- Chaque entité porte un `syncStatus` (`SyncStatus` enum) qui pilote
  l'icône `SyncStatusBadge` côté UI.
- Le DAO préserve le `syncStatus != synced` : un refresh serveur ne
  doit jamais écraser une modification locale en attente.
- Les écrans consomment des streams (`watchList`, `watchById`) plutôt
  que des futures, pour répercuter l'évolution `pending → synced`
  sans intervention.
