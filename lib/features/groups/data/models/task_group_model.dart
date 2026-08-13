import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/group_appearance.dart';
import '../../domain/entities/task_group.dart';

class TaskGroupModel extends TaskGroupEntity {
  const TaskGroupModel({
    required super.id,
    required super.ownerId,
    required super.name,
    super.description,
    required super.colorHex,
    required super.iconName,
    super.appearance,
    super.backgroundConfig,
    super.layoutConfig,
    required super.sortOrder,
    super.isArchived,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  factory TaskGroupModel.fromEntity(TaskGroupEntity entity) {
    return TaskGroupModel(
      id: entity.id,
      ownerId: entity.ownerId,
      name: entity.name,
      description: entity.description,
      colorHex: entity.colorHex,
      iconName: entity.iconName,
      appearance: entity.appearance,
      backgroundConfig: entity.backgroundConfig,
      layoutConfig: entity.layoutConfig,
      sortOrder: entity.sortOrder,
      isArchived: entity.isArchived,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      deletedAt: entity.deletedAt,
    );
  }

  factory TaskGroupModel.fromFirestoreMap(Map<String, dynamic> map) {
    return TaskGroupModel(
      id: map['id'] as String,
      ownerId: map['ownerId'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      colorHex: map['colorHex'] as String? ?? '#6750A4',
      iconName: map['iconName'] as String? ?? 'folder',
      appearance: map['appearance'] != null
          ? GroupAppearanceEntity.fromMap(map['appearance'] as Map<String, dynamic>)
          : const GroupAppearanceEntity(),
      backgroundConfig: (map['backgroundConfig'] as Map<String, dynamic>?) ?? const {},
      layoutConfig: map['layoutConfig'] as String? ?? 'list',
      sortOrder: (map['sortOrder'] as num?)?.toDouble() ?? 0.0,
      isArchived: map['isArchived'] as bool? ?? false,
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
      'name': name,
      'description': description,
      'colorHex': colorHex,
      'iconName': iconName,
      'appearance': appearance.toMap(),
      'backgroundConfig': backgroundConfig,
      'layoutConfig': layoutConfig,
      'sortOrder': sortOrder,
      'isArchived': isArchived,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'deletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
    };
  }

  factory TaskGroupModel.fromLocalMap(Map<String, dynamic> map) {
    return TaskGroupModel(
      id: map['id'] as String,
      ownerId: map['ownerId'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      colorHex: map['colorHex'] as String? ?? '#6750A4',
      iconName: map['iconName'] as String? ?? 'folder',
      appearance: map['appearance'] != null
          ? GroupAppearanceEntity.fromMap(map['appearance'] as Map<String, dynamic>)
          : const GroupAppearanceEntity(),
      backgroundConfig: (map['backgroundConfig'] as Map<String, dynamic>?) ?? const {},
      layoutConfig: map['layoutConfig'] as String? ?? 'list',
      sortOrder: (map['sortOrder'] as num?)?.toDouble() ?? 0.0,
      isArchived: map['isArchived'] as bool? ?? false,
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
      'name': name,
      'description': description,
      'colorHex': colorHex,
      'iconName': iconName,
      'appearance': appearance.toMap(),
      'backgroundConfig': backgroundConfig,
      'layoutConfig': layoutConfig,
      'sortOrder': sortOrder,
      'isArchived': isArchived,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'deletedAt': deletedAt?.millisecondsSinceEpoch,
    };
  }
}
