import 'dart:convert';

import 'package:equatable/equatable.dart';

/// Type d'un extrafield Dolibarr — détermine le widget de saisie rendu
/// par `ExtrafieldsForm`.
enum ExtrafieldType {
  varchar,
  text,
  integer,
  double,
  date,
  datetime,
  boolean,
  select,
  unknown;

  static ExtrafieldType fromApi(String raw) {
    final v = raw.toLowerCase();
    if (v == 'varchar' || v == 'string') return ExtrafieldType.varchar;
    if (v == 'text' || v == 'html') return ExtrafieldType.text;
    if (v == 'int' || v == 'integer') return ExtrafieldType.integer;
    if (v == 'double' || v == 'float' || v == 'price') {
      return ExtrafieldType.double;
    }
    if (v == 'date') return ExtrafieldType.date;
    if (v == 'datetime') return ExtrafieldType.datetime;
    if (v == 'boolean' || v == 'checkbox') return ExtrafieldType.boolean;
    if (v == 'select' || v == 'sellist') return ExtrafieldType.select;
    return ExtrafieldType.unknown;
  }
}

/// Définition d'un champ personnalisé Dolibarr.
final class ExtrafieldDefinition extends Equatable {
  const ExtrafieldDefinition({
    required this.entityType,
    required this.fieldName,
    required this.label,
    required this.type,
    this.required = false,
    this.options = const {},
    this.position = 0,
  });

  /// `thirdparty`, `socpeople` (= contact), etc.
  final String entityType;

  /// Nom technique côté API (`options_xxx`).
  final String fieldName;

  /// Libellé affiché à l'utilisateur.
  final String label;

  final ExtrafieldType type;
  final bool required;

  /// Pour les champs `select` : map `value -> label`.
  final Map<String, String> options;

  final int position;

  /// Décode le champ `options` brut (souvent JSON ou tableau PHP serialisé)
  /// en map. Best-effort : retourne map vide si format inconnu.
  static Map<String, String> decodeOptions(Object? raw) {
    if (raw is Map) {
      return raw.map((k, v) => MapEntry('$k', '$v'));
    }
    if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          return decoded.map((k, v) => MapEntry('$k', '$v'));
        }
      } catch (_) {
        // Ignoré : format PHP serialisé non géré pour le MVP.
      }
    }
    return const {};
  }

  @override
  List<Object?> get props => [
        entityType,
        fieldName,
        label,
        type,
        required,
        options,
        position,
      ];
}
