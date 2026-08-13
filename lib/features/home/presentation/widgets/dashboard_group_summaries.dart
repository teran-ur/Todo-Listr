import 'package:flutter/material.dart';
import '../../../groups/domain/entities/task_group.dart';

class DashboardGroupSummaries extends StatelessWidget {
  final List<TaskGroupEntity> groups;
  final String? selectedGroupId;
  final ValueChanged<String?> onSelectGroup;

  const DashboardGroupSummaries({
    super.key,
    required this.groups,
    required this.selectedGroupId,
    required this.onSelectGroup,
  });

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Text(
            'Groups Summary',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              final isSelected = selectedGroupId == group.id;
              final accentColor = group.parsedColor;

              return SizedBox(
                width: 140,
                child: Card(
                  key: Key('summary_group_${group.id}'),
                  elevation: isSelected ? 3 : 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: isSelected
                        ? BorderSide(color: accentColor, width: 2)
                        : BorderSide.none,
                  ),
                  child: InkWell(
                    onTap: () => onSelectGroup(group.id),
                    borderRadius: BorderRadius.circular(12),
                    hoverColor: accentColor.withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: accentColor,
                                child: Icon(
                                  group.parsedIcon,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  group.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
