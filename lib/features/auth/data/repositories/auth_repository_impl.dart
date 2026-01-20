import 'package:dartz/dartz.dart';
import 'package:gig_task_manager/core/errors/auth_exception.dart';
import 'package:gig_task_manager/core/errors/failures.dart';
import 'package:gig_task_manager/features/auth/data/datasources/firebase_auth_data_source.dart';
import 'package:gig_task_manager/features/auth/domain/entities/user_entity.dart';
import 'package:gig_task_manager/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource dataSource;

  AuthRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user = await dataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on Exception catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user = await dataSource.registerWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on Exception catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await dataSource.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on Exception catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Stream<UserEntity?> watchAuthState() {
    return dataSource.watchAuthState();
  }

  @override
  UserEntity? getCurrentUser() {
    return dataSource.getCurrentUser();
  }
}
