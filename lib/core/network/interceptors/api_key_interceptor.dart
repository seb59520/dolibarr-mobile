import 'package:dio/dio.dart';
import 'package:dolibarr_mobile/core/constants/api_paths.dart';
import 'package:dolibarr_mobile/core/storage/secure_storage.dart';

/// Injecte l'en-tête `DOLAPIKEY` sur toutes les requêtes sortantes.
///
/// La clé est lue paresseusement depuis le `SecureStorage` à chaque
/// requête. Si elle est absente (premier lancement, déconnexion en cours),
/// la requête part sans clé : le serveur répondra 401 et le pipeline
/// `error_interceptor` propagera l'événement de re-login.
final class ApiKeyInterceptor extends Interceptor {
  ApiKeyInterceptor(this._storage);

  final SecureStorage _storage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final apiKey = await _storage.readApiKey();
    if (apiKey != null && apiKey.isNotEmpty) {
      options.headers[ApiHeaders.dolApiKey] = apiKey;
    }
    options.headers[ApiHeaders.accept] = ApiHeaders.applicationJson;
    options.headers[ApiHeaders.contentType] = ApiHeaders.applicationJson;
    handler.next(options);
  }
}
