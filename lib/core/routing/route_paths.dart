/// Constantes des paths utilisés par `go_router`.
///
/// Toute nouvelle route doit être ajoutée ici plutôt que codée en dur dans
/// les widgets, pour faciliter le refactoring et les tests.
abstract final class RoutePaths {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String shell = '/app';
  static const String thirdparties = '/app/thirdparties';
  static const String thirdpartyNew = '/app/thirdparties/new';
  static const String thirdpartyDetail = '/app/thirdparties/:id';
  static const String thirdpartyEdit = '/app/thirdparties/:id/edit';
  static const String contacts = '/app/contacts';
  static const String contactNew = '/app/contacts/new';
  static const String contactDetail = '/app/contacts/:id';
  static const String contactEdit = '/app/contacts/:id/edit';
  static const String settings = '/app/settings';
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
}
