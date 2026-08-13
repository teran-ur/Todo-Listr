import 'package:flutter/material.dart';
import '../../domain/entities/group_appearance.dart';
import '../../domain/entities/task_group.dart';

class GroupFormDialog extends StatefulWidget {
  final String userId;
  final TaskGroupEntity? initialGroup;
  final ValueChanged<TaskGroupEntity> onSubmit;

  const GroupFormDialog({
    super.key,
    required this.userId,
    this.initialGroup,
    required this.onSubmit,
  });

  @override
  State<GroupFormDialog> createState() => _GroupFormDialogState();
}

class _GroupFormDialogState extends State<GroupFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String? _description;
  late String _colorHex;
  late String _iconName;

  static const List<String> _colorOptions = [
    '#6750A4', // Purple
    '#2196F3', // Blue
    '#4CAF50', // Green
    '#FF9800', // Orange
    '#E91E63', // Pink
    '#00BCD4', // Cyan
  ];

  static const List<Map<String, dynamic>> _iconOptions = [
    {'name': 'folder', 'icon': Icons.folder_open, 'label': 'Folder'},
    {'name': 'work', 'icon': Icons.work_outline, 'label': 'Work'},
    {'name': 'school', 'icon': Icons.school_outlined, 'label': 'University'},
    {'name': 'personal', 'icon': Icons.person_outline, 'label': 'Personal'},
    {'name': 'fitness', 'icon': Icons.fitness_center, 'label': 'Fitness'},
    {'name': 'project', 'icon': Icons.account_tree_outlined, 'label': 'Project'},
  ];

  @override
  void initState() {
    super.initState();
    final g = widget.initialGroup;
    _name = g?.name ?? '';
    _description = g?.description;
    _colorHex = g?.colorHex ?? '#6750A4';
    _iconName = g?.iconName ?? 'folder';
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final now = DateTime.now();
      final group = TaskGroupEntity(
        id: widget.initialGroup?.id ?? now.millisecondsSinceEpoch.toString(),
        ownerId: widget.userId,
        name: _name.trim(),
        description: _description?.trim().isEmpty == true ? null : _description?.trim(),
        colorHex: _colorHex,
        iconName: _iconName,
        appearance: widget.initialGroup?.appearance ?? const GroupAppearanceEntity(),
        backgroundConfig: widget.initialGroup?.backgroundConfig ?? const {},
        layoutConfig: widget.initialGroup?.layoutConfig ?? 'list',
        sortOrder: widget.initialGroup?.sortOrder ?? 0.0,
        createdAt: widget.initialGroup?.createdAt ?? now,
        updatedAt: now,
      );

      widget.onSubmit(group);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialGroup != null;

    return AlertDialog(
      key: const Key('group_form_dialog'),
      title: Text(isEditing ? 'Edit Task Group' : 'New Task Group'),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  key: const Key('group_name_input'),
                  initialValue: _name,
                  decoration: const InputDecoration(
                    labelText: 'Group Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter a group name';
                    }
                    return null;
                  },
                  onSaved: (val) => _name = val!,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('group_description_input'),
                  initialValue: _description,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (val) => _description = val,
                ),
                const SizedBox(height: 16),

                // Color Picker
                Text('Accent Color', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  children: _colorOptions.map((hex) {
                    final color = Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
                    final isSelected = _colorHex == hex;

                    return GestureDetector(
                      onTap: () => setState(() => _colorHex = hex),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.black, width: 3)
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, size: 18, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Icon Picker
                Text('Group Icon', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _iconOptions.map((item) {
                    final iconName = item['name'] as String;
                    final iconData = item['icon'] as IconData;
                    final isSelected = _iconName == iconName;

                    return ChoiceChip(
                      selected: isSelected,
                      avatar: Icon(iconData, size: 18),
                      label: Text(item['label'] as String),
                      onSelected: (_) => setState(() => _iconName = iconName),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          key: const Key('group_submit_button'),
          onPressed: _submit,
          child: Text(isEditing ? 'Save Changes' : 'Create Group'),
        ),
      ],
    );
  }
}
