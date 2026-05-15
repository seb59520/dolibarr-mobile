import 'package:dolibarr_mobile/core/di/providers.dart';
import 'package:dolibarr_mobile/core/storage/secure_storage.dart';
import 'package:dolibarr_mobile/features/expenses/data/datasources/ocr_remote_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Endpoint racine du backend OCR (sans `/api/extract_ticket`).
///
/// Source de vérité unique = [SecureStorage]. La valeur par défaut tombe
/// sur l'instance production `ocr.lab.scinnova-academy.cloud`. Au boot,
/// si le user ne l'a jamais saisi, on initialise la storage avec cette
/// valeur via le notifier — comme ça l'écran Paramètres affiche bien le
/// défaut au lieu d'un champ vide.
const String kDefaultOcrEndpoint =
    'https://ocr.lab.scinnova-academy.cloud';

/// Token Bearer OCR : injectable au build via `--dart-define`.
const String kBuildOcrBearer = String.fromEnvironment(
  'OCR_BEARER_TOKEN',
);

class OcrEndpointNotifier extends AsyncNotifier<String> {
  late final SecureStorage _storage = ref.watch(secureStorageProvider);

  @override
  Future<String> build() async {
    final stored = await _storage.readOcrEndpoint();
    if (stored != null && stored.trim().isNotEmpty) return stored;
    return kDefaultOcrEndpoint;
  }

  Future<void> set(String url) async {
    final value = url.trim();
    state = AsyncData(value.isEmpty ? kDefaultOcrEndpoint : value);
    await _storage.writeOcrEndpoint(value);
  }
}

final ocrEndpointProvider =
    AsyncNotifierProvider<OcrEndpointNotifier, String>(
  OcrEndpointNotifier.new,
);

class OcrBearerNotifier extends AsyncNotifier<String> {
  late final SecureStorage _storage = ref.watch(secureStorageProvider);

  @override
  Future<String> build() async {
    final stored = await _storage.readOcrBearer();
    if (stored != null && stored.isNotEmpty) return stored;
    if (kBuildOcrBearer.isNotEmpty) {
      // Persiste la valeur build pour qu'elle survive aux relances et
      // soit éditable / effaçable depuis l'écran Paramètres.
      await _storage.writeOcrBearer(kBuildOcrBearer);
      return kBuildOcrBearer;
    }
    return '';
  }

  Future<void> set(String token) async {
    state = AsyncData(token);
    if (token.isEmpty) {
      await _storage.deleteOcrBearer();
    } else {
      await _storage.writeOcrBearer(token);
    }
  }
}

final ocrBearerProvider =
    AsyncNotifierProvider<OcrBearerNotifier, String>(
  OcrBearerNotifier.new,
);

/// Datasource OCR (single instance — pas de coût à recréer).
final ocrRemoteDataSourceProvider = Provider<OcrRemoteDataSource>((ref) {
  return OcrRemoteDataSourceImpl();
});

/// Vrai si à la fois l'endpoint et le bearer sont configurés. Sert au
/// FAB "Scanner" : disabled tant que les paramètres ne sont pas
/// renseignés (le user voit un tooltip explicatif).
final ocrConfiguredProvider = Provider<bool>((ref) {
  final endpoint = ref.watch(ocrEndpointProvider).valueOrNull ?? '';
  final bearer = ref.watch(ocrBearerProvider).valueOrNull ?? '';
  return endpoint.trim().isNotEmpty && bearer.trim().isNotEmpty;
});
