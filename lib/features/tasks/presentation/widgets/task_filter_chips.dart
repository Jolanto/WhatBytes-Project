import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gig_task_manager/features/tasks/domain/entities/task_entity.dart';
import 'package:gig_task_manager/features/tasks/presentation/bloc/task_list_bloc.dart';

class TaskFilterChips extends StatelessWidget {
  const TaskFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskListBloc, TaskListState>(
      builder: (context, state) {
        TaskPriority? currentPriority;
        TaskStatusFilter? currentStatus;

        if (state is TasksLoaded) {
          currentPriority = state.priorityFilter;
          currentStatus = state.statusFilter;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  'Filter by Priority',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              Wrap(
                spacing: 8,
                children: [
                  _buildPriorityChip(
                    context,
                    null,
                    'All',
                    currentPriority == null,
                    () {
                      context.read<TaskListBloc>().add(
                        const SetPriorityFilter(null),
                      );
                    },
                  ),
                  _buildPriorityChip(
                    context,
                    TaskPriority.low,
                    'Low',
                    currentPriority == TaskPriority.low,
                    () {
                      context.read<TaskListBloc>().add(
                        const SetPriorityFilter(TaskPriority.low),
                      );
                    },
                  ),
                  _buildPriorityChip(
                    context,
                    TaskPriority.medium,
                    'Medium',
                    currentPriority == TaskPriority.medium,
                    () {
                      context.read<TaskListBloc>().add(
                        const SetPriorityFilter(TaskPriority.medium),
                      );
                    },
                  ),
                  _buildPriorityChip(
                    context,
                    TaskPriority.high,
                    'High',
                    currentPriority == TaskPriority.high,
                    () {
                      context.read<TaskListBloc>().add(
                        const SetPriorityFilter(TaskPriority.high),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  'Filter by Status',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              Wrap(
                spacing: 8,
                children: [
                  _buildStatusChip(
                    context,
                    TaskStatusFilter.all,
                    'All',
                    currentStatus == TaskStatusFilter.all ||
                        currentStatus == null,
                    () {
                      context.read<TaskListBloc>().add(
                        const SetStatusFilter(TaskStatusFilter.all),
                      );
                    },
                  ),
                  _buildStatusChip(
                    context,
                    TaskStatusFilter.completed,
                    'Completed',
                    currentStatus == TaskStatusFilter.completed,
                    () {
                      context.read<TaskListBloc>().add(
                        const SetStatusFilter(TaskStatusFilter.completed),
                      );
                    },
                  ),
                  _buildStatusChip(
                    context,
                    TaskStatusFilter.incomplete,
                    'Incomplete',
                    currentStatus == TaskStatusFilter.incomplete,
                    () {
                      context.read<TaskListBloc>().add(
                        const SetStatusFilter(TaskStatusFilter.incomplete),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPriorityChip(
    BuildContext context,
    TaskPriority? priority,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    Color chipColor;
    switch (priority) {
      case TaskPriority.high:
        chipColor = Colors.red;
        break;
      case TaskPriority.medium:
        chipColor = Colors.orange;
        break;
      case TaskPriority.low:
        chipColor = Colors.green;
        break;
      case null:
        chipColor = Colors.grey;
        break;
    }

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: chipColor.withOpacity(0.3),
      checkmarkColor: chipColor,
      labelStyle: TextStyle(
        color: isSelected ? chipColor : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildStatusChip(
    BuildContext context,
    TaskStatusFilter status,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: Colors.blue.withOpacity(0.3),
      checkmarkColor: Colors.blue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.blue : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
