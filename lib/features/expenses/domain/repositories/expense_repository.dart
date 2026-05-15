import 'package:dolibarr_mobile/core/utils/result.dart';
import 'package:dolibarr_mobile/features/expenses/domain/entities/expense_filters.dart';
import 'package:dolibarr_mobile/features/expenses/domain/entities/expense_line.dart';
import 'package:dolibarr_mobile/features/expenses/domain/entities/expense_report.dart';
import 'package:dolibarr_mobile/features/expenses/domain/entities/expense_type.dart';

/// Accès aux notes de frais Dolibarr, avec écritures offline-first.
abstract interface class ExpenseRepository {
  Stream<List<ExpenseReport>> watchList(ExpenseFilters filters);

  Stream<ExpenseReport?> watchById(int localId);

  Stream<List<ExpenseLine>> watchLinesByReportLocal(int reportLocalId);

  /// Stream du catalogue local des types de frais (`c_type_fees`).
  Stream<List<ExpenseType>> watchTypes();

  Future<Result<int>> refreshPage({
    required ExpenseFilters filters,
    required int page,
    int limit = 100,
  });

  Future<Result<ExpenseReport>> refreshById(int remoteId);

  /// Rafraîchit le cache local des types de frais.
  Future<Result<int>> refreshTypes();

  // -------- Écritures header (Outbox + Optimistic UI) --------------

  Future<Result<int>> createLocal(ExpenseReport draft);
  Future<Result<void>> updateLocal(ExpenseReport entity);
  Future<Result<void>> deleteLocal(int localId);

  // -------- Écritures lignes (cascade interne note→ligne) -----------

  Future<Result<int>> createLocalLine(ExpenseLine draft);
  Future<Result<void>> updateLocalLine(ExpenseLine entity);
  Future<Result<void>> deleteLocalLine(int lineLocalId);

  // ---------- Workflow (online required) ----------------------------

  /// Passe le brouillon en note de frais validée (statut 2).
  Future<Result<ExpenseReport>> validate(int localId);

  /// Approuve la note (statut 4) — réservé au valideur.
  Future<Result<ExpenseReport>> approve(int localId);

  /// Upload un justificatif (PDF/photo) attaché à la note via l'ECM.
  /// `bytes` est encodé en base64 par le datasource.
  Future<Result<String>> uploadJustificatif({
    required int localId,
    required String filename,
    required List<int> bytes,
  });
}
