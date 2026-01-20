part of 'auth_form_bloc.dart';

abstract class AuthFormEvent extends Equatable {
  const AuthFormEvent();

  @override
  List<Object?> get props => [];
}

class EmailChanged extends AuthFormEvent {
  final String email;

  const EmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

class PasswordChanged extends AuthFormEvent {
  final String password;

  const PasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

class FormSubmitted extends AuthFormEvent {
  final bool isLogin;

  const FormSubmitted(this.isLogin);

  @override
  List<Object?> get props => [isLogin];
}

class FormReset extends AuthFormEvent {
  const FormReset();
}
