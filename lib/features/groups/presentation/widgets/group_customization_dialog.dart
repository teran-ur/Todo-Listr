import 'package:flutter/material.dart';
import '../../domain/entities/group_appearance.dart';
import '../../domain/entities/task_group.dart';

class GroupCustomizationDialog extends StatefulWidget {
  final TaskGroupEntity group;
  final ValueChanged<TaskGroupEntity> onSave;

  const GroupCustomizationDialog({
    super.key,
    required this.group,
    required this.onSave,
  });

  @override
  State<GroupCustomizationDialog> createState() => _GroupCustomizationDialogState();
}

class _GroupCustomizationDialogState extends State<GroupCustomizationDialog> {
  late String _colorHex;
  late String _iconName;
  late GroupCardStyle _cardStyle;
  late GroupLayoutStyle _layoutStyle;
  late GroupProgressStyle _progressStyle;

  static const List<String> _colorOptions = [
    '#6750A4', // Purple
    '#2196F3', // Blue
    '#4CAF50', // Green
    '#FF9800', // Orange
    '#E91E63', // Pink
    '#00BCD4', // Cyan
    '#9C27B0', // Deep Purple
    '#795548', // Brown
  ];

  static const List<Map<String, dynamic>> _iconOptions = [
    {'name': 'folder', 'icon': Icons.folder_open, 'label': 'Folder'},
    {'name': 'work', 'icon': Icons.work_outline, 'label': 'Work'},
    {'name': 'school', 'icon': Icons.school_outlined, 'label': 'University'},
    {'name': 'personal', 'icon': Icons.person_outline, 'label': 'Personal'},
    {'name': 'fitness', 'icon': Icons.fitness_center, 'label': 'Fitness'},
    {'name': 'project', 'icon': Icons.account_tree_outlined, 'label': 'Project'},
    {'name': 'shopping', 'icon': Icons.shopping_cart_outlined, 'label': 'Shopping'},
    {'name': 'home', 'icon': Icons.home_outlined, 'label': 'Home'},
  ];

  @override
  void initState() {
    super.initState();
    _colorHex = widget.group.colorHex;
    _iconName = widget.group.iconName;
    _cardStyle = widget.group.appearance.cardStyle;
    _layoutStyle = widget.group.appearance.layoutStyle;
    _progressStyle = widget.group.appearance.progressStyle;
  }

  Color get _parsedColor {
    final hexString = _colorHex.replaceAll('#', '');
    if (hexString.length == 6) {
      return Color(int.parse('FF$hexString', radix: 16));
    }
    return const Color(0xFF6750A4);
  }

  IconData get _parsedIcon {
    final found = _iconOptions.firstWhere(
      (item) => item['name'] == _iconName,
      orElse: () => _iconOptions.first,
    );
    return found['icon'] as IconData;
  }

  void _submit() {
    final updated = widget.group.copyWith(
      colorHex: _colorHex,
      iconName: _iconName,
      appearance: widget.group.appearance.copyWith(
        cardStyle: _cardStyle,
        layoutStyle: _layoutStyle,
        progressStyle: _progressStyle,
      ),
      updatedAt: DateTime.now(),
    );

    widget.onSave(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: const Key('group_customization_dialog'),
      title: Text('Customize "${widget.group.name}"'),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Live Visual Preview Box
              Text('Live Visual Preview', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              _buildLivePreviewCard(),
              const SizedBox(height: 20),

              // Accent Color Palette
              Text('Accent Color', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _colorOptions.map((hex) {
                  final color = Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
                  final isSelected = _colorHex == hex;

                  return GestureDetector(
                    onTap: () => setState(() => _colorHex = hex),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.black, width: 3)
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 20, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Icon Selector
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
              const SizedBox(height: 16),

              // Card Style Selector
              Text('Card Style', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<GroupCardStyle>(
                key: const Key('card_style_segmented_button'),
                segments: const [
                  ButtonSegment(value: GroupCardStyle.elevated, label: Text('Elevated')),
                  ButtonSegment(value: GroupCardStyle.outlined, label: Text('Outlined')),
                  ButtonSegment(value: GroupCardStyle.flat, label: Text('Flat')),
                ],
                selected: {_cardStyle},
                onSelectionChanged: (set) => setState(() => _cardStyle = set.first),
              ),
              const SizedBox(height: 16),

              // Layout Style Selector
              Text('Layout Mode', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<GroupLayoutStyle>(
                key: const Key('layout_style_segmented_button'),
                segments: const [
                  ButtonSegment(
                    value: GroupLayoutStyle.list,
                    icon: Icon(Icons.view_list),
                    label: Text('List'),
                  ),
                  ButtonSegment(
                    value: GroupLayoutStyle.grid,
                    icon: Icon(Icons.grid_view),
                    label: Text('Grid'),
                  ),
                ],
                selected: {_layoutStyle},
                onSelectionChanged: (set) => setState(() => _layoutStyle = set.first),
              ),
              const SizedBox(height: 16),

              // Progress Visualization Style Selector
              Text('Progress Visualization', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<GroupProgressStyle>(
                key: const Key('progress_style_segmented_button'),
                segments: const [
                  ButtonSegment(value: GroupProgressStyle.bar, label: Text('Bar')),
                  ButtonSegment(value: GroupProgressStyle.ring, label: Text('Ring')),
                  ButtonSegment(value: GroupProgressStyle.badge, label: Text('Badge')),
                ],
                selected: {_progressStyle},
                onSelectionChanged: (set) => setState(() => _progressStyle = set.first),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          key: const Key('save_customization_button'),
          onPressed: _submit,
          child: const Text('Save Customization'),
        ),
      ],
    );
  }

  Widget _buildLivePreviewCard() {
    return Card(
      elevation: _cardStyle == GroupCardStyle.elevated ? 4 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: _cardStyle == GroupCardStyle.outlined
            ? BorderSide(color: _parsedColor, width: 2)
            : BorderSide.none,
      ),
      color: _cardStyle == GroupCardStyle.flat
          ? _parsedColor.withValues(alpha: 0.12)
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _parsedColor,
                  child: Icon(_parsedIcon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.group.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        'Style: ${_cardStyle.name.toUpperCase()} • Layout: ${_layoutStyle.name.toUpperCase()}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                if (_progressStyle == GroupProgressStyle.badge)
                  Chip(
                    backgroundColor: _parsedColor.withValues(alpha: 0.2),
                    label: Text(
                      '75%',
                      style: TextStyle(color: _parsedColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                if (_progressStyle == GroupProgressStyle.ring)
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      value: 0.75,
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation<Color>(_parsedColor),
                    ),
                  ),
              ],
            ),
            if (_progressStyle == GroupProgressStyle.bar) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: 0.75,
                backgroundColor: _parsedColor.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(_parsedColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
