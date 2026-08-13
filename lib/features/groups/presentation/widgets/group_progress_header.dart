import 'package:flutter/material.dart';
import '../../domain/entities/group_appearance.dart';
import '../../domain/entities/task_group.dart';

class GroupProgressHeader extends StatelessWidget {
  final TaskGroupEntity? group;
  final int totalTasks;
  final int completedTasks;

  const GroupProgressHeader({
    super.key,
    this.group,
    required this.totalTasks,
    required this.completedTasks,
  });

  @override
  Widget build(BuildContext context) {
    if (group == null || totalTasks == 0) {
      return const SizedBox.shrink();
    }

    final double progress = completedTasks / totalTasks;
    final int percent = (progress * 100).round();
    final accentColor = group!.parsedColor;
    final style = group!.appearance.progressStyle;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accentColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: accentColor,
              child: Icon(group!.parsedIcon, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group!.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '$completedTasks of $totalTasks tasks completed ($percent%)',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                  if (style == GroupProgressStyle.bar) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: accentColor.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (style == GroupProgressStyle.badge)
              Chip(
                backgroundColor: accentColor,
                label: Text(
                  '$percent%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            if (style == GroupProgressStyle.ring)
              SizedBox(
                width: 36,
                height: 36,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 4,
                      backgroundColor: accentColor.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                    ),
                    Text(
                      '$percent%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
