# ADR 0009 — Cascade Outbox multi-niveaux

Statut : accepté
Date : 2026-05-09

## Contexte

L'ADR 0005 a posé le principe de la cascade Outbox via
`dependsOnLocalId` : un contact dont le tiers parent est en
`pendingCreate` est marqué dépendant de l'op create du parent et
patché automatiquement (`socidRemote`) à la résolution du parent.

Avec l'arrivée des projets (Étape 12), tâches (Étape 13) et factures
(Étapes 14-16), la cascade s'est étendue à plusieurs niveaux et plusieurs
branches parallèles depuis un même tiers parent.

## Décision

La cascade reste **monoparentale** (un enfant a au plus un parent
direct via `dependsOnLocalId`) mais peut maintenant former une chaîne
sur plusieurs niveaux :

- niveau 1 — `tiers → contact` (cascade `socid`)
- niveau 1 — `tiers → projet` (cascade `socid`)
- niveau 1 — `tiers → facture` (cascade `socid`)
- niveau 2 — `projet → tâche` (cascade `fk_projet`)
- niveau 2 — `facture → ligne` (cascade `fk_facture`)

Ainsi un utilisateur en mobilité peut créer en pure offline :

```
tiers (pendingCreate)
├── contact (pendingCreate, dependsOnLocalId = op tiers)
├── projet (pendingCreate, dependsOnLocalId = op tiers)
│   └── tâche (pendingCreate, dependsOnLocalId = op projet)
└── facture (pendingCreate, dependsOnLocalId = op tiers)
    └── ligne facture (pendingCreate, dependsOnLocalId = op facture)
```

À la reconnexion, le SyncEngine résout dans l'ordre topologique :

1. Push `tiers` → reçoit `remoteId`. À la réussite, en transaction
   Drift :
   - `contactDao.patchSocidRemoteByParent(parentLocalId, remoteId)`
   - `projectDao.patchSocidRemoteByParent(...)`
   - `invoiceDao.patchSocidRemoteByParent(...)`
   - `completeAndUnblockChildren(opId)` qui null-ifie
     `dependsOnLocalId` des ops enfants ET supprime l'op parente.
2. Les ops enfants deviennent `dispatchable()` au prochain tour.
3. Idem pour `projet → tâche` et `facture → ligne` aux niveaux 2.

Au moment du dispatch d'une op enfant `create`, le SyncEngine
**ré-injecte la FK depuis l'entité fraîche** (DAO `watchById`) plutôt
que depuis le payload sérialisé. Ainsi le payload original peut
ignorer le champ — il est résolu just-in-time à partir de la cascade
qui vient juste de patcher la table locale.

## Pourquoi pas un graphe DAG complet

- Le besoin est une **forêt** (parent unique par enfant) et non un
  graphe quelconque.
- `dependsOnLocalId` (un seul ancêtre) suffit pour les 5 cascades
  identifiées.
- Étendre à plusieurs ancêtres demanderait une table associative
  séparée et complexifierait `completeAndUnblockChildren`.

## Conséquences

- L'utilisateur peut composer hors-ligne un dossier complet (tiers
  + contact + projet + tâches + facture + lignes) puis tout pousser
  en bloc à la reconnexion.
- Les patches de FK sont idempotents (clause `socidRemote IS NULL`)
  et peuvent être ré-appelés sans risque.
- Si l'utilisateur **discarde** une op parent en pendingCreate, les
  ops enfants restent bloquées : elles n'ont pas d'autre source pour
  leur FK. L'UI de `PendingOperationsPage` met en évidence le lien
  via une icône de chaîne — l'utilisateur doit discarder en cascade
  manuellement.
