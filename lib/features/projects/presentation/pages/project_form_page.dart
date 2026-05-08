import 'dart:async';

import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/features/extrafields/presentation/providers/extrafield_providers.dart';
import 'package:dolibarr_mobile/features/projects/domain/entities/project.dart';
import 'package:dolibarr_mobile/features/projects/presentation/providers/project_providers.dart';
import 'package:dolibarr_mobile/features/thirdparties/domain/entities/third_party.dart';
import 'package:dolibarr_mobile/features/thirdparties/presentation/providers/third_party_providers.dart';
import 'package:dolibarr_mobile/shared/widgets/bottom_action_bar.dart';
import 'package:dolibarr_mobile/shared/widgets/confirm_dialog.dart';
import 'package:dolibarr_mobile/shared/widgets/extrafields_form.dart';
import 'package:dolibarr_mobile/shared/widgets/network_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

const Duration _autosaveDebounce = Duration(milliseconds: 500);

class ProjectFormPage extends ConsumerStatefulWidget {
  const ProjectFormPage({
    this.existingLocalId,
    this.parentLocalId,
    super.key,
  });

  final int? existingLocalId;
  final int? parentLocalId;

  bool get isCreate => existingLocalId == null;

  @override
  ConsumerState<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends ConsumerState<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();

  int? _parentLocalId;
  ProjectStatus _status = ProjectStatus.opened;
  bool _public = false;
  DateTime? _dateStart;
  DateTime? _dateEnd;
  Map<String, Object?> _extrafieldValues = {};

  Timer? _autosaveTimer;
  bool _initialized = false;
  bool _draftRestored = false;
  bool _busy = false;
  Project? _existing;

  @override
  void initState() {
    super.initState();
    _parentLocalId = widget.parentLocalId;
    for (final c in _allCtrls) {
      c.addListener(_scheduleAutosave);
    }
  }

  List<TextEditingController> get _allCtrls =>
      [_titleCtrl, _descriptionCtrl, _budgetCtrl];

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

