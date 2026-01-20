import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gig_task_manager/features/tasks/domain/entities/task_entity.dart';
import 'package:gig_task_manager/features/tasks/domain/usecases/create_task.dart';
import 'package:gig_task_manager/features/tasks/domain/usecases/update_task.dart';
import 'package:gig_task_manager/features/tasks/domain/usecases/delete_task.dart';

part 'task_edit_event.dart';
part 'task_edit_state.dart';

class TaskEditBloc extends Bloc<TaskEditEvent, TaskEditState> {
  final CreateTask createTask;
  final UpdateTask updateTask;
  final DeleteTask deleteTask;

  TaskEditBloc({
    required this.createTask,
    required this.updateTask,
    required this.deleteTask,
  }) : super(TaskEditInitial()) {
    on<LoadTask>(_onLoadTask);
    on<TitleChanged>(_onTitleChanged);
    on<DescriptionChanged>(_onDescriptionChanged);
    on<DueDateChanged>(_onDueDateChanged);
    on<PriorityChanged>(_onPriorityChanged);
    on<SaveTask>(_onSaveTask);
    on<DeleteTaskRequested>(_onDeleteTaskRequested);
  }

  void _onLoadTask(LoadTask event, Emitter<TaskEditState> emit) {
    if (event.task != null) {
      emit(
        TaskEditLoaded(
          task: event.task!,
          title: event.task!.title,
          description: event.task!.description,
          dueDate: event.task!.dueDate,
          priority: event.task!.priority,
          userId: event.userId,
        ),
      );
    } else {
      emit(
        TaskEditLoaded(
          task: null,
          title: '',
          description: '',
          dueDate: DateTime.now(),
          priority: TaskPriority.medium,
          userId: event.userId,
        ),
      );
    }
  }

  void _onTitleChanged(TitleChanged event, Emitter<TaskEditState> emit) {
    if (state is TaskEditLoaded) {
      final currentState = state as TaskEditLoaded;
      emit(currentState.copyWith(title: event.title));
    }
  }

  void _onDescriptionChanged(
    DescriptionChanged event,
    Emitter<TaskEditState> emit,
  ) {
    if (state is TaskEditLoaded) {
      final currentState = state as TaskEditLoaded;
      emit(currentState.copyWith(description: event.description));
    }
  }

  void _onDueDateChanged(DueDateChanged event, Emitter<TaskEditState> emit) {
    if (state is TaskEditLoaded) {
      final currentState = state as TaskEditLoaded;
      emit(currentState.copyWith(dueDate: event.dueDate));
    }
  }

  void _onPriorityChanged(PriorityChanged event, Emitter<TaskEditState> emit) {
    if (state is TaskEditLoaded) {
      final currentState = state as TaskEditLoaded;
      emit(currentState.copyWith(priority: event.priority));
    }
  }

  void _onSaveTask(SaveTask event, Emitter<TaskEditState> emit) async {
    if (state is TaskEditLoaded) {
      final currentState = state as TaskEditLoaded;

      if (currentState.title.trim().isEmpty) {
        emit(TaskEditError('Title cannot be empty'));
        return;
      }

      emit(TaskEditSaving());

      if (currentState.task == null) {
        // Create new task
        final result = await createTask(
          CreateTaskParams(
            userId: currentState.userId,
            title: currentState.title,
            description: currentState.description,
            dueDate: currentState.dueDate,
            priority: currentState.priority,
          ),
        );

        result.fold(
          (failure) => emit(TaskEditError(failure.toString())),
          (_) => emit(TaskEditSuccess()),
        );
      } else {
        // Update existing task
        final updatedTask = currentState.task!.copyWith(
          title: currentState.title,
          description: currentState.description,
          dueDate: currentState.dueDate,
          priority: currentState.priority,
        );

        final result = await updateTask(
          UpdateTaskParams(userId: currentState.userId, task: updatedTask),
        );

        result.fold(
          (failure) => emit(TaskEditError(failure.toString())),
          (_) => emit(TaskEditSuccess()),
        );
      }
    }
  }

  void _onDeleteTaskRequested(
    DeleteTaskRequested event,
    Emitter<TaskEditState> emit,
  ) async {
    if (state is TaskEditLoaded) {
      final currentState = state as TaskEditLoaded;

      if (currentState.task == null) {
        return;
      }

      emit(TaskEditDeleting());

      final result = await deleteTask(
        DeleteTaskParams(
          userId: currentState.userId,
          taskId: currentState.task!.id,
        ),
      );

      result.fold(
        (failure) => emit(TaskEditError(failure.toString())),
        (_) => emit(TaskEditDeleted()),
      );
    }
  }
}
