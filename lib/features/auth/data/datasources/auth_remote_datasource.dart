import 'package:dio/dio.dart';
import 'package:dolibarr_mobile/core/constants/api_paths.dart';
import 'package:dolibarr_mobile/core/errors/error_mapper.dart';
import 'package:dolibarr_mobile/core/errors/exceptions.dart';

/// Réponse `POST /login` Dolibarr.
final class DolibarrLoginResponse {
  const DolibarrLoginResponse({required this.token});
  final String token;
}

/// Réponse `GET /users/info` Dolibarr (champs utilisés par l'app).
final class DolibarrUserInfo {
  const DolibarrUserInfo({
    required this.id,
    required this.login,
    required this.firstname,
    required this.lastname,
    this.email,
    this.admin = false,
  });

  factory DolibarrUserInfo.fromJson(Map<String, Object?> json) {
    return DolibarrUserInfo(
      id: int.parse('${json['id'] ?? 0}'),
      login: '${json['login'] ?? ''}',
      firstname: '${json['firstname'] ?? ''}',
      lastname: '${json['lastname'] ?? ''}',
      email: json['email'] as String?,
      admin: '${json['admin'] ?? '0'}' == '1',
    );
  }

  final int id;
  final String login;
  final String firstname;
  final String lastname;
  final String? email;
  final bool admin;
}

/// Datasource HTTP pour les endpoints d'authentification.
///
/// `Dio` est injecté avec une `baseUrl` orientée vers l'instance ciblée.
/// L'`ApiKeyInterceptor` est BYPASSÉ pour `POST /login` (pas encore de
/// clé) en lui passant un `Options(extra: {'_skipApiKey': true})` —
/// non implémenté encore : la 1re version utilise une instance Dio
/// dédiée au login, sans intercepteur.
abstract interface class AuthRemoteDataSource {
  /// Appelle `POST /login` et retourne le token retourné.
  Future<DolibarrLoginResponse> login({
    required String baseUrl,
    required String login,
    required String password,
  });

  /// Appelle `GET /users/info` avec la clé API fournie. Retourne les
  /// infos utilisateur ou jette une `UnauthorizedException` si 401.
  Future<DolibarrUserInfo> getUserInfo({
    required String baseUrl,
    required String apiKey,
  });
}

final class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({Dio Function()? dioFactory})
      : _dioFactory = dioFactory ?? Dio.new;

  final Dio Function() _dioFactory;

  static const _apiPathPrefix = '/api/index.php';

  Dio _buildDio(String baseUrl, {String? apiKey}) {
    final dio = _dioFactory()
      ..options.baseUrl =
          '${baseUrl.replaceFirst(RegExp(r'/+$'), '')}$_apiPathPrefix'
      ..options.connectTimeout = const Duration(seconds: 10)
      ..options.receiveTimeout = const Duration(seconds: 15)
      ..options.headers[ApiHeaders.accept] = ApiHeaders.applicationJson
      ..options.headers[ApiHeaders.contentType] = ApiHeaders.applicationJson;
    if (apiKey != null && apiKey.isNotEmpty) {
      dio.options.headers[ApiHeaders.dolApiKey] = apiKey;
    }
    return dio;
  }

  @override
  Future<DolibarrLoginResponse> login({
    required String baseUrl,
    required String login,
    required String password,
  }) async {
    final dio = _buildDio(baseUrl);
    try {
      final res = await dio.post<Map<String, Object?>>(
        ApiPaths.login,
        data: <String, Object?>{'login': login, 'password': password},
      );
      final data = res.data ?? const <String, Object?>{};
      final success = data['success'];
      if (success is Map<String, Object?> && success['token'] is String) {
        return DolibarrLoginResponse(token: success['token']! as String);
      }
      throw const ServerException(
        statusCode: 200,
        message: 'Réponse /login inattendue',
      );
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  @override
  Future<DolibarrUserInfo> getUserInfo({
    required String baseUrl,
    required String apiKey,
  }) async {
    final dio = _buildDio(baseUrl, apiKey: apiKey);
    try {
      final res = await dio.get<Map<String, Object?>>(ApiPaths.userInfo);
      return DolibarrUserInfo.fromJson(res.data ?? const {});
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }
}
