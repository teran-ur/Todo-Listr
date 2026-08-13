import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/task.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.ownerId,
    super.groupId = 'default',
    required super.title,
    super.description,
    super.isCompleted = false,
    super.priority = TaskPriority.medium,
    super.dueDate,
    super.reminderDateTime,
    super.isReminderEnabled = false,
    super.sortOrder = 0.0,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      ownerId: entity.ownerId,
      groupId: entity.groupId,
      title: entity.title,
      description: entity.description,
      isCompleted: entity.isCompleted,
      priority: entity.priority,
      dueDate: entity.dueDate,
      reminderDateTime: entity.reminderDateTime,
      isReminderEnabled: entity.isReminderEnabled,
      sortOrder: entity.sortOrder,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      deletedAt: entity.deletedAt,
    );
  }

  factory TaskModel.fromFirestoreMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      ownerId: map['ownerId'] as String,
      groupId: map['groupId'] as String? ?? 'default',
      title: map['title'] as String,
      description: map['description'] as String?,
      isCompleted: map['isCompleted'] as bool? ?? false,
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      dueDate: map['dueDate'] != null
          ? (map['dueDate'] as Timestamp).toDate()
          : null,
      reminderDateTime: map['reminderDateTime'] != null
          ? (map['reminderDateTime'] as Timestamp).toDate()
          : null,
      isReminderEnabled: map['isReminderEnabled'] as bool? ?? false,
      sortOrder: (map['sortOrder'] as num?)?.toDouble() ?? 0.0,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      deletedAt: map['deletedAt'] != null
          ? (map['deletedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'groupId': groupId,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'priority': priority.name,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'reminderDateTime': reminderDateTime != null
          ? Timestamp.fromDate(reminderDateTime!)
          : null,
      'isReminderEnabled': isReminderEnabled,
      'sortOrder': sortOrder,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'deletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
    };
  }

  factory TaskModel.fromLocalMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      ownerId: map['ownerId'] as String,
      groupId: map['groupId'] as String? ?? 'default',
      title: map['title'] as String,
      description: map['description'] as String?,
      isCompleted: map['isCompleted'] as bool? ?? false,
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      dueDate: map['dueDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dueDate'] as int)
          : null,
      reminderDateTime: map['reminderDateTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['reminderDateTime'] as int)
          : null,
      isReminderEnabled: map['isReminderEnabled'] as bool? ?? false,
      sortOrder: (map['sortOrder'] as num?)?.toDouble() ?? 0.0,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
          : DateTime.now(),
      deletedAt: map['deletedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['deletedAt'] as int)
          : null,
    );
  }

  Map<String, dynamic> toLocalMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'groupId': groupId,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'priority': priority.name,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'reminderDateTime': reminderDateTime?.millisecondsSinceEpoch,
      'isReminderEnabled': isReminderEnabled,
      'sortOrder': sortOrder,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'deletedAt': deletedAt?.millisecondsSinceEpoch,
    };
  }
}
