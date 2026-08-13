import 'package:equatable/equatable.dart';

enum TaskPriority { low, medium, high }

enum TaskFilterCategory { all, today, upcoming, overdue, completed }

enum TaskSortOption { dueDate, priority, title, createdAt }

/// Domain entity representing a personal Task
class TaskEntity extends Equatable {
  final String id;
  final String ownerId;
  final String groupId;
  final String title;
  final String? description;
  final bool isCompleted;
  final TaskPriority priority;
  final DateTime? dueDate;
  final DateTime? reminderDateTime;
  final bool isReminderEnabled;
  final double sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const TaskEntity({
    required this.id,
    required this.ownerId,
    this.groupId = 'default',
    required this.title,
    this.description,
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    this.dueDate,
    this.reminderDateTime,
    this.isReminderEnabled = false,
    this.sortOrder = 0.0,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Helper getter to check if task is overdue
  bool get isOverdue {
    if (isCompleted || dueDate == null) return false;
    final now = DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return dueDate!.isBefore(todayEnd) && !isDueToday;
  }

  /// Helper getter to check if task is due today
  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  /// Helper getter to check if task is upcoming (future due date)
  bool get isUpcoming {
    if (isCompleted || dueDate == null) return false;
    final now = DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return dueDate!.isAfter(todayEnd);
  }

  TaskEntity copyWith({
    String? id,
    String? ownerId,
    String? groupId,
    String? title,
    String? description,
    bool? isCompleted,
    TaskPriority? priority,
    DateTime? dueDate,
    DateTime? reminderDateTime,
    bool? isReminderEnabled,
    double? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      groupId: groupId ?? this.groupId,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      reminderDateTime: reminderDateTime ?? this.reminderDateTime,
      isReminderEnabled: isReminderEnabled ?? this.isReminderEnabled,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        ownerId,
        groupId,
        title,
        description,
        isCompleted,
        priority,
        dueDate,
        reminderDateTime,
        isReminderEnabled,
        sortOrder,
        createdAt,
        updatedAt,
        deletedAt,
      ];
}
