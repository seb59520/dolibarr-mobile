import 'package:dolibarr_mobile/core/routing/route_paths.dart';
import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/features/expenses/data/expense_ticket_pipeline.dart';
import 'package:dolibarr_mobile/features/expenses/domain/entities/expense_type.dart';
import 'package:dolibarr_mobile/features/expenses/domain/entities/extracted_ticket.dart';
import 'package:dolibarr_mobile/features/expenses/presentation/controllers/expense_scan_controller.dart';
import 'package:dolibarr_mobile/features/expenses/presentation/providers/expense_providers.dart';
import 'package:dolibarr_mobile/shared/widgets/bottom_action_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Formulaire de ligne de note de frais pré-rempli depuis l'OCR.
///
/// L'utilisateur peut tout éditer (commerçant, date, montant, TVA, type).
/// Au "Enregistrer", on appelle [ExpenseScanController.push] qui :
///   - cherche/crée la note de frais brouillon de l'utilisateur courant
///   - POST la ligne (`/expensereports/<id>/line`)
///   - upload le JPEG dans l'ECM Dolibarr
class ExpenseLineFormPage extends ConsumerStatefulWidget {
  const ExpenseLineFormPage({super.key});

  @override
  ConsumerState<ExpenseLineFormPage> createState() =>
      _ExpenseLineFormPageState();
}

