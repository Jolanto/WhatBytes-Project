import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:gig_task_manager/features/auth/data/datasources/firebase_auth_data_source.dart';
import 'package:gig_task_manager/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:gig_task_manager/features/auth/domain/repositories/auth_repository.dart';
import 'package:gig_task_manager/features/auth/domain/usecases/sign_in_with_email_and_password.dart';
import 'package:gig_task_manager/features/auth/domain/usecases/register_with_email_and_password.dart';
import 'package:gig_task_manager/features/auth/domain/usecases/sign_out.dart';
import 'package:gig_task_manager/features/auth/domain/usecases/watch_auth_state.dart';
import 'package:gig_task_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gig_task_manager/features/auth/presentation/bloc/auth_form_bloc.dart';
import 'package:gig_task_manager/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:gig_task_manager/features/tasks/domain/repositories/task_repository.dart';
import 'package:gig_task_manager/features/tasks/domain/usecases/create_task.dart';
import 'package:gig_task_manager/features/tasks/domain/usecases/update_task.dart';
import 'package:gig_task_manager/features/tasks/domain/usecases/delete_task.dart';
import 'package:gig_task_manager/features/tasks/domain/usecases/toggle_task_completion.dart';
import 'package:gig_task_manager/features/tasks/domain/usecases/watch_tasks.dart';
import 'package:gig_task_manager/features/tasks/presentation/bloc/task_list_bloc.dart';
import 'package:gig_task_manager/features/tasks/presentation/bloc/task_edit_bloc.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // External
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  // Data Sources
  getIt.registerLazySingleton<FirebaseAuthDataSource>(
    () => FirebaseAuthDataSourceImpl(getIt<FirebaseAuth>()),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<FirebaseAuthDataSource>()),
  );

  getIt.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(getIt<FirebaseFirestore>()),
  );

  // Use Cases - Auth
  getIt.registerLazySingleton(
    () => SignInWithEmailAndPassword(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton(
    () => RegisterWithEmailAndPassword(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton(() => SignOut(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => WatchAuthState(getIt<AuthRepository>()));

  // Use Cases - Tasks
  getIt.registerLazySingleton(() => CreateTask(getIt<TaskRepository>()));
  getIt.registerLazySingleton(() => UpdateTask(getIt<TaskRepository>()));
  getIt.registerLazySingleton(() => DeleteTask(getIt<TaskRepository>()));
  getIt.registerLazySingleton(
    () => ToggleTaskCompletion(getIt<TaskRepository>()),
  );
  getIt.registerLazySingleton(() => WatchTasks(getIt<TaskRepository>()));

  // BLoCs
  getIt.registerFactory(
    () => AuthBloc(
      watchAuthState: getIt<WatchAuthState>(),
      signOut: getIt<SignOut>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );

  getIt.registerFactory(
    () => AuthFormBloc(
      signIn: getIt<SignInWithEmailAndPassword>(),
      register: getIt<RegisterWithEmailAndPassword>(),
    ),
  );

  getIt.registerFactory(
    () => TaskListBloc(
      watchTasks: getIt<WatchTasks>(),
      toggleTaskCompletion: getIt<ToggleTaskCompletion>(),
      deleteTask: getIt<DeleteTask>(),
    ),
  );

  getIt.registerFactory(
    () => TaskEditBloc(
      createTask: getIt<CreateTask>(),
      updateTask: getIt<UpdateTask>(),
      deleteTask: getIt<DeleteTask>(),
    ),
  );
}
