import 'package:flutter/material.dart';
import '../../../tasks/domain/entities/task.dart';

class DashboardMetricsOverview extends StatelessWidget {
  final int todayCount;
  final int overdueCount;
  final int totalCount;
  final int completedCount;
  final ValueChanged<TaskFilterCategory> onSelectCategory;

  const DashboardMetricsOverview({
    super.key,
    required this.todayCount,
    required this.overdueCount,
    required this.totalCount,
    required this.completedCount,
    required this.onSelectCategory,
  });

  @override
  Widget build(BuildContext context) {
    final remainingCount = totalCount - completedCount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth >= 600 ? 4 : 2;

          return GridView.count(
            crossAxisCount: crossAxisCount,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: constraints.maxWidth >= 600 ? 2.8 : 2.2,
            children: [
              _buildMetricCard(
                context,
                key: 'metric_today',
                title: 'Due Today',
                count: todayCount,
                icon: Icons.today,
                color: Colors.amber.shade800,
                onTap: () => onSelectCategory(TaskFilterCategory.today),
              ),
              _buildMetricCard(
                context,
                key: 'metric_overdue',
                title: 'Overdue',
                count: overdueCount,
                icon: Icons.warning_amber_rounded,
                color: Colors.red,
                isAlert: overdueCount > 0,
                onTap: () => onSelectCategory(TaskFilterCategory.overdue),
              ),
              _buildMetricCard(
                context,
                key: 'metric_remaining',
                title: 'Remaining',
                count: remainingCount < 0 ? 0 : remainingCount,
                icon: Icons.pending_actions,
                color: Colors.blue,
                onTap: () => onSelectCategory(TaskFilterCategory.all),
              ),
              _buildMetricCard(
                context,
                key: 'metric_completed',
                title: 'Completed',
                count: completedCount,
                icon: Icons.task_alt,
                color: Colors.green,
                onTap: () => onSelectCategory(TaskFilterCategory.completed),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String key,
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    bool isAlert = false,
    required VoidCallback onTap,
  }) {
    return Card(
      key: Key(key),
      elevation: isAlert ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isAlert ? BorderSide(color: color, width: 2) : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 18),
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
