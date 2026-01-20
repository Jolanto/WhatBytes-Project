import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gig_task_manager/core/errors/failures.dart';
import 'package:gig_task_manager/core/usecases/usecase.dart';
import 'package:gig_task_manager/features/tasks/domain/repositories/task_repository.dart';

class DeleteTask implements UseCase<void, DeleteTaskParams> {
  final TaskRepository repository;

  DeleteTask(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteTaskParams params) async {
    return await repository.deleteTask(
      userId: params.userId,
      taskId: params.taskId,
    );
  }
}

class DeleteTaskParams extends Equatable {
  final String userId;
  final String taskId;

  const DeleteTaskParams({required this.userId, required this.taskId});

  @override
  List<Object?> get props => [userId, taskId];
}