  Future<void> _bootstrap(Project? existing) async {
    if (_initialized) return;
    _initialized = true;
    _existing = existing;

    if (existing != null) {
      _hydrateFrom(existing);
    }

    final draftDao = ref.read(draftLocalDaoProvider);
    final draft = await draftDao.read(
      entityType: 'project',
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
          entityType: 'project',
          refLocalId: widget.existingLocalId,
        );
      }
    }
    if (mounted) setState(() {});
  }

  Future<bool?> _askRestoreDraft() => ConfirmDialog.show(
        context,
        title: 'Reprendre votre brouillon ?',
        message: 'Vous avez des modifications non envoyées sur ce projet. '
            'Souhaitez-vous les reprendre ou repartir des valeurs serveur ?',
        confirmLabel: 'Reprendre',
        cancelLabel: 'Repartir',
      );

  void _hydrateFrom(Project p) {
    _titleCtrl.text = p.title;
    _descriptionCtrl.text = p.description ?? '';
    _budgetCtrl.text = p.budgetAmount ?? '';
    _parentLocalId = p.socidLocal ?? _parentLocalId;
    _status = p.status;
    _public = p.publicLevel == 1;
    _dateStart = p.dateStart;
    _dateEnd = p.dateEnd;
    _extrafieldValues = Map.of(p.extrafields);
  }

  void _hydrateFromDraft(Map<String, Object?> d) {
    _titleCtrl.text = (d['title'] as String?) ?? _titleCtrl.text;
    _descriptionCtrl.text =
        (d['description'] as String?) ?? _descriptionCtrl.text;
    _budgetCtrl.text =
        (d['budget_amount'] as String?) ?? _budgetCtrl.text;
    final p = d['parent_local_id'];
    if (p is int) _parentLocalId = p;
    final st = d['status'];
    if (st is int) _status = ProjectStatus.fromInt(st);
    final pub = d['public'];
    if (pub is bool) _public = pub;
    final ds = d['date_start'];
    if (ds is int) {
      _dateStart = DateTime.fromMillisecondsSinceEpoch(ds);
    }
    final de = d['date_end'];
    if (de is int) {
      _dateEnd = DateTime.fromMillisecondsSinceEpoch(de);
    }
    final ef = d['extrafields'];
    if (ef is Map) {
      _extrafieldValues = ef.cast<String, Object?>();
    }
  }

  void _scheduleAutosave() {
    if (!_initialized) return;
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(_autosaveDebounce, _persistDraft);
  }

  Future<void> _persistDraft() async {
    if (!mounted) return;
    final fields = _snapshot();
    await ref.read(projectRepositoryProvider).saveDraft(
          fields: fields,
          refLocalId: widget.existingLocalId,
        );
  }

  Map<String, Object?> _snapshot() => {
        'title': _emptyToNull(_titleCtrl.text),
        'description': _emptyToNull(_descriptionCtrl.text),
        'budget_amount': _emptyToNull(_budgetCtrl.text),
        'parent_local_id': _parentLocalId,
        'status': _status.apiValue,
        'public': _public,
        'date_start': _dateStart?.millisecondsSinceEpoch,
        'date_end': _dateEnd?.millisecondsSinceEpoch,
        'extrafields': _extrafieldValues,
      };

  String? _emptyToNull(String v) => v.trim().isEmpty ? null : v.trim();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_parentLocalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez un tiers parent.')),
      );
      return;
    }
    setState(() => _busy = true);

    final repo = ref.read(projectRepositoryProvider);
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
            _showSuccess('Projet créé — synchronisation en attente.');
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

  Future<Project?> _toEntity() async {
    final base = _existing;
    final parent = await ref
        .read(thirdPartyRepositoryProvider)
        .watchById(_parentLocalId!)
        .first;
    final socidRemote = parent?.remoteId ?? base?.socidRemote;
    return Project(
      localId: base?.localId ?? 0,
      remoteId: base?.remoteId,
      socidRemote: socidRemote,
      socidLocal: _parentLocalId,
      ref: base?.ref,
      title: _titleCtrl.text.trim(),
      description: _emptyToNull(_descriptionCtrl.text),
      status: _status,
      publicLevel: _public ? 1 : 0,
      fkUserResp: base?.fkUserResp,
      dateStart: _dateStart,
      dateEnd: _dateEnd,
      budgetAmount: _emptyToNull(_budgetCtrl.text),
      oppStatus: base?.oppStatus,
      oppAmount: base?.oppAmount,
      oppPercent: base?.oppPercent,
      extrafields: _extrafieldValues,
      tms: base?.tms,
      localUpdatedAt: DateTime.now(),
      syncStatus: base?.syncStatus ?? SyncStatus.synced,
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showFailure(Object failure) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Échec : $failure'),
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
      ),
    );
  }

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
    await ref.read(projectRepositoryProvider).discardDraft(
          refLocalId: widget.existingLocalId,
        );
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final extrafieldsAsync =
        ref.watch(extrafieldsByEntityTypeProvider('projet'));

    if (widget.existingLocalId != null) {
      final async = ref.watch(projectByIdProvider(widget.existingLocalId!));
      return async.when(
        data: (p) {
          if (!_initialized) {
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _bootstrap(p));
          }
          return _scaffold(extrafieldsAsync, missingEntity: p == null);
        },
        loading: () => const _LoadingScaffold(),
        error: (e, _) => _ErrorScaffold(message: '$e'),
      );
    }

    if (!_initialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap(null));
    }
    return _scaffold(extrafieldsAsync);
  }

  Widget _scaffold(
    AsyncValue<List<dynamic>> extrafieldsAsync, {
    bool missingEntity = false,
  }) {
    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(
          title:
              Text(widget.isCreate ? 'Nouveau projet' : 'Modifier le projet'),
          leading: IconButton(
            icon: const Icon(LucideIcons.x),
            onPressed: _busy ? null : _confirmDiscard,
            tooltip: 'Annuler',
          ),
        ),
        body: missingEntity
            ? const Center(child: Text('Projet introuvable.'))
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
                          const _SectionTitle('Tiers parent'),
                          _ParentPicker(
                            selectedLocalId: _parentLocalId,
                            onChanged: (id) {
                              setState(() => _parentLocalId = id);
                              _scheduleAutosave();
                            },
                          ),
                          const SizedBox(height: AppTokens.spaceLg),
                          const _SectionTitle('Identité'),
                          TextFormField(
                            controller: _titleCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Titre *',
                              prefixIcon: Icon(LucideIcons.folderOpen),
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (v) => (v?.trim().isEmpty ?? true)
                                ? 'Champ requis'
                                : null,
                          ),
                          const SizedBox(height: AppTokens.spaceMd),
                          TextFormField(
                            controller: _descriptionCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                            ),
                            maxLines: 4,
                          ),
                          const SizedBox(height: AppTokens.spaceLg),
                          const _SectionTitle('Statut'),
                          Wrap(
                            spacing: 8,
                            children: [
                              for (final s in ProjectStatus.values)
                                ChoiceChip(
                                  label: Text(_statusLabel(s)),
                                  selected: _status == s,
                                  onSelected: (_) {
                                    setState(() => _status = s);
                                    _scheduleAutosave();
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: AppTokens.spaceMd),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Projet public'),
                            subtitle: const Text(
                              'Visible par tous les utilisateurs Dolibarr',
                            ),
                            value: _public,
                            onChanged: (v) {
                              setState(() => _public = v);
                              _scheduleAutosave();
                            },
                          ),
                          const SizedBox(height: AppTokens.spaceLg),
                          const _SectionTitle('Période'),
                          _DateField(
                            label: 'Début',
                            value: _dateStart,
                            onChanged: (v) {
                              setState(() => _dateStart = v);
                              _scheduleAutosave();
                            },
                          ),
                          const SizedBox(height: AppTokens.spaceMd),
                          _DateField(
                            label: 'Fin',
                            value: _dateEnd,
                            onChanged: (v) {
                              setState(() => _dateEnd = v);
                              _scheduleAutosave();
                            },
                          ),
                          const SizedBox(height: AppTokens.spaceLg),
                          const _SectionTitle('Financier'),
                          TextFormField(
                            controller: _budgetCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Budget alloué (HT)',
                              prefixIcon: Icon(LucideIcons.banknote),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                          const SizedBox(height: AppTokens.spaceLg),
                          const _SectionTitle('Champs personnalisés'),
                          extrafieldsAsync.when(
                            data: (defs) => ExtrafieldsForm(
                              definitions: defs.cast(),
                              initialValues: _extrafieldValues,
                              onChanged: (v) {
                                _extrafieldValues = v;
                                _scheduleAutosave();
                              },
                            ),
                            loading: () => const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: LinearProgressIndicator(),
                            ),
                            error: (_, __) => const Text(
                              'Champs personnalisés indisponibles.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
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

  String _statusLabel(ProjectStatus s) => switch (s) {
        ProjectStatus.draft => 'Brouillon',
        ProjectStatus.opened => 'Ouvert',
        ProjectStatus.closed => 'Fermé',
      };
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

/// Picker tiers (mirror of the contact form's picker).
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
        'Sélectionner un tiers',
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
              'Choisir un tiers',
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
                      : items
                          .where(
                            (tp) => _matches(tp, _query),
                          )
                          .toList();
                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text('Aucun tiers trouvé.'),
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

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chargement…')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorScaffold extends StatelessWidget {
  const _ErrorScaffold({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Erreur')),
      body: Center(child: Text(message)),
    );
  }
}
