import 'package:equatable/equatable.dart';

/// Paiement d'une facture (lecture). Pas de cache local pour le MVP :
/// les paiements sont rechargés à chaque ouverture du détail facture
/// (online required).
final class InvoicePayment extends Equatable {
  const InvoicePayment({
    required this.remoteId,
    this.date,
    this.amount,
    this.type,
    this.num,
    this.ref,
  });

  factory InvoicePayment.fromJson(Map<String, Object?> json) {
    DateTime? d(String key) {
      final raw = json[key];
      if (raw == null) return null;
      final n = int.tryParse('$raw');
      if (n == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(n * 1000);
    }

    String? s(String key) {
      final v = json[key];
      if (v == null || v == '' || v == 'null') return null;
      return '$v';
    }

    return InvoicePayment(
      remoteId: int.tryParse('${json['id'] ?? json['rowid'] ?? 0}') ?? 0,
      date: d('date') ?? d('datep'),
      amount: s('amount') ?? s('amount_ttc'),
      type: s('type_code') ?? s('type'),
      num: s('num_payment') ?? s('num'),
      ref: s('ref'),
    );
  }

  final int remoteId;
  final DateTime? date;
  final String? amount;
  final String? type;
  final String? num;
  final String? ref;

  @override
  List<Object?> get props => [remoteId, date, amount, type, num, ref];
}
