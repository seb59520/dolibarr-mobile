# ADR 0007 — Authentification dual-mode (clé API + login/password)

Statut : accepté
Date : 2026-05-08

## Contexte

L'API Dolibarr accepte deux modes d'authentification :

- **Clé API** : header `DOLAPIKEY` envoyé sur chaque requête. La clé
  est créée par l'utilisateur depuis son profil web Dolibarr.
- **Login/password** : `POST /login` avec login + password retourne
  un `token` qui est ensuite envoyé dans le header `DOLAPIKEY` (le
  serveur traite token et clé API de manière interchangeable).

Le profil utilisateur cible mélange administrateurs (à l'aise avec
les clés) et commerciaux (préfèrent leur login habituel). On veut
supporter les deux flux sans dupliquer la couche réseau.

## Décision

- L'écran de login propose un `SegmentedButton` *Clé API* /
  *Identifiants*, et la `Credentials` est un sealed type
  (`apiKeyDirect` ou `loginPassword`).
- Côté repository :
  - mode `apiKeyDirect` : on stocke la clé en `flutter_secure_storage`
    et on appelle `/users/info` pour récupérer le profil et valider ;
  - mode `loginPassword` : on appelle `/login`, on récupère le token,
    on stocke le token comme s'il s'agissait d'une clé API (le
    password n'est jamais persisté), puis `/users/info` comme ci-dessus.
- Tous les appels suivants passent par le même intercepteur Dio
  (`api_key_interceptor`) qui injecte le `DOLAPIKEY` depuis le
  storage.

## Pourquoi ne jamais stocker le password

- Surface d'attaque : un dump de keychain ne doit pas révéler le
  password de l'utilisateur (réutilisable sur d'autres services
  Dolibarr).
- Le token retourné par `/login` joue exactement le rôle d'une clé
  API — pas besoin de re-soumettre le couple plus tard.

## Pourquoi pas OAuth2

- Dolibarr ne fournit pas de flux OAuth2 standard activable de série.
- L'app cible des instances internes ; le flux clé API + token
  couvre l'essentiel.

## Conséquences

- Une `SessionExpired` (401 sur n'importe quelle requête) émise par
  l'`error_interceptor` invalide la session et renvoie sur l'écran
  de login. L'auth_guard du `go_router` redirige les routes
  protégées (`/app/*`).
- Le re-login restaure les données via la couche locale Drift sans
  perte côté UX.
