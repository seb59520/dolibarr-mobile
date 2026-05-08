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
  static const String contacts = '/app/contacts';
  static const String settings = '/app/settings';
}
