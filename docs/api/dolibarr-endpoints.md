# Endpoints Dolibarr utilisés par l'app

Référence figée des endpoints REST Dolibarr 23 consommés par
`dolibarr_mobile`. Toute nouvelle entrée doit être ajoutée ici en même
temps que dans `lib/core/constants/api_paths.dart`.

Préfixe ajouté automatiquement par `DioClient` : `/api/index.php`. Les
chemins ci-dessous sont donc relatifs à `<baseUrl>/api/index.php`.
Authentification via header `DOLAPIKEY` sur toutes les requêtes
(sauf `/login`).

## Authentification

| Méthode | Path           | Usage                                                      |
| ------- | -------------- | ---------------------------------------------------------- |
| POST    | `/login`       | Échange login+password contre un token (mode loginPassword)|
| GET     | `/users/info`  | Profil utilisateur courant — sert aussi à valider la clé    |

Le token retourné par `/login` est stocké comme une clé API et utilisé
dans le header `DOLAPIKEY` pour les appels suivants.

## Tiers (`/thirdparties`)

| Méthode | Path                      | Usage                                                          |
| ------- | ------------------------- | -------------------------------------------------------------- |
| GET     | `/thirdparties`           | Liste paginée — paramètres `limit`, `page`, `sqlfilters`        |
| GET     | `/thirdparties/:id`       | Détail d'un tiers (utilisé pour SWR + GET-then-PUT conflit)     |
| POST    | `/thirdparties`           | Création — retourne le `rowid`                                 |
| PUT     | `/thirdparties/:id`       | Mise à jour — payload partiel accepté                          |
| DELETE  | `/thirdparties/:id`       | Suppression                                                    |
| GET     | `/thirdparties/:id/contacts` | Contacts rattachés à un tiers                                |

`sqlfilters` reconnus côté UI :

- `t.status:=:1` (tiers actifs) ;
- `t.client:in:'1,3'` (clients), `t.client:in:'2,3'` (prospects),
  `t.fournisseur:=:1` (fournisseurs) ;
- `t.fk_commercial:=:<userId>` (mes tiers uniquement) ;
- `t.nom:like:'%X%'` OR `t.code_client:like:...` OR `t.town:like:...`
  (recherche libre, apostrophes échappées).

## Contacts (`/contacts`)

| Méthode | Path             | Usage                                                  |
| ------- | ---------------- | ------------------------------------------------------ |
| GET     | `/contacts`      | Liste paginée — `limit`, `page`, `sqlfilters`           |
| GET     | `/contacts/:id`  | Détail d'un contact                                     |
| POST    | `/contacts`      | Création (champ `socid` requis)                        |
| PUT     | `/contacts/:id`  | Mise à jour                                             |
| DELETE  | `/contacts/:id`  | Suppression                                             |

`sqlfilters` reconnus :

- `t.fk_soc:=:<remoteId>` (par tiers parent) ;
- `t.email:!=:'' AND t.email:is not:NULL` (avec email) ;
- `(t.phone:!=:'') OR (t.phone_mobile:!=:'')` (avec téléphone) ;
- `t.lastname:like:'%X%' OR t.firstname:... OR t.email:... OR t.town:...`
  (recherche libre).

## Catégories (lecture seule)

| Méthode | Path                         | Usage                                                    |
| ------- | ---------------------------- | -------------------------------------------------------- |
| GET     | `/categories?type=customer`  | Catégories tiers/clients                                 |
| GET     | `/categories?type=supplier`  | Catégories fournisseurs                                  |
| GET     | `/categories?type=contact`   | Catégories contacts                                      |

Pas de POST/PUT/DELETE côté mobile — la gestion du référentiel reste
sur la web UI Dolibarr.

## Champs personnalisés (extrafields)

| Méthode | Path                            | Usage                                                   |
| ------- | ------------------------------- | ------------------------------------------------------- |
| GET     | `/setup/extrafields`            | Définitions de tous les extrafields, filtré par entité   |

Lecture seule. Les valeurs sont incluses dans les payloads tiers /
contacts via le champ `array_options`.

## Conventions de mapping local ↔ remote

- `tms` Dolibarr est un timestamp en seconds-epoch — converti en
  `DateTime` côté client via `DateTime.fromMillisecondsSinceEpoch(n *
  1000)`.
- `client` est un bitfield (0=aucun, 1=client, 2=prospect, 3=client+
  prospect). `fournisseur` est 0/1.
- `socid` côté contact = `rowid` du tiers parent. Côté local, on
  garde aussi `socidLocal` (PK Drift du parent) pour gérer les
  contacts dont le parent est encore en pendingCreate (cf. ADR 0005).

## Codes HTTP attendus

| Code | Sens (côté SyncEngine)                                                |
| ---- | --------------------------------------------------------------------- |
| 200  | Succès. Pour POST création, body = id (int) ou Map.id                  |
| 401  | `UnauthorizedException` → SessionExpired → re-login                    |
| 403  | `ForbiddenException` → op marquée `dead`                               |
| 404  | `NotFoundException` → si DELETE, succès idempotent ; sinon `dead`      |
| 400 / 422 | `ValidationException` → op `dead`                                |
| 5xx  | `ServerException` → backoff + retry, max kMaxAttempts=5 puis `dead`    |
