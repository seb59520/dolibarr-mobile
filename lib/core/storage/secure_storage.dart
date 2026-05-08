import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wrapper autour de `flutter_secure_storage`.
///
/// Centralise la configuration plateforme (Keystore Android, Keychain iOS,
/// IndexedDB chiffré sur web) et expose un contrat ergonomique pour ne
/// stocker QUE la clé API et les métadonnées d'instance Dolibarr.
///
/// Note de sécurité : aucune autre donnée — login utilisateur, mot de
/// passe, données métier — ne doit transiter par ce wrapper. Les autres
/// caches doivent passer par Drift (chiffrement disque optionnel).
abstract interface class SecureStorage {
  Future<void> writeApiKey(String apiKey);
  Future<String?> readApiKey();
  Future<void> deleteApiKey();

  Future<void> writeBaseUrl(String url);
  Future<String?> readBaseUrl();

  Future<void> clear();
}

final class SecureStorageImpl implements SecureStorage {
  SecureStorageImpl([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  static const _kApiKey = 'dolibarr.apiKey';
  static const _kBaseUrl = 'dolibarr.baseUrl';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readApiKey() => _storage.read(key: _kApiKey);

  @override
  Future<void> writeApiKey(String apiKey) =>
      _storage.write(key: _kApiKey, value: apiKey);

  @override
  Future<void> deleteApiKey() => _storage.delete(key: _kApiKey);

  @override
  Future<String?> readBaseUrl() => _storage.read(key: _kBaseUrl);

  @override
  Future<void> writeBaseUrl(String url) =>
      _storage.write(key: _kBaseUrl, value: url);

  @override
  Future<void> clear() => _storage.deleteAll();
}
