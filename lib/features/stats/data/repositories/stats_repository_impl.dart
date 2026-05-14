import 'package:dolibarr_mobile/features/invoices/data/datasources/invoice_local_dao.dart';
import 'package:dolibarr_mobile/features/invoices/data/datasources/invoice_payment_local_dao.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice_filters.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice_payment.dart';
import 'package:dolibarr_mobile/features/stats/domain/entities/monthly_stat.dart';
import 'package:dolibarr_mobile/features/stats/domain/entities/stats_snapshot.dart';
import 'package:dolibarr_mobile/features/stats/domain/entities/yearly_stat.dart';
import 'package:dolibarr_mobile/features/stats/domain/repositories/stats_repository.dart';
import 'package:rxdart/rxdart.dart';

final class StatsRepositoryImpl implements StatsRepository {
  StatsRepositoryImpl({
    required InvoiceLocalDao invoiceDao,
    required InvoicePaymentLocalDao paymentDao,
    DateTime Function()? clock,
  })  : _invoiceDao = invoiceDao,
        _paymentDao = paymentDao,
        _clock = clock ?? DateTime.now;

  final InvoiceLocalDao _invoiceDao;
  final InvoicePaymentLocalDao _paymentDao;
  final DateTime Function() _clock;

  @override
  Stream<StatsSnapshot> watchSnapshot({
    StatsPeriod period = StatsPeriod.rolling12,
  }) {
    final invoices = _invoiceDao.watchFiltered(
      InvoiceFilters(statuses: InvoiceStatus.values.toSet()),
    );
    final payments = _paymentDao.watchAll();
    return Rx.combineLatest2<List<Invoice>, List<InvoicePayment>,
        StatsSnapshot>(
      invoices,
      payments,
      (inv, pay) {
        final now = _clock();
        return compute(
          invoices: inv,
          payments: pay,
          monthWindow: _resolveWindow(period, inv, pay, now),
          now: now,
        );
      },
    );
  }

  /// Convertit une [StatsPeriod] en nombre de mois à inclure.
  /// Garantit un minimum de 1 et un maximum protecteur de 240 mois (20 ans).
  static int _resolveWindow(
    StatsPeriod period,
    List<Invoice> invoices,
    List<InvoicePayment> payments,
    DateTime now,
  ) {
    switch (period) {
      case StatsPeriod.rolling12:
        return 12;
      case StatsPeriod.currentYear:
        return now.month;
      case StatsPeriod.allHistory:
        DateTime? earliest;
        for (final i in invoices) {
          if (i.status == InvoiceStatus.draft) continue;
          if (i.status == InvoiceStatus.abandoned) continue;
          final d = i.dateInvoice;
          if (d == null) continue;
          if (earliest == null || d.isBefore(earliest)) earliest = d;
        }
        for (final p in payments) {
          final d = p.date;
          if (d == null) continue;
          if (earliest == null || d.isBefore(earliest)) earliest = d;
        }
        if (earliest == null) return 12;
        final months = (now.year - earliest.year) * 12
            + (now.month - earliest.month) + 1;
        return months.clamp(1, 240);
    }
  }

  /// Visible-for-testing : pur, déterministe, ne dépend que de ses
  /// entrées. La page de tests s'en sert pour valider les agrégats.
  static StatsSnapshot compute({
    required List<Invoice> invoices,
    required List<InvoicePayment> payments,
    required int monthWindow,
    required DateTime now,
  }) {
    // Fenêtre mensuelle : [now − (monthWindow − 1) mois ; now], normalisée
    // au premier jour du mois.
    final months = List<MonthlyStat>.generate(monthWindow, (i) {
      final offset = monthWindow - 1 - i;
      final ref = DateTime(now.year, now.month - offset);
      return MonthlyStat(year: ref.year, month: ref.month);
    });
    final monthsIndex = <int, int>{};
    for (var i = 0; i < months.length; i++) {
      monthsIndex[months[i].year * 100 + months[i].month] = i;
    }

    // Agrégat factures (par dateInvoice).
    final factureHt = List<double>.filled(monthWindow, 0);
    final factureTtc = List<double>.filled(monthWindow, 0);
    var yearFactureHt = 0.0;
    var yearFactureTtc = 0.0;
    var prevYearFactureHt = 0.0;
    var prevYearFactureTtc = 0.0;
    final currentYear = now.year;
    final previousYear = currentYear - 1;

    for (final i in invoices) {
      if (i.status == InvoiceStatus.draft) continue;
      if (i.status == InvoiceStatus.abandoned) continue;
      final d = i.dateInvoice;
      if (d == null) continue;
      final ttc = _toDouble(i.totalTtc);
      final ht = _toDouble(i.totalHt);
      final key = d.year * 100 + d.month;
      final idx = monthsIndex[key];
      if (idx != null) {
        factureHt[idx] += ht;
        factureTtc[idx] += ttc;
      }
      if (d.year == currentYear) {
        yearFactureHt += ht;
        yearFactureTtc += ttc;
      } else if (d.year == previousYear) {
        prevYearFactureHt += ht;
        prevYearFactureTtc += ttc;
      }
    }

    // Agrégat paiements (par date paiement).
    final percu = List<double>.filled(monthWindow, 0);
    var yearPercu = 0.0;
    var prevYearPercu = 0.0;

    for (final p in payments) {
      final d = p.date;
      if (d == null) continue;
      final amount = _toDouble(p.amount);
      final key = d.year * 100 + d.month;
      final idx = monthsIndex[key];
      if (idx != null) percu[idx] += amount;
      if (d.year == currentYear) {
        yearPercu += amount;
      } else if (d.year == previousYear) {
        prevYearPercu += amount;
      }
    }

    final monthly = <MonthlyStat>[
      for (var k = 0; k < monthWindow; k++)
        months[k].copyWith(
          factureHt: factureHt[k],
          factureTtc: factureTtc[k],
          percu: percu[k],
        ),
    ];

    return StatsSnapshot(
      monthly: monthly,
      currentYear: YearlyStat(
        year: currentYear,
        factureHt: yearFactureHt,
        factureTtc: yearFactureTtc,
        percu: yearPercu,
      ),
      previousYear: YearlyStat(
        year: previousYear,
        factureHt: prevYearFactureHt,
        factureTtc: prevYearFactureTtc,
        percu: prevYearPercu,
      ),
    );
  }

  static double _toDouble(String? raw) {
    if (raw == null) return 0;
    return double.tryParse(raw.replaceAll(',', '.')) ?? 0;
  }
}
