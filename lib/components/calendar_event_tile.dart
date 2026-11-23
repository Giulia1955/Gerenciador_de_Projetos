import 'package:flutter/material.dart';

import '../providers/calendar_provider.dart';
import '../theme/app_theme.dart';

class CalendarEventTile extends StatelessWidget {
  const CalendarEventTile(
      {super.key, required this.event, required this.onTap});
  final CalendarEvent event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(event.isProject ? Icons.folder : Icons.task_alt,
            color: AppTheme.accent),
        title: Text(event.title),
        subtitle:
            Text(event.isProject ? 'Prazo do projeto' : 'Prazo da tarefa'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
