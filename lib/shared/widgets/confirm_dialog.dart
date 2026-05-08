import 'package:flutter/material.dart';

/// Helpers pour afficher un dialog de confirmation standard.
///
/// Retourne `true` si l'utilisateur a confirmé, `false` ou `null` sinon.
abstract final class ConfirmDialog {
  /// Dialogue de confirmation neutre (CTA primaire bleu).
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirmer',
    String cancelLabel = 'Annuler',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  /// Dialogue de confirmation destructif (CTA primaire rouge) pour
  /// suppressions, déconnexions, écrasement de brouillon.
  static Future<bool?> showDestructive(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Supprimer',
    String cancelLabel = 'Annuler',
  }) {
    final scheme = Theme.of(context).colorScheme;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }
}
