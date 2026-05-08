import 'dart:async';

import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/features/proposals/domain/entities/proposal.dart';
import 'package:dolibarr_mobile/features/proposals/presentation/providers/proposal_providers.dart';
import 'package:dolibarr_mobile/features/thirdparties/domain/entities/third_party.dart';
import 'package:dolibarr_mobile/features/thirdparties/presentation/providers/third_party_providers.dart';
import 'package:dolibarr_mobile/shared/widgets/bottom_action_bar.dart';
import 'package:dolibarr_mobile/shared/widgets/confirm_dialog.dart';
import 'package:dolibarr_mobile/shared/widgets/network_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

const Duration _autosaveDebounce = Duration(milliseconds: 500);

class ProposalFormPage extends ConsumerStatefulWidget {
  const ProposalFormPage({
    this.existingLocalId,
    this.parentLocalId,
    super.key,
  });

  final int? existingLocalId;
  final int? parentLocalId;

  bool get isCreate => existingLocalId == null;

  @override
  ConsumerState<ProposalFormPage> createState() => _ProposalFormPageState();
}

class _ProposalFormPageState extends ConsumerState<ProposalFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _refClientCtrl = TextEditingController();
  final _notePublicCtrl = TextEditingController();
  final _notePrivateCtrl = TextEditingController();

  int? _parentLocalId;
  DateTime? _dateProposal;
  DateTime? _dateEnd;

  Timer? _autosaveTimer;
  bool _initialized = false;
  bool _draftRestored = false;
  bool _busy = false;
  Proposal? _existing;

  @override
  void initState() {
    super.initState();
    _parentLocalId = widget.parentLocalId;
    _dateProposal = DateTime.now();
    for (final c in _allCtrls) {
      c.addListener(_scheduleAutosave);
    }
  }

  List<TextEditingController> get _allCtrls =>
      [_refClientCtrl, _notePublicCtrl, _notePrivateCtrl];

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    for (final c in _allCtrls) {
      c
        ..removeListener(_scheduleAutosave)
        ..dispose();
    }
    super.dispose();
  }

  Future<void> _bootstrap(Proposal? existing) async {
    if (_initialized) return;
    _initialized = true;
    _existing = existing;
    if (existing != null) _hydrateFrom(existing);

    final draftDao = ref.read(draftLocalDaoProvider);
    final draft = await draftDao.read(
      entityType: 'proposal',
      refLocalId: widget.existingLocalId,
    );
    if (draft != null && draft.isNotEmpty) {
      final shouldRestore = widget.isCreate ? true : await _askRestoreDraft();
      if (shouldRestore ?? false) {
        _hydrateFromDraft(draft);
        if (mounted) {
          setState(() => _draftRestored = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Brouillon restauré.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        await draftDao.discard(
          entityType: 'proposal',
          refLocalId: widget.existingLocalId,
        );
      }
    }
    if (mounted) setState(() {});
  }

  Future<bool?> _askRestoreDraft() => ConfirmDialog.show(
        context,
        title: 'Reprendre votre brouillon ?',
        message: 'Vous avez des modifications non envoyées sur ce devis. '
            'Souhaitez-vous les reprendre ou repartir des valeurs serveur ?',
        confirmLabel: 'Reprendre',
        cancelLabel: 'Repartir',
      );

  void _hydrateFrom(Proposal p) {
    _refClientCtrl.text = p.refClient ?? '';
    _notePublicCtrl.text = p.notePublic ?? '';
    _notePrivateCtrl.text = p.notePrivate ?? '';
    _parentLocalId = p.socidLocal ?? _parentLocalId;
    _dateProposal = p.dateProposal;
    _dateEnd = p.dateEnd;
  }

  void _hydrateFromDraft(Map<String, Object?> d) {
    _refClientCtrl.text = (d['ref_client'] as String?) ?? _refClientCtrl.text;
    _notePublicCtrl.text =
        (d['note_public'] as String?) ?? _notePublicCtrl.text;
    _notePrivateCtrl.text =
        (d['note_private'] as String?) ?? _notePrivateCtrl.text;
    final p = d['parent_local_id'];
    if (p is int) _parentLocalId = p;
    final dp = d['date_proposal'];
    if (dp is int) _dateProposal = DateTime.fromMillisecondsSinceEpoch(dp);
    final de = d['date_end'];
    if (de is int) _dateEnd = DateTime.fromMillisecondsSinceEpoch(de);
  }

  void _scheduleAutosave() {
    if (!_initialized) return;
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(_autosaveDebounce, _persistDraft);
  }

  Future<void> _persistDraft() async {
    if (!mounted) return;
    await ref.read(proposalRepositoryProvider).saveDraft(
          fields: _snapshot(),
          refLocalId: widget.existingLocalId,
        );
  }

  Map<String, Object?> _snapshot() => {
        'ref_client': _emptyToNull(_refClientCtrl.text),
        'note_public': _emptyToNull(_notePublicCtrl.text),
        'note_private': _emptyToNull(_notePrivateCtrl.text),
        'parent_local_id': _parentLocalId,
        'date_proposal': _dateProposal?.millisecondsSinceEpoch,
        'date_end': _dateEnd?.millisecondsSinceEpoch,
      };

  String? _emptyToNull(String v) => v.trim().isEmpty ? null : v.trim();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_parentLocalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez un client.')),
      );
      return;
    }
    setState(() => _busy = true);
    final repo = ref.read(proposalRepositoryProvider);
    final entity = await _toEntity();
    if (entity == null) {
      setState(() => _busy = false);
      return;
    }
    try {
      if (widget.isCreate) {
        final result = await repo.createLocal(entity);
        result.fold(
          onSuccess: (_) async {
            await repo.discardDraft();
            if (!mounted) return;
            _showSuccess(
              'Devis créé — ajoutez les lignes depuis la fiche.',
            );
            context.pop();
          },
          onFailure: _showFailure,
        );
      } else {
        final result = await repo.updateLocal(entity);
        result.fold(
          onSuccess: (_) async {
            await repo.discardDraft(refLocalId: widget.existingLocalId);
            if (!mounted) return;
            _showSuccess('Modifications enregistrées localement.');
            context.pop();
          },
          onFailure: _showFailure,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<Proposal?> _toEntity() async {
    final base = _existing;
    final parent = await ref
        .read(thirdPartyRepositoryProvider)
        .watchById(_parentLocalId!)
        .first;
    final socidRemote = parent?.remoteId ?? base?.socidRemote;
    return Proposal(
      localId: base?.localId ?? 0,
      remoteId: base?.remoteId,
      socidRemote: socidRemote,
      socidLocal: _parentLocalId,
      ref: base?.ref,
      refClient: _emptyToNull(_refClientCtrl.text),
      status: base?.status ?? ProposalStatus.draft,
      dateProposal: _dateProposal,
      dateEnd: _dateEnd,
      totalHt: base?.totalHt,
      totalTva: base?.totalTva,
      totalTtc: base?.totalTtc,
      fkModeReglement: base?.fkModeReglement,
      fkCondReglement: base?.fkCondReglement,
      notePublic: _emptyToNull(_notePublicCtrl.text),
      notePrivate: _emptyToNull(_notePrivateCtrl.text),
      extrafields: base?.extrafields ?? const {},
      tms: base?.tms,
      localUpdatedAt: DateTime.now(),
      syncStatus: base?.syncStatus ?? SyncStatus.synced,
    );
  }

  void _showSuccess(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

  void _showFailure(Object failure) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Échec : $failure'),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );

  Future<void> _confirmDiscard() async {
    if (!_initialized) {
      context.pop();
      return;
    }
    final ok = await ConfirmDialog.showDestructive(
      context,
      title: 'Abandonner les modifications ?',
      message: _draftRestored
          ? 'Le brouillon en cours sera supprimé.'
          : 'Les modifications saisies seront perdues.',
      confirmLabel: 'Abandonner',
    );
    if (ok != true || !mounted) return;
    await ref.read(proposalRepositoryProvider).discardDraft(
          refLocalId: widget.existingLocalId,
        );
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.existingLocalId != null) {
      final async = ref.watch(proposalByIdProvider(widget.existingLocalId!));
      return async.when(
        data: (p) {
          if (!_initialized) {
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _bootstrap(p));
          }
          return _scaffold(missingEntity: p == null);
        },
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Chargement…')),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Scaffold(
          appBar: AppBar(title: const Text('Erreur')),
          body: Center(child: Text('$e')),
        ),
      );
    }
    if (!_initialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap(null));
    }
    return _scaffold();
  }

  Widget _scaffold({bool missingEntity = false}) {
    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.isCreate ? 'Nouveau devis' : 'Modifier le devis',
          ),
          leading: IconButton(
            icon: const Icon(LucideIcons.x),
            onPressed: _busy ? null : _confirmDiscard,
            tooltip: 'Annuler',
          ),
        ),
        body: missingEntity
            ? const Center(child: Text('Devis introuvable.'))
            : Column(
                children: [
                  const NetworkBanner(),
                  Expanded(
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: ListView(
                        padding: const EdgeInsets.all(AppTokens.spaceMd),
                        children: [
                          const _SectionTitle('Client'),
                          _ParentPicker(
                            selectedLocalId: _parentLocalId,
                            onChanged: (id) {
                              setState(() => _parentLocalId = id);
                              _scheduleAutosave();
                            },
                          ),
                          const SizedBox(height: AppTokens.spaceLg),
                          const _SectionTitle('Dates'),
                          _DateField(
                            label: 'Date du devis',
                            value: _dateProposal,
                            onChanged: (v) {
                              setState(() => _dateProposal = v);
                              _scheduleAutosave();
                            },
                          ),
                          const SizedBox(height: AppTokens.spaceMd),
                          _DateField(
                            label: 'Fin de validité',
                            value: _dateEnd,
                            onChanged: (v) {
                              setState(() => _dateEnd = v);
                              _scheduleAutosave();
                            },
                          ),
                          const SizedBox(height: AppTokens.spaceLg),
                          const _SectionTitle('Référence'),
                          TextFormField(
                            controller: _refClientCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Référence client',
                              prefixIcon: Icon(LucideIcons.tag),
                            ),
                          ),
                          const SizedBox(height: AppTokens.spaceLg),
                          const _SectionTitle('Notes'),
                          TextFormField(
                            controller: _notePublicCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Note publique',
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: AppTokens.spaceMd),
                          TextFormField(
                            controller: _notePrivateCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Note privée',
                              prefixIcon: Icon(LucideIcons.lock),
                            ),
                            maxLines: 3,
                          ),
                          if (widget.isCreate) ...[
                            const SizedBox(height: AppTokens.spaceLg),
                            Container(
                              padding:
                                  const EdgeInsets.all(AppTokens.spaceMd),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer
                                    .withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(
                                  AppTokens.radiusChip,
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Icon(LucideIcons.info, size: 16),
                                  SizedBox(width: AppTokens.spaceXs),
                                  Expanded(
                                    child: Text(
                                      'Vous pourrez ajouter les lignes '
                                      'depuis la fiche détail après '
                                      'création.',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: AppTokens.spaceXl),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
        bottomNavigationBar: missingEntity
            ? null
            : BottomActionBar(
                secondary: OutlinedButton(
                  onPressed: _busy ? null : _confirmDiscard,
                  child: const Text('Annuler'),
                ),
                primary: FilledButton.icon(
                  onPressed: _busy ? null : _submit,
                  icon: _busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(LucideIcons.save),
                  label: Text(widget.isCreate ? 'Créer' : 'Enregistrer'),
                ),
              ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.spaceXs),
      child: Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  Future<void> _pick(BuildContext context) async {
    final initial = value ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) onChanged(date);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = value == null
        ? 'Choisir…'
        : '${value!.day.toString().padLeft(2, '0')}/'
            '${value!.month.toString().padLeft(2, '0')}/${value!.year}';
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _pick(context),
            child: InputDecorator(
              decoration: InputDecoration(labelText: label),
              child: Text(fmt),
            ),
          ),
        ),
        if (value != null)
          IconButton(
            icon: const Icon(LucideIcons.x, size: 16),
            tooltip: 'Effacer',
            onPressed: () => onChanged(null),
          ),
      ],
    );
  }
}

class _ParentPicker extends ConsumerWidget {
  const _ParentPicker({
    required this.selectedLocalId,
    required this.onChanged,
  });

  final int? selectedLocalId;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    Widget label;
    if (selectedLocalId == null) {
      label = Text(
        'Sélectionner un client',
        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
      );
    } else {
      final async = ref.watch(thirdPartyByIdProvider(selectedLocalId!));
      label = async.maybeWhen(
        data: (tp) => Text(tp?.name ?? '(introuvable)'),
        orElse: () => const Text('Chargement…'),
      );
    }
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: const Icon(LucideIcons.briefcase),
        title: label,
        trailing: const Icon(LucideIcons.chevronRight),
        onTap: () => _openPicker(context, ref),
      ),
    );
  }

  Future<void> _openPicker(BuildContext context, WidgetRef ref) async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _ParentPickerSheet(),
    );
    if (picked != null) onChanged(picked);
  }
}

