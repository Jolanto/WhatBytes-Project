import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gig_task_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gig_task_manager/features/auth/presentation/bloc/auth_form_bloc.dart';
import 'package:gig_task_manager/features/tasks/presentation/pages/task_home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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
      appBar: AppBar(title: const Text('Register')),
      body: const RegisterForm(),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
              // Trigger auth state check after successful registration
              context.read<AuthBloc>().add(const CheckAuthStatus());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Registration successful!')),
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
                'Create Account',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Sign up to start managing your tasks',
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
                          ? 'Password must be at least 6 characters long'
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
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  hintText: 'Re-enter your password',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
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
                                const FormSubmitted(false),
                              );
                            }
                          },
                    child: state.isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Register'),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
