import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gig_task_manager/core/injection/injection.dart';
import 'package:gig_task_manager/core/theme/app_theme.dart';
import 'package:gig_task_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gig_task_manager/features/auth/presentation/bloc/auth_form_bloc.dart';
import 'package:gig_task_manager/features/auth/presentation/pages/splash_page.dart';
import 'package:gig_task_manager/features/tasks/presentation/bloc/task_edit_bloc.dart';
import 'package:gig_task_manager/features/tasks/presentation/bloc/task_list_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => getIt<AuthBloc>()..add(const CheckAuthStatus()),
        ),
        BlocProvider<AuthFormBloc>(create: (_) => getIt<AuthFormBloc>()),
        BlocProvider<TaskListBloc>(create: (_) => getIt<TaskListBloc>()),
      ],
      child: MaterialApp(
        title: 'Gig Task Manager',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
