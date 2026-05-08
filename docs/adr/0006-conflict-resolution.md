# ADR 0006 — Résolution de conflits via comparaison `tms`

Statut : accepté
Date : 2026-05-09

## Contexte

L'app autorise plusieurs utilisateurs à modifier la même fiche
(typique : deux commerciaux mettent à jour un client), et autorise
aussi un mode offline avec push différé. Sans précaution, un
`PUT /thirdparties/:id` envoyé en différé peut écraser une
modification effectuée entretemps via la web UI Dolibarr.

L'API Dolibarr ne fournit pas d'ETag ni de `If-Unmodified-Since`. Le
seul vecteur de version disponible est le champ `tms` (timestamp de
dernière modification, exposé en seconds-epoch).

## Décision

Pattern **GET-then-PUT optimiste** :

1. à l'enqueue d'une op `update`, le repository capture le `tms` de
   l'entité locale au moment de la modification (`expectedTms`) ;
2. au dispatch, le SyncEngine fait un `GET /thirdparties/:id` (ou
   `/contacts/:id`), parse `tms_serveur`, et compare :
   - `tms_serveur ≤ expectedTms` → pas de conflit, `PUT` envoyé ;
   - `tms_serveur > expectedTms` → conflit, op marquée `conflict`,
     entité Drift marquée `SyncStatus.conflict`, plus de retry
     automatique tant que l'utilisateur n'a pas tranché ;
3. la `PendingOperationsPage` expose les ops `conflict` avec un
   message clair et deux actions : *Réessayer* (re-écrase le serveur
   en réutilisant `expectedTms = tms_serveur`) ou *Discarder*.

Pour la suppression, même principe : on compare `tms_serveur` avant
le `DELETE`, et un 404 est considéré comme un succès idempotent (la
ressource est déjà supprimée).

## Pourquoi pas tenter le PUT direct et inspecter la réponse

- Dolibarr ne renvoie pas de code spécifique pour un conflit : un
  `PUT` réussit toujours en écrasant. Il n'existe donc pas de
  signal serveur fiable autre que la pré-comparaison.

## Pourquoi pas un sha256 du body

- `tms` est moins coûteux à comparer, et déjà exposé par Dolibarr.
- Il évite les faux positifs sur des champs cosmétiques recalculés
  côté serveur.

## Pourquoi pas garder l'op `failed` au lieu de `conflict`

- Une op `failed` retente automatiquement : on rentrerait en boucle
  d'écrasement à chaque reconnexion. `conflict` exige une décision
  utilisateur explicite.

## Conséquences

- Chaque `update` coûte une requête `GET` supplémentaire avant le
  `PUT`. Acceptable au volume cible (≤ 5–10 ops par session).
- Le badge `SyncStatusBadge` distingue visuellement
  `SyncStatus.conflict` (rouge) des `pendingX` (ambre).
- Une écriture forcée (re-tenter en écrasant) est l'option par
  défaut côté UI ; une vue "diff serveur vs local" est prévue post-MVP.
