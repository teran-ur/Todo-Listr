import 'package:flutter/material.dart';
import '../../domain/entities/task.dart';

class TaskFilterBar extends StatelessWidget {
  final TaskFilterCategory activeFilter;
  final int totalCount;
  final int todayCount;
  final int upcomingCount;
  final int overdueCount;
  final int completedCount;
  final ValueChanged<TaskFilterCategory> onFilterSelected;

  const TaskFilterBar({
    super.key,
    required this.activeFilter,
    required this.totalCount,
    required this.todayCount,
    required this.upcomingCount,
    required this.overdueCount,
    required this.completedCount,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildChip(
            context,
            category: TaskFilterCategory.all,
            label: 'All',
            count: totalCount,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            category: TaskFilterCategory.today,
            label: 'Due Today',
            count: todayCount,
            accentColor: Colors.amber.shade800,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            category: TaskFilterCategory.upcoming,
            label: 'Upcoming',
            count: upcomingCount,
            accentColor: Colors.blue,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            category: TaskFilterCategory.overdue,
            label: 'Overdue',
            count: overdueCount,
            accentColor: Colors.red,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            category: TaskFilterCategory.completed,
            label: 'Completed',
            count: completedCount,
            accentColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required TaskFilterCategory category,
    required String label,
    required int count,
    Color? accentColor,
  }) {
    final isSelected = activeFilter == category;
    final theme = Theme.of(context);

    return FilterChip(
      key: Key('filter_chip_${category.name}'),
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : (accentColor ?? theme.colorScheme.surfaceContainerHighest),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? theme.colorScheme.primary
                    : (accentColor != null ? Colors.white : theme.textTheme.bodyMedium?.color),
              ),
            ),
          ),
        ],
      ),
      onSelected: (_) => onFilterSelected(category),
    );
  }
}
