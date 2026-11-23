import 'package:flutter/material.dart';

import '../models/project_task.dart';

class TaskTile extends StatelessWidget {
  const TaskTile(
      {super.key,
      required this.task,
      required this.onEdit,
      required this.onToggle,
      required this.onDelete});
  final ProjectTask task;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: ListTile(
      leading: IconButton(
          onPressed: onToggle,
          icon: Icon(task.completed
              ? Icons.check_circle
              : Icons.radio_button_unchecked)),
      title: Text(task.name,
          style: TextStyle(
              decoration: task.completed ? TextDecoration.lineThrough : null)),
      subtitle: Text(
          '${task.assigneeName ?? 'Sem responsável'}${task.dueDate == null ? '' : ' • ${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}'}'),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined)),
        IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline))
      ]),
    ));
  }
}