class _ExpenseLineFormPageState extends ConsumerState<ExpenseLineFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _merchantCtrl = TextEditingController();
  final _amountTtcCtrl = TextEditingController();
  final _vatRateCtrl = TextEditingController();
  final _commentsCtrl = TextEditingController();

  DateTime _date = DateTime.now();
  ExpenseType? _selectedType;
  bool _typeManuallyChanged = false;
  bool _initialized = false;

  @override
  void dispose() {
    _merchantCtrl.dispose();
    _amountTtcCtrl.dispose();
    _vatRateCtrl.dispose();
    _commentsCtrl.dispose();
    super.dispose();
  }

  void _hydrateFromExtracted(ExtractedTicketDto dto, List<ExpenseType> types) {
    if (_initialized) return;
    _initialized = true;
    _merchantCtrl.text = dto.merchant ?? '';
    if (dto.amountTtc != null) {
      _amountTtcCtrl.text = _formatNumber(dto.amountTtc!);
    }
    if (dto.vatRate != null) {
      _vatRateCtrl.text = _formatNumber(dto.vatRate!);
    }
    if (dto.dateIso != null) _date = dto.dateIso!;
    if (dto.rawText != null && dto.rawText!.isNotEmpty) {
      _commentsCtrl.text = _shortenRawText(
        merchant: dto.merchant,
        raw: dto.rawText!,
      );
    }
    if (dto.suggestedFeeTypeCode != null && !_typeManuallyChanged) {
      final code = dto.suggestedFeeTypeCode!.apiCode;
      for (final t in types) {
        if (t.code == code) {
          _selectedType = t;
          break;
        }
      }
    }
  }

  String _formatNumber(double v) {
    final s = v.toStringAsFixed(2);
    return s.endsWith('.00') ? s.substring(0, s.length - 3) : s;
  }

  String _shortenRawText({required String raw, String? merchant}) {
    final excerpt = raw.length > 120 ? '${raw.substring(0, 120)}…' : raw;
    if (merchant == null || merchant.isEmpty) return excerpt;
    return '$merchant — $excerpt';
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(expenseScanControllerProvider);
    final typesAsync = ref.watch(expenseTypesProvider);

    // Quand on bascule en `done`, snack et go back to liste.
    ref.listen<ExpenseScanState>(expenseScanControllerProvider, (prev, next) {
      if (prev?.phase == next.phase) return;
      if (next.phase == ExpenseScanPhase.done && next.outcome != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ligne ajoutée à la note ${next.outcome!.reportRef}.',
            ),
          ),
        );
        context.go(RoutePaths.expenses);
      } else if (next.phase == ExpenseScanPhase.error &&
          next.failure != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.failure!.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => context.go(RoutePaths.expenseScan),
        ),
        title: const Text('Nouvelle ligne de frais'),
      ),
      body: typesAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppTokens.spaceLg),
            child: Text('Impossible de charger les types : $e'),
          ),
        ),
        data: (types) {
          if (scanState.extracted != null) {
            _hydrateFromExtracted(scanState.extracted!, types);
          }
          return _Form(
            formKey: _formKey,
            merchantCtrl: _merchantCtrl,
            amountTtcCtrl: _amountTtcCtrl,
            vatRateCtrl: _vatRateCtrl,
            commentsCtrl: _commentsCtrl,
            date: _date,
            onDateChanged: (d) => setState(() => _date = d),
            selectedType: _selectedType,
            types: types,
            onTypeChanged: (t) => setState(() {
              _selectedType = t;
              _typeManuallyChanged = true;
            }),
            extracted: scanState.extracted,
            manualEntry: scanState.manualEntry,
            jpegPresent: scanState.jpegBytes != null,
            onChanged: () => setState(() {}),
          );
        },
      ),
      bottomNavigationBar: BottomActionBar(
        secondary: OutlinedButton(
          onPressed: scanState.phase == ExpenseScanPhase.pushing
              ? null
              : () => context.go(RoutePaths.expenseScan),
          child: const Text('Annuler'),
        ),
        primary: FilledButton.icon(
          icon: scanState.phase == ExpenseScanPhase.pushing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(LucideIcons.save),
          label: Text(
            scanState.phase == ExpenseScanPhase.pushing
                ? 'Envoi…'
                : 'Enregistrer',
          ),
          onPressed: _canSubmit(scanState) ? _submit : null,
        ),
      ),
    );
  }

  bool _canSubmit(ExpenseScanState scanState) {
    if (scanState.phase == ExpenseScanPhase.pushing) return false;
    if (_amountTtcCtrl.text.trim().isEmpty) return false;
    if (_selectedType == null) return false;
    return true;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ttc = _parseDouble(_amountTtcCtrl.text);
    if (ttc == null) return;
    final vat = _parseDouble(_vatRateCtrl.text);
    final overrides = ExpenseTicketOverrides(
      merchant: _merchantCtrl.text.trim().isEmpty
          ? null
          : _merchantCtrl.text.trim(),
      date: _date,
      amountTtc: ttc,
      vatRate: vat,
      feeTypeId: _selectedType?.remoteId,
      feeTypeCode: _selectedType?.code,
      comments: _commentsCtrl.text.trim().isEmpty
          ? null
          : _commentsCtrl.text.trim(),
    );
    await ref
        .read(expenseScanControllerProvider.notifier)
        .push(overrides);
  }

  double? _parseDouble(String raw) {
    final cleaned = raw.replaceAll(',', '.').trim();
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }
}

