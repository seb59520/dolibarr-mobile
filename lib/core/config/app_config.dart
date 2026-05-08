import 'package:dolibarr_mobile/core/config/env.dart';
import 'package:equatable/equatable.dart';

/// Configuration runtime de l'app (URL Dolibarr courante, modes…).
///
/// Issue d'un mélange entre `Env` (figé au build) et le `SecureStorage`
/// (la dernière URL utilisée par l'utilisateur). L'instance est exposée
/// via Riverpod et reconstruite au login / au changement d'instance.
final class AppConfig extends Equatable {
  const AppConfig({
    required this.baseUrl,
    required this.apiPathPrefix,
    this.connectTimeout = const Duration(seconds: 10),
    this.receiveTimeout = const Duration(seconds: 30),
    this.mapTileUrl = '',
    this.mapAttribution = '',
  });

  factory AppConfig.fromBaseUrl(String baseUrl) => AppConfig(
        baseUrl: baseUrl,
        apiPathPrefix: '/api/index.php',
        mapTileUrl: Env.defaultMapTileUrl,
        mapAttribution: Env.defaultMapAttribution,
      );

  /// URL racine de l'instance Dolibarr (sans `/api/index.php`).
  final String baseUrl;

  /// Préfixe API REST. Reste `'/api/index.php'` pour Dolibarr 23 par défaut.
  final String apiPathPrefix;

  final Duration connectTimeout;
  final Duration receiveTimeout;

  final String mapTileUrl;
  final String mapAttribution;

  /// URL complète à donner à Dio (`baseUrl + apiPathPrefix`).
  String get apiBaseUrl =>
      '${baseUrl.replaceFirst(RegExp(r'/+$'), '')}$apiPathPrefix';

  AppConfig copyWith({String? baseUrl}) => AppConfig(
        baseUrl: baseUrl ?? this.baseUrl,
        apiPathPrefix: apiPathPrefix,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        mapTileUrl: mapTileUrl,
        mapAttribution: mapAttribution,
      );

  @override
  List<Object?> get props => [
        baseUrl,
        apiPathPrefix,
        connectTimeout,
        receiveTimeout,
        mapTileUrl,
        mapAttribution,
      ];
}
