import 'package:dolibarr_mobile/core/errors/exceptions.dart';
import 'package:dolibarr_mobile/features/invoices/data/datasources/invoice_local_dao.dart';
import 'package:dolibarr_mobile/features/invoices/data/datasources/invoice_payment_local_dao.dart';
import 'package:dolibarr_mobile/features/invoices/data/datasources/invoice_remote_datasource.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice_filters.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice_payment.dart';

/// Résultat d'une sync paiements : nombre de factures balayées,
/// nombre de paiements upsertés, erreurs rencontrées.
final class PaymentSyncResult {
  const PaymentSyncResult({
    required this.invoicesScanned,
    required this.paymentsUpserted,
    this.errors = const [],
  });

  final int invoicesScanned;
  final int paymentsUpserted;
  final List<String> errors;

  bool get hasErrors => errors.isNotEmpty;
}

/// Synchronise les paiements Dolibarr vers le cache local.
///
/// Stratégie : on parcourt les factures dont `dateInvoice` tombe dans
/// la fenêtre demandée (par défaut 13 mois pour couvrir 12 mois + buffer)
/// ET qui sont au statut `validated` ou `paid` (les paiements partiels
/// concernent les validées non encore marquées payées).
final class PaymentSyncService {
  PaymentSyncService({
    required InvoiceLocalDao invoiceDao,
    required InvoicePaymentLocalDao paymentDao,
    required InvoiceRemoteDataSource remote,
    DateTime Function()? clock,
  })  : _invoiceDao = invoiceDao,
        _paymentDao = paymentDao,
        _remote = remote,
        _clock = clock ?? DateTime.now;

  final InvoiceLocalDao _invoiceDao;
  final InvoicePaymentLocalDao _paymentDao;
  final InvoiceRemoteDataSource _remote;
  final DateTime Function() _clock;

  Future<PaymentSyncResult> syncRecent({int monthWindow = 13}) async {
    final now = _clock();
    final windowStart = DateTime(now.year, now.month - (monthWindow - 1));

    // Liste locale (déjà synchronisée par ailleurs) — on ne fait PAS
    // d'appel réseau pour la liste des factures, on s'appuie sur le cache.
    final invoices = await _invoiceDao
        .watchFiltered(
          const InvoiceFilters(
            statuses: {
              InvoiceStatus.validated,
              InvoiceStatus.paid,
            },
          ),
        )
        .first;

    final candidates = invoices
        .where((i) => i.remoteId != null)
        .where(
          (i) =>
              i.dateInvoice != null &&
              !i.dateInvoice!.isBefore(windowStart),
        )
        .toList();

    var upserted = 0;
    final errors = <String>[];

    for (final inv in candidates) {
      try {
        final raws = await _remote.fetchPayments(inv.remoteId!);
        final mapped = raws.map(InvoicePayment.fromJson).toList();
        await _paymentDao.replaceForInvoice(inv.remoteId!, mapped);
        upserted += mapped.length;
      } on NetworkException catch (_) {
        // Offline : on s'arrête tôt, le cache reste utilisable.
        errors.add('Réseau indisponible — sync interrompue');
        break;
      } on Exception catch (e) {
        errors.add('Facture ${inv.ref ?? inv.remoteId} : $e');
      }
    }

    return PaymentSyncResult(
      invoicesScanned: candidates.length,
      paymentsUpserted: upserted,
      errors: errors,
    );
  }
}
