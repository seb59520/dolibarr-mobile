/// Chemins relatifs des endpoints Dolibarr utilisés par l'app.
///
/// Tous les chemins sont relatifs au préfixe `/api/index.php` que le
/// `DioClient` ajoute automatiquement via `baseUrl`. Ne pas dupliquer
/// ce préfixe ici.
///
/// Liste figée : toute nouvelle entrée doit être validée et reportée
/// dans `docs/api/dolibarr-endpoints.md`.
abstract final class ApiPaths {
  // Authentification
  static const String login = '/login';
  static const String userInfo = '/users/info';

  // Tiers
  static const String thirdparties = '/thirdparties';
  static String thirdpartyById(int id) => '/thirdparties/$id';
  static String thirdpartyContacts(int id) => '/thirdparties/$id/contacts';

  // Contacts
  static const String contacts = '/contacts';
  static String contactById(int id) => '/contacts/$id';

  // Catégories (lecture seule). Le type est requis : customer / supplier / contact.
  static const String categories = '/categories';

  // Champs personnalisés (definitions)
  static const String setupExtrafields = '/setup/extrafields';

  // Projets
  static const String projects = '/projects';
  static String projectById(int id) => '/projects/$id';
  static String projectTasks(int id) => '/projects/$id/tasks';
}

/// Header HTTP obligatoire sur toutes les requêtes authentifiées.
abstract final class ApiHeaders {
  static const String dolApiKey = 'DOLAPIKEY';
  static const String contentType = 'Content-Type';
  static const String accept = 'Accept';
  static const String applicationJson = 'application/json';
}
