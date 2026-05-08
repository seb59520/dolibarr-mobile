import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/features/proposals/domain/entities/proposal_line.dart';
import 'package:flutter/material.dart';

/// Dialog modal de saisie d'une ligne de devis (création OU édition).
///
/// Retourne la `ProposalLine` modifiée, ou `null` si annulée. Le caller
/// est responsable d'appeler `createLocalLine` / `updateLocalLine`
/// sur le repository.
class ProposalLineEditDialog extends StatefulWidget {
  const ProposalLineEditDialog({
    required this.proposalLocalId,
    this.proposalRemoteId,
    this.existing,
    super.key,
  });

  final int proposalLocalId;
  final int? proposalRemoteId;
  final ProposalLine? existing;

  static Future<ProposalLine?> show(
    BuildContext context, {
    required int proposalLocalId,
    int? proposalRemoteId,
    ProposalLine? existing,
  }) {
    return showDialog<ProposalLine>(
      context: context,
      builder: (_) => ProposalLineEditDialog(
        proposalLocalId: proposalLocalId,
        proposalRemoteId: proposalRemoteId,
        existing: existing,
      ),
    );
  }

  @override
  State<ProposalLineEditDialog> createState() =>
      _ProposalLineEditDialogState();
}

class _ProposalLineEditDialogState extends State<ProposalLineEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _labelCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '1');
  final _subpriceCtrl = TextEditingController();
  final _tvaCtrl = TextEditingController(text: '20');
  final _remiseCtrl = TextEditingController();

  ProposalLineProductType _type = ProposalLineProductType.service;

  @override
  void initState() {
    super.initState();
    final l = widget.existing;
    if (l != null) {
      _labelCtrl.text = l.label ?? '';
      _descCtrl.text = l.description ?? '';
      _qtyCtrl.text = l.qty;
      _subpriceCtrl.text = l.subprice ?? '';
      _tvaCtrl.text = l.tvaTx ?? '';
      _remiseCtrl.text = l.remisePercent ?? '';
      _type = l.productType;
    }
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _descCtrl.dispose();
    _qtyCtrl.dispose();
    _subpriceCtrl.dispose();
    _tvaCtrl.dispose();
    _remiseCtrl.dispose();
    super.dispose();
  }

  /// Calcul live des totaux (HT, TVA, TTC) pour preview.
  ({double? ht, double? tva, double? ttc}) _computeTotals() {
    final qty = double.tryParse(_qtyCtrl.text.replaceAll(',', '.'));
    final pu = double.tryParse(_subpriceCtrl.text.replaceAll(',', '.'));
    if (qty == null || pu == null) return (ht: null, tva: null, ttc: null);
    final remise =
        double.tryParse(_remiseCtrl.text.replaceAll(',', '.')) ?? 0;
    final tvaPct = double.tryParse(_tvaCtrl.text.replaceAll(',', '.')) ?? 0;
    final ht = qty * pu * (1 - remise / 100);
    final tva = ht * tvaPct / 100;
    final ttc = ht + tva;
    return (ht: ht, tva: tva, ttc: ttc);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final base = widget.existing;
    final totals = _computeTotals();

    String? notEmpty(String s) => s.trim().isEmpty ? null : s.trim();

    final entity = ProposalLine(
      localId: base?.localId ?? 0,
      remoteId: base?.remoteId,
      proposalLocal: widget.proposalLocalId,
      proposalRemote: widget.proposalRemoteId ?? base?.proposalRemote,
      fkProduct: base?.fkProduct,
      label: notEmpty(_labelCtrl.text),
      description: notEmpty(_descCtrl.text),
      productType: _type,
      qty: _qtyCtrl.text.trim().isEmpty ? '1' : _qtyCtrl.text.trim(),
      subprice: notEmpty(_subpriceCtrl.text),
      tvaTx: notEmpty(_tvaCtrl.text),
      remisePercent: notEmpty(_remiseCtrl.text),
      totalHt: totals.ht?.toStringAsFixed(2),
      totalTva: totals.tva?.toStringAsFixed(2),
      totalTtc: totals.ttc?.toStringAsFixed(2),
      rang: base?.rang ?? 0,
      tms: base?.tms,
      localUpdatedAt: DateTime.now(),
      syncStatus: base?.syncStatus ?? SyncStatus.synced,
    );
    Navigator.of(context).pop(entity);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(widget.existing == null ? 'Nouvelle ligne' : 'Modifier'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<ProposalLineProductType>(
                segments: const [
                  ButtonSegment(
                    value: ProposalLineProductType.service,
                    label: Text('Service'),
                  ),
                  ButtonSegment(
                    value: ProposalLineProductType.product,
                    label: Text('Produit'),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (s) =>
                    setState(() => _type = s.first),
              ),
              const SizedBox(height: AppTokens.spaceMd),
              TextFormField(
                controller: _labelCtrl,
                decoration: const InputDecoration(labelText: 'Intitulé'),
              ),
              const SizedBox(height: AppTokens.spaceMd),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              const SizedBox(height: AppTokens.spaceMd),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _qtyCtrl,
                      decoration: const InputDecoration(labelText: 'Qté'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTokens.spaceXs),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _subpriceCtrl,
                      decoration: const InputDecoration(
                        labelText: 'PU HT',
                        suffixText: '€',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.spaceMd),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tvaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'TVA',
                        suffixText: '%',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: AppTokens.spaceXs),
                  Expanded(
                    child: TextFormField(
                      controller: _remiseCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Remise',
                        suffixText: '%',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.spaceMd),
              Builder(
                builder: (_) {
                  final totals = _computeTotals();
                  if (totals.ht == null) {
                    return const SizedBox.shrink();
                  }
                  return Container(
                    padding: const EdgeInsets.all(AppTokens.spaceXs),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(
                        AppTokens.radiusChip,
                      ),
                    ),
                    child: Column(
                      children: [
                        _totalRow('HT', totals.ht!),
                        _totalRow('TVA', totals.tva ?? 0),
                        _totalRow('TTC', totals.ttc ?? 0, bold: true),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.existing == null ? 'Ajouter' : 'Enregistrer'),
        ),
      ],
    );
  }

  Widget _totalRow(String label, double value, {bool bold = false}) {
    final style = bold ? const TextStyle(fontWeight: FontWeight.w700) : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text('${value.toStringAsFixed(2)} €', style: style),
        ],
      ),
    );
  }
}
