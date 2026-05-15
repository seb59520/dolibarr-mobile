/// Constantes des paths utilisés par `go_router`.
///
/// Toute nouvelle route doit être ajoutée ici plutôt que codée en dur dans
/// les widgets, pour faciliter le refactoring et les tests.
abstract final class RoutePaths {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String loginHelp = '/login/help';
  static const String shell = '/app';
  static const String dashboard = '/app/dashboard';
  static const String thirdparties = '/app/thirdparties';
  static const String thirdpartyNew = '/app/thirdparties/new';
  static const String thirdpartyDetail = '/app/thirdparties/:id';
  static const String thirdpartyEdit = '/app/thirdparties/:id/edit';
  static const String contacts = '/app/contacts';
  static const String contactNew = '/app/contacts/new';
  static const String contactDetail = '/app/contacts/:id';
  static const String contactEdit = '/app/contacts/:id/edit';
  static const String projects = '/app/projects';
  static const String projectNew = '/app/projects/new';
  static const String projectDetail = '/app/projects/:id';
  static const String projectEdit = '/app/projects/:id/edit';
  static const String taskNew = '/app/tasks/new';
  static const String taskDetail = '/app/tasks/:id';
  static const String taskEdit = '/app/tasks/:id/edit';
  static const String invoices = '/app/invoices';
  static const String invoiceNew = '/app/invoices/new';
  static const String invoiceDetail = '/app/invoices/:id';
  static const String invoiceEdit = '/app/invoices/:id/edit';
  static const String proposals = '/app/proposals';
  static const String proposalNew = '/app/proposals/new';
  static const String proposalDetail = '/app/proposals/:id';
  static const String proposalEdit = '/app/proposals/:id/edit';
  static const String expenses = '/app/expenses';
  static const String expenseDetail = '/app/expenses/:id';
  static const String settings = '/app/settings';
  static const String stats = '/app/stats';
  static const String tweaks = '/app/tweaks';
  static const String pendingOperations = '/app/sync';

  static String thirdpartyDetailFor(int localId) =>
      '/app/thirdparties/$localId';

  static String thirdpartyEditFor(int localId) =>
      '/app/thirdparties/$localId/edit';

  static String contactDetailFor(int localId) => '/app/contacts/$localId';

  static String contactEditFor(int localId) => '/app/contacts/$localId/edit';

  /// Crée la route "nouveau contact" en pré-sélectionnant un tiers
  /// parent par sa PK locale (passé en query string `?parent=`).
  static String contactNewForParent(int parentLocalId) =>
      '/app/contacts/new?parent=$parentLocalId';

  static String projectDetailFor(int localId) =>
      '/app/projects/$localId';

  static String projectEditFor(int localId) =>
      '/app/projects/$localId/edit';

  /// Crée la route "nouveau projet" en pré-sélectionnant un tiers
  /// parent par sa PK locale.
  static String projectNewForParent(int parentLocalId) =>
      '/app/projects/new?parent=$parentLocalId';

  static String taskDetailFor(int localId) => '/app/tasks/$localId';

  static String taskEditFor(int localId) => '/app/tasks/$localId/edit';

  /// Crée la route "nouvelle tâche" en pré-sélectionnant un projet
  /// parent par sa PK locale.
  static String taskNewForProject(int projectLocalId) =>
      '/app/tasks/new?project=$projectLocalId';

  static String invoiceDetailFor(int localId) =>
      '/app/invoices/$localId';

  static String invoiceEditFor(int localId) =>
      '/app/invoices/$localId/edit';

  /// Crée la route "nouvelle facture" en pré-sélectionnant un tiers
  /// parent (client) par sa PK locale.
  static String invoiceNewForParent(int parentLocalId) =>
      '/app/invoices/new?parent=$parentLocalId';

  static String proposalDetailFor(int localId) =>
      '/app/proposals/$localId';

  static String proposalEditFor(int localId) =>
      '/app/proposals/$localId/edit';

  /// Crée la route "nouveau devis" en pré-sélectionnant un tiers
  /// parent (client) par sa PK locale.
  static String proposalNewForParent(int parentLocalId) =>
      '/app/proposals/new?parent=$parentLocalId';

  static String expenseDetailFor(int localId) =>
      '/app/expenses/$localId';
}
