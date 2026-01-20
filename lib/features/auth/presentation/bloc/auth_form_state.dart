part of 'auth_form_bloc.dart';

class AuthFormState extends Equatable {
  final String email;
  final String password;
  final bool isEmailValid;
  final bool isPasswordValid;
  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;

  const AuthFormState({
    this.email = '',
    this.password = '',
    this.isEmailValid = false,
    this.isPasswordValid = false,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  AuthFormState copyWith({
    String? email,
    String? password,
    bool? isEmailValid,
    bool? isPasswordValid,
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return AuthFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    email,
    password,
    isEmailValid,
    isPasswordValid,
    isSubmitting,
    isSuccess,
    errorMessage,
  ];
}

class AuthFormInitial extends AuthFormState {
  const AuthFormInitial();
}
