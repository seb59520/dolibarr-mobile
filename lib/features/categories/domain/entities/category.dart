import 'package:equatable/equatable.dart';

/// Type d'une catégorie côté Dolibarr — sert à scoper les listes
/// (un client n'a que des catégories `customer`, etc.).
enum CategoryType {
  customer,
  supplier,
  contact;

  /// Représentation texte attendue par l'API Dolibarr.
  String get apiValue => name;

  static CategoryType fromApi(String raw) {
    return CategoryType.values.firstWhere(
      (t) => t.apiValue == raw,
      orElse: () => CategoryType.customer,
    );
  }
}

/// Catégorie Dolibarr. Lecture seule (pas de CRUD côté mobile).
final class Category extends Equatable {
  const Category({
    required this.remoteId,
    required this.label,
    required this.type,
    this.parentRemoteId,
    this.color,
  });

  final int remoteId;
  final String label;
  final CategoryType type;
  final int? parentRemoteId;
  final String? color;

  @override
  List<Object?> get props => [remoteId, label, type, parentRemoteId, color];
}
