# ADR 0010 — Workflow facture (validation, paiements, PDF) en mode online

Statut : accepté
Date : 2026-05-09

## Contexte

Les écritures CRUD sur la facture (header + lignes) passent par
l'Outbox et fonctionnent offline (cf. ADR 0004 + ADR 0009). Mais
trois autres actions de cycle de vie sortent de ce périmètre :

1. **Valider** : `POST /invoices/:id/validate` génère la référence
   Dolibarr (`FA2026-0042`), passe `fk_statut` 0→1, fige les totaux ;
2. **Marquer payée** : `POST /invoices/:id/markaspaid` modifie le
   champ `paye` ;
3. **Ajouter un paiement** : `POST /invoices/:id/payments` insère un
   enregistrement dans `llx_paiement` et recalcule les totaux ;
4. **Télécharger le PDF** : `GET /documents/download` renvoie le
   contenu base64 d'un PDF généré côté serveur.

Ces actions partagent une caractéristique : elles **dépendent du
serveur pour produire de la donnée** (ref générée, PDF rendu) qui
n'a aucun équivalent côté client.

## Décision

Ces 4 actions sont **online-only** :

- les boutons sont rendus dans `_WorkflowActions` mais désactivés si
  la facture n'a pas de `remoteId` (jamais poussée) ;
- les boutons retournent une `ValidationFailure` propre via le
  repository si l'utilisateur tente l'action sans connectivité —
  l'erreur est remontée dans une SnackBar ;
- aucune entrée n'est créée dans la table `pending_operations` ;
- le PDF est récupéré en base64, écrit dans un fichier temp via
  `path_provider`, puis présenté à l'utilisateur via `share_plus`
  (Share sheet natif iOS/Android, fallback `navigator.share` sur web).

## Pourquoi ne pas passer ces actions par l'Outbox

- **Validation** : générer la ref côté client serait dangereux (risque
  de collision avec d'autres clients du même Dolibarr). Le serveur
  est seul gardien de la séquence `FA{yyyy}-{N}`.
- **Marquer payée / paiement** : ces écritures peuvent en théorie
  être différées, mais l'usage cible est synchrone (le commercial
  marque le paiement *quand* il le reçoit). L'effort d'implémentation
  d'une cascade `payment ↔ invoice` n'est pas justifié au MVP.
- **PDF** : pas un write, c'est une lecture. Il est inutile de
  l'enqueuer.

## Pourquoi base64 + Share au lieu d'ouvrir directement

- L'API REST Dolibarr renvoie le PDF en base64 dans un body JSON,
  pas un binary stream. Donc on doit le décoder côté client.
- `share_plus` couvre tous les usages cibles : ouvrir avec un viewer
  (Adobe, Apple Files), envoyer par email, sauvegarder dans
  iCloud/Drive, AirDrop. Pas besoin d'un PDF viewer intégré au MVP.

## Conséquences

- L'app affiche les actions désactivées avec un visuel discret quand
  la facture n'est pas synchronisée, plutôt qu'un message d'erreur
  surprenant.
- `share_plus 10.x` ajouté comme dépendance.
- Côté audit trail Dolibarr, ces actions apparaîtront comme issues
  de l'utilisateur authentifié via la clé API (pas de divergence
  par rapport à l'usage web).
