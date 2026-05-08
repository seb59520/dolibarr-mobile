import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/features/extrafields/domain/entities/extrafield_definition.dart';
import 'package:flutter/material.dart';

/// Formulaire dynamique rendu à partir d'une liste d'`ExtrafieldDefinition`.
///
/// Types pris en charge : varchar, text, integer, double, date, boolean,
/// select. Les types `unknown` sont rendus en TextField texte simple
/// pour ne pas perdre la saisie utilisateur.
///
/// Stocke ses valeurs en interne (pour les controllers de texte) et émet
/// le snapshot complet via `onChanged` à chaque modification.
class ExtrafieldsForm extends StatefulWidget {
  const ExtrafieldsForm({
    required this.definitions,
    required this.initialValues,
    required this.onChanged,
    super.key,
  });

  final List<ExtrafieldDefinition> definitions;
  final Map<String, Object?> initialValues;
  final ValueChanged<Map<String, Object?>> onChanged;

  @override
  State<ExtrafieldsForm> createState() => _ExtrafieldsFormState();
}

class _ExtrafieldsFormState extends State<ExtrafieldsForm> {
  late final Map<String, Object?> _values;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _values = Map.of(widget.initialValues);
    for (final d in widget.definitions) {
      if (_isText(d.type)) {
        _controllers[d.fieldName] = TextEditingController(
          text: _values[d.fieldName]?.toString() ?? '',
        );
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  bool _isText(ExtrafieldType t) =>
      t == ExtrafieldType.varchar ||
      t == ExtrafieldType.text ||
      t == ExtrafieldType.integer ||
      t == ExtrafieldType.double ||
      t == ExtrafieldType.unknown;

  void _set(String name, Object? value) {
    setState(() => _values[name] = value);
    widget.onChanged(Map.of(_values));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.definitions.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final d in widget.definitions) ...[
          _fieldFor(context, d),
          const SizedBox(height: AppTokens.spaceMd),
        ],
      ],
    );
  }

  Widget _fieldFor(BuildContext context, ExtrafieldDefinition d) {
    final label = d.required ? '${d.label} *' : d.label;
    return switch (d.type) {
      ExtrafieldType.boolean => SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(label),
          value: _values[d.fieldName] as bool? ?? false,
          onChanged: (v) => _set(d.fieldName, v),
        ),
      ExtrafieldType.date ||
      ExtrafieldType.datetime =>
        _DateField(
          label: label,
          value: _values[d.fieldName] as DateTime?,
          onChanged: (v) => _set(d.fieldName, v),
          withTime: d.type == ExtrafieldType.datetime,
        ),
      ExtrafieldType.select => _SelectField(
          label: label,
          options: d.options,
          value: _values[d.fieldName]?.toString(),
          required: d.required,
          onChanged: (v) => _set(d.fieldName, v),
        ),
      ExtrafieldType.text => TextFormField(
          controller: _controllers[d.fieldName],
          decoration: InputDecoration(labelText: label),
          maxLines: 4,
          validator: (v) =>
              d.required && (v?.isEmpty ?? true) ? 'Champ requis' : null,
          onChanged: (v) => _set(d.fieldName, v),
        ),
      ExtrafieldType.integer => TextFormField(
          controller: _controllers[d.fieldName],
          decoration: InputDecoration(labelText: label),
          keyboardType: TextInputType.number,
          validator: (v) => _validateInt(v, d.required),
          onChanged: (v) => _set(d.fieldName, int.tryParse(v)),
        ),
      ExtrafieldType.double => TextFormField(
          controller: _controllers[d.fieldName],
          decoration: InputDecoration(labelText: label),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) => _validateDouble(v, d.required),
          onChanged: (v) =>
              _set(d.fieldName, double.tryParse(v.replaceAll(',', '.'))),
        ),
      ExtrafieldType.varchar || ExtrafieldType.unknown => TextFormField(
          controller: _controllers[d.fieldName],
          decoration: InputDecoration(labelText: label),
          validator: (v) =>
              d.required && (v?.isEmpty ?? true) ? 'Champ requis' : null,
          onChanged: (v) => _set(d.fieldName, v),
        ),
    };
  }

  String? _validateInt(String? v, bool required) {
    if (v == null || v.isEmpty) {
      return required ? 'Champ requis' : null;
    }
    return int.tryParse(v) == null ? 'Entier attendu' : null;
  }

  String? _validateDouble(String? v, bool required) {
    if (v == null || v.isEmpty) {
      return required ? 'Champ requis' : null;
    }
    return double.tryParse(v.replaceAll(',', '.')) == null
        ? 'Nombre attendu'
        : null;
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.withTime = false,
  });
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final bool withTime;

  Future<void> _pick(BuildContext context) async {
    final initial = value ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    if (!withTime) {
      onChanged(date);
      return;
    }
    if (!context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) {
      onChanged(date);
    } else {
      onChanged(
        DateTime(date.year, date.month, date.day, time.hour, time.minute),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = value == null
        ? 'Choisir…'
        : withTime
            ? value!.toLocal().toString().substring(0, 16)
            : value!.toLocal().toString().substring(0, 10);
    return InkWell(
      onTap: () => _pick(context),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(fmt),
      ),
    );
  }
}

class _SelectField extends StatelessWidget {
  const _SelectField({
    required this.label,
    required this.options,
    required this.value,
    required this.required,
    required this.onChanged,
  });
  final String label;
  final Map<String, String> options;
  final String? value;
  final bool required;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: options.containsKey(value) ? value : null,
      decoration: InputDecoration(labelText: label),
      validator: (v) =>
          required && (v == null || v.isEmpty) ? 'Champ requis' : null,
      items: [
        for (final entry in options.entries)
          DropdownMenuItem(value: entry.key, child: Text(entry.value)),
      ],
      onChanged: onChanged,
    );
  }
}
