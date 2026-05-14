import 'package:dolibarr_mobile/core/utils/formatters.dart';
import 'package:dolibarr_mobile/features/contacts/data/datasources/contact_local_dao.dart';
import 'package:dolibarr_mobile/features/contacts/domain/entities/contact_filters.dart';
import 'package:dolibarr_mobile/features/dashboard/domain/entities/dashboard_details.dart';
import 'package:dolibarr_mobile/features/dashboard/domain/entities/dashboard_metrics.dart';
import 'package:dolibarr_mobile/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:dolibarr_mobile/features/invoices/data/datasources/invoice_local_dao.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice.dart';
import 'package:dolibarr_mobile/features/invoices/domain/entities/invoice_filters.dart';
import 'package:dolibarr_mobile/features/projects/data/datasources/project_local_dao.dart';
import 'package:dolibarr_mobile/features/projects/domain/entities/project_filters.dart';
import 'package:dolibarr_mobile/features/proposals/data/datasources/proposal_local_dao.dart';
import 'package:dolibarr_mobile/features/proposals/domain/entities/proposal.dart';
import 'package:dolibarr_mobile/features/proposals/domain/entities/proposal_filters.dart';
import 'package:dolibarr_mobile/features/tasks/data/datasources/task_local_dao.dart';
import 'package:dolibarr_mobile/features/tasks/domain/entities/task_filters.dart';
import 'package:dolibarr_mobile/features/thirdparties/data/datasources/third_party_local_dao.dart';
import 'package:dolibarr_mobile/features/thirdparties/domain/entities/third_party_filters.dart';
import 'package:rxdart/rxdart.dart';

