import 'package:flutter/material.dart';

class TaskSearchBar extends StatelessWidget {
  final String query;
  final ValueChanged<String> onChanged;

  const TaskSearchBar({
    super.key,
    required this.query,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        key: const Key('task_search_input'),
        controller: TextEditingController(text: query)
          ..selection = TextSelection.collapsed(offset: query.length),
        decoration: InputDecoration(
          hintText: 'Search tasks by title or notes...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => onChanged(''),
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
