import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gig_task_manager/core/errors/failures.dart';
import 'package:gig_task_manager/core/usecases/usecase.dart';
import 'package:gig_task_manager/features/tasks/domain/entities/task_entity.dart';
import 'package:gig_task_manager/features/tasks/domain/repositories/task_repository.dart';

class ToggleTaskCompletion
    implements UseCase<TaskEntity, ToggleTaskCompletionParams> {
  final TaskRepository repository;

  ToggleTaskCompletion(this.repository);

  @override
  Future<Either<Failure, TaskEntity>> call(
    ToggleTaskCompletionParams params,
  ) async {
    return await repository.toggleTaskCompletion(
      userId: params.userId,
      taskId: params.taskId,
    );
  }
}

class ToggleTaskCompletionParams extends Equatable {
  final String userId;
  final String taskId;

  const ToggleTaskCompletionParams({
    required this.userId,
    required this.taskId,
  });

  @override
  List<Object?> get props => [userId, taskId];
}
