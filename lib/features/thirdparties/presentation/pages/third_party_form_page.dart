import 'dart:async';

import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/features/categories/domain/entities/category.dart';
import 'package:dolibarr_mobile/features/categories/presentation/providers/category_providers.dart';
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

const String _draftEntityType = 'thirdparty';
const Duration _autosaveDebounce = Duration(milliseconds: 500);

/// Formulaire création / édition d'un tiers.
///
/// Comportement clé :
/// - en mode édition (`existingLocalId != null`), pré-remplit depuis Drift ;
/// - propose la reprise d'un brouillon non commité s'il existe ;
/// - autosave debouncé 500 ms vers `Drafts` ;
/// - submit appelle `createLocal` / `updateLocal`, vide le brouillon, pop.
class ThirdPartyFormPage extends ConsumerStatefulWidget {
  const ThirdPartyFormPage({this.existingLocalId, super.key});

  final int? existingLocalId;

  bool get isCreate => existingLocalId == null;

  @override
  ConsumerState<ThirdPartyFormPage> createState() =>
      _ThirdPartyFormPageState();
}

class _ThirdPartyFormPageState extends ConsumerState<ThirdPartyFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _codeClientCtrl = TextEditingController();
  final _codeFournisseurCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  final _townCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  final _sirenCtrl = TextEditingController();
  final _siretCtrl = TextEditingController();
  final _tvaCtrl = TextEditingController();
  final _notePublicCtrl = TextEditingController();
  final _notePrivateCtrl = TextEditingController();

  bool _isCustomer = true;
  bool _isProspect = false;
  bool _isSupplier = false;
  bool _active = true;

  Set<int> _selectedCategoryIds = {};
  Map<String, Object?> _extrafieldValues = {};

  Timer? _autosaveTimer;
  bool _initialized = false;
  bool _draftRestored = false;
  bool _busy = false;
  ThirdParty? _existing;

  @override
  void initState() {
    super.initState();
    for (final c in _allCtrls) {
      c.addListener(_scheduleAutosave);
    }
  }

  List<TextEditingController> get _allCtrls => [
        _nameCtrl,
        _codeClientCtrl,
        _codeFournisseurCtrl,
        _addressCtrl,
        _zipCtrl,
        _townCtrl,
        _countryCtrl,
        _phoneCtrl,
        _emailCtrl,
        _urlCtrl,
        _sirenCtrl,
        _siretCtrl,
        _tvaCtrl,
        _notePublicCtrl,
        _notePrivateCtrl,
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

  // ----------------------------- Bootstrap -----------------------------

  Future<void> _bootstrap(ThirdParty? existing) async {
    if (_initialized) return;
    _initialized = true;
    _existing = existing;

    // Pré-remplit depuis l'entité existante en édition.
    if (existing != null) {
      _hydrateFrom(existing);
    }

    // Cherche un brouillon en cours.
    final draftDao = ref.read(draftLocalDaoProvider);
    final draft = await draftDao.read(
      entityType: _draftEntityType,
      refLocalId: widget.existingLocalId,
    );
    if (draft != null && draft.isNotEmpty) {
      // Si on est en édition et que le draft diffère de l'entité,
      // on demande à l'utilisateur s'il veut reprendre.
      final shouldRestore = widget.isCreate
          ? true
          : await _askRestoreDraft();
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
        // Drop le brouillon obsolète.
        await draftDao.discard(
          entityType: _draftEntityType,
          refLocalId: widget.existingLocalId,
        );
      }
    }
    if (mounted) setState(() {});
  }

  Future<bool?> _askRestoreDraft() async {
    return ConfirmDialog.show(
      context,
      title: 'Reprendre votre brouillon ?',
      message: 'Vous avez des modifications non envoyées sur ce tiers. '
          'Souhaitez-vous les reprendre ou repartir des valeurs serveur ?',
      confirmLabel: 'Reprendre',
      cancelLabel: 'Repartir',
    );
  }

  void _hydrateFrom(ThirdParty t) {
    _nameCtrl.text = t.name;
    _codeClientCtrl.text = t.codeClient ?? '';
    _codeFournisseurCtrl.text = t.codeFournisseur ?? '';
    _addressCtrl.text = t.address ?? '';
    _zipCtrl.text = t.zip ?? '';
    _townCtrl.text = t.town ?? '';
    _countryCtrl.text = t.countryCode ?? '';
    _phoneCtrl.text = t.phone ?? '';
    _emailCtrl.text = t.email ?? '';
    _urlCtrl.text = t.url ?? '';
    _sirenCtrl.text = t.siren ?? '';
    _siretCtrl.text = t.siret ?? '';
    _tvaCtrl.text = t.tvaIntra ?? '';
    _notePublicCtrl.text = t.notePublic ?? '';
    _notePrivateCtrl.text = t.notePrivate ?? '';
    _isCustomer = t.isCustomer;
    _isProspect = t.isProspect;
    _isSupplier = t.isSupplier;
    _active = t.isActive;
    _selectedCategoryIds = t.categories.toSet();
    _extrafieldValues = Map.of(t.extrafields);
  }

  void _hydrateFromDraft(Map<String, Object?> d) {
    _nameCtrl.text = (d['name'] as String?) ?? _nameCtrl.text;
    _codeClientCtrl.text =
        (d['code_client'] as String?) ?? _codeClientCtrl.text;
    _codeFournisseurCtrl.text =
        (d['code_fournisseur'] as String?) ?? _codeFournisseurCtrl.text;
    _addressCtrl.text = (d['address'] as String?) ?? _addressCtrl.text;
    _zipCtrl.text = (d['zip'] as String?) ?? _zipCtrl.text;
    _townCtrl.text = (d['town'] as String?) ?? _townCtrl.text;
    _countryCtrl.text =
        (d['country_code'] as String?) ?? _countryCtrl.text;
    _phoneCtrl.text = (d['phone'] as String?) ?? _phoneCtrl.text;
    _emailCtrl.text = (d['email'] as String?) ?? _emailCtrl.text;
    _urlCtrl.text = (d['url'] as String?) ?? _urlCtrl.text;
    _sirenCtrl.text = (d['siren'] as String?) ?? _sirenCtrl.text;
    _siretCtrl.text = (d['siret'] as String?) ?? _siretCtrl.text;
    _tvaCtrl.text = (d['tva_intra'] as String?) ?? _tvaCtrl.text;
    _notePublicCtrl.text =
        (d['note_public'] as String?) ?? _notePublicCtrl.text;
    _notePrivateCtrl.text =
        (d['note_private'] as String?) ?? _notePrivateCtrl.text;
    _isCustomer = (d['is_customer'] as bool?) ?? _isCustomer;
    _isProspect = (d['is_prospect'] as bool?) ?? _isProspect;
    _isSupplier = (d['is_supplier'] as bool?) ?? _isSupplier;
    _active = (d['active'] as bool?) ?? _active;
    final cats = d['categories'];
    if (cats is List) {
      _selectedCategoryIds = cats
          .map((e) => int.tryParse('$e'))
          .whereType<int>()
          .toSet();
    }
    final ef = d['extrafields'];
    if (ef is Map) {
      _extrafieldValues = ef.cast<String, Object?>();
    }
  }

  // ----------------------------- Autosave ------------------------------

  void _scheduleAutosave() {
    if (!_initialized) return;
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(_autosaveDebounce, _persistDraft);
  }

  Future<void> _persistDraft() async {
    if (!mounted) return;
    final fields = _snapshot();
    await ref.read(thirdPartyRepositoryProvider).saveDraft(
          refLocalId: widget.existingLocalId,
          fields: fields,
        );
  }

  Map<String, Object?> _snapshot() => {
        'name': _nameCtrl.text,
        'code_client': _emptyToNull(_codeClientCtrl.text),
        'code_fournisseur': _emptyToNull(_codeFournisseurCtrl.text),
        'is_customer': _isCustomer,
        'is_prospect': _isProspect,
        'is_supplier': _isSupplier,
        'active': _active,
        'address': _emptyToNull(_addressCtrl.text),
        'zip': _emptyToNull(_zipCtrl.text),
        'town': _emptyToNull(_townCtrl.text),
        'country_code': _emptyToNull(_countryCtrl.text),
        'phone': _emptyToNull(_phoneCtrl.text),
        'email': _emptyToNull(_emailCtrl.text),
        'url': _emptyToNull(_urlCtrl.text),
        'siren': _emptyToNull(_sirenCtrl.text),
        'siret': _emptyToNull(_siretCtrl.text),
        'tva_intra': _emptyToNull(_tvaCtrl.text),
        'note_public': _emptyToNull(_notePublicCtrl.text),
        'note_private': _emptyToNull(_notePrivateCtrl.text),
        'categories': _selectedCategoryIds.toList(),
        'extrafields': _extrafieldValues,
      };

  String? _emptyToNull(String v) => v.trim().isEmpty ? null : v.trim();

  // ----------------------------- Submit --------------------------------

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!(_isCustomer || _isProspect || _isSupplier)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Sélectionnez au moins un type (client, prospect ou fournisseur).',
          ),
        ),
      );
      return;
    }
    setState(() => _busy = true);

    final repo = ref.read(thirdPartyRepositoryProvider);
    final entity = _toEntity();

    try {
      if (widget.isCreate) {
        final result = await repo.createLocal(entity);
        result.fold(
          onSuccess: (_) async {
            await repo.discardDraft();
            if (!mounted) return;
            _showSuccess('Tiers créé — synchronisation en attente.');
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

  ThirdParty _toEntity() {
    final clientFlags = (_isCustomer ? 1 : 0) | (_isProspect ? 2 : 0);
    final base = _existing;
    return ThirdParty(
      localId: base?.localId ?? 0,
      remoteId: base?.remoteId,
      name: _nameCtrl.text.trim(),
      localUpdatedAt: DateTime.now(),
      codeClient: _emptyToNull(_codeClientCtrl.text),
      codeFournisseur: _emptyToNull(_codeFournisseurCtrl.text),
      clientFlags: clientFlags,
      fournisseur: _isSupplier,
      status: _active ? 1 : 0,
      address: _emptyToNull(_addressCtrl.text),
      zip: _emptyToNull(_zipCtrl.text),
      town: _emptyToNull(_townCtrl.text),
      countryCode: _emptyToNull(_countryCtrl.text),
      phone: _emptyToNull(_phoneCtrl.text),
      email: _emptyToNull(_emailCtrl.text),
      url: _emptyToNull(_urlCtrl.text),
      siren: _emptyToNull(_sirenCtrl.text),
      siret: _emptyToNull(_siretCtrl.text),
      tvaIntra: _emptyToNull(_tvaCtrl.text),
      notePublic: _emptyToNull(_notePublicCtrl.text),
      notePrivate: _emptyToNull(_notePrivateCtrl.text),
      categories: _selectedCategoryIds.toList(),
      extrafields: _extrafieldValues,
      tms: base?.tms,
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
    await ref.read(thirdPartyRepositoryProvider).discardDraft(
          refLocalId: widget.existingLocalId,
        );
    if (mounted) context.pop();
  }

  // ----------------------------- Build ---------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extrafieldsAsync =
        ref.watch(extrafieldsByEntityTypeProvider('thirdparty'));

    if (widget.existingLocalId != null) {
      final async =
          ref.watch(thirdPartyByIdProvider(widget.existingLocalId!));
      return async.when(
        data: (tp) {
          // Premier build avec donnée disponible : on peut bootstrap.
          if (!_initialized) {
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _bootstrap(tp));
          }
          return _scaffold(theme, extrafieldsAsync, missingEntity: tp == null);
        },
        loading: () => const _LoadingScaffold(),
        error: (e, _) => _ErrorScaffold(message: '$e'),
      );
    }

    if (!_initialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap(null));
    }
    return _scaffold(theme, extrafieldsAsync);
  }

  Widget _scaffold(
    ThemeData theme,
    AsyncValue<List<dynamic>> extrafieldsAsync, {
    bool missingEntity = false,
  }) {
    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isCreate ? 'Nouveau tiers' : 'Modifier le tiers'),
          leading: IconButton(
            icon: const Icon(LucideIcons.x),
            onPressed: _busy ? null : _confirmDiscard,
            tooltip: 'Annuler',
          ),
        ),
        body: missingEntity
            ? const Center(child: Text('Tiers introuvable.'))
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
                          const _SectionTitle('Identité'),
                          TextFormField(
                            controller: _nameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Nom *',
                              prefixIcon: Icon(LucideIcons.briefcase),
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (v) => (v?.trim().isEmpty ?? true)
                                ? 'Champ requis'
                                : null,
                          ),
                          const SizedBox(height: AppTokens.spaceMd),
                          TextFormField(
                            controller: _codeClientCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Code client',
                            ),
                          ),
                          const SizedBox(height: AppTokens.spaceMd),
                          TextFormField(
                            controller: _codeFournisseurCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Code fournisseur',
                            ),
                          ),
                          const SizedBox(height: AppTokens.spaceLg),
                          const _SectionTitle('Type & rôles'),
                          _kindToggle(theme),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Tiers actif'),
                            value: _active,
                            onChanged: (v) {
                              setState(() => _active = v);
                              _scheduleAutosave();
                            },
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
                          const SizedBox(height: AppTokens.spaceMd),
                          TextFormField(
                            controller: _countryCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Pays (ISO)',
                              hintText: 'FR, BE, CH…',
                            ),
                            textCapitalization: TextCapitalization.characters,
                          ),
                          const SizedBox(height: AppTokens.spaceLg),
                          const _SectionTitle('Contact'),
                          TextFormField(
                            controller: _phoneCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Téléphone',
                              prefixIcon: Icon(LucideIcons.phone),
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
                          const SizedBox(height: AppTokens.spaceMd),
                          TextFormField(
                            controller: _urlCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Site web',
                              prefixIcon: Icon(LucideIcons.link),
                            ),
                            keyboardType: TextInputType.url,
                          ),
                          const SizedBox(height: AppTokens.spaceLg),
                          const _SectionTitle('Identifiants fiscaux'),
                          TextFormField(
                            controller: _sirenCtrl,
                            decoration: const InputDecoration(
                              labelText: 'SIREN',
                            ),
                          ),
                          const SizedBox(height: AppTokens.spaceMd),
                          TextFormField(
                            controller: _siretCtrl,
                            decoration: const InputDecoration(
                              labelText: 'SIRET',
                            ),
                          ),
                          const SizedBox(height: AppTokens.spaceMd),
                          TextFormField(
                            controller: _tvaCtrl,
                            decoration: const InputDecoration(
                              labelText: 'TVA intra.',
                            ),
                          ),
                          const SizedBox(height: AppTokens.spaceLg),
                          const _SectionTitle('Catégories'),
                          _CategoriesPicker(
                            selectedIds: _selectedCategoryIds,
                            onChanged: (ids) {
                              setState(() => _selectedCategoryIds = ids);
                              _scheduleAutosave();
                            },
                            includeSupplier: _isSupplier,
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

  Widget _kindToggle(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          label: const Text('Client'),
          selected: _isCustomer,
          onSelected: (v) {
            setState(() => _isCustomer = v);
            _scheduleAutosave();
          },
        ),
        FilterChip(
          label: const Text('Prospect'),
          selected: _isProspect,
          onSelected: (v) {
            setState(() => _isProspect = v);
            _scheduleAutosave();
          },
        ),
        FilterChip(
          label: const Text('Fournisseur'),
          selected: _isSupplier,
          onSelected: (v) {
            setState(() => _isSupplier = v);
            _scheduleAutosave();
          },
        ),
      ],
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

