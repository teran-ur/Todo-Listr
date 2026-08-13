import 'package:equatable/equatable.dart';

enum GroupCardStyle { elevated, outlined, flat }

enum GroupLayoutStyle { list, grid }

enum GroupProgressStyle { bar, ring, badge }

class GroupAppearanceEntity extends Equatable {
  final GroupCardStyle cardStyle;
  final GroupLayoutStyle layoutStyle;
  final GroupProgressStyle progressStyle;

  const GroupAppearanceEntity({
    this.cardStyle = GroupCardStyle.elevated,
    this.layoutStyle = GroupLayoutStyle.list,
    this.progressStyle = GroupProgressStyle.bar,
  });

  GroupAppearanceEntity copyWith({
    GroupCardStyle? cardStyle,
    GroupLayoutStyle? layoutStyle,
    GroupProgressStyle? progressStyle,
  }) {
    return GroupAppearanceEntity(
      cardStyle: cardStyle ?? this.cardStyle,
      layoutStyle: layoutStyle ?? this.layoutStyle,
      progressStyle: progressStyle ?? this.progressStyle,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cardStyle': cardStyle.name,
      'layoutStyle': layoutStyle.name,
      'progressStyle': progressStyle.name,
    };
  }

  factory GroupAppearanceEntity.fromMap(Map<String, dynamic> map) {
    return GroupAppearanceEntity(
      cardStyle: GroupCardStyle.values.firstWhere(
        (e) => e.name == map['cardStyle'],
        orElse: () => GroupCardStyle.elevated,
      ),
      layoutStyle: GroupLayoutStyle.values.firstWhere(
        (e) => e.name == map['layoutStyle'],
        orElse: () => GroupLayoutStyle.list,
      ),
      progressStyle: GroupProgressStyle.values.firstWhere(
        (e) => e.name == map['progressStyle'],
        orElse: () => GroupProgressStyle.bar,
      ),
    );
  }

  @override
  List<Object?> get props => [cardStyle, layoutStyle, progressStyle];
}
