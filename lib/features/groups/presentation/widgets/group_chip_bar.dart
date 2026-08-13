import 'package:flutter/material.dart';
import '../../domain/entities/task_group.dart';

class GroupChipBar extends StatelessWidget {
  final List<TaskGroupEntity> groups;
  final String? selectedGroupId;
  final ValueChanged<String?> onGroupSelected;
  final VoidCallback onAddGroup;
  final VoidCallback onManageGroups;

  const GroupChipBar({
    super.key,
    required this.groups,
    required this.selectedGroupId,
    required this.onGroupSelected,
    required this.onAddGroup,
    required this.onManageGroups,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // All Tasks Chip
            ChoiceChip(
              key: const Key('group_chip_all'),
              selected: selectedGroupId == null,
              avatar: const Icon(Icons.apps, size: 18),
              label: const Text('All Tasks'),
              onSelected: (_) => onGroupSelected(null),
            ),
            const SizedBox(width: 8),

            // Dynamic Groups Chips (Data-Driven styling, no name hardcoding!)
            ...groups.map((group) {
              final isSelected = selectedGroupId == group.id;
              final accentColor = group.parsedColor;

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  key: Key('group_chip_${group.id}'),
                  selected: isSelected,
                  avatar: Icon(
                    group.parsedIcon,
                    size: 18,
                    color: isSelected ? Colors.white : accentColor,
                  ),
                  label: Text(group.name),
                  selectedColor: accentColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : null,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (_) => onGroupSelected(group.id),
                ),
              );
            }),

            // Add Group Action Chip
            ActionChip(
              key: const Key('add_group_chip'),
              avatar: const Icon(Icons.add, size: 18),
              label: const Text('New Group'),
              onPressed: onAddGroup,
            ),
            const SizedBox(width: 8),

            // Manage Groups Action Chip
            IconButton(
              key: const Key('manage_groups_button'),
              icon: const Icon(Icons.tune, size: 20),
              tooltip: 'Manage Groups',
              onPressed: onManageGroups,
            ),
          ],
        ),
      ),
    );
  }
}
