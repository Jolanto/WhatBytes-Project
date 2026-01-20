import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gig_task_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gig_task_manager/features/auth/presentation/pages/login_page.dart';
import 'package:gig_task_manager/features/tasks/presentation/bloc/task_list_bloc.dart';
import 'package:gig_task_manager/features/tasks/presentation/pages/task_edit_page.dart';
import 'package:gig_task_manager/features/tasks/presentation/widgets/task_list_item.dart';
import 'package:gig_task_manager/features/tasks/domain/entities/task_entity.dart';
import 'package:gig_task_manager/features/tasks/presentation/widgets/task_filter_chips.dart';

class TaskHomePage extends StatefulWidget {
  const TaskHomePage({super.key});

  @override
  State<TaskHomePage> createState() => _TaskHomePageState();
}

class _TaskHomePageState extends State<TaskHomePage> {
  @override
  void initState() {
    super.initState();
    // Dispatch subscribe event when the page initializes.
    // The AuthBloc state is used to get the userId.
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<TaskListBloc>().add(SubscribeTasks(authState.user.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        }
      },
      child: Builder(
        builder: (context) {
          final authState = context.watch<AuthBloc>().state;

          if (authState is! AuthAuthenticated) {
            // During logout, we might transiently be in Loading/Unauthenticated state.
            // We just show a loader until the Listener navigates us away.
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final userId = authState.user.uid;

          // Notes on RenderFlex overflow:
          // TaskFilterChips uses a Column. If the list is large, having Expanded properly constraints the ListView.
          // Ensure task list is constrained.

          return Scaffold(
            appBar: AppBar(
              title: const Text('My Tasks'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    context.read<AuthBloc>().add(const SignOutRequested());
                  },
                  tooltip: 'Logout',
                ),
              ],
            ),
            body: Column(
              children: [
                const TaskFilterChips(),
                Expanded(
                  child: BlocBuilder<TaskListBloc, TaskListState>(
                    builder: (context, state) {
                      if (state is TaskListLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is TaskListError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Error: ${state.message}',
                                style: const TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  context.read<TaskListBloc>().add(
                                    SubscribeTasks(userId),
                                  );
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (state is TasksLoaded) {
                        if (state.filteredTasks.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.task_alt,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No tasks found',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap the + button to create a new task',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: () async {
                            context.read<TaskListBloc>().add(
                              SubscribeTasks(userId),
                            );
                          },
                          child: _buildGroupedTaskList(
                            context,
                            state.filteredTasks,
                            userId,
                          ),
                        );
                      }

                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TaskEditPage(userId: userId),
                  ),
                );
              },
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGroupedTaskList(
    BuildContext context,
    List<TaskEntity> tasks,
    String userId,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final nextWeek = today.add(const Duration(days: 7));

    final overdue = <TaskEntity>[];
    final todaysTasks = <TaskEntity>[];
    final tomorrowsTasks = <TaskEntity>[];
    final thisWeeksTasks = <TaskEntity>[];
    final laterTasks = <TaskEntity>[];
    final completedTasks = <TaskEntity>[];

    for (var task in tasks) {
      if (task.isCompleted) {
        completedTasks.add(task);
        continue;
      }

      final due = DateTime(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
      );

      if (due.isBefore(today)) {
        overdue.add(task);
      } else if (due.isAtSameMomentAs(today)) {
        todaysTasks.add(task);
      } else if (due.isAtSameMomentAs(tomorrow)) {
        tomorrowsTasks.add(task);
      } else if (due.isBefore(nextWeek)) {
        thisWeeksTasks.add(task);
      } else {
        laterTasks.add(task);
      }
    }

    final List<Widget> listItems = [];

    if (overdue.isNotEmpty) {
      listItems.add(_buildSectionHeader(context, 'Overdue', Colors.red));
      listItems.addAll(overdue.map((t) => _buildTaskItem(context, t, userId)));
    }

    if (todaysTasks.isNotEmpty) {
      listItems.add(_buildSectionHeader(context, 'Today', Colors.blue));
      listItems.addAll(
        todaysTasks.map((t) => _buildTaskItem(context, t, userId)),
      );
    }

    if (tomorrowsTasks.isNotEmpty) {
      listItems.add(_buildSectionHeader(context, 'Tomorrow', Colors.orange));
      listItems.addAll(
        tomorrowsTasks.map((t) => _buildTaskItem(context, t, userId)),
      );
    }

    if (thisWeeksTasks.isNotEmpty) {
      listItems.add(_buildSectionHeader(context, 'This Week', Colors.purple));
      listItems.addAll(
        thisWeeksTasks.map((t) => _buildTaskItem(context, t, userId)),
      );
    }

    if (laterTasks.isNotEmpty) {
      listItems.add(_buildSectionHeader(context, 'Later', Colors.grey));
      listItems.addAll(
        laterTasks.map((t) => _buildTaskItem(context, t, userId)),
      );
    }

    if (completedTasks.isNotEmpty) {
      listItems.add(_buildSectionHeader(context, 'Completed', Colors.green));
      listItems.addAll(
        completedTasks.map((t) => _buildTaskItem(context, t, userId)),
      );
    }

    return ListView(padding: const EdgeInsets.all(8), children: listItems);
  }

  Widget _buildSectionHeader(BuildContext context, String title, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, TaskEntity task, String userId) {
    return TaskListItem(
      task: task,
      userId: userId,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TaskEditPage(userId: userId, task: task),
          ),
        );
      },
    );
  }
}
