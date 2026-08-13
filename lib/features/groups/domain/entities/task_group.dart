import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'group_appearance.dart';

/// Domain entity representing a customizable Task Group
class TaskGroupEntity extends Equatable {
  final String id;
  final String ownerId;
  final String name;
  final String? description;
  final String colorHex;
  final String iconName;
  final GroupAppearanceEntity appearance;
  final Map<String, dynamic> backgroundConfig;
  final String layoutConfig;
  final double sortOrder;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const TaskGroupEntity({
    required this.id,
    required this.ownerId,
    required this.name,
    this.description,
    required this.colorHex,
    required this.iconName,
    this.appearance = const GroupAppearanceEntity(),
    this.backgroundConfig = const {},
    this.layoutConfig = 'list',
    required this.sortOrder,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Data-driven color parsing from Hex string (No name hardcoding!)
  Color get parsedColor {
    final hexString = colorHex.replaceAll('#', '');
    if (hexString.length == 6) {
      return Color(int.parse('FF$hexString', radix: 16));
    } else if (hexString.length == 8) {
      return Color(int.parse(hexString, radix: 16));
    }
    return const Color(0xFF6750A4); // Fallback color
  }

  /// Data-driven Material Icon parsing from stored identifier string
  IconData get parsedIcon {
    switch (iconName) {
      case 'work':
        return Icons.work_outline;
      case 'school':
      case 'university':
        return Icons.school_outlined;
      case 'person':
      case 'personal':
        return Icons.person_outline;
      case 'fitness':
      case 'health':
        return Icons.fitness_center;
      case 'project':
      case 'folder':
        return Icons.folder_open;
      case 'star':
        return Icons.star_border;
      case 'shopping':
        return Icons.shopping_cart_outlined;
      case 'home':
        return Icons.home_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  TaskGroupEntity copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? description,
    String? colorHex,
    String? iconName,
    GroupAppearanceEntity? appearance,
    Map<String, dynamic>? backgroundConfig,
    String? layoutConfig,
    double? sortOrder,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return TaskGroupEntity(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
      colorHex: colorHex ?? this.colorHex,
      iconName: iconName ?? this.iconName,
      appearance: appearance ?? this.appearance,
      backgroundConfig: backgroundConfig ?? this.backgroundConfig,
      layoutConfig: layoutConfig ?? this.layoutConfig,
      sortOrder: sortOrder ?? this.sortOrder,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        ownerId,
        name,
        description,
        colorHex,
        iconName,
        appearance,
        backgroundConfig,
        layoutConfig,
        sortOrder,
        isArchived,
        createdAt,
        updatedAt,
        deletedAt,
      ];
}
