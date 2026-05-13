import 'package:equatable/equatable.dart';

/// Agrégat « facturé / perçu » sur une année calendaire.
final class YearlyStat extends Equatable {
  const YearlyStat({
    required this.year,
    this.factureHt = 0,
    this.factureTtc = 0,
    this.percu = 0,
  });

  final int year;
  final double factureHt;
  final double factureTtc;
  final double percu;

  @override
  List<Object?> get props => [year, factureHt, factureTtc, percu];
}
