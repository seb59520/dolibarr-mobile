import 'dart:async';

import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/features/projects/domain/entities/project.dart';
import 'package:dolibarr_mobile/features/projects/presentation/providers/project_providers.dart';
import 'package:dolibarr_mobile/features/tasks/domain/entities/task.dart';
import 'package:dolibarr_mobile/features/tasks/presentation/providers/task_providers.dart';
import 'package:dolibarr_mobile/features/thirdparties/presentation/providers/third_party_providers.dart';
import 'package:dolibarr_mobile/shared/widgets/bottom_action_bar.dart';
import 'package:dolibarr_mobile/shared/widgets/confirm_dialog.dart';
import 'package:dolibarr_mobile/shared/widgets/network_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

const Duration _autosaveDebounce = Duration(milliseconds: 500);

class TaskFormPage extends ConsumerStatefulWidget {
  const TaskFormPage({
    this.existingLocalId,
    this.projectLocalId,
    super.key,
  });

  final int? existingLocalId;
  final int? projectLocalId;

  bool get isCreate => existingLocalId == null;

  @override
  ConsumerState<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends ConsumerState<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _labelCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _plannedHoursCtrl = TextEditingController();

  int? _projectLocalId;
  TaskStatus _status = TaskStatus.inProgress;
  int _progress = 0;
  DateTime? _dateStart;
  DateTime? _dateEnd;

  Timer? _autosaveTimer;
  bool _initialized = false;
  bool _draftRestored = false;
  bool _busy = false;
  Task? _existing;

  @override
  void initState() {
    super.initState();
    _projectLocalId = widget.projectLocalId;
    for (final c in _allCtrls) {
      c.addListener(_scheduleAutosave);
    }
  }

  List<TextEditingController> get _allCtrls =>
      [_labelCtrl, _descriptionCtrl, _plannedHoursCtrl];

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

