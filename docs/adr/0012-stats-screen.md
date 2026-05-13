# ADR 0012 — Écran Statistiques (facturé / perçu) + cache paiements

Statut : accepté
Date : 2026-05-13

## Contexte

Le dashboard d'accueil propose déjà un KPI « CA mois en cours » calculé
à partir du cache local Drift des factures. L'utilisateur veut un écran
dédié plus riche : suivi mensuel/annuel de ce qu'il a **facturé** et
de ce qu'il a **réellement perçu**.

Deux contraintes structurelles :

1. La somme « perçu » ne peut pas être déduite des factures seules : une
   facture marquée `paye=1` est payée à la date du dernier règlement, pas
   à `dateInvoice`. Pour un graphe mensuel honnête il faut connaître la
   date du paiement, pas celle de la facture.
2. Les paiements Dolibarr (`llx_paiement_facture` ∘ `llx_paiement`) sont
   exposés par REST via `/invoices/{id}/payments` uniquement, sans
   endpoint « liste plate ». Ils étaient déjà chargés à l'ouverture du
   détail facture mais jamais persistés.

## Décisions

### Cache des paiements

- Nouvelle table Drift `invoice_payments` (schema v8) avec colonnes
  `localId`, `remoteId`, `invoiceRemoteId`, `date`, `amount`, `type`,
  `num`, `ref`, `localUpdatedAt`. Unicité = `remoteId`.
- Pas de cascade Outbox : les paiements restent lecture-seule depuis
  l'app (création de paiement = `createPayment` direct online via le
  détail facture, hors scope Stats).
- Sync paiements : nouveau service `PaymentSyncService.syncPaymentsForRecentInvoices(window)`
  qui itère sur les factures `paye=1` OR `validated` dont `dateInvoice`
  tombe dans la fenêtre (par défaut 13 mois roulants pour couvrir « 12
  derniers mois » + buffer mois courant). Pour chacune, `fetchPayments`
  est appelé et les lignes upsertées. Tolérant aux erreurs réseau (skip
  silencieux, le calcul utilise alors uniquement les paiements déjà
  cachés).
- Idempotent : un paiement déjà connu (`remoteId` existant) est mis à
  jour. Suppression côté serveur non détectée (acceptable : un
  paiement supprimé dans Dolibarr est un cas rare, l'utilisateur peut
  forcer un reset cache via pull-to-refresh `/app/stats`).

### Modèle Stats

- `MonthlyStat { year, month, factureHt, factureTtc, percu }` : un point
  par mois sur la fenêtre 12 mois roulants.
- `YearlyStat { year, factureHt, factureTtc, percu }` : agrégat année
  courante + N-1.
- `StatsSnapshot { monthly, currentYear, previousYear, lastSync }` :
  snapshot complet exposé par le repository.
- Le calcul reste **local** : `StatsRepository.watchSnapshot()` combine
  les streams `invoices` + `invoice_payments` via `rxdart.combineLatest2`
  pour rester offline-friendly.

### Source de chaque montant

- **Facturé** = somme `totalTtc` des factures NON brouillon ET NON
  abandonnée, groupées par `month(dateInvoice)`. (Une facture validée
  mais non payée reste comptée en « facturé ».)
- **Perçu** = somme `amount` des `invoice_payments` groupées par
  `month(date)`. Indépendant du statut de la facture.
- Le HT n'est utilisé que pour l'année courante (KPI de marge brute
  hors taxe). La courbe mensuelle reste TTC pour cohérence avec le KPI
  « CA mois » existant.

### UI

- Page `/app/stats` (StatefulConsumerWidget) accessible depuis la
  grille KPI du dashboard (nouvelle carte « Statistiques »).
- Bar chart `fl_chart` 12 mois roulants, deux barres par mois
  (facturé / perçu), palette DoliMob : `accentSoft` + `success`.
- KPIs scalaires : `Année N facturé`, `Année N perçu`,
  `Année N-1 facturé`, `Année N-1 perçu`.
- Section repliable « Détail par mois » (liste lignes mois + montants),
  pour confort terminal (cohérent avec [[feedback_no_wide_tables]]).
- Pull-to-refresh = lance une sync paiements en arrière-plan.

### Dépendances pubspec

- `fl_chart: ^0.69.0` (MIT, pure Dart, supporte web/mobile, pas de
  worker natif). Position alphabétique entre `equatable` et `flutter`.

## Conséquences

- Schéma Drift v8, migration `onUpgrade if (from < 8)` qui crée la
  table `invoice_payments`.
- Pas de nouvel onglet bottom-nav (la barre reste à 6 destinations).
- Le KPI dashboard « CA mois en cours » reste calculé sur les
  factures (cohérent avec ce qu'on facture, indépendant du paiement).
  Pas de divergence : le KPI Stats « perçu mois courant » sera
  affiché en plus.
- ~12 tests unitaires supplémentaires (DAO paiements + StatsRepository).

## Alternatives écartées

- **Endpoint custom Dolibarr** pour une liste plate de paiements : aurait
  économisé N appels HTTP mais ajoute un module PHP custom à maintenir.
  Trop coûteux pour le gain.
- **Approximation `dateInvoice` pour le perçu** : avait notre faveur en
  cadrage initial mais l'utilisateur a tranché vers les vrais paiements
  pour précision.
- **Page intégrée au dashboard** (section dépliable) : envisagé mais la
  page dédiée permet pull-to-refresh dédié + futures évolutions
  (breakdown par client, export CSV) sans surcharger l'accueil.
