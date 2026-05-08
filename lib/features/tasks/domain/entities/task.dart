import 'package:dolibarr_mobile/core/storage/sync_status.dart';
import 'package:equatable/equatable.dart';

/// Statut Dolibarr d'une tâche projet.
enum TaskStatus {
  inProgress,
  closed;

  static TaskStatus fromInt(int v) =>
      v == 1 ? TaskStatus.closed : TaskStatus.inProgress;

  int get apiValue => switch (this) {
        TaskStatus.inProgress => 0,
        TaskStatus.closed => 1,
      };
}

/// Tâche d'un projet (`llx_projet_task`).
///
/// Rattachement dual au projet parent (cascade Outbox 2ᵉ niveau) :
/// - `projectRemote` : `fk_projet` côté Dolibarr ;
/// - `projectLocal` : PK locale du projet parent quand il est encore
///   en `pendingCreate`.
final class Task extends Equatable {
  const Task({
    required this.localId,
    required this.localUpdatedAt,
    this.remoteId,
    this.projectRemote,
    this.projectLocal,
    this.ref,
    this.label = '',
    this.description,
    this.status = TaskStatus.inProgress,
    this.progress = 0,
    this.plannedHours,
    this.fkUser,
    this.dateStart,
    this.dateEnd,
    this.extrafields = const {},
    this.tms,
    this.syncStatus = SyncStatus.synced,
  });

  final int localId;
  final int? remoteId;

  final int? projectRemote;
  final int? projectLocal;

  final String? ref;
  final String label;
  final String? description;

  final TaskStatus status;
  final int progress;

  final String? plannedHours;
  final int? fkUser;

  final DateTime? dateStart;
  final DateTime? dateEnd;

  final Map<String, Object?> extrafields;

  final DateTime? tms;
  final DateTime localUpdatedAt;
  final SyncStatus syncStatus;

  bool get isClosed => status == TaskStatus.closed;

  String get displayLabel =>
      label.trim().isEmpty ? '(sans intitulé)' : label;

  Task copyWithSync(SyncStatus next) => Task(
        localId: localId,
        remoteId: remoteId,
        projectRemote: projectRemote,
        projectLocal: projectLocal,
        ref: ref,
        label: label,
        description: description,
        status: status,
        progress: progress,
        plannedHours: plannedHours,
        fkUser: fkUser,
        dateStart: dateStart,
        dateEnd: dateEnd,
        extrafields: extrafields,
        tms: tms,
        localUpdatedAt: localUpdatedAt,
        syncStatus: next,
      );

  @override
  List<Object?> get props => [
        localId,
        remoteId,
        projectRemote,
        projectLocal,
        ref,
        label,
        description,
        status,
        progress,
        plannedHours,
        fkUser,
        dateStart,
        dateEnd,
        extrafields,
        tms,
        localUpdatedAt,
        syncStatus,
      ];
}
