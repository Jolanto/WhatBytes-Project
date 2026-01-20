import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gig_task_manager/core/errors/failures.dart';
import 'package:gig_task_manager/core/usecases/usecase.dart';
import 'package:gig_task_manager/features/auth/domain/entities/user_entity.dart';
import 'package:gig_task_manager/features/auth/domain/repositories/auth_repository.dart';

class RegisterWithEmailAndPassword
    implements UseCase<UserEntity, RegisterParams> {
  final AuthRepository repository;

  RegisterWithEmailAndPassword(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(RegisterParams params) async {
    return await repository.registerWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );
  }
}

class RegisterParams extends Equatable {
  final String email;
  final String password;

  const RegisterParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}
