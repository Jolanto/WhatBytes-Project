import 'package:gig_task_manager/core/usecases/usecase.dart';
import 'package:gig_task_manager/features/auth/domain/entities/user_entity.dart';
import 'package:gig_task_manager/features/auth/domain/repositories/auth_repository.dart';

class WatchAuthState implements StreamUseCase<UserEntity?, NoParams> {
  final AuthRepository repository;

  WatchAuthState(this.repository);

  @override
  Stream<UserEntity?> call(NoParams params) {
    return repository.watchAuthState();
  }
}
