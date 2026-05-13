import 'package:equatable/equatable.dart';

/// Agrégat « facturé / perçu » sur un mois calendaire.
final class MonthlyStat extends Equatable {
  const MonthlyStat({
    required this.year,
    required this.month,
    this.factureHt = 0,
    this.factureTtc = 0,
    this.percu = 0,
  });

  final int year;
  final int month;
  final double factureHt;
  final double factureTtc;
  final double percu;

  /// Premier jour du mois (utile pour formatage et tri).
  DateTime get firstDay => DateTime(year, month);

  MonthlyStat copyWith({
    double? factureHt,
    double? factureTtc,
    double? percu,
  }) =>
      MonthlyStat(
        year: year,
        month: month,
        factureHt: factureHt ?? this.factureHt,
        factureTtc: factureTtc ?? this.factureTtc,
        percu: percu ?? this.percu,
      );

  @override
  List<Object?> get props => [year, month, factureHt, factureTtc, percu];
}
