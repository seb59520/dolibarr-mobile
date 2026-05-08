import 'package:dolibarr_mobile/core/storage/app_database.dart';
import 'package:dolibarr_mobile/features/thirdparties/presentation/providers/third_party_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stream de toutes les ops Outbox (toutes statuts confondus) pour la
/// page "Opérations en attente".
final pendingOperationsAllProvider =
    StreamProvider.autoDispose<List<PendingOperationRow>>((ref) {
  return ref.watch(pendingOperationDaoProvider).watchAll();
});

/// Compteur des ops à afficher dans le badge AppBar.
final pendingOperationsCountProvider =
    StreamProvider.autoDispose<int>((ref) {
  return ref.watch(pendingOperationDaoProvider).watchPendingCount();
});
