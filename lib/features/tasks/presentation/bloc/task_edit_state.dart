part of 'task_edit_bloc.dart';

abstract class TaskEditState extends Equatable {
  const TaskEditState();

  @override
  List<Object?> get props => [];
}

class TaskEditInitial extends TaskEditState {}

class TaskEditLoaded extends TaskEditState {
  final TaskEntity? task;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskPriority priority;
  final String userId;

  const TaskEditLoaded({
    this.task,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.userId,
  });

  TaskEditLoaded copyWith({
    TaskEntity? task,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    String? userId,
  }) {
    return TaskEditLoaded(
      task: task ?? this.task,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object?> get props => [
    task,
    title,
    description,
    dueDate,
    priority,
    userId,
  ];
}

class TaskEditSaving extends TaskEditState {}

class TaskEditDeleting extends TaskEditState {}

class TaskEditSuccess extends TaskEditState {}

class TaskEditDeleted extends TaskEditState {}

class TaskEditError extends TaskEditState {
  final String message;

  const TaskEditError(this.message);

  @override
  List<Object?> get props => [message];
}