class _CategoriesPicker extends ConsumerWidget {
  const _CategoriesPicker({
    required this.selectedIds,
    required this.onChanged,
    required this.includeSupplier,
  });

  final Set<int> selectedIds;
  final ValueChanged<Set<int>> onChanged;
  final bool includeSupplier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customer = ref.watch(
      categoriesByTypeProvider(CategoryType.customer),
    );
    final supplier = ref.watch(
      categoriesByTypeProvider(CategoryType.supplier),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _chips('Client', customer),
        if (includeSupplier) ...[
          const SizedBox(height: AppTokens.spaceXs),
          _chips('Fournisseur', supplier),
        ],
      ],
    );
  }

  Widget _chips(String legend, AsyncValue<List<Category>> async) {
    return async.when(
      data: (cats) {
        if (cats.isEmpty) {
          return Text(
            'Aucune catégorie « $legend ».',
            style: const TextStyle(color: Colors.grey),
          );
        }
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in cats)
              FilterChip(
                label: Text(c.label),
                selected: selectedIds.contains(c.remoteId),
                onSelected: (sel) {
                  final next = {...selectedIds};
                  if (sel) {
                    next.add(c.remoteId);
                  } else {
                    next.remove(c.remoteId);
                  }
                  onChanged(next);
                },
              ),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: LinearProgressIndicator(),
      ),
      error: (_, __) => const Text(
        'Catégories indisponibles.',
        style: TextStyle(color: Colors.grey),
      ),
    );
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
