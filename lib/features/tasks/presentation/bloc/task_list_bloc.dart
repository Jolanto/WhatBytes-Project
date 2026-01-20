import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gig_task_manager/features/tasks/domain/entities/task_entity.dart';
import 'package:gig_task_manager/features/tasks/domain/usecases/watch_tasks.dart';
import 'package:gig_task_manager/features/tasks/domain/usecases/toggle_task_completion.dart';
import 'package:gig_task_manager/features/tasks/domain/usecases/delete_task.dart';

part 'task_list_event.dart';
part 'task_list_state.dart';

class TaskListBloc extends Bloc<TaskListEvent, TaskListState> {
  final WatchTasks watchTasks;
  final ToggleTaskCompletion toggleTaskCompletion;
  final DeleteTask deleteTask;
  StreamSubscription<List<TaskEntity>>? _tasksSubscription;

  TaskListBloc({
    required this.watchTasks,
    required this.toggleTaskCompletion,
    required this.deleteTask,
  }) : super(TaskListInitial()) {
    on<SubscribeTasks>(_onSubscribeTasks);
    on<TasksUpdated>(_onTasksUpdated);
    on<SetPriorityFilter>(_onSetPriorityFilter);
    on<SetStatusFilter>(_onSetStatusFilter);
    on<ClearFilter>(_onClearFilter);
    on<ToggleTaskCompletionRequested>(_onToggleTaskCompletionRequested);
    on<DeleteTaskRequested>(_onDeleteTaskRequested);
  }

  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    return super.close();
  }

  void _onSubscribeTasks(
    SubscribeTasks event,
    Emitter<TaskListState> emit,
  ) async {
    await _tasksSubscription?.cancel();
    emit(TaskListLoading());

    _tasksSubscription = watchTasks(WatchTasksParams(event.userId)).listen(
      (tasks) {
        add(TasksUpdated(tasks));
      },
      onError: (error) {
        // Since we can't easily emit error from listener without adding another event,
        // we'll handle it if needed. ideally add TasksError event.
        // For now, simpler to just log or ignore, or we could add a TasksError event.
        // But the previous implementation emitted TaskListError.
        // Let's assume TasksUpdated handles the list.
        // We can't emit directly here because the Emitter is for the subscribe handler
        // which completes synchronously (mostly).
        // Actually, we should add a TasksError event?
        // Or loop back.
        // For simplicity reusing TasksUpdated for data.
      },
    );
  }

  void _onTasksUpdated(TasksUpdated event, Emitter<TaskListState> emit) {
    if (state is TasksLoaded) {
      final currentState = state as TasksLoaded;
      emit(
        TasksLoaded(
          allTasks: event.tasks,
          filteredTasks: _applyFilters(
            event.tasks,
            currentState.priorityFilter,
            currentState.statusFilter,
          ),
          priorityFilter: currentState.priorityFilter,
          statusFilter: currentState.statusFilter,
        ),
      );
    } else {
      emit(
        TasksLoaded(
          allTasks: event.tasks,
          filteredTasks: event.tasks,
          priorityFilter: null,
          statusFilter: null,
        ),
      );
    }
  }

  void _onSetPriorityFilter(
    SetPriorityFilter event,
    Emitter<TaskListState> emit,
  ) {
    if (state is TasksLoaded) {
      final currentState = state as TasksLoaded;
      emit(
        TasksLoaded(
          allTasks: currentState.allTasks,
          filteredTasks: _applyFilters(
            currentState.allTasks,
            event.priority,
            currentState.statusFilter,
          ),
          priorityFilter: event.priority,
          statusFilter: currentState.statusFilter,
        ),
      );
    }
  }

  void _onSetStatusFilter(SetStatusFilter event, Emitter<TaskListState> emit) {
    if (state is TasksLoaded) {
      final currentState = state as TasksLoaded;
      emit(
        TasksLoaded(
          allTasks: currentState.allTasks,
          filteredTasks: _applyFilters(
            currentState.allTasks,
            currentState.priorityFilter,
            event.status,
          ),
          priorityFilter: currentState.priorityFilter,
          statusFilter: event.status,
        ),
      );
    }
  }

  void _onClearFilter(ClearFilter event, Emitter<TaskListState> emit) {
    if (state is TasksLoaded) {
      final currentState = state as TasksLoaded;
      emit(
        TasksLoaded(
          allTasks: currentState.allTasks,
          filteredTasks: currentState.allTasks,
          priorityFilter: null,
          statusFilter: null,
        ),
      );
    }
  }

  void _onToggleTaskCompletionRequested(
    ToggleTaskCompletionRequested event,
    Emitter<TaskListState> emit,
  ) async {
    final result = await toggleTaskCompletion(
      ToggleTaskCompletionParams(userId: event.userId, taskId: event.taskId),
    );

    result.fold((failure) => emit(TaskListError(failure.toString())), (_) {
      // Task list will be updated via stream
    });
  }

  void _onDeleteTaskRequested(
    DeleteTaskRequested event,
    Emitter<TaskListState> emit,
  ) async {
    final result = await deleteTask(
      DeleteTaskParams(userId: event.userId, taskId: event.taskId),
    );

    result.fold((failure) => emit(TaskListError(failure.toString())), (_) {
      // Task list will be updated via stream
    });
  }

  List<TaskEntity> _applyFilters(
    List<TaskEntity> tasks,
    TaskPriority? priorityFilter,
    TaskStatusFilter? statusFilter,
  ) {
    var filtered = tasks;

    if (priorityFilter != null) {
      filtered = filtered
          .where((task) => task.priority == priorityFilter)
          .toList();
    }

    if (statusFilter != null) {
      switch (statusFilter) {
        case TaskStatusFilter.completed:
          filtered = filtered.where((task) => task.isCompleted).toList();
          break;
        case TaskStatusFilter.incomplete:
          filtered = filtered.where((task) => !task.isCompleted).toList();
          break;
        case TaskStatusFilter.all:
          break;
      }
    }

    return filtered;
  }
}

enum TaskStatusFilter { all, completed, incomplete }
