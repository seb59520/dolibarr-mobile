import 'package:equatable/equatable.dart';

/// Type Dolibarr d'un produit (`type` côté `llx_product`).
enum ProductType {
  product,
  service;

  static ProductType fromInt(int v) =>
      v == 1 ? ProductType.service : ProductType.product;

  int get apiValue => switch (this) {
        ProductType.product => 0,
        ProductType.service => 1,
      };
}

/// Produit ou service du catalogue Dolibarr. Lecture seule côté mobile :
/// sert à pré-remplir les lignes de devis et de facture (label,
/// description, prix, TVA).
final class Product extends Equatable {
  const Product({
    required this.remoteId,
    required this.ref,
    required this.label,
    this.description,
    this.type = ProductType.service,
    this.price,
    this.tvaTx,
    this.onSell = true,
    this.onBuy = false,
  });

  final int remoteId;
  final String ref;
  final String label;
  final String? description;
  final ProductType type;
  final String? price;
  final String? tvaTx;
  final bool onSell;
  final bool onBuy;

  String get displayLabel => label.trim().isEmpty ? ref : label;

  @override
  List<Object?> get props => [
        remoteId,
        ref,
        label,
        description,
        type,
        price,
        tvaTx,
        onSell,
        onBuy,
      ];
}
