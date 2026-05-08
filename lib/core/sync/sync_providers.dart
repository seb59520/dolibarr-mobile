import 'package:dolibarr_mobile/core/di/providers.dart';
import 'package:dolibarr_mobile/core/sync/sync_engine.dart';
import 'package:dolibarr_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:dolibarr_mobile/features/contacts/presentation/providers/contact_providers.dart';
import 'package:dolibarr_mobile/features/thirdparties/presentation/providers/third_party_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// `SyncEngine` racine. Démarre automatiquement dès qu'une session
/// authentifiée est disponible — voir `syncBootstrapProvider`.
final syncEngineProvider = Provider<SyncEngine>((ref) {
  final engine = SyncEngine(
    outbox: ref.watch(pendingOperationDaoProvider),
    thirdpartyRemote: ref.watch(thirdPartyRemoteDataSourceProvider),
    thirdpartyDao: ref.watch(thirdPartyLocalDaoProvider),
    contactRemote: ref.watch(contactRemoteDataSourceProvider),
    contactDao: ref.watch(contactLocalDaoProvider),
    network: ref.watch(networkInfoProvider),
  );
  ref.onDispose(engine.stop);
  return engine;
});

/// Listen-only provider : démarre/arrête l'engine selon l'état d'auth.
/// À monter une seule fois (depuis `app.dart`) avec `ref.watch`.
final syncBootstrapProvider = Provider<void>((ref) {
  final engine = ref.watch(syncEngineProvider);
  ref.listen<AuthState>(authNotifierProvider, (previous, next) {
    if (next is AuthAuthenticated) {
      // ignore: unawaited_futures
      engine.start();
    } else {
      // ignore: unawaited_futures
      engine.stop();
    }
  }, fireImmediately: true);
});
