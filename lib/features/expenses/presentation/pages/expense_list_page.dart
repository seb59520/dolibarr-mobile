import 'package:dolibarr_mobile/core/routing/route_paths.dart';
import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/features/expenses/domain/entities/expense_report.dart';
import 'package:dolibarr_mobile/features/expenses/presentation/providers/expense_providers.dart';
import 'package:dolibarr_mobile/features/expenses/presentation/providers/ocr_providers.dart';
import 'package:dolibarr_mobile/features/expenses/presentation/widgets/expense_card.dart';
import 'package:dolibarr_mobile/shared/widgets/empty_state.dart';
import 'package:dolibarr_mobile/shared/widgets/error_state.dart';
import 'package:dolibarr_mobile/shared/widgets/loading_skeleton.dart';
import 'package:dolibarr_mobile/shared/widgets/network_banner.dart';
import 'package:dolibarr_mobile/shared/widgets/shell_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Liste des notes de frais — lecture seule (étape 27).
///
/// Le scan + création arriveront à l'étape 29. Cette page expose donc
/// uniquement : top bar 28px, chips de filtre par statut, liste paginée
/// pull-to-refresh, état vide et skeleton de chargement.
class ExpenseListPage extends ConsumerStatefulWidget {
  const ExpenseListPage({super.key});

  @override
  ConsumerState<ExpenseListPage> createState() => _ExpenseListPageState();
}

class _ExpenseListPageState extends ConsumerState<ExpenseListPage> {
  final _scroll = ScrollController();
  int _page = 0;
  bool _loadingMore = false;
  bool _exhausted = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _exhausted) return;
    final filters = ref.read(expenseFiltersProvider);
    setState(() => _loadingMore = true);
    final result = await ref.read(expenseRepositoryProvider).refreshPage(
          filters: filters,
          page: _page + 1,
        );
    if (!mounted) return;
    result.fold(
      onSuccess: (count) {
        setState(() {
          _loadingMore = false;
          if (count == 0) {
            _exhausted = true;
          } else {
            _page++;
          }
        });
      },
      onFailure: (_) => setState(() => _loadingMore = false),
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _page = 0;
      _exhausted = false;
    });
    final filters = ref.read(expenseFiltersProvider);
    await ref.read(expenseRepositoryProvider).refreshPage(
          filters: filters,
          page: 0,
        );
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(expenseFiltersProvider);
    final listAsync = ref.watch(expenseListProvider);
    final ocrConfigured = ref.watch(ocrConfiguredProvider);
    final c = DoliMobColors.of(context);

    return Scaffold(
      backgroundColor: c.bg,
      floatingActionButton: Tooltip(
        message: ocrConfigured
            ? 'Scanner un ticket'
            : 'Configure l’endpoint et le jeton OCR dans Paramètres '
                'pour activer le scan.',
        child: FloatingActionButton.extended(
          onPressed: ocrConfigured
              ? () => context.go(RoutePaths.expenseScan)
              : null,
          backgroundColor: ocrConfigured ? null : c.fill,
          foregroundColor: ocrConfigured ? null : c.ink3,
          icon: const Icon(LucideIcons.camera),
          label: const Text('Scanner'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const NetworkBanner(),
            _LargeTopBar(
              title: 'Frais',
              subtitle: listAsync.maybeWhen(
                data: (items) => '${items.length} note'
                    '${items.length > 1 ? 's' : ''}',
                orElse: () => null,
              ),
              leading: const ShellMenuButton(),
            ),
            _StatusChipsRow(activeStatuses: filters.statuses),
            const SizedBox(height: AppTokens.spaceXs),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: listAsync.when(
                  data: _buildList,
                  error: (e, _) => ErrorState(
                    title: 'Impossible de charger les notes de frais',
                    description: '$e',
                    onRetry: _refresh,
                  ),
                  loading: () => ListView(
                    children: List.generate(
                      6,
                      (_) => LoadingSkeleton.card(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<ExpenseReport> items) {
    if (items.isEmpty) {
      return EmptyState(
        icon: LucideIcons.wallet,
        title: 'Aucune note de frais',
        description:
            'Scanne ton premier ticket → étape 29 (à venir). '
            'Tu peux aussi rafraîchir pour récupérer les notes du '
            'serveur.',
        actionLabel: 'Rafraîchir',
        action: _refresh,
      );
    }
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 100),
      itemCount: items.length + (_loadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= items.length) {
          return Padding(
            padding: const EdgeInsets.all(AppTokens.spaceMd),
            child: LoadingSkeleton.card(),
          );
        }
        final e = items[index];
        return ExpenseCard(
          expense: e,
          onTap: () => context.go(RoutePaths.expenseDetailFor(e.localId)),
        );
      },
    );
  }
}

class _LargeTopBar extends StatelessWidget {
  const _LargeTopBar({
    required this.title,
    this.subtitle,
    this.leading,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final c = DoliMobColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null)
            Row(
              children: [
                leading!,
                const Spacer(),
              ],
            ),
          Text(
            title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
              color: c.ink,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(fontSize: 13, color: c.ink2),
            ),
          ],
        ],
      ),
    );
  }
}

