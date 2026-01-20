import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gig_task_manager/core/injection/injection.dart';
import 'package:gig_task_manager/features/tasks/domain/entities/task_entity.dart';
import 'package:gig_task_manager/features/tasks/presentation/bloc/task_edit_bloc.dart';
import 'package:intl/intl.dart';

class TaskEditPage extends StatefulWidget {
  final String userId;
  final TaskEntity? task;

  const TaskEditPage({super.key, required this.userId, this.task});

  @override
  State<TaskEditPage> createState() => _TaskEditPageState();
}

class _TaskEditPageState extends State<TaskEditPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<TaskEditBloc>()
            ..add(LoadTask(userId: widget.userId, task: widget.task)),
      child: BlocListener<TaskEditBloc, TaskEditState>(
        listener: (context, state) {
          if (state is TaskEditSuccess || state is TaskEditDeleted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state is TaskEditDeleted
                      ? 'Task deleted successfully'
                      : 'Task saved successfully',
                ),
              ),
            );
          } else if (state is TaskEditError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.task == null ? 'New Task' : 'Edit Task'),
            actions: [
              if (widget.task != null)
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Task'),
                        content: const Text(
                          'Are you sure you want to delete this task?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              context.read<TaskEditBloc>().add(
                                const DeleteTaskRequested(),
                              );
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
          body: BlocBuilder<TaskEditBloc, TaskEditState>(
            builder: (context, state) {
              if (state is TaskEditLoaded) {
                // Determine if we need to update text from state or keep user input.
                // Usually for edits, we initialize once.
                // However, if the Bloc loads data async (like for existing task), we might need to update controller.
                // But here we passed `widget.task` to `LoadTask`.
                // For a *New* task, it starts empty.
                // For an *Existing* task, we passed it in param.
                // So initState usage is correct for the initial value.
                // We should NOT update controller text on every rebuild as that disturbs cursor.
                return _buildForm(context, state);
              } else if (state is TaskEditSaving || state is TaskEditDeleting) {
                return const Center(child: CircularProgressIndicator());
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, TaskEditLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title *',
              hintText: 'Enter task title',
            ),
            onChanged: (value) {
              context.read<TaskEditBloc>().add(TitleChanged(value));
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Enter task description',
            ),
            maxLines: 4,
            onChanged: (value) {
              context.read<TaskEditBloc>().add(DescriptionChanged(value));
            },
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Due Date'),
            subtitle: Text(DateFormat('MMM dd, yyyy').format(state.dueDate)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: state.dueDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
              );
              if (picked != null) {
                context.read<TaskEditBloc>().add(DueDateChanged(picked));
              }
            },
          ),
          const SizedBox(height: 16),
          const Text('Priority'),
          const SizedBox(height: 8),
          SegmentedButton<TaskPriority>(
            segments: const [
              ButtonSegment(
                value: TaskPriority.low,
                label: Text('Low'),
                icon: Icon(Icons.arrow_downward),
              ),
              ButtonSegment(
                value: TaskPriority.medium,
                label: Text('Medium'),
                icon: Icon(Icons.remove),
              ),
              ButtonSegment(
                value: TaskPriority.high,
                label: Text('High'),
                icon: Icon(Icons.arrow_upward),
              ),
            ],
            selected: {state.priority},
            onSelectionChanged: (Set<TaskPriority> newSelection) {
              context.read<TaskEditBloc>().add(
                PriorityChanged(newSelection.first),
              );
            },
          ),
          const SizedBox(height: 32),
          BlocBuilder<TaskEditBloc, TaskEditState>(
            buildWhen: (previous, current) =>
                current is TaskEditSaving || current is TaskEditDeleting,
            builder: (context, state) {
              final isSaving = state is TaskEditSaving;
              return ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () {
                        if (_titleController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Title cannot be empty'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        context.read<TaskEditBloc>().add(const SaveTask());
                      },
                child: isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              );
            },
          ),
        ],
      ),
    );
  }
}
