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
    // Dolibarr expose la date sous deux formes selon l'endpoint :
    //   - timestamp Unix (entier) — ex. /invoices listing
    //   - chaîne SQL `YYYY-MM-DD HH:MM:SS` — ex. /invoices/{id}/payments
    // On gère les deux ; sinon ISO-8601 ; sinon null.
    DateTime? d(String key) {
      final raw = json[key];
      if (raw == null || raw == '' || raw == 'null') return null;
      final str = '$raw';
      final n = int.tryParse(str);
      if (n != null) {
        return DateTime.fromMillisecondsSinceEpoch(n * 1000);
      }
      return DateTime.tryParse(str.replaceFirst(' ', 'T'));
    }

    String? s(String key) {
      final v = json[key];
      if (v == null || v == '' || v == 'null') return null;
      return '$v';
    }

    // Le payload /invoices/{id}/payments ne porte pas `id` :
    // on retombe sur fk_bank_line (stable par paiement) puis `ref`.
    int resolveRemoteId() {
      final raw = json['id']
          ?? json['rowid']
          ?? json['fk_bank_line']
          ?? json['ref'];
      final asInt = int.tryParse('${raw ?? ''}');
      if (asInt != null && asInt > 0) return asInt;
      // Dernier recours : hash stable construit à partir des
      // attributs identifiants pour ne pas collapser plusieurs
      // paiements sur remoteId=0.
      final fingerprint = '${json['ref'] ?? ''}|${json['date'] ?? ''}'
          '|${json['amount'] ?? ''}|${json['fk_bank_line'] ?? ''}';
      return fingerprint.hashCode & 0x7FFFFFFF;
    }

    return InvoicePayment(
      remoteId: resolveRemoteId(),
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
