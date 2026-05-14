# Se connecter à votre Dolibarr depuis l'app mobile

Ce guide vous explique pas à pas comment connecter l'application
**Dolibarr Mobile** à votre instance Dolibarr.

## Ce dont vous avez besoin

- L'**URL** de votre instance Dolibarr — celle que vous tapez dans votre
  navigateur, par exemple `https://erp.masociete.fr`.
- Soit votre **clé API personnelle** (méthode recommandée), soit votre
  **identifiant + mot de passe** Dolibarr.
- Une **connexion Internet** (Wi-Fi ou 4G/5G) le temps de la première
  connexion. L'app fonctionne ensuite en mode hors-ligne pour les
  opérations courantes.

## Méthode 1 — Clé API (recommandée)

La clé API est plus sûre : elle ne contient pas votre mot de passe et
peut être révoquée à tout moment depuis Dolibarr sans changer vos
identifiants. C'est la méthode privilégiée pour un usage durable.

### Étape 1 — Récupérer la clé côté Dolibarr web

1. Connectez-vous à votre Dolibarr depuis un navigateur sur ordinateur.
2. Cliquez sur votre nom en haut à droite → **« Carte d'utilisateur »**
   (parfois libellée « Mon profil »).
3. Ouvrez l'onglet **« Authentification »** (ou « Sécurité » selon la
   version de Dolibarr).
4. Cherchez la section **« Clé pour API »**. Cliquez sur
   **« Générer/regénérer la clé API »**.
5. Copiez la longue chaîne de caractères qui s'affiche — c'est votre
   clé API.

> Si l'onglet ou la section ne s'affichent pas, demandez à votre
> administrateur Dolibarr d'activer le module **« REST API »** et de
> vous attribuer le droit « Utiliser l'API ».

### Étape 2 — Renseigner la clé dans l'app

1. Ouvrez l'app **Dolibarr Mobile** sur votre téléphone.
2. Dans le champ **URL de l'instance**, tapez l'adresse de votre
   Dolibarr avec `https://` au début (ex : `https://erp.masociete.fr`).
3. Sélectionnez le mode **« Clé API »**.
4. Collez la clé API dans le champ.
5. Appuyez sur **« Tester la connexion »**. Si tout va bien, un message
   vert s'affiche : *« Connecté en tant que [votre nom] »*.
6. Appuyez sur **« Se connecter »** : vous arrivez sur le tableau de
   bord.

## Méthode 2 — Identifiants

Plus simple si vous n'avez pas accès à la clé API. L'app utilise votre
identifiant et mot de passe pour obtenir un jeton de session ; votre
mot de passe n'est jamais stocké en clair, mais la méthode clé API
reste préférable sur le long terme.

1. Sur l'écran de connexion, tapez l'URL de votre instance.
2. Sélectionnez le mode **« Identifiants »**.
3. Tapez votre **identifiant** et **mot de passe** Dolibarr (les mêmes
   que pour le web).
4. **« Tester la connexion »** puis **« Se connecter »**.

## Si la connexion échoue

- **« Impossible de joindre l'instance »** : vérifiez l'URL (avec le
  `https://`) et que votre Dolibarr est accessible depuis Internet. Si
  votre Dolibarr n'est accessible que depuis le réseau interne de
  votre entreprise, il vous faut un VPN actif sur votre téléphone.
- **« Identifiants ou clé API invalides »** : vérifiez que vous avez
  bien copié la clé API en entier, ou retapez identifiant/mot de passe
  en faisant attention aux majuscules.
- **« Erreur serveur »** : votre Dolibarr est en panne ou en
  maintenance. Réessayez plus tard ou contactez votre administrateur.

## Une fois connecté

Votre session est mémorisée : vous n'aurez plus à vous reconnecter au
prochain lancement de l'app. La synchronisation se fait
automatiquement en arrière-plan ; vous pouvez consulter et modifier
vos tiers, contacts, projets, devis, factures et tâches même hors
connexion — les changements seront poussés vers Dolibarr dès que le
réseau sera disponible.

Pour vous déconnecter, ouvrez les **Paramètres** depuis le menu de
l'app puis appuyez sur **« Se déconnecter »**.
