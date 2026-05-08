# ADR 0011 — Devis (`llx_propal`) : modèle, workflow et UI

Statut : accepté
Date : 2026-05-09

## Contexte

Étape 18 / v1.2 ajoute la feature **Devis** (propositions
commerciales Dolibarr) à l'app. Le périmètre fonctionnel cible :

1. Lecture liste paginée + filtres (statut, dates, recherche, tiers)
2. Lecture détail (header + lignes)
3. Écriture header (CRUD offline-first via Outbox)
4. Écriture lignes (CRUD offline-first avec cascade devis→ligne)
5. Workflow : Valider, marquer Signé / Refusé, marquer Facturé, PDF

Le devis partage 90 % de son modèle avec la facture (ADR 0010) mais
diffère sur trois points :

- **Statuts** : `draft (0) → validated (1) → signed (2) | refused (-1)`
  (vs `draft (0) → validated (1) → paid (2)` pour la facture).
- **Pas de paiements** : un devis n'a pas de table `llx_paiement` côté
  Dolibarr. À la place, le serveur expose `setinvoiced` qui marque le
  devis comme "facturé" (statut `4` côté Dolibarr).
- **Endpoints workflow** : `validate`, `close` (pour signer/refuser),
  `setinvoiced`. Pas de `markaspaid` ni `payments`.

## Décisions

### Modèle local

- Tables Drift `proposals` + `proposal_lines` strictement parallèles
  à `invoices` + `invoice_lines` (mêmes index, mêmes triggers de
  watch). Réutilise `SyncStatus` et `PendingOpEntity` (ajout de
  `proposal` + `proposalLine`).
- `ProposalStatus` enum : `draft | validated | signed | refused`,
  mappage `apiValue` ↔ Dolibarr.
- `Proposal.isExpired` : true si `dateEnd != null && now > dateEnd`
  ET le devis n'est ni signé ni refusé. Cette dérivée alimente le
  badge "Expiré" sur la liste et le détail.

### Synchronisation

- Cascade tiers→devis : `prDao.patchSocidRemoteByParent` est appelé
  par le `SyncEngine` après création réussie d'un tiers (cf. ADR 0009).
- Cascade devis→ligne : symétrique à invoice→invoiceLine. Le moteur
  ré-injecte le `fk_propal` au moment du dispatch de la ligne via
  `proposalLines.proposalRemote`.
- Écriture des lignes : payload identique à `invoice_lines` (champs
  `qty`, `subprice`, `tva_tx`, `remise_percent`, `product_type`,
  `desc`, `label`).

### Workflow online-only

Reprend la même décision que l'ADR 0010 :

- `validate(localId)`, `close(localId, status, {note})`,
  `setInvoiced(localId)` et `downloadPdf(localId)` ne passent **pas**
  par l'Outbox. Elles sont désactivées dans l'UI tant que le devis
  n'a pas de `remoteId`.
- `close()` accepte uniquement `signed (2)` ou `refused (-1)`.
  Les autres valeurs sont rejetées avec une `ValidationFailure`.
- `setInvoiced()` n'crée **pas** la facture associée — il marque
  juste le devis comme facturé côté Dolibarr. La création
  effective de la facture reste manuelle (depuis l'écran factures
  ou l'UI Dolibarr web). Justification : éviter une mécanique
  d'enchaînement complexe qui devrait recopier les lignes du devis
  vers la facture, dupliquer les `array_options`, gérer les acomptes…
  Hors scope MVP.

### UI

- Onglet `Devis` dans la bottom-nav (6 destinations au total ;
  acceptable en M3 même si la spec recommande ≤5).
- Section `ThirdPartyProposalsSection` insérée sur la fiche tiers
  entre les projets et les factures (ordre miroir du workflow
  commercial : Tiers → Contacts → Projets → Devis → Factures).
- `ProposalCard` reprend l'architecture de `InvoiceCard` (barre
  latérale colorée + label statut + montant TTC). Couleurs :
  signé = `syncSynced` (vert) ; refusé/expiré = `syncConflict` ;
  brouillon = `syncOffline` ; validé = `syncPending`.
- `ProposalLineEditDialog` est strictement parallèle à
  `InvoiceLineEditDialog` (mêmes calculs HT/TVA/TTC live).
- Le formulaire (`ProposalFormPage`) supporte le brouillon
  autosauvegardé (entityType `proposal` dans `drafts` table) avec la
  même UX de restauration/abandon que la facture.

## Conséquences

- 6 onglets dans la bottom-nav. Si l'expérience visuelle se dégrade
  trop sur petit écran, l'évolution sera de regrouper Devis +
  Factures sous un onglet "Commerce" avec un sub-tab.
- Les workflow actions sont désactivées offline → cohérent avec la
  facture, donc aucune surprise UX.
- 20 nouveaux tests unitaires (workflow + sqlfilters + cascade
  sync_engine).
- Pas de nouvelle dépendance pubspec : les libs déjà présentes
  (`share_plus`, `path_provider`) couvrent le téléchargement PDF.

## Alternatives écartées

- **Convertir devis → facture en un clic dans l'app** : nécessiterait
  un endpoint `/invoices/createfromproposal/:id` (pas exposé par
  défaut sur l'API REST Dolibarr) ou une duplication client-side
  des lignes. Reporté à une étape ultérieure.
- **Acceptation par signature électronique embarquée** :
  intéressant mais hors scope MVP. Le statut `signed` est défini
  par un humain dans Dolibarr, pas par une signature crypto.
