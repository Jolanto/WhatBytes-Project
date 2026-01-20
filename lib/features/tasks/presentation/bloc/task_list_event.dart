part of 'task_list_bloc.dart';

abstract class TaskListEvent extends Equatable {
  const TaskListEvent();

  @override
  List<Object?> get props => [];
}

class SubscribeTasks extends TaskListEvent {
  final String userId;

  const SubscribeTasks(this.userId);

  @override
  List<Object?> get props => [userId];
}

class TasksUpdated extends TaskListEvent {
  final List<TaskEntity> tasks;

  const TasksUpdated(this.tasks);

  @override
  List<Object?> get props => [tasks];
}

class SetPriorityFilter extends TaskListEvent {
  final TaskPriority? priority;

  const SetPriorityFilter(this.priority);

  @override
  List<Object?> get props => [priority];
}

class SetStatusFilter extends TaskListEvent {
  final TaskStatusFilter? status;

  const SetStatusFilter(this.status);

  @override
  List<Object?> get props => [status];
}

class ClearFilter extends TaskListEvent {
  const ClearFilter();
}

class ToggleTaskCompletionRequested extends TaskListEvent {
  final String userId;
  final String taskId;

  const ToggleTaskCompletionRequested({
    required this.userId,
    required this.taskId,
  });

  @override
  List<Object?> get props => [userId, taskId];
}

class DeleteTaskRequested extends TaskListEvent {
  final String userId;
  final String taskId;

  const DeleteTaskRequested({required this.userId, required this.taskId});

  @override
  List<Object?> get props => [userId, taskId];
}
