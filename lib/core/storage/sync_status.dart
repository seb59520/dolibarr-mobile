/// État de synchronisation d'une entité avec le serveur Dolibarr.
///
/// Persisté en base locale (Drift) sur chaque ligne d'entité (third_parties,
/// contacts, etc.) ainsi que sur les opérations en attente.
enum SyncStatus {
  /// Aligné avec le serveur (tms local == tms serveur).
  synced,

  /// Création locale jamais poussée.
  pendingCreate,

  /// Modification locale jamais poussée.
  pendingUpdate,

  /// Suppression locale jamais poussée.
  pendingDelete,

  /// Conflit détecté (tms serveur > tms attendu) : nécessite résolution UI.
  conflict;
}

/// État du cycle de vie d'une opération en attente dans l'Outbox.
enum PendingOpStatus {
  /// En file d'attente, prête à être tentée.
  queued,

  /// En cours d'exécution réseau.
  inProgress,

  /// Échec transitoire — sera retentée selon `nextRetryAt`.
  failed,

  /// Conflit détecté — bloque la file pour cette entité.
  conflict,

  /// Échec définitif après épuisement des retries.
  dead;
}

/// Type d'opération côté Outbox.
enum PendingOpType { create, update, delete }

/// Type d'entité ciblée par une opération Outbox.
enum PendingOpEntity { thirdparty, contact }
