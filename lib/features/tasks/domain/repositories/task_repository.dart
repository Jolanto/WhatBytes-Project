import 'package:dartz/dartz.dart';
import 'package:gig_task_manager/core/errors/failures.dart';
import 'package:gig_task_manager/features/tasks/domain/entities/task_entity.dart';

abstract class TaskRepository {
  Stream<List<TaskEntity>> watchTasks(String userId);

  Future<Either<Failure, TaskEntity>> createTask({
    required String userId,
    required String title,
    required String description,
    required DateTime dueDate,
    required TaskPriority priority,
  });

  Future<Either<Failure, TaskEntity>> updateTask({
    required String userId,
    required TaskEntity task,
  });

  Future<Either<Failure, void>> deleteTask({
    required String userId,
    required String taskId,
  });

  Future<Either<Failure, TaskEntity>> toggleTaskCompletion({
    required String userId,
    required String taskId,
  });
}
