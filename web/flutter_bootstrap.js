/*
 * Bootstrap personnalisé : charge l'app Flutter SANS enregistrer de
 * service worker. Évite le cache PWA agressif qui forçait l'utilisateur
 * à "Clear site data" à chaque déploiement (et donc à re-saisir clé
 * API + URL serveur stockées via flutter_secure_storage).
 *
 * Référence : https://docs.flutter.dev/platform-integration/web/initialization
 *
 * Les deux directives ci-dessous sont substituées par flutter build web ;
 * ne pas mentionner leur nom littéral en dehors d'elles, car la substitution
 * s'applique à toutes les occurrences du fichier.
 */

{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load();
