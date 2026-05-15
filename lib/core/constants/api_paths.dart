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

  // Tâches projet
  static const String tasks = '/tasks';
  static String taskById(int id) => '/tasks/$id';

  // Factures
  static const String invoices = '/invoices';
  static String invoiceById(int id) => '/invoices/$id';
  static String invoiceLines(int id) => '/invoices/$id/lines';
  static String invoiceLineById(int invoiceId, int lineId) =>
      '/invoices/$invoiceId/lines/$lineId';
  static String invoiceValidate(int id) => '/invoices/$id/validate';
  static String invoicePayments(int id) => '/invoices/$id/payments';
  static String invoiceMarkPaid(int id) => '/invoices/$id/settopaid';

  // Produits / services
  static const String products = '/products';
  static String productById(int id) => '/products/$id';

  // Devis (propositions commerciales)
  static const String proposals = '/proposals';
  static String proposalById(int id) => '/proposals/$id';
  static String proposalLines(int id) => '/proposals/$id/lines';
  static String proposalLineById(int proposalId, int lineId) =>
      '/proposals/$proposalId/lines/$lineId';
  static String proposalValidate(int id) => '/proposals/$id/validate';
  static String proposalClose(int id) => '/proposals/$id/close';
  static String proposalSetInvoiced(int id) => '/proposals/$id/setinvoiced';

  // Notes de frais (expense reports)
  static const String expenseReports = '/expensereports';
  static String expenseReportById(int id) => '/expensereports/$id';
  static String expenseReportLines(int id) => '/expensereports/$id/lines';
  // ATTENTION : POST utilise `/line` (singulier) côté Dolibarr, alors que
  // GET liste l'utilise au pluriel. Voir api_expensereports.class.php
  // (@url POST {id}/line vs @url GET {id}/lines).
  static String expenseReportLineCreate(int id) =>
      '/expensereports/$id/line';
  static String expenseReportLineById(int id, int lineId) =>
      '/expensereports/$id/lines/$lineId';
  static String expenseReportValidate(int id) =>
      '/expensereports/$id/validate';
  static String expenseReportApprove(int id) =>
      '/expensereports/$id/approve';

  /// Cache local du dictionnaire `c_type_fees` (codes et IDs des types
  /// de frais : TF_LUNCH, EX_HOT, etc.).
  static const String expenseReportTypes =
      '/setup/dictionary/expensereport_types';

  // Documents (upload + download). Upload utilisé pour les justificatifs
  // ECM (modulepart=expensereport, ref=<ref note>).
  static const String documentUpload = '/documents/upload';

  // Documents (PDF). Le module appelant + le nom du fichier serveur
  // sont passés en query string : ?modulepart=facture&original_file=...
  static const String documentDownload = '/documents/download';
}

/// Header HTTP obligatoire sur toutes les requêtes authentifiées.
abstract final class ApiHeaders {
  static const String dolApiKey = 'DOLAPIKEY';
  static const String contentType = 'Content-Type';
  static const String accept = 'Accept';
  static const String applicationJson = 'application/json';
}
