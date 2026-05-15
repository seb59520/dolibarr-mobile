// ignore_for_file: one_member_abstracts

import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dolibarr_mobile/core/errors/failure.dart';
import 'package:dolibarr_mobile/features/expenses/domain/entities/extracted_ticket.dart';

/// Exception interne du datasource OCR. Convertie en [OcrFailure] par
/// le pipeline avant traversée de la frontière `data → domain`.
final class OcrException implements Exception {
  const OcrException(this.message);
  final String message;
  @override
  String toString() => 'OcrException: $message';
}

/// Mappe une `DioException` brute vers une `OcrFailure` lisible.
OcrFailure mapDioToOcrFailure(
  DioException e, {
  String? fallbackEndpoint,
}) {
  final code = e.response?.statusCode;
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const OcrFailure(
        message: 'Le service OCR n’a pas répondu à temps. '
            'Réessayez dans 1 à 2 minutes.',
      );
    case DioExceptionType.connectionError:
      final endpoint = fallbackEndpoint ?? 'le backend OCR';
      return OcrFailure(
        message: 'Impossible de joindre $endpoint. '
            'Vérifiez votre connexion ou l’URL configurée.',
      );
    case DioExceptionType.cancel:
      return const OcrFailure(message: 'Analyse annulée.');
    case DioExceptionType.badCertificate:
      return const OcrFailure(
        message: 'Certificat TLS du backend OCR invalide.',
      );
    case DioExceptionType.badResponse:
    case DioExceptionType.unknown:
      break;
  }
  if (code == 401 || code == 403) {
    return const OcrFailure(
      message: 'Jeton OCR invalide. Vérifiez le Bearer dans Paramètres.',
    );
  }
  if (code == 413) {
    return const OcrFailure(
      message: 'Image trop volumineuse (>15 Mo). Réduisez la résolution.',
    );
  }
  if (code == 415) {
    return const OcrFailure(
      message: 'Format non supporté par le backend OCR.',
    );
  }
  if (code != null && code >= 500) {
    return OcrFailure(
      message: 'Le backend OCR a renvoyé une erreur $code. '
          'Réessayez plus tard.',
    );
  }
  return OcrFailure(message: e.message ?? 'Erreur OCR inconnue.');
}

/// Datasource OCR — talk to `<endpoint>/api/extract_ticket`.
///
/// Volontairement découplé du Dio principal de l'app : on prend l'URL et
/// le bearer **en argument à chaque appel** pour que la valeur courante
/// du `flutter_secure_storage` soit toujours utilisée sans recréer le
/// provider à chaque mutation. Le client interne a un timeout long
/// (300 s) parce que le modèle Qwen2.5-VL CPU peut prendre ≥ 80 s.
abstract interface class OcrRemoteDataSource {
  Future<ExtractedTicketDto> extractTicket({
    required Uint8List jpegBytes,
    required String endpoint,
    required String bearer,
    String filename = 'ticket.jpg',
  });

  Future<bool> healthCheck({required String endpoint});
}

final class OcrRemoteDataSourceImpl implements OcrRemoteDataSource {
  OcrRemoteDataSourceImpl({Dio? client})
      : _client = client ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 15),
                sendTimeout: const Duration(seconds: 60),
                receiveTimeout: const Duration(seconds: 300),
              ),
            );

  final Dio _client;

  static const String _extractPath = '/api/extract_ticket';
  static const String _healthPath = '/health';

  @override
  Future<ExtractedTicketDto> extractTicket({
    required Uint8List jpegBytes,
    required String endpoint,
    required String bearer,
    String filename = 'ticket.jpg',
  }) async {
    final base = _normalize(endpoint);
    final formData = FormData.fromMap(<String, Object>{
      'file': MultipartFile.fromBytes(
        jpegBytes,
        filename: filename,
        contentType: DioMediaType('image', 'jpeg'),
      ),
    });
    final res = await _client.post<Map<String, Object?>>(
      '$base$_extractPath',
      data: formData,
      options: Options(
        headers: <String, Object?>{
          'Authorization': 'Bearer $bearer',
          'Accept': 'application/json',
        },
      ),
    );
    final body = res.data;
    if (body == null) {
      throw const OcrException('Réponse OCR vide.');
    }
    return ExtractedTicketDto.fromJson(body);
  }

  @override
  Future<bool> healthCheck({required String endpoint}) async {
    final base = _normalize(endpoint);
    try {
      final res = await _client.get<Map<String, Object?>>(
        '$base$_healthPath',
        options: Options(
          headers: const <String, Object?>{'Accept': 'application/json'},
          // Pas de retry interne sur le healthcheck.
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      final body = res.data;
      if (body == null) return false;
      return body['ok'] == true;
    } on DioException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Supprime le slash final pour éviter `//api/...`.
  String _normalize(String endpoint) =>
      endpoint.replaceFirst(RegExp(r'/+$'), '');
}
