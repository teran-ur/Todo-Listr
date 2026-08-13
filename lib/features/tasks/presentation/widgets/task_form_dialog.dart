import 'package:flutter/material.dart';
import '../../../groups/domain/entities/task_group.dart';
import '../../domain/entities/task.dart';

class TaskFormDialog extends StatefulWidget {
  final String userId;
  final TaskEntity? initialTask;
  final List<TaskGroupEntity> availableGroups;
  final ValueChanged<TaskEntity> onSubmit;

  const TaskFormDialog({
    super.key,
    required this.userId,
    this.initialTask,
    required this.availableGroups,
    required this.onSubmit,
  });

  @override
  State<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<TaskFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String? _description;
  late String _groupId;
  late TaskPriority _priority;
  late DateTime? _dueDate;
  late DateTime? _reminderDateTime;
  late bool _isReminderEnabled;

  @override
  void initState() {
    super.initState();
    final task = widget.initialTask;
    _title = task?.title ?? '';
    _description = task?.description;
    _groupId = task?.groupId ?? 'default';
    _priority = task?.priority ?? TaskPriority.medium;
    _dueDate = task?.dueDate;
    _reminderDateTime = task?.reminderDateTime;
    _isReminderEnabled = task?.isReminderEnabled ?? false;
  }

  Future<void> _pickDueDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() => _dueDate = pickedDate);
    }
  }

  Future<void> _pickReminderTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _reminderDateTime ?? now,
      firstDate: now,
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: _reminderDateTime != null
            ? TimeOfDay.fromDateTime(_reminderDateTime!)
            : TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _reminderDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _isReminderEnabled = true;
        });
      }
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final now = DateTime.now();
      final task = TaskEntity(
        id: widget.initialTask?.id ?? now.millisecondsSinceEpoch.toString(),
        ownerId: widget.userId,
        groupId: _groupId,
        title: _title.trim(),
        description: _description?.trim().isEmpty == true ? null : _description?.trim(),
        isCompleted: widget.initialTask?.isCompleted ?? false,
        priority: _priority,
        dueDate: _dueDate,
        reminderDateTime: _reminderDateTime,
        isReminderEnabled: _isReminderEnabled,
        sortOrder: widget.initialTask?.sortOrder ?? 0.0,
        createdAt: widget.initialTask?.createdAt ?? now,
        updatedAt: now,
      );

      widget.onSubmit(task);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialTask != null;

    return AlertDialog(
      key: const Key('task_form_dialog'),
      title: Text(isEditing ? 'Edit Task' : 'New Task'),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  key: const Key('task_title_input'),
                  initialValue: _title,
                  decoration: const InputDecoration(
                    labelText: 'Task Title *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter a task title';
                    }
                    return null;
                  },
                  onSaved: (val) => _title = val!,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('task_description_input'),
                  initialValue: _description,
                  decoration: const InputDecoration(
                    labelText: 'Description / Notes (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  onSaved: (val) => _description = val,
                ),
                const SizedBox(height: 12),

                // Group Selector Dropdown
                DropdownButtonFormField<String>(
                  key: const Key('task_group_dropdown'),
                  initialValue: widget.availableGroups.any((g) => g.id == _groupId)
                      ? _groupId
                      : 'default',
                  decoration: const InputDecoration(
                    labelText: 'Assign Group',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: 'default',
                      child: Text('Unassigned'),
                    ),
                    ...widget.availableGroups.map((g) => DropdownMenuItem(
                          value: g.id,
                          child: Row(
                            children: [
                              Icon(g.parsedIcon, size: 18, color: g.parsedColor),
                              const SizedBox(width: 8),
                              Text(g.name),
                            ],
                          ),
                        )),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _groupId = val);
                  },
                ),
                const SizedBox(height: 12),

                // Priority Dropdown
                DropdownButtonFormField<TaskPriority>(
                  key: const Key('task_priority_dropdown'),
                  initialValue: _priority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  items: TaskPriority.values.map((p) {
                    return DropdownMenuItem(
                      value: p,
                      child: Text(p.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _priority = val);
                  },
                ),
                const SizedBox(height: 12),

                // Due Date Selector
                ListTile(
                  key: const Key('task_due_date_tile'),
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: Text(_dueDate == null
                      ? 'No Due Date'
                      : 'Due: ${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'),
                  trailing: TextButton(
                    onPressed: _pickDueDate,
                    child: Text(_dueDate == null ? 'Set Date' : 'Change'),
                  ),
                ),

                // Task Reminder & Notification Settings
                const Divider(),
                SwitchListTile(
                  key: const Key('task_reminder_switch'),
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.notifications_active_outlined),
                  title: const Text('Enable Reminder Notification'),
                  value: _isReminderEnabled,
                  onChanged: (val) {
                    setState(() {
                      _isReminderEnabled = val;
                      if (val && _reminderDateTime == null) {
                        _pickReminderTime();
                      }
                    });
                  },
                ),
                if (_isReminderEnabled)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_reminderDateTime == null
                        ? 'Select reminder time'
                        : 'Reminder: ${_reminderDateTime!.day}/${_reminderDateTime!.month}/${_reminderDateTime!.year} at ${_reminderDateTime!.hour.toString().padLeft(2, '0')}:${_reminderDateTime!.minute.toString().padLeft(2, '0')}'),
                    trailing: TextButton(
                      onPressed: _pickReminderTime,
                      child: Text(_reminderDateTime == null ? 'Pick Time' : 'Change'),
                    ),
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
          key: const Key('task_submit_button'),
          onPressed: _submit,
          child: Text(isEditing ? 'Save Changes' : 'Create Task'),
        ),
      ],
    );
  }
}