class _ParentPickerSheet extends ConsumerStatefulWidget {
  const _ParentPickerSheet();

  @override
  ConsumerState<_ParentPickerSheet> createState() =>
      _ParentPickerSheetState();
}

class _ParentPickerSheetState extends ConsumerState<_ParentPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(thirdPartiesListProvider);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (context, scroll) => Padding(
        padding: const EdgeInsets.all(AppTokens.spaceMd),
        child: Column(
          children: [
            Text(
              'Choisir un client',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTokens.spaceMd),
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(LucideIcons.search),
                hintText: 'Rechercher dans le cache local',
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: AppTokens.spaceMd),
            Expanded(
              child: listAsync.when(
                data: (items) {
                  final filtered = _query.trim().isEmpty
                      ? items
                      : items.where((tp) => _matches(tp, _query)).toList();
                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text('Aucun client trouvé.'),
                    );
                  }
                  return ListView.builder(
                    controller: scroll,
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final tp = filtered[i];
                      return ListTile(
                        title: Text(tp.name),
                        subtitle:
                            tp.cityLine.isEmpty ? null : Text(tp.cityLine),
                        onTap: () => Navigator.of(context).pop(tp.localId),
                      );
                    },
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('$e')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _matches(ThirdParty tp, String q) {
    final hay = [tp.name, tp.codeClient ?? '', tp.town ?? '']
        .join(' ')
        .toLowerCase();
    return hay.contains(q.toLowerCase());
  }
}
