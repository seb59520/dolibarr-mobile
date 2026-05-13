import 'package:dolibarr_mobile/core/utils/formatters.dart';
import 'package:dolibarr_mobile/features/contacts/data/datasources/contact_local_dao.dart';
import 'package:dolibarr_mobile/features/contacts/domain/entities/contact_filters.dart';
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
      _compute,
    );
  }

  DashboardMetrics _compute(
    List<Invoice> invoices,
    List<Proposal> proposals,
  ) {
    final now = DateTime.now();
    final firstOfMonth = DateTime(now.year, now.month);

    var caMois = 0.0;
    var impayeesCount = 0;
    var impayeesMontant = 0.0;

    for (final i in invoices) {
      // CA mois : facture validée OU payée, datée dans le mois courant.
      if ((i.status == InvoiceStatus.validated ||
              i.status == InvoiceStatus.paid) &&
          i.dateInvoice != null &&
          !i.dateInvoice!.isBefore(firstOfMonth)) {
        caMois += _toDouble(i.totalTtc);
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
      devisEnAttenteCount: devisAttente,
      facturesImpayeesCount: impayeesCount,
      facturesImpayeesMontant: impayeesMontant,
    );
  }

  double _toDouble(String? raw) {
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
