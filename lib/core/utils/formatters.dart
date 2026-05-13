double? _parseAmount(Object? v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) {
    final s = v.trim();
    if (s.isEmpty) return null;
    return double.tryParse(s.replaceAll(',', '.'));
  }
  return null;
}

String formatMoney(Object? v, {String currency = '€', String fallback = '—'}) {
  final n = _parseAmount(v);
  if (n == null) return '$fallback $currency';
  return '${n.toStringAsFixed(2).replaceAll('.', ',')} $currency';
}

String formatPercent(Object? v, {String fallback = '—'}) {
  final n = _parseAmount(v);
  if (n == null) return '$fallback %';
  final s = n.toStringAsFixed(2);
  final trimmed = s.replaceAll(RegExp(r'\.?0+$'), '').replaceAll('.', ',');
  return '${trimmed.isEmpty ? '0' : trimmed} %';
}

String formatQty(Object? v, {String fallback = '—'}) {
  final n = _parseAmount(v);
  if (n == null) return fallback;
  final s = n.toStringAsFixed(2);
  final trimmed = s.replaceAll(RegExp(r'\.?0+$'), '').replaceAll('.', ',');
  return trimmed.isEmpty ? '0' : trimmed;
}
