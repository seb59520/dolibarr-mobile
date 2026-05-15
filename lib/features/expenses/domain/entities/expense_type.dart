import 'package:equatable/equatable.dart';

/// Type de frais Dolibarr (`llx_c_type_fees`).
///
/// Le code (`TF_LUNCH`, `EX_HOT`, ...) est l'identifiant stable côté
/// utilisateur. `remoteId` est l'`id` numérique requis pour le POST
/// d'une ligne (`fk_c_type_fees`).
final class ExpenseType extends Equatable {
  const ExpenseType({
    required this.code,
    required this.remoteId,
    required this.label,
    required this.fetchedAt,
    this.accountancyCode,
    this.active = true,
  });

  /// Construit depuis la réponse `/setup/dictionary/expensereport_types`.
  factory ExpenseType.fromJson(
    Map<String, Object?> json, {
    DateTime? fetchedAt,
  }) {
    final id = int.tryParse('${json['id'] ?? json['rowid'] ?? ''}') ?? 0;
    final active = '${json['active'] ?? '1'}' == '1';
    return ExpenseType(
      code: '${json['code'] ?? ''}',
      remoteId: id,
      label: '${json['label'] ?? json['code'] ?? ''}',
      accountancyCode: _nullable(json['accountancy_code']),
      active: active,
      fetchedAt: fetchedAt ?? DateTime.now(),
    );
  }

  static String? _nullable(Object? v) {
    if (v == null || v == '' || v == 'null') return null;
    return '$v';
  }

  /// Code textuel stable (ex. `TF_LUNCH`).
  final String code;

  /// id numérique Dolibarr.
  final int remoteId;

  final String label;

  final String? accountancyCode;

  final bool active;

  final DateTime fetchedAt;

  @override
  List<Object?> get props => [
        code,
        remoteId,
        label,
        accountancyCode,
        active,
        fetchedAt,
      ];
}
