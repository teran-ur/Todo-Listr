import 'package:flutter/material.dart';
import '../../domain/entities/task.dart';

class TaskCard extends StatelessWidget {
  final TaskEntity task;
  final ValueChanged<bool?> onToggleCompletion;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggleCompletion,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange.shade800;
      case TaskPriority.low:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor(task.priority);
    final theme = Theme.of(context);

    return Semantics(
      label: 'Task ${task.title}, priority ${task.priority.name}, ${task.isCompleted ? "Completed" : "Incomplete"}',
      child: Card(
        key: Key('task_card_${task.id}'),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(12),
          hoverColor: theme.colorScheme.primary.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: ListTile(
              leading: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: Checkbox(
                    key: Key('task_checkbox_${task.id}'),
                    value: task.isCompleted,
                    onChanged: onToggleCompletion,
                  ),
                ),
              ),
              title: Text(
                task.title,
                style: TextStyle(
                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  color: task.isCompleted ? Colors.grey : null,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (task.description != null && task.description!.isNotEmpty)
                    Text(
                      task.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Priority Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: priorityColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: priorityColor.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          task.priority.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: priorityColor,
                          ),
                        ),
                      ),
                      // Due Date Badge
                      if (task.dueDate != null) ...[
                        if (task.isOverdue)
                          Chip(
                            visualDensity: VisualDensity.compact,
                            backgroundColor: Colors.red.shade100,
                            avatar: const Icon(Icons.warning, size: 14, color: Colors.red),
                            label: Text(
                              'Overdue (${task.dueDate!.day}/${task.dueDate!.month})',
                              style: const TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                          )
                        else if (task.isDueToday)
                          Chip(
                            visualDensity: VisualDensity.compact,
                            backgroundColor: Colors.amber.shade100,
                            avatar: const Icon(Icons.today, size: 14, color: Colors.amber),
                            label: const Text('Due Today', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          )
                        else
                          Text(
                            'Due: ${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                      ],
                      // Scheduled Reminder Badge
                      if (task.isReminderEnabled && task.reminderDateTime != null)
                        Tooltip(
                          message:
                              'Reminder: ${task.reminderDateTime!.day}/${task.reminderDateTime!.month} at ${task.reminderDateTime!.hour.toString().padLeft(2, '0')}:${task.reminderDateTime!.minute.toString().padLeft(2, '0')}',
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.notifications_active,
                                size: 14,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${task.reminderDateTime!.hour.toString().padLeft(2, '0')}:${task.reminderDateTime!.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    tooltip: 'Edit Task',
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                    tooltip: 'Delete Task',
                    onPressed: onDelete,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
