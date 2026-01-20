part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

class AuthStateChanged extends AuthEvent {
  final UserEntity? user;

  const AuthStateChanged(this.user);

  @override
  List<Object?> get props => [user];
}
