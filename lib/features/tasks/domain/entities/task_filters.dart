import 'package:dolibarr_mobile/features/tasks/domain/entities/task.dart';
import 'package:equatable/equatable.dart';

final class TaskFilters extends Equatable {
  const TaskFilters({
    this.search = '',
    this.statuses = const {TaskStatus.inProgress},
    this.projectRemoteId,
    this.mineOnly = false,
  });

  final String search;
  final Set<TaskStatus> statuses;
  final int? projectRemoteId;
  final bool mineOnly;

  TaskFilters copyWith({
    String? search,
    Set<TaskStatus>? statuses,
    int? projectRemoteId,
    bool clearProject = false,
    bool? mineOnly,
  }) =>
      TaskFilters(
        search: search ?? this.search,
        statuses: statuses ?? this.statuses,
        projectRemoteId: clearProject
            ? null
            : (projectRemoteId ?? this.projectRemoteId),
        mineOnly: mineOnly ?? this.mineOnly,
      );

  @override
  List<Object?> get props => [search, statuses, projectRemoteId, mineOnly];
}
