import 'package:flutter/material.dart';
import '../../domain/entities/task_group.dart';

class GroupManagementDialog extends StatefulWidget {
  final List<TaskGroupEntity> groups;
  final ValueChanged<TaskGroupEntity> onEditGroup;
  final ValueChanged<String> onDeleteGroup;
  final ValueChanged<List<TaskGroupEntity>> onReorderGroups;

  const GroupManagementDialog({
    super.key,
    required this.groups,
    required this.onEditGroup,
    required this.onDeleteGroup,
    required this.onReorderGroups,
  });

  @override
  State<GroupManagementDialog> createState() => _GroupManagementDialogState();
}

class _GroupManagementDialogState extends State<GroupManagementDialog> {
  late List<TaskGroupEntity> _groupsList;

  @override
  void initState() {
    super.initState();
    _groupsList = List.from(widget.groups);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: const Key('group_management_dialog'),
      title: const Text('Manage & Reorder Groups'),
      content: SizedBox(
        width: 420,
        height: 360,
        child: _groupsList.isEmpty
            ? const Center(child: Text('No custom groups created.'))
            : ReorderableListView.builder(
                itemCount: _groupsList.length,
                onReorderItem: (oldIndex, newIndex) {
                  setState(() {
                    final item = _groupsList.removeAt(oldIndex);
                    _groupsList.insert(newIndex, item);
                  });
                  widget.onReorderGroups(_groupsList);
                },
                itemBuilder: (context, index) {
                  final group = _groupsList[index];
                  return ListTile(
                    key: Key('manage_group_item_${group.id}'),
                    leading: CircleAvatar(
                      backgroundColor: group.parsedColor,
                      child: Icon(group.parsedIcon, size: 18, color: Colors.white),
                    ),
                    title: Text(group.name),
                    subtitle: group.description != null
                        ? Text(
                            group.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          tooltip: 'Edit Group',
                          onPressed: () {
                            Navigator.of(context).pop();
                            widget.onEditGroup(group);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                          tooltip: 'Delete Group',
                          onPressed: () {
                            widget.onDeleteGroup(group.id);
                            setState(() {
                              _groupsList.removeWhere((g) => g.id == group.id);
                            });
                          },
                        ),
                        const Icon(Icons.drag_handle),
                      ],
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