  Future<void> _bootstrap(Task? existing) async {
    if (_initialized) return;
    _initialized = true;
    _existing = existing;
    if (existing != null) _hydrateFrom(existing);

    final draftDao = ref.read(draftLocalDaoProvider);
    final draft = await draftDao.read(
      entityType: 'task',
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
          entityType: 'task',
          refLocalId: widget.existingLocalId,
        );
      }
    }
    if (mounted) setState(() {});
  }

  Future<bool?> _askRestoreDraft() => ConfirmDialog.show(
        context,
        title: 'Reprendre votre brouillon ?',
        message: 'Vous avez des modifications non envoyées sur cette tâche. '
            'Souhaitez-vous les reprendre ou repartir des valeurs serveur ?',
        confirmLabel: 'Reprendre',
        cancelLabel: 'Repartir',
      );

  void _hydrateFrom(Task t) {
    _labelCtrl.text = t.label;
    _descriptionCtrl.text = t.description ?? '';
    _plannedHoursCtrl.text = t.plannedHours ?? '';
    _projectLocalId = t.projectLocal ?? _projectLocalId;
    _status = t.status;
    _progress = t.progress;
    _dateStart = t.dateStart;
    _dateEnd = t.dateEnd;
  }

  void _hydrateFromDraft(Map<String, Object?> d) {
    _labelCtrl.text = (d['label'] as String?) ?? _labelCtrl.text;
    _descriptionCtrl.text =
        (d['description'] as String?) ?? _descriptionCtrl.text;
    _plannedHoursCtrl.text =
        (d['planned_hours'] as String?) ?? _plannedHoursCtrl.text;
    final p = d['project_local_id'];
    if (p is int) _projectLocalId = p;
    final st = d['status'];
    if (st is int) _status = TaskStatus.fromInt(st);
    final pg = d['progress'];
    if (pg is int) _progress = pg;
    final ds = d['date_start'];
    if (ds is int) _dateStart = DateTime.fromMillisecondsSinceEpoch(ds);
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
    await ref.read(taskRepositoryProvider).saveDraft(
          fields: _snapshot(),
          refLocalId: widget.existingLocalId,
        );
  }

  Map<String, Object?> _snapshot() => {
        'label': _emptyToNull(_labelCtrl.text),
        'description': _emptyToNull(_descriptionCtrl.text),
        'planned_hours': _emptyToNull(_plannedHoursCtrl.text),
        'project_local_id': _projectLocalId,
        'status': _status.apiValue,
        'progress': _progress,
        'date_start': _dateStart?.millisecondsSinceEpoch,
        'date_end': _dateEnd?.millisecondsSinceEpoch,
      };

  String? _emptyToNull(String v) => v.trim().isEmpty ? null : v.trim();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_projectLocalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez un projet parent.')),
      );
      return;
    }
    setState(() => _busy = true);
    final repo = ref.read(taskRepositoryProvider);
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
            _showSuccess('Tâche créée — synchronisation en attente.');
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

  Future<Task?> _toEntity() async {
    final base = _existing;
    final parent = await ref
        .read(projectRepositoryProvider)
        .watchById(_projectLocalId!)
        .first;
    final projectRemote = parent?.remoteId ?? base?.projectRemote;
    return Task(
      localId: base?.localId ?? 0,
      remoteId: base?.remoteId,
      projectRemote: projectRemote,
      projectLocal: _projectLocalId,
      ref: base?.ref,
      label: _labelCtrl.text.trim(),
      description: _emptyToNull(_descriptionCtrl.text),
      status: _status,
      progress: _progress,
      plannedHours: _emptyToNull(_plannedHoursCtrl.text),
      fkUser: base?.fkUser,
      dateStart: _dateStart,
      dateEnd: _dateEnd,
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
    await ref.read(taskRepositoryProvider).discardDraft(
          refLocalId: widget.existingLocalId,
        );
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.existingLocalId != null) {
      final async = ref.watch(taskByIdProvider(widget.existingLocalId!));
      return async.when(
        data: (t) {
          if (!_initialized) {
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _bootstrap(t));
          }
          return _scaffold(missingEntity: t == null);
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
          title:
              Text(widget.isCreate ? 'Nouvelle tâche' : 'Modifier la tâche'),
          leading: IconButton(
            icon: const Icon(LucideIcons.x),
            onPressed: _busy ? null : _confirmDiscard,
            tooltip: 'Annuler',
          ),
        ),
        body: missingEntity
            ? const Center(child: Text('Tâche introuvable.'))
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
                          const _SectionTitle('Projet parent'),
                          _ProjectPicker(
                            selectedLocalId: _projectLocalId,
                            onChanged: (id) {
                              setState(() => _projectLocalId = id);
                              _scheduleAutosave();
                            },
                          ),
                          const SizedBox(height: AppTokens.spaceLg),
                          const _SectionTitle('Identité'),
                          TextFormField(
                            controller: _labelCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Intitulé *',
                              prefixIcon: Icon(LucideIcons.checkSquare),
                            ),
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
                          const _SectionTitle('Avancement'),
                          Row(
                            children: [
                              for (final s in TaskStatus.values)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(_statusLabel(s)),
                                    selected: _status == s,
                                    onSelected: (_) {
                                      setState(() {
                                        _status = s;
                                        if (s == TaskStatus.closed &&
                                            _progress < 100) {
                                          _progress = 100;
                                        }
                                      });
                                      _scheduleAutosave();
                                    },
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: AppTokens.spaceMd),
                          Text('Progression : $_progress %'),
                          Slider(
                            value: _progress.toDouble(),
                            max: 100,
                            divisions: 20,
                            label: '$_progress %',
                            onChanged: (v) {
                              setState(() {
                                _progress = v.round();
                                if (_progress == 100) {
                                  _status = TaskStatus.closed;
                                } else if (_progress < 100 &&
                                    _status == TaskStatus.closed) {
                                  _status = TaskStatus.inProgress;
                                }
                              });
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
                          const _SectionTitle('Charge prévue'),
                          TextFormField(
                            controller: _plannedHoursCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Heures prévues (h)',
                              prefixIcon: Icon(LucideIcons.clock),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
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

  String _statusLabel(TaskStatus s) => switch (s) {
        TaskStatus.inProgress => 'En cours',
        TaskStatus.closed => 'Terminée',
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

class _ProjectPicker extends ConsumerWidget {
  const _ProjectPicker({
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
        'Sélectionner un projet',
        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
      );
    } else {
      final async = ref.watch(projectByIdProvider(selectedLocalId!));
      label = async.maybeWhen(
        data: (p) => Text(p?.displayLabel ?? '(introuvable)'),
        orElse: () => const Text('Chargement…'),
      );
    }
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: const Icon(LucideIcons.folderOpen),
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
      builder: (_) => const _ProjectPickerSheet(),
    );
    if (picked != null) onChanged(picked);
  }
}

class _ProjectPickerSheet extends ConsumerStatefulWidget {
  const _ProjectPickerSheet();

  @override
  ConsumerState<_ProjectPickerSheet> createState() =>
      _ProjectPickerSheetState();
}

class _ProjectPickerSheetState extends ConsumerState<_ProjectPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(projectsListProvider);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (context, scroll) => Padding(
        padding: const EdgeInsets.all(AppTokens.spaceMd),
        child: Column(
          children: [
            Text(
              'Choisir un projet',
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
                      : items.where((p) => _matches(p, _query)).toList();
                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text('Aucun projet trouvé.'),
                    );
                  }
                  return ListView.builder(
                    controller: scroll,
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final p = filtered[i];
                      return ListTile(
                        title: Text(p.displayLabel),
                        subtitle: p.description != null
                            ? Text(
                                p.description!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            : null,
                        onTap: () => Navigator.of(context).pop(p.localId),
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

  bool _matches(Project p, String q) {
    final hay = [p.ref ?? '', p.title, p.description ?? '']
        .join(' ')
        .toLowerCase();
    return hay.contains(q.toLowerCase());
  }
}
