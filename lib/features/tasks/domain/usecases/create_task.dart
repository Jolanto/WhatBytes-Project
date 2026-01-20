import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gig_task_manager/core/errors/failures.dart';
import 'package:gig_task_manager/core/usecases/usecase.dart';
import 'package:gig_task_manager/features/tasks/domain/entities/task_entity.dart';
import 'package:gig_task_manager/features/tasks/domain/repositories/task_repository.dart';

class CreateTask implements UseCase<TaskEntity, CreateTaskParams> {
  final TaskRepository repository;

  CreateTask(this.repository);

  @override
  Future<Either<Failure, TaskEntity>> call(CreateTaskParams params) async {
    return await repository.createTask(
      userId: params.userId,
      title: params.title,
      description: params.description,
      dueDate: params.dueDate,
      priority: params.priority,
    );
  }
}

class CreateTaskParams extends Equatable {
  final String userId;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskPriority priority;

  const CreateTaskParams({
    required this.userId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
  });

  @override
  List<Object?> get props => [userId, title, description, dueDate, priority];
}
