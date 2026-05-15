import 'package:equatable/equatable.dart';

/// Code suggéré par le backend OCR pour le type de frais (`c_type_fees.code`).
///
/// Le backend retourne déjà une chaîne pré-validée parmi le set ci-dessous,
/// mais l'app re-valide pour mapper proprement et tolérer un éventuel
/// élargissement futur sans crash.
enum SuggestedFeeTypeCode {
  exFueVp('EX_FUE_VP'),
  exHot('EX_HOT'),
  exTolVp('EX_TOL_VP'),
  exParVp('EX_PAR_VP'),
  exSuo('EX_SUO'),
  exPos('EX_POS'),
  exCar('EX_CAR'),
  exKme('EX_KME'),
  tfLunch('TF_LUNCH'),
  tfTrip('TF_TRIP'),
  tfOther('TF_OTHER');

  const SuggestedFeeTypeCode(this.apiCode);

  /// Valeur Dolibarr de `llx_c_type_fees.code`.
  final String apiCode;

  static SuggestedFeeTypeCode? fromCode(String? code) {
    if (code == null || code.isEmpty) return null;
    for (final v in SuggestedFeeTypeCode.values) {
      if (v.apiCode == code) return v;
    }
    return null;
  }
}

/// Réponse parsée du backend `/api/extract_ticket`.
///
/// Tous les champs sont optionnels (`amountTtc` peut manquer si l'OCR
/// échoue à lire le total) ; l'UI affichera un formulaire éditable et
/// `confidence` permet de teinter la couleur de la suggestion.
final class ExtractedTicketDto extends Equatable {
  const ExtractedTicketDto({
    this.merchant,
    this.dateIso,
    this.currency,
    this.amountHt,
    this.amountVat,
    this.amountTtc,
    this.vatRate,
    this.suggestedFeeTypeCode,
    this.confidence,
    this.rawText,
  });

  factory ExtractedTicketDto.fromJson(Map<String, Object?> json) {
    String? s(String key) {
      final v = json[key];
      if (v == null || v == '' || v == 'null') return null;
      return '$v';
    }

    double? d(String key) {
      final v = json[key];
      if (v == null || v == '' || v == 'null') return null;
      if (v is num) return v.toDouble();
      return double.tryParse('$v');
    }

    DateTime? parseDate(String? raw) {
      if (raw == null || raw.isEmpty) return null;
      return DateTime.tryParse(raw);
    }

    return ExtractedTicketDto(
      merchant: s('merchant'),
      dateIso: parseDate(s('dateIso')),
      currency: s('currency'),
      amountHt: d('amountHt'),
      amountVat: d('amountVat'),
      amountTtc: d('amountTtc'),
      vatRate: d('vatRate'),
      suggestedFeeTypeCode:
          SuggestedFeeTypeCode.fromCode(s('suggestedFeeTypeCode')),
      confidence: d('confidence'),
      rawText: s('rawText'),
    );
  }

  final String? merchant;
  final DateTime? dateIso;
  final String? currency;
  final double? amountHt;
  final double? amountVat;
  final double? amountTtc;

  /// Taux TVA en pourcentage (ex. 20.0 = 20 %).
  final double? vatRate;

  final SuggestedFeeTypeCode? suggestedFeeTypeCode;

  /// Score de confiance global retourné par le modèle (0..1).
  final double? confidence;

  /// Texte brut OCR — sert à pré-remplir `comments` en fallback et à
  /// montrer un diagnostic en cas d'extraction partielle.
  final String? rawText;

  @override
  List<Object?> get props => [
        merchant,
        dateIso,
        currency,
        amountHt,
        amountVat,
        amountTtc,
        vatRate,
        suggestedFeeTypeCode,
        confidence,
        rawText,
      ];
}
