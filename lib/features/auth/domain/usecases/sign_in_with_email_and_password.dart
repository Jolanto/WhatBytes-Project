import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gig_task_manager/core/errors/failures.dart';
import 'package:gig_task_manager/core/usecases/usecase.dart';
import 'package:gig_task_manager/features/auth/domain/entities/user_entity.dart';
import 'package:gig_task_manager/features/auth/domain/repositories/auth_repository.dart';

class SignInWithEmailAndPassword implements UseCase<UserEntity, SignInParams> {
  final AuthRepository repository;

  SignInWithEmailAndPassword(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignInParams params) async {
    return await repository.signInWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );
  }
}

class SignInParams extends Equatable {
  final String email;
  final String password;

  const SignInParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}
