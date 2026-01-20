part of 'task_list_bloc.dart';

abstract class TaskListState extends Equatable {
  const TaskListState();

  @override
  List<Object?> get props => [];
}

class TaskListInitial extends TaskListState {}

class TaskListLoading extends TaskListState {}

class TasksLoaded extends TaskListState {
  final List<TaskEntity> allTasks;
  final List<TaskEntity> filteredTasks;
  final TaskPriority? priorityFilter;
  final TaskStatusFilter? statusFilter;

  const TasksLoaded({
    required this.allTasks,
    required this.filteredTasks,
    this.priorityFilter,
    this.statusFilter,
  });

  @override
  List<Object?> get props => [
    allTasks,
    filteredTasks,
    priorityFilter,
    statusFilter,
  ];
}

class TaskListError extends TaskListState {
  final String message;

  const TaskListError(this.message);

  @override
  List<Object?> get props => [message];
}
