# ADR 0005 — Cascade Outbox via dependsOnLocalId

Statut : accepté
Date : 2026-05-08

## Contexte

Un contact Dolibarr est rattaché à un tiers via `socid` (= `rowid` du
tiers). En mode offline, l'utilisateur peut très bien créer un tiers
ET un contact rattaché dans la même session, alors qu'aucun des deux
n'a encore été poussé. Au moment de la synchronisation, l'op `create
contact` ne peut pas s'exécuter avant que l'op `create tiers`
parent n'ait reçu son `rowid` du serveur.

## Décision

Chaque ligne `pending_operations` porte un champ optionnel
`dependsOnLocalId` :

- au moment de l'enqueue d'un `create contact` dont le tiers parent
  n'a pas de `remoteId`, le repository contacts cherche l'op create du
  parent (`PendingOperationDao.findLatestPendingCreate`) et stocke son
  `id` dans le `dependsOnLocalId` du contact ;
- la requête `dispatchable()` du SyncEngine filtre `dependsOnLocalId
  IS NULL`, donc une op bloquée n'est pas tentée prématurément ;
- à la réussite d'une op, `completeAndUnblockChildren` (transaction
  Drift) :
  1. `UPDATE pending_operations SET dependsOnLocalId = NULL WHERE
     dependsOnLocalId = <op.id>` — débloque les enfants ;
  2. `DELETE FROM pending_operations WHERE id = <op.id>` — supprime
     l'op terminée.

En complément, après la création réussie d'un tiers, le SyncEngine
appelle `ContactLocalDao.patchSocidRemoteByParent(parentLocalId,
parentRemoteId)` pour patcher `socidRemote` sur tous les contacts
fils orphelins. Ainsi le payload réinjecte automatiquement le `socid`
au moment du dispatch du contact (re-lecture de l'entité fraîche
avant POST).

## Pourquoi pas modifier le payload du contact à la volée

- Le payload sérialisé en `pending_operations.payload` est figé à
  l'enqueue. Le repas re-lit la table `contacts` au dispatch et
  injecte la valeur courante de `socidRemote` — c'est à la fois plus
  simple et plus robuste qu'une mise à jour différée du payload.

## Pourquoi pas un graphe de dépendances généralisé

- Le besoin actuel est uniquement parent/enfant 1:1. Une vraie DAG
  serait sur-ingéniérée. `dependsOnLocalId` (un seul ancêtre) suffit
  et reste simple à raisonner.

## Conséquences

- L'UI `PendingOperationsPage` affiche une icône `link` sur les ops
  qui ont un `dependsOnLocalId != null` pour signaler la dépendance.
- Si un utilisateur discarde l'op create d'un tiers, les ops enfants
  qui en dépendent se retrouvent bloquées définitivement —
  `discard(parent)` ne supprime pas en cascade. À l'utilisateur de
  discarder aussi les enfants. Une amélioration future pourrait
  proposer la cascade.
