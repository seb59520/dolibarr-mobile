import 'dart:async';

import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/features/contacts/domain/entities/contact.dart';
import 'package:dolibarr_mobile/features/contacts/presentation/providers/contact_providers.dart';
import 'package:dolibarr_mobile/features/extrafields/presentation/providers/extrafield_providers.dart';
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

/// Formulaire création / édition d'un contact.
///
/// Mode édition : `existingLocalId != null`.
/// Mode création : `existingLocalId = null`. Le tiers parent peut être
/// pré-sélectionné via `parentLocalId` (ex : depuis la fiche tiers) ou
/// choisi via le picker.
class ContactFormPage extends ConsumerStatefulWidget {
  const ContactFormPage({
    this.existingLocalId,
    this.parentLocalId,
    super.key,
  });

  final int? existingLocalId;
  final int? parentLocalId;

  bool get isCreate => existingLocalId == null;

  @override
  ConsumerState<ContactFormPage> createState() => _ContactFormPageState();
}

class _ContactFormPageState extends ConsumerState<ContactFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _firstnameCtrl = TextEditingController();
  final _lastnameCtrl = TextEditingController();
  final _posteCtrl = TextEditingController();
  final _phoneProCtrl = TextEditingController();
  final _phoneMobileCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  final _townCtrl = TextEditingController();

  int? _parentLocalId;
  Map<String, Object?> _extrafieldValues = {};

  Timer? _autosaveTimer;
  bool _initialized = false;
  bool _draftRestored = false;
  bool _busy = false;
  Contact? _existing;

  @override
  void initState() {
    super.initState();
    _parentLocalId = widget.parentLocalId;
    for (final c in _allCtrls) {
      c.addListener(_scheduleAutosave);
    }
  }

  List<TextEditingController> get _allCtrls => [
        _firstnameCtrl,
        _lastnameCtrl,
        _posteCtrl,
        _phoneProCtrl,
        _phoneMobileCtrl,
        _emailCtrl,
        _addressCtrl,
        _zipCtrl,
        _townCtrl,
      ];

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

  Future<void> _bootstrap(Contact? existing) async {
    if (_initialized) return;
    _initialized = true;
    _existing = existing;

    if (existing != null) {
      _hydrateFrom(existing);
    }

    final draftDao = ref.read(draftLocalDaoProvider);
    final draft = await draftDao.read(
      entityType: 'contact',
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
          entityType: 'contact',
          refLocalId: widget.existingLocalId,
        );
      }
    }
    if (mounted) setState(() {});
  }

  Future<bool?> _askRestoreDraft() => ConfirmDialog.show(
        context,
        title: 'Reprendre votre brouillon ?',
        message: 'Vous avez des modifications non envoyées sur ce contact. '
            'Souhaitez-vous les reprendre ou repartir des valeurs serveur ?',
        confirmLabel: 'Reprendre',
        cancelLabel: 'Repartir',
      );

  void _hydrateFrom(Contact c) {
    _firstnameCtrl.text = c.firstname ?? '';
    _lastnameCtrl.text = c.lastname ?? '';
    _posteCtrl.text = c.poste ?? '';
    _phoneProCtrl.text = c.phonePro ?? '';
    _phoneMobileCtrl.text = c.phoneMobile ?? '';
    _emailCtrl.text = c.email ?? '';
    _addressCtrl.text = c.address ?? '';
    _zipCtrl.text = c.zip ?? '';
    _townCtrl.text = c.town ?? '';
    _parentLocalId = c.socidLocal ?? _parentLocalId;
    _extrafieldValues = Map.of(c.extrafields);
  }

  void _hydrateFromDraft(Map<String, Object?> d) {
    _firstnameCtrl.text = (d['firstname'] as String?) ?? _firstnameCtrl.text;
    _lastnameCtrl.text = (d['lastname'] as String?) ?? _lastnameCtrl.text;
    _posteCtrl.text = (d['poste'] as String?) ?? _posteCtrl.text;
    _phoneProCtrl.text = (d['phone_pro'] as String?) ?? _phoneProCtrl.text;
    _phoneMobileCtrl.text =
        (d['phone_mobile'] as String?) ?? _phoneMobileCtrl.text;
    _emailCtrl.text = (d['email'] as String?) ?? _emailCtrl.text;
    _addressCtrl.text = (d['address'] as String?) ?? _addressCtrl.text;
    _zipCtrl.text = (d['zip'] as String?) ?? _zipCtrl.text;
    _townCtrl.text = (d['town'] as String?) ?? _townCtrl.text;
    final p = d['parent_local_id'];
    if (p is int) _parentLocalId = p;
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
    await ref.read(contactRepositoryProvider).saveDraft(
          fields: fields,
          refLocalId: widget.existingLocalId,
        );
  }

  Map<String, Object?> _snapshot() => {
        'firstname': _emptyToNull(_firstnameCtrl.text),
        'lastname': _emptyToNull(_lastnameCtrl.text),
        'poste': _emptyToNull(_posteCtrl.text),
        'phone_pro': _emptyToNull(_phoneProCtrl.text),
        'phone_mobile': _emptyToNull(_phoneMobileCtrl.text),
        'email': _emptyToNull(_emailCtrl.text),
        'address': _emptyToNull(_addressCtrl.text),
        'zip': _emptyToNull(_zipCtrl.text),
        'town': _emptyToNull(_townCtrl.text),
        'parent_local_id': _parentLocalId,
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
    if (_emptyToNull(_firstnameCtrl.text) == null &&
        _emptyToNull(_lastnameCtrl.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Renseignez au moins un prénom ou un nom.'),
        ),
      );
      return;
    }
    setState(() => _busy = true);

    final repo = ref.read(contactRepositoryProvider);
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
            _showSuccess('Contact créé — synchronisation en attente.');
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

  Future<Contact?> _toEntity() async {
    final base = _existing;
    // Résoud le socidRemote depuis le tiers parent en cache.
    final parentAsync = await ref
        .read(thirdPartyRepositoryProvider)
        .watchById(_parentLocalId!)
        .first;
    final socidRemote = parentAsync?.remoteId ?? base?.socidRemote;
    return Contact(
      localId: base?.localId ?? 0,
      remoteId: base?.remoteId,
      socidRemote: socidRemote,
      socidLocal: _parentLocalId,
      firstname: _emptyToNull(_firstnameCtrl.text),
      lastname: _emptyToNull(_lastnameCtrl.text),
      poste: _emptyToNull(_posteCtrl.text),
      phonePro: _emptyToNull(_phoneProCtrl.text),
      phoneMobile: _emptyToNull(_phoneMobileCtrl.text),
      email: _emptyToNull(_emailCtrl.text),
      address: _emptyToNull(_addressCtrl.text),
      zip: _emptyToNull(_zipCtrl.text),
      town: _emptyToNull(_townCtrl.text),
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
    await ref.read(contactRepositoryProvider).discardDraft(
          refLocalId: widget.existingLocalId,
        );
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final extrafieldsAsync =
        ref.watch(extrafieldsByEntityTypeProvider('socpeople'));

    if (widget.existingLocalId != null) {
      final async = ref.watch(contactByIdProvider(widget.existingLocalId!));
      return async.when(
        data: (c) {
          if (!_initialized) {
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _bootstrap(c));
          }
          return _scaffold(extrafieldsAsync, missingEntity: c == null);
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
              Text(widget.isCreate ? 'Nouveau contact' : 'Modifier le contact'),
          leading: IconButton(
            icon: const Icon(LucideIcons.x),
            onPressed: _busy ? null : _confirmDiscard,
            tooltip: 'Annuler',
          ),
        ),
        body: missingEntity
            ? const Center(child: Text('Contact introuvable.'))
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
                            controller: _lastnameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Nom',
                              prefixIcon: Icon(LucideIcons.user),
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: AppTokens.spaceMd),
                          TextFormField(
                            controller: _firstnameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Prénom',
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: AppTokens.spaceMd),
                          TextFormField(
                            controller: _posteCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Poste',
                            ),
                          ),
                          const SizedBox(height: AppTokens.spaceLg),
                          const _SectionTitle('Coordonnées'),
                          TextFormField(
                            controller: _phoneProCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Téléphone pro',
                              prefixIcon: Icon(LucideIcons.phone),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: AppTokens.spaceMd),
                          TextFormField(
                            controller: _phoneMobileCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Téléphone mobile',
                              prefixIcon: Icon(LucideIcons.smartphone),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: AppTokens.spaceMd),
                          TextFormField(
                            controller: _emailCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(LucideIcons.mail),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: AppTokens.spaceLg),
                          const _SectionTitle('Adresse'),
                          TextFormField(
                            controller: _addressCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Adresse',
                              prefixIcon: Icon(LucideIcons.mapPin),
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: AppTokens.spaceMd),
                          Row(
                            children: [
                              SizedBox(
                                width: 100,
                                child: TextFormField(
                                  controller: _zipCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'CP',
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppTokens.spaceMd),
                              Expanded(
                                child: TextFormField(
                                  controller: _townCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Ville',
                                  ),
                                ),
                              ),
                            ],
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

  String? _validateEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);
    return ok ? null : 'Email invalide';
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

/// Picker de tiers parent : tile cliquable qui ouvre une feuille
/// modale listant les tiers du cache local.
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
                      : items.where((tp) => _matches(tp, _query)).toList();
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
