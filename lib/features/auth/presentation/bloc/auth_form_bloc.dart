import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gig_task_manager/core/errors/failures.dart';
import 'package:gig_task_manager/features/auth/domain/usecases/sign_in_with_email_and_password.dart';
import 'package:gig_task_manager/features/auth/domain/usecases/register_with_email_and_password.dart';

part 'auth_form_event.dart';
part 'auth_form_state.dart';

class AuthFormBloc extends Bloc<AuthFormEvent, AuthFormState> {
  final SignInWithEmailAndPassword signIn;
  final RegisterWithEmailAndPassword register;

  AuthFormBloc({required this.signIn, required this.register})
    : super(AuthFormInitial()) {
    on<EmailChanged>(_onEmailChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<FormSubmitted>(_onFormSubmitted);
    on<FormReset>(_onFormReset);
  }

  void _onEmailChanged(EmailChanged event, Emitter<AuthFormState> emit) {
    emit(
      state.copyWith(
        email: event.email,
        isEmailValid: _isValidEmail(event.email),
      ),
    );
  }

  void _onPasswordChanged(PasswordChanged event, Emitter<AuthFormState> emit) {
    emit(
      state.copyWith(
        password: event.password,
        isPasswordValid: event.password.length >= 6,
      ),
    );
  }

  void _onFormSubmitted(
    FormSubmitted event,
    Emitter<AuthFormState> emit,
  ) async {
    if (!state.isEmailValid || !state.isPasswordValid) {
      emit(
        state.copyWith(errorMessage: 'Please enter valid email and password'),
      );
      return;
    }

    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    final result = event.isLogin
        ? await signIn(
            SignInParams(email: state.email, password: state.password),
          )
        : await register(
            RegisterParams(email: state.email, password: state.password),
          );

    result.fold((failure) {
      final errorMessage = failure is AuthFailure
          ? failure.message
          : 'An unexpected error occurred';
      emit(state.copyWith(isSubmitting: false, errorMessage: errorMessage));
    }, (user) => emit(state.copyWith(isSubmitting: false, isSuccess: true)));
  }

  void _onFormReset(FormReset event, Emitter<AuthFormState> emit) {
    emit(AuthFormInitial());
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
