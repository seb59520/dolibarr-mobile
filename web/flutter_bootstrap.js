// Bootstrap personnalisé : charge l'app Flutter SANS enregistrer de
// service worker. Évite le cache PWA agressif qui forçait l'utilisateur
// à "Clear site data" à chaque déploiement (et donc à re-saisir clé
// API + URL serveur stockées via flutter_secure_storage).
//
// Référence officielle :
// https://docs.flutter.dev/platform-integration/web/initialization
//
// Les placeholders {{flutter_js}} et {{flutter_build_config}} sont
// substitués par `flutter build web`.

{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load();