class _Form extends StatelessWidget {
  const _Form({
    required this.formKey,
    required this.merchantCtrl,
    required this.amountTtcCtrl,
    required this.vatRateCtrl,
    required this.commentsCtrl,
    required this.date,
    required this.onDateChanged,
    required this.selectedType,
    required this.types,
    required this.onTypeChanged,
    required this.extracted,
    required this.manualEntry,
    required this.jpegPresent,
    required this.onChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController merchantCtrl;
  final TextEditingController amountTtcCtrl;
  final TextEditingController vatRateCtrl;
  final TextEditingController commentsCtrl;
  final DateTime date;
  final ValueChanged<DateTime> onDateChanged;
  final ExpenseType? selectedType;
  final List<ExpenseType> types;
  final ValueChanged<ExpenseType> onTypeChanged;
  final ExtractedTicketDto? extracted;
  final bool manualEntry;
  final bool jpegPresent;
  final VoidCallback onChanged;

  static final _dateFmt = DateFormat('EEEE d MMMM yyyy', 'fr_FR');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppTokens.spaceLg,
          AppTokens.spaceLg,
          AppTokens.spaceLg,
          120,
        ),
        children: [
          if (extracted != null && !manualEntry)
            _OcrSummaryCard(extracted: extracted!),
          if (extracted != null && !manualEntry)
            const SizedBox(height: AppTokens.spaceLg),
          if (manualEntry)
            Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.spaceMd),
              child: Text(
                'Saisie manuelle — aucun ticket joint.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          TextFormField(
            controller: merchantCtrl,
            onChanged: (_) => onChanged(),
            decoration: const InputDecoration(
              labelText: 'Commerçant',
              prefixIcon: Icon(LucideIcons.store),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppTokens.spaceMd),
          _DateField(
            value: date,
            onChanged: onDateChanged,
            formatter: _dateFmt,
          ),
          const SizedBox(height: AppTokens.spaceMd),
          DropdownButtonFormField<ExpenseType>(
            initialValue: selectedType,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Type de frais *',
              prefixIcon: Icon(LucideIcons.tag),
              border: OutlineInputBorder(),
            ),
            items: [
              for (final t in types.where((t) => t.active))
                DropdownMenuItem(
                  value: t,
                  child: Text(
                    '${t.label} (${t.code})',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (v) {
              if (v != null) onTypeChanged(v);
            },
            validator: (v) => v == null ? 'Type obligatoire' : null,
          ),
          const SizedBox(height: AppTokens.spaceMd),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: amountTtcCtrl,
                  onChanged: (_) => onChanged(),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp('[0-9.,]'),
                    ),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Montant TTC *',
                    suffixText: '€',
                    prefixIcon: Icon(LucideIcons.euro),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Obligatoire';
                    }
                    final n = double.tryParse(
                      v.replaceAll(',', '.').trim(),
                    );
                    if (n == null || n <= 0) return 'Montant invalide';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: AppTokens.spaceMd),
              Expanded(
                child: TextFormField(
                  controller: vatRateCtrl,
                  onChanged: (_) => onChanged(),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp('[0-9.,]'),
                    ),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'TVA',
                    suffixText: '%',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.spaceMd),
          TextFormField(
            controller: commentsCtrl,
            onChanged: (_) => onChanged(),
            minLines: 2,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Commentaire',
              prefixIcon: Icon(LucideIcons.messageSquare),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppTokens.spaceLg),
          if (jpegPresent)
            Row(
              children: [
                Icon(
                  LucideIcons.paperclip,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppTokens.spaceXs),
                Expanded(
                  child: Text(
                    'Le ticket sera joint comme justificatif (.jpg) '
                    'à la note.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.value,
    required this.onChanged,
    required this.formatter,
  });
  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  final DateFormat formatter;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppTokens.radiusCardLg),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 1)),
          locale: const Locale('fr', 'FR'),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date du ticket',
          prefixIcon: Icon(LucideIcons.calendar),
          border: OutlineInputBorder(),
        ),
        child: Text(formatter.format(value)),
      ),
    );
  }
}

class _OcrSummaryCard extends StatelessWidget {
  const _OcrSummaryCard({required this.extracted});
  final ExtractedTicketDto extracted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final confidencePct = extracted.confidence == null
        ? null
        : (extracted.confidence! * 100).round();
    Color toneColor() {
      if (confidencePct == null) return scheme.surfaceContainerHighest;
      if (confidencePct >= 80) return scheme.primaryContainer;
      if (confidencePct >= 50) return scheme.secondaryContainer;
      return scheme.errorContainer;
    }

    return Container(
      padding: const EdgeInsets.all(AppTokens.spaceMd),
      decoration: BoxDecoration(
        color: toneColor(),
        borderRadius: BorderRadius.circular(AppTokens.radiusCardLg),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.sparkles, color: scheme.primary),
          const SizedBox(width: AppTokens.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OCR : suggestion appliquée',
                  style: theme.textTheme.labelLarge,
                ),
                Text(
                  confidencePct == null
                      ? 'Tous les champs restent modifiables.'
                      : 'Confiance globale : $confidencePct %. '
                          'Modifie au besoin.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
