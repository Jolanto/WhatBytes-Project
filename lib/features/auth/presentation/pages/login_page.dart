import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gig_task_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gig_task_manager/features/auth/presentation/bloc/auth_form_bloc.dart';
import 'package:gig_task_manager/features/auth/presentation/pages/register_page.dart';
import 'package:gig_task_manager/features/tasks/presentation/pages/task_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    // Reset form when page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthFormBloc>().add(const FormReset());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: const LoginForm(),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const TaskHomePage()),
                (route) => false,
              );
            }
          },
        ),
        BlocListener<AuthFormBloc, AuthFormState>(
          listener: (context, state) {
            if (state.isSuccess) {
              // Trigger auth state check after successful login
              // context.read<AuthBloc>().add(const CheckAuthStatus()); // REMOVED: Redundant and causes refresh issue
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Login successful!')),
              );
            } else if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Image.asset('assets/icon.png', height: 100),
              const SizedBox(height: 24),
              Text(
                'Welcome Back',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to manage your tasks',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              BlocBuilder<AuthFormBloc, AuthFormState>(
                buildWhen: (previous, current) =>
                    previous.email != current.email ||
                    previous.isEmailValid != current.isEmailValid,
                builder: (context, state) {
                  return TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      errorText: state.email.isNotEmpty && !state.isEmailValid
                          ? 'Invalid email'
                          : null,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      context.read<AuthFormBloc>().add(EmailChanged(value));
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              BlocBuilder<AuthFormBloc, AuthFormState>(
                buildWhen: (previous, current) =>
                    previous.password != current.password ||
                    previous.isPasswordValid != current.isPasswordValid,
                builder: (context, state) {
                  return TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      errorText:
                          state.password.isNotEmpty && !state.isPasswordValid
                          ? 'Password must be at least 6 characters'
                          : null,
                    ),
                    obscureText: true,
                    onChanged: (value) {
                      context.read<AuthFormBloc>().add(PasswordChanged(value));
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
              BlocBuilder<AuthFormBloc, AuthFormState>(
                buildWhen: (previous, current) =>
                    previous.isSubmitting != current.isSubmitting ||
                    previous.isEmailValid != current.isEmailValid ||
                    previous.isPasswordValid != current.isPasswordValid,
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed:
                        state.isSubmitting ||
                            !state.isEmailValid ||
                            !state.isPasswordValid
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              context.read<AuthFormBloc>().add(
                                const FormSubmitted(true),
                              );
                            }
                          },
                    child: state.isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Login'),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  );
                },
                child: const Text('Don\'t have an account? Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
