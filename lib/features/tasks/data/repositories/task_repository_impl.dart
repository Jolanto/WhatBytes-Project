import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:gig_task_manager/core/constants/constants.dart';
import 'package:gig_task_manager/core/errors/failures.dart';
import 'package:gig_task_manager/features/tasks/data/models/task_model.dart';
import 'package:gig_task_manager/features/tasks/domain/entities/task_entity.dart';
import 'package:gig_task_manager/features/tasks/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final FirebaseFirestore firestore;

  TaskRepositoryImpl(this.firestore);

  @override
  Stream<List<TaskEntity>> watchTasks(String userId) {
    return firestore
        .collection(Constants.usersCollection)
        .doc(userId)
        .collection(Constants.tasksCollection)
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TaskModel.fromFirestore(doc).toEntity())
              .toList();
        });
  }

  @override
  Future<Either<Failure, TaskEntity>> createTask({
    required String userId,
    required String title,
    required String description,
    required DateTime dueDate,
    required TaskPriority priority,
  }) async {
    try {
      final now = DateTime.now();
      final taskRef = firestore
          .collection(Constants.usersCollection)
          .doc(userId)
          .collection(Constants.tasksCollection)
          .doc();

      final taskModel = TaskModel(
        id: taskRef.id,
        title: title,
        description: description,
        dueDate: dueDate,
        priority: priority,
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
      );

      await taskRef.set(taskModel.toFirestore());
      return Right(taskModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> updateTask({
    required String userId,
    required TaskEntity task,
  }) async {
    try {
      final taskModel = TaskModel(
        id: task.id,
        title: task.title,
        description: task.description,
        dueDate: task.dueDate,
        priority: task.priority,
        isCompleted: task.isCompleted,
        createdAt: task.createdAt,
        updatedAt: DateTime.now(),
      );

      await firestore
          .collection(Constants.usersCollection)
          .doc(userId)
          .collection(Constants.tasksCollection)
          .doc(task.id)
          .update(taskModel.toFirestore());

      return Right(taskModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask({
    required String userId,
    required String taskId,
  }) async {
    try {
      await firestore
          .collection(Constants.usersCollection)
          .doc(userId)
          .collection(Constants.tasksCollection)
          .doc(taskId)
          .delete();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> toggleTaskCompletion({
    required String userId,
    required String taskId,
  }) async {
    try {
      final taskRef = firestore
          .collection(Constants.usersCollection)
          .doc(userId)
          .collection(Constants.tasksCollection)
          .doc(taskId);

      final doc = await taskRef.get();
      if (!doc.exists) {
        return Left(ServerFailure('Task not found'));
      }

      final taskModel = TaskModel.fromFirestore(doc);
      final updatedTask = taskModel.copyWith(
        isCompleted: !taskModel.isCompleted,
        updatedAt: DateTime.now(),
      );

      await taskRef.update(updatedTask.toFirestore());
      return Right(updatedTask.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