/// Quick chips de filtre par statut (Tous + 4 statuts utiles).
///
/// "Tous" = ensemble exact des 4 statuts par défaut (sans le statut
/// refused). Cliquer sur un statut active uniquement ce statut.
class _StatusChipsRow extends ConsumerWidget {
  const _StatusChipsRow({required this.activeStatuses});

  final Set<ExpenseReportStatus> activeStatuses;

  static const _defaultAll = {
    ExpenseReportStatus.draft,
    ExpenseReportStatus.validated,
    ExpenseReportStatus.approved,
    ExpenseReportStatus.paid,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = DoliMobColors.of(context);
    final notifier = ref.read(expenseFiltersProvider.notifier);

    bool isOnly(ExpenseReportStatus s) =>
        activeStatuses.length == 1 && activeStatuses.contains(s);

    final chips = <_StatusChipDef>[
      _StatusChipDef(
        label: 'Tous',
        active: _setEq(activeStatuses, _defaultAll),
        onTap: () {
          // Reset au défaut (les 4 statuts utiles).
          for (final s in ExpenseReportStatus.values) {
            final shouldBeActive = _defaultAll.contains(s);
            final isActive = activeStatuses.contains(s);
            if (shouldBeActive != isActive) {
              notifier.toggleStatus(s);
            }
          }
        },
      ),
      _StatusChipDef(
        label: 'Brouillon',
        active: isOnly(ExpenseReportStatus.draft),
        onTap: () => _selectOnly(ref, ExpenseReportStatus.draft),
      ),
      _StatusChipDef(
        label: 'Validé',
        active: isOnly(ExpenseReportStatus.validated),
        onTap: () => _selectOnly(ref, ExpenseReportStatus.validated),
      ),
      _StatusChipDef(
        label: 'Approuvé',
        active: isOnly(ExpenseReportStatus.approved),
        onTap: () => _selectOnly(ref, ExpenseReportStatus.approved),
      ),
      _StatusChipDef(
        label: 'Payé',
        active: isOnly(ExpenseReportStatus.paid),
        onTap: () => _selectOnly(ref, ExpenseReportStatus.paid),
      ),
    ];

    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        children: [
          for (final chip in chips) ...[
            _QuickChip(c: c, def: chip),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  static bool _setEq(
    Set<ExpenseReportStatus> a,
    Set<ExpenseReportStatus> b,
  ) {
    if (a.length != b.length) return false;
    for (final v in a) {
      if (!b.contains(v)) return false;
    }
    return true;
  }

  /// Sélectionne uniquement le statut donné dans le notifier en
  /// togglant les autres au besoin.
  void _selectOnly(WidgetRef ref, ExpenseReportStatus target) {
    final notifier = ref.read(expenseFiltersProvider.notifier);
    final current = ref.read(expenseFiltersProvider).statuses;
    for (final s in ExpenseReportStatus.values) {
      final shouldBeActive = s == target;
      final isActive = current.contains(s);
      if (shouldBeActive != isActive) {
        notifier.toggleStatus(s);
      }
    }
  }
}

class _StatusChipDef {
  const _StatusChipDef({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.c, required this.def});
  final DoliMobColors c;
  final _StatusChipDef def;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: def.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: def.active ? c.ink : c.surface,
          border: Border.all(color: def.active ? c.ink : c.hairline),
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.center,
        child: Text(
          def.label,
          style: TextStyle(
            color: def.active ? (c.dark ? c.bg : Colors.white) : c.ink,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
