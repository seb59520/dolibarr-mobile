import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:dolibarr_mobile/core/config/app_config.dart';
import 'package:dolibarr_mobile/core/config/env.dart';
import 'package:dolibarr_mobile/core/network/dio_client.dart';
import 'package:dolibarr_mobile/core/network/interceptors/error_interceptor.dart';
import 'package:dolibarr_mobile/core/network/network_info.dart';
import 'package:dolibarr_mobile/core/storage/app_database.dart';
import 'package:dolibarr_mobile/core/storage/secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Providers Riverpod globaux pour la couche `core`.
///
/// Tous les providers exposés ici sont fournis sans surcharge en prod et
/// surchargeables en test via `ProviderScope.overrides`.

/// Configuration runtime de l'app. Reconstruite après login (override
/// dans `bootstrap.dart` ou par un ChangeNotifier dédié plus tard).
final appConfigProvider = Provider<AppConfig>((ref) {
  final url = Env.defaultDolibarrUrl.isNotEmpty
      ? Env.defaultDolibarrUrl
      : 'https://dolibarr.invalid';
  return AppConfig.fromBaseUrl(url);
});

/// Stockage sécurisé (clé API + URL instance).
final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorageImpl();
});

/// Bus d'événements réseau (notamment SessionExpired).
final networkEventBusProvider = Provider<NetworkEventBus>((ref) {
  final bus = NetworkEventBus();
  ref.onDispose(bus.dispose);
  return bus;
});

/// Service d'inspection de l'état réseau.
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  final info = NetworkInfoImpl(Connectivity());
  ref.onDispose(info.dispose);
  return info;
});

/// `Dio` racine avec les 4 intercepteurs branchés.
final dioProvider = Provider<Dio>((ref) {
  return DioClientFactory.create(
    config: ref.watch(appConfigProvider),
    storage: ref.watch(secureStorageProvider),
    eventBus: ref.watch(networkEventBusProvider),
  );
});

/// Base Drift (singleton). Initialisée par `bootstrap.dart`.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError(
    'appDatabaseProvider doit être surchargé dans bootstrap()',
  );
});
