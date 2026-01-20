import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gig_task_manager/core/errors/failures.dart';
import 'package:gig_task_manager/core/usecases/usecase.dart';
import 'package:gig_task_manager/features/tasks/domain/entities/task_entity.dart';
import 'package:gig_task_manager/features/tasks/domain/repositories/task_repository.dart';

class UpdateTask implements UseCase<TaskEntity, UpdateTaskParams> {
  final TaskRepository repository;

  UpdateTask(this.repository);

  @override
  Future<Either<Failure, TaskEntity>> call(UpdateTaskParams params) async {
    return await repository.updateTask(
      userId: params.userId,
      task: params.task,
    );
  }
}

class UpdateTaskParams extends Equatable {
  final String userId;
  final TaskEntity task;

  const UpdateTaskParams({required this.userId, required this.task});

  @override
  List<Object?> get props => [userId, task];
}
