import 'package:equatable/equatable.dart';
import 'package:gig_task_manager/core/usecases/usecase.dart';
import 'package:gig_task_manager/features/tasks/domain/entities/task_entity.dart';
import 'package:gig_task_manager/features/tasks/domain/repositories/task_repository.dart';

class WatchTasks implements StreamUseCase<List<TaskEntity>, WatchTasksParams> {
  final TaskRepository repository;

  WatchTasks(this.repository);

  @override
  Stream<List<TaskEntity>> call(WatchTasksParams params) {
    return repository.watchTasks(params.userId);
  }
}

class WatchTasksParams extends Equatable {
  final String userId;

  const WatchTasksParams(this.userId);

  @override
  List<Object?> get props => [userId];
}
