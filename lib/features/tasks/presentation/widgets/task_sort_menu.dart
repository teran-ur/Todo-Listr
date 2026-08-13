import 'package:flutter/material.dart';
import '../../domain/entities/task.dart';

class TaskSortMenu extends StatelessWidget {
  final TaskSortOption activeSort;
  final ValueChanged<TaskSortOption> onSortSelected;

  const TaskSortMenu({
    super.key,
    required this.activeSort,
    required this.onSortSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<TaskSortOption>(
      key: const Key('task_sort_menu'),
      icon: const Icon(Icons.sort),
      tooltip: 'Sort Tasks',
      initialValue: activeSort,
      onSelected: onSortSelected,
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: TaskSortOption.dueDate,
          child: Text('Sort by Due Date'),
        ),
        const PopupMenuItem(
          value: TaskSortOption.priority,
          child: Text('Sort by Priority'),
        ),
        const PopupMenuItem(
          value: TaskSortOption.title,
          child: Text('Sort by Title'),
        ),
        const PopupMenuItem(
          value: TaskSortOption.createdAt,
          child: Text('Sort by Creation Date'),
        ),
      ],
    );
  }
}