final class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl({
    required InvoiceLocalDao invoiceDao,
    required ProposalLocalDao proposalDao,
    required ThirdPartyLocalDao thirdPartyDao,
    required ContactLocalDao contactDao,
    required ProjectLocalDao projectDao,
    required TaskLocalDao taskDao,
  })  : _invoiceDao = invoiceDao,
        _proposalDao = proposalDao,
        _thirdPartyDao = thirdPartyDao,
        _contactDao = contactDao,
        _projectDao = projectDao,
        _taskDao = taskDao;

  final InvoiceLocalDao _invoiceDao;
  final ProposalLocalDao _proposalDao;
  final ThirdPartyLocalDao _thirdPartyDao;
  final ContactLocalDao _contactDao;
  final ProjectLocalDao _projectDao;
  final TaskLocalDao _taskDao;

  @override
  Stream<DashboardMetrics> watchMetrics() {
    final invoices = _invoiceDao.watchFiltered(
      InvoiceFilters(statuses: InvoiceStatus.values.toSet()),
    );
    final proposals = _proposalDao.watchFiltered(
      ProposalFilters(statuses: ProposalStatus.values.toSet()),
    );
    return Rx.combineLatest2<List<Invoice>, List<Proposal>, DashboardMetrics>(
      invoices,
      proposals,
      (i, p) => compute(invoices: i, proposals: p),
    );
  }

  /// Calcul pur — extrait en static pour testabilité.
  ///
  /// [now] permet d'injecter une référence temporelle dans les tests ;
  /// défaut = `DateTime.now()`.
  static DashboardMetrics compute({
    required List<Invoice> invoices,
    required List<Proposal> proposals,
    DateTime? now,
  }) {
    final ref = now ?? DateTime.now();
    final firstOfMonth = DateTime(ref.year, ref.month);
    // Borne supérieure exclusive : 1er du mois suivant.
    final firstOfNextMonth = DateTime(ref.year, ref.month + 1);

    var caMois = 0.0;
    var facturesMoisCount = 0;
    final clientsMois = <String>{};
    var versementAttenduMontant = 0.0;
    var versementAttenduCount = 0;
    var impayeesCount = 0;
    var impayeesMontant = 0.0;

    for (final i in invoices) {
      final inMonth = i.dateInvoice != null &&
          !i.dateInvoice!.isBefore(firstOfMonth) &&
          i.dateInvoice!.isBefore(firstOfNextMonth);
      final isBilled = i.status == InvoiceStatus.validated ||
          i.status == InvoiceStatus.paid;

      // CA mois : facture validée OU payée, datée dans le mois courant.
      if (isBilled && inMonth) {
        caMois += _toDouble(i.totalTtc);
        facturesMoisCount += 1;
        final clientKey = _clientKey(i);
        if (clientKey != null) clientsMois.add(clientKey);
      }

      // Versement attendu fin de mois : facture validée non payée,
      // dont l'échéance tombe entre le 1er et le dernier jour du mois.
      if (i.status == InvoiceStatus.validated &&
          i.paye == 0 &&
          i.dateDue != null &&
          !i.dateDue!.isBefore(firstOfMonth) &&
          i.dateDue!.isBefore(firstOfNextMonth)) {
        versementAttenduMontant += _toDouble(i.totalTtc);
        versementAttenduCount += 1;
      }

      // Impayées : validée + paye=0 (pas brouillon, pas abandonnée).
      if (i.status == InvoiceStatus.validated && i.paye == 0) {
        impayeesCount += 1;
        impayeesMontant += _toDouble(i.totalTtc);
      }
    }

    final devisAttente = proposals
        .where((p) => p.status == ProposalStatus.validated)
        .length;

    return DashboardMetrics(
      caMois: caMois,
      facturesMoisCount: facturesMoisCount,
      clientsMoisCount: clientsMois.length,
      versementAttenduMontant: versementAttenduMontant,
      versementAttenduCount: versementAttenduCount,
      devisEnAttenteCount: devisAttente,
      facturesImpayeesCount: impayeesCount,
      facturesImpayeesMontant: impayeesMontant,
    );
  }

  @override
  Stream<DashboardDetails> watchDetails() {
    final invoices = _invoiceDao.watchFiltered(
      InvoiceFilters(statuses: InvoiceStatus.values.toSet()),
    );
    return invoices.map((i) => computeDetails(invoices: i));
  }

  /// Calcul pur des détails — extrait pour testabilité.
  static DashboardDetails computeDetails({
    required List<Invoice> invoices,
    DateTime? now,
  }) {
    final ref = now ?? DateTime.now();
    final firstOfMonth = DateTime(ref.year, ref.month);
    final firstOfNextMonth = DateTime(ref.year, ref.month + 1);
    final firstOfPrevMonth = DateTime(ref.year, ref.month - 1);

    var caMoisPrev = 0.0;
    var facturesMoisPrevCount = 0;
    final invoicesMois = <Invoice>[];
    final invoicesDue = <Invoice>[];
    final invoicesEnRetard = <Invoice>[];
    var enRetardMontant = 0.0;
    final weeklyMontant = [0.0, 0.0, 0.0, 0.0];
    final weeklyCount = [0, 0, 0, 0];

    for (final i in invoices) {
      final isBilled = i.status == InvoiceStatus.validated ||
          i.status == InvoiceStatus.paid;

      if (isBilled && i.dateInvoice != null) {
        final inCurrent = !i.dateInvoice!.isBefore(firstOfMonth) &&
            i.dateInvoice!.isBefore(firstOfNextMonth);
        final inPrev = !i.dateInvoice!.isBefore(firstOfPrevMonth) &&
            i.dateInvoice!.isBefore(firstOfMonth);
        if (inCurrent) {
          invoicesMois.add(i);
        } else if (inPrev) {
          caMoisPrev += _toDouble(i.totalTtc);
          facturesMoisPrevCount += 1;
        }
      }

      if (i.status == InvoiceStatus.validated &&
          i.paye == 0 &&
          i.dateDue != null) {
        if (!i.dateDue!.isBefore(firstOfMonth) &&
            i.dateDue!.isBefore(firstOfNextMonth)) {
          invoicesDue.add(i);
          final bucket = _weekBucket(i.dateDue!.day);
          weeklyMontant[bucket] += _toDouble(i.totalTtc);
          weeklyCount[bucket] += 1;
        } else if (i.dateDue!.isBefore(firstOfMonth)) {
          invoicesEnRetard.add(i);
          enRetardMontant += _toDouble(i.totalTtc);
        }
      }
    }

    invoicesMois.sort((a, b) {
      final da = a.dateInvoice;
      final db = b.dateInvoice;
      if (da == null || db == null) return 0;
      return db.compareTo(da);
    });
    invoicesDue.sort((a, b) {
      final da = a.dateDue;
      final db = b.dateDue;
      if (da == null || db == null) return 0;
      return da.compareTo(db);
    });
    invoicesEnRetard.sort((a, b) {
      final da = a.dateDue;
      final db = b.dateDue;
      if (da == null || db == null) return 0;
      return da.compareTo(db);
    });

    return DashboardDetails(
      caMoisPrev: caMoisPrev,
      facturesMoisPrevCount: facturesMoisPrevCount,
      invoicesMois: List.unmodifiable(invoicesMois),
      invoicesDueMois: List.unmodifiable(invoicesDue),
      invoicesEnRetard: List.unmodifiable(invoicesEnRetard),
      facturesEnRetardMontant: enRetardMontant,
      weeklyDueMontant: List.unmodifiable(weeklyMontant),
      weeklyDueCount: List.unmodifiable(weeklyCount),
    );
  }

  /// Renvoie l'index 0..3 du bucket hebdomadaire pour un jour 1..31.
  ///   S1 = 1..7, S2 = 8..14, S3 = 15..21, S4 = 22..fin.
  static int _weekBucket(int day) {
    if (day <= 7) return 0;
    if (day <= 14) return 1;
    if (day <= 21) return 2;
    return 3;
  }

  /// Clé d'identification d'un client pour comptage distinct — préfère
  /// l'id local si présent, sinon l'id distant.
  static String? _clientKey(Invoice i) {
    if (i.socidLocal != null) return 'L${i.socidLocal}';
    if (i.socidRemote != null) return 'R${i.socidRemote}';
    return null;
  }

  static double _toDouble(String? raw) {
    if (raw == null) return 0;
    return double.tryParse(raw.replaceAll(',', '.')) ?? 0;
  }

  @override
  Stream<List<RecentActivityItem>> watchRecentActivity({int limit = 10}) {
    final tps = _thirdPartyDao
        .watchFiltered(const ThirdPartyFilters())
        .map(
          (rows) => rows.map(
            (t) => RecentActivityItem(
              entityType: 'thirdparty',
              localId: t.localId,
              label: t.name,
              subtitle: t.cityLine.isEmpty ? null : t.cityLine,
              updatedAt: t.localUpdatedAt,
            ),
          ),
        );
    final contacts =
        _contactDao.watchFiltered(const ContactFilters()).map(
              (rows) => rows.map(
                (c) => RecentActivityItem(
                  entityType: 'contact',
                  localId: c.localId,
                  label: c.displayName,
                  subtitle: c.email,
                  updatedAt: c.localUpdatedAt,
                ),
              ),
            );
    final projects =
        _projectDao.watchFiltered(const ProjectFilters()).map(
              (rows) => rows.map(
                (p) => RecentActivityItem(
                  entityType: 'project',
                  localId: p.localId,
                  label: p.displayLabel,
                  subtitle: p.ref,
                  updatedAt: p.localUpdatedAt,
                ),
              ),
            );
    final tasks = _taskDao.watchFiltered(const TaskFilters()).map(
          (rows) => rows.map(
            (t) => RecentActivityItem(
              entityType: 'task',
              localId: t.localId,
              label: t.displayLabel,
              updatedAt: t.localUpdatedAt,
            ),
          ),
        );
    final invoices = _invoiceDao
        .watchFiltered(
          InvoiceFilters(statuses: InvoiceStatus.values.toSet()),
        )
        .map(
          (rows) => rows.map(
            (i) => RecentActivityItem(
              entityType: 'invoice',
              localId: i.localId,
              label: i.displayLabel,
              subtitle: i.totalTtc != null
                  ? '${formatMoney(i.totalTtc)} TTC'
                  : null,
              updatedAt: i.localUpdatedAt,
            ),
          ),
        );
    final proposals = _proposalDao
        .watchFiltered(
          ProposalFilters(statuses: ProposalStatus.values.toSet()),
        )
        .map(
          (rows) => rows.map(
            (p) => RecentActivityItem(
              entityType: 'proposal',
              localId: p.localId,
              label: p.displayLabel,
              subtitle: p.totalTtc != null
                  ? '${formatMoney(p.totalTtc)} TTC'
                  : null,
              updatedAt: p.localUpdatedAt,
            ),
          ),
        );

    return Rx.combineLatest6<
        Iterable<RecentActivityItem>,
        Iterable<RecentActivityItem>,
        Iterable<RecentActivityItem>,
        Iterable<RecentActivityItem>,
        Iterable<RecentActivityItem>,
        Iterable<RecentActivityItem>,
        List<RecentActivityItem>>(
      tps,
      contacts,
      projects,
      tasks,
      invoices,
      proposals,
      (a, b, c, d, e, f) {
        final all = <RecentActivityItem>[
          ...a,
          ...b,
          ...c,
          ...d,
          ...e,
          ...f,
        ]..sort((x, y) => y.updatedAt.compareTo(x.updatedAt));
        return all.take(limit).toList();
      },
    );
  }
}
