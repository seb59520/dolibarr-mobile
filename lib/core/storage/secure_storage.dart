import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  /// Drapeau "onboarding terminé" (non sensible mais pratique à
  /// loger ici — évite d'introduire shared_preferences uniquement
  /// pour ce besoin).
  Future<void> writeOnboardingCompleted();
  Future<bool> readOnboardingCompleted();

  /// Endpoint backend OCR (URL racine, sans `/api/extract_ticket`).
  /// Stocké en clair (URL publique) mais via le secure storage pour
  /// rester cohérent avec le couple endpoint + bearer.
  Future<void> writeOcrEndpoint(String url);
  Future<String?> readOcrEndpoint();

  /// Bearer token OCR — sensible (donne accès au modèle Qwen2.5-VL).
  Future<void> writeOcrBearer(String token);
  Future<String?> readOcrBearer();
  Future<void> deleteOcrBearer();

  Future<void> clear();
}

final class SecureStorageImpl implements SecureStorage {
  SecureStorageImpl({
    FlutterSecureStorage? storage,
    SharedPreferences? webPrefs,
  })  : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            ),
        _webPrefs = webPrefs;

  static const _kApiKey = 'dolibarr.apiKey';
  static const _kBaseUrl = 'dolibarr.baseUrl';
  static const _kOnboarding = 'dolibarr.onboardingCompleted';
  static const _kOcrEndpoint = 'dolibarr.ocrEndpoint';
  static const _kOcrBearer = 'dolibarr.ocrBearer';

  final FlutterSecureStorage _storage;

  /// SharedPreferences est utilisé sur web à la place de
  /// `flutter_secure_storage` qui s'avère non fiable sur Safari iOS et
  /// dérivés (Opera iOS, dérivés WebKit) : la persistance via
  /// SubtleCrypto+IndexedDB échoue silencieusement, l'utilisateur perd
  /// sa session à chaque reload. Les valeurs stockées ne sont pas des
  /// secrets critiques (URL d'instance + token utilisateur déjà visible
  /// dans les requêtes XHR / DevTools), donc le local storage navigateur
  /// est un compromis acceptable. Sur iOS/Android natif, on continue à
  /// passer par Keychain/Keystore comme avant.
  final SharedPreferences? _webPrefs;

  bool get _useWebPrefs => kIsWeb && _webPrefs != null;

  @override
  Future<String?> readApiKey() async {
    if (_useWebPrefs) return _webPrefs!.getString(_kApiKey);
    return _storage.read(key: _kApiKey);
  }

  @override
  Future<void> writeApiKey(String apiKey) async {
    if (_useWebPrefs) {
      await _webPrefs!.setString(_kApiKey, apiKey);
      return;
    }
    await _storage.write(key: _kApiKey, value: apiKey);
  }

  @override
  Future<void> deleteApiKey() async {
    if (_useWebPrefs) {
      await _webPrefs!.remove(_kApiKey);
      return;
    }
    await _storage.delete(key: _kApiKey);
  }

  @override
  Future<String?> readBaseUrl() async {
    if (_useWebPrefs) return _webPrefs!.getString(_kBaseUrl);
    return _storage.read(key: _kBaseUrl);
  }

  @override
  Future<void> writeBaseUrl(String url) async {
    if (_useWebPrefs) {
      await _webPrefs!.setString(_kBaseUrl, url);
      return;
    }
    await _storage.write(key: _kBaseUrl, value: url);
  }

  @override
  Future<void> writeOnboardingCompleted() async {
    if (_useWebPrefs) {
      await _webPrefs!.setString(_kOnboarding, 'true');
      return;
    }
    await _storage.write(key: _kOnboarding, value: 'true');
  }

  @override
  Future<bool> readOnboardingCompleted() async {
    if (_useWebPrefs) return _webPrefs!.getString(_kOnboarding) == 'true';
    final v = await _storage.read(key: _kOnboarding);
    return v == 'true';
  }

  @override
  Future<String?> readOcrEndpoint() async {
    if (_useWebPrefs) return _webPrefs!.getString(_kOcrEndpoint);
    return _storage.read(key: _kOcrEndpoint);
  }

  @override
  Future<void> writeOcrEndpoint(String url) async {
    if (_useWebPrefs) {
      await _webPrefs!.setString(_kOcrEndpoint, url);
      return;
    }
    await _storage.write(key: _kOcrEndpoint, value: url);
  }

  @override
  Future<String?> readOcrBearer() async {
    if (_useWebPrefs) return _webPrefs!.getString(_kOcrBearer);
    return _storage.read(key: _kOcrBearer);
  }

  @override
  Future<void> writeOcrBearer(String token) async {
    if (_useWebPrefs) {
      await _webPrefs!.setString(_kOcrBearer, token);
      return;
    }
    await _storage.write(key: _kOcrBearer, value: token);
  }

  @override
  Future<void> deleteOcrBearer() async {
    if (_useWebPrefs) {
      await _webPrefs!.remove(_kOcrBearer);
      return;
    }
    await _storage.delete(key: _kOcrBearer);
  }

  @override
  Future<void> clear() async {
    final prefs = _webPrefs;
    if (_useWebPrefs && prefs != null) {
      await Future.wait([
        prefs.remove(_kApiKey),
        prefs.remove(_kBaseUrl),
        prefs.remove(_kOnboarding),
        prefs.remove(_kOcrEndpoint),
        prefs.remove(_kOcrBearer),
      ]);
      return;
    }
    await _storage.deleteAll();
  }
}
