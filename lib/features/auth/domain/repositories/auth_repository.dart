import 'package:gig_task_manager/core/errors/failures.dart';
import 'package:gig_task_manager/features/auth/domain/entities/user_entity.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> registerWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> signOut();

  Stream<UserEntity?> watchAuthState();

  UserEntity? getCurrentUser();
}
