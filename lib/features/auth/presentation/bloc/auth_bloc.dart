import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gig_task_manager/core/usecases/usecase.dart';
import 'package:gig_task_manager/features/auth/domain/entities/user_entity.dart';
import 'package:gig_task_manager/features/auth/domain/repositories/auth_repository.dart';
import 'package:gig_task_manager/features/auth/domain/usecases/watch_auth_state.dart';
import 'package:gig_task_manager/features/auth/domain/usecases/sign_out.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final WatchAuthState watchAuthState;
  final SignOut signOut;
  final AuthRepository authRepository;
  StreamSubscription<UserEntity?>? _authStateSubscription;

  AuthBloc({
    required this.watchAuthState,
    required this.signOut,
    required this.authRepository,
  }) : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<SignOutRequested>(_onSignOutRequested);
    on<AuthStateChanged>(_onAuthStateChanged);
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }

  void _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    // Cancel existing subscription if any
    await _authStateSubscription?.cancel();

    emit(AuthLoading());

    // Check current user immediately
    final currentUser = authRepository.getCurrentUser();
    if (currentUser != null) {
      emit(AuthAuthenticated(currentUser));
    } else {
      emit(AuthUnauthenticated());
    }

    // Then listen to future changes
    _authStateSubscription = watchAuthState(NoParams()).listen(
      (user) {
        if (user != null) {
          add(AuthStateChanged(user));
        } else {
          add(const AuthStateChanged(null));
        }
      },
      onError: (error) {
        add(const AuthStateChanged(null));
      },
    );
  }

  void _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signOut(NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.toString())),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  void _onAuthStateChanged(AuthStateChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(AuthAuthenticated(event.user!));
    } else {
      emit(AuthUnauthenticated());
    }
  }
}
