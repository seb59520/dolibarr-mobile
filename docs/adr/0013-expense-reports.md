# ADR 0013 — Notes de frais (expense reports)

Statut : accepté
Date : 2026-05-15

## Contexte

Étape 26 : ajouter le modèle local + repo + sync des notes de frais
Dolibarr (`/api/index.php/expensereports`). Lecture-écriture, sans UI
(l'UI viendra à l'étape 27). Le cas d'usage cible est la saisie en
mobilité (en clientèle, en déplacement) avec un brouillon hors-ligne
+ flush à la reconnexion, dans la même philosophie que les factures
et les devis.

## Décisions

### 1. Trois tables Drift

- `expense_reports` — entête (id local, remoteId, ref, status, dates
  début/fin, fk_user_author, fk_user_valid, totaux, notes, sync).
- `expense_lines` — lignes (FK `expenseReportRemote` + FK locale
  `expenseReportLocal` pour la cascade Outbox interne note → ligne,
  type de frais (`fkCTypeFees` id + `codeCTypeFees` text), date,
  comments, qty, value_unit, tvaTx, totaux, fk_project, rang).
- `expense_types` — cache local du dictionnaire `c_type_fees` (clé
  primaire = `code` textuel, ex. `TF_LUNCH`), peuplé via
  `GET /setup/dictionary/expensereport_types`.

Schéma Drift v8 → v9 : `onUpgrade(8→9)` crée les 3 tables.

### 2. Statuts non contigus

Dolibarr utilise un mapping non contigu (`ExpenseReport::STATUS_*`) :

- `0` brouillon (draft)
- `2` validé (validated)
- `4` approuvé (approved)
- `6` payé (paid)
- `99` refusé (refused)

L'enum `ExpenseReportStatus` gère le mapping bidirectionnel
(`fromInt`/`apiValue`) avec un fallback sécuritaire vers `draft` pour
toute valeur inattendue.

### 3. Type de frais : id numérique + code textuel

L'API exige `fk_c_type_fees` (id numérique). Mais le code textuel
(ex. `TF_LUNCH`) est plus stable et plus parlant côté UI.

On stocke les deux sur chaque `ExpenseLine` :

- `fkCTypeFees` : id Dolibarr (utilisé pour le POST/PUT).
- `codeCTypeFees` : code (`TF_LUNCH`, `EX_HOT`...) pour l'affichage
  et pour récupérer l'id depuis le cache `expense_types` si
  nécessaire (lookup `resolveTypeIdByCode`).

Le repo essaie d'abord d'utiliser `fkCTypeFees` ; le SyncEngine
re-résout depuis le cache au dispatch si l'id est nul (parade aux
flux où l'utilisateur a saisi en code mais l'id n'a pas été pré-rempli).

### 4. Cascade Outbox 2ᵉ niveau — 8ᵉ chaîne

Suit le pattern documenté dans l'ADR 0009 (multi-niveaux). On ajoute
une 8ᵉ chaîne au catalogue, parallèle à `invoice → invoice_line` et
`proposal → proposal_line` :

- niveau 2 — `expense_report → expense_line` (cascade
  `fk_expensereport`, méthode `patchExpenseReportRemoteByParent`).

Pas de cascade niveau 1 pour les notes de frais : il n'y a pas de
parent tiers (la note est portée par un `fk_user_author`, pas par un
`fk_soc`). La cascade reste donc strictement interne note → ligne.

Au dispatch d'une `expense_line` create, le SyncEngine :

1. re-lit l'entité ligne fraîche (`watchLineById`) pour récupérer
   l'`expenseReportRemote` qui vient d'être patché par la cascade ;
2. si `fk_c_type_fees` est absent du payload mais que `codeCTypeFees`
   est connu, résout l'id depuis le cache local (`resolveTypeIdByCode`) ;
3. POST sur `/expensereports/{id}/line` (singulier !) — détail au §5.

### 5. Endpoints Dolibarr — pièges à connaître

L'API expensereport est plus hétérogène que la facture / le devis :

- `GET {id}/lines` (pluriel) → liste des lignes.
- `POST {id}/line` (**singulier**) → ajout d'une ligne.
- `PUT {id}/lines/{lineid}` (pluriel) → update.
- `DELETE {id}/lines/{lineid}` (pluriel) → delete.

Le payload de ligne attend `vatrate` (et pas `tva_tx` comme côté
facture), `value_unit` (montant TTC unitaire) et `fk_c_type_fees`
(id numérique). Les dates `date_debut`/`date_fin`/`date` sont des
timestamps Unix (secondes) au POST. La lecture renvoie `date` en
chaîne SQL `YYYY-MM-DD` côté détail des lignes — le mapper le gère.

Constantes centralisées dans `lib/core/constants/api_paths.dart`.

### 6. Justificatifs ECM

L'upload d'un justificatif (PDF / photo) passe par l'endpoint
général `POST /documents/upload` avec `modulepart=expensereport` et
`ref=<note.ref>`. Le repo expose `uploadJustificatif(localId, ...)`
qui base64-encode le binaire avant envoi. Pas de cache local — les
justificatifs ne sont pas remontés en local pour le MVP (lourd, et
peu utile sans visualisation côté app).

## Conséquences

- Une note de frais complète peut être saisie hors-ligne (brouillon
  + lignes) puis poussée d'un bloc à la reconnexion via la cascade
  note → ligne, exactement comme `invoice → invoice_line`.
- Le dictionnaire `c_type_fees` est mis en cache local au premier
  usage (peu volatil, économise une requête à chaque saisie).
- Le pattern Outbox reste monoparental (cf. ADR 0009) — pas de
  dépendance externe parent côté note de frais.
- L'ADR 0010 (workflow factures online-only) ne s'applique pas tel
  quel : la création hors-ligne est autorisée pour les notes de
  frais en brouillon ; seule la `validate` et l'`approve` exigent
  d'être online (cohérent avec les contraintes serveur Dolibarr).
