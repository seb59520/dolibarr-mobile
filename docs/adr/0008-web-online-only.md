# ADR 0008 — Web online-only en v1.0

Statut : accepté
Date : 2026-05-08

## Contexte

L'app vise trois cibles : Android, iOS, Web (PWA). Le mode offline
complet est obligatoire sur mobile, où les commerciaux saisissent en
mobilité. Côté web, l'usage cible est différent (poste sédentaire +
réseau d'entreprise stable), et les contraintes techniques sont
plus lourdes :

- `flutter_secure_storage` retombe sur `localStorage` non chiffré
  (la clé API serait stockée en clair) ;
- `flutter_contacts` n'a pas d'équivalent web (carnet du système) ;
- les service workers requièrent une instrumentation manuelle pour
  intercepter les écritures offline ;
- `sqlite3.wasm` impose un service worker pour l'opfs.

## Décision

Pour la **v1.0**, le web est livré en mode **online-only** :

- `flutter_secure_storage` est utilisé (fallback localStorage), mais
  l'utilisateur est averti dans la doc.
- Les écritures offline ne sont pas testées sur web. Drift via
  `sqlite3.wasm` reste en place, mais le scénario "écrire offline
  puis reconnecter" n'est pas garanti.
- L'import de `flutter_contacts` est conditionnel (mobile-only).

La PWA reste pertinente : elle couvre 80 % des usages web (consultation,
édition rapide en ligne) et permet de n'avoir qu'un seul codebase.

## Pourquoi pas couper le web complètement

- Codebase commun = moins de divergence à long terme.
- Le besoin "consulter un client depuis un poste fixe" est légitime
  et ne nécessite pas l'offline.

## Pourquoi pas livrer l'offline web aussi

- Service worker + opfs + chiffrement key storage = 2–3 semaines
  d'effort dédié, hors périmètre MVP.
- Ouvre une surface de tests (matrice navigateurs) que le MVP ne
  peut pas absorber.

## Conséquences

- v1.0 web : consultation + édition online uniquement.
- v1.1 (post-MVP) : offline web complet, avec un service worker
  personnalisé qui orchestre l'Outbox côté navigateur.
- La doc README signale clairement le statut "online-only" pour la
  PWA.
