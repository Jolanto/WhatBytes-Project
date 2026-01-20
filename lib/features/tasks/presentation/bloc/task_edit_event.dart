part of 'task_edit_bloc.dart';

abstract class TaskEditEvent extends Equatable {
  const TaskEditEvent();

  @override
  List<Object?> get props => [];
}

class LoadTask extends TaskEditEvent {
  final String userId;
  final TaskEntity? task;

  const LoadTask({required this.userId, this.task});

  @override
  List<Object?> get props => [userId, task];
}

class TitleChanged extends TaskEditEvent {
  final String title;

  const TitleChanged(this.title);

  @override
  List<Object?> get props => [title];
}

class DescriptionChanged extends TaskEditEvent {
  final String description;

  const DescriptionChanged(this.description);

  @override
  List<Object?> get props => [description];
}

class DueDateChanged extends TaskEditEvent {
  final DateTime dueDate;

  const DueDateChanged(this.dueDate);

  @override
  List<Object?> get props => [dueDate];
}

class PriorityChanged extends TaskEditEvent {
  final TaskPriority priority;

  const PriorityChanged(this.priority);

  @override
  List<Object?> get props => [priority];
}

class SaveTask extends TaskEditEvent {
  const SaveTask();
}

class DeleteTaskRequested extends TaskEditEvent {
  const DeleteTaskRequested();
}
