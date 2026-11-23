import 'package:flutter/foundation.dart';

import '../models/project.dart';
import '../models/project_task.dart';

class CalendarEvent {
  const CalendarEvent.project(this.project)
      : task = null,
        projectId = null;
  const CalendarEvent.task(this.projectId, this.task) : project = null;

  final Project? project;
  final ProjectTask? task;
  final String? projectId;
  bool get isProject => project != null;
  bool get isTask => task != null;
  String get title => project?.name ?? task?.name ?? '';
}

class CalendarProvider extends ChangeNotifier {
  CalendarProvider({required this.projects, this.tasksByProject = const {}});

  final List<Project> projects;
  final Map<String, List<ProjectTask>> tasksByProject;

  static Map<DateTime, List<CalendarEvent>> groupEvents({
    required List<Project> projects,
    required Map<String, List<ProjectTask>> tasksByProject,
  }) {
    final events = <DateTime, List<CalendarEvent>>{};
    DateTime day(DateTime value) =>
        DateTime(value.year, value.month, value.day);
    for (final project in projects) {
      if (project.dueDate != null) {
        events
            .putIfAbsent(day(project.dueDate!), () => [])
            .add(CalendarEvent.project(project));
      }
      for (final task in tasksByProject[project.id] ?? const []) {
        if (task.dueDate != null) {
          events
              .putIfAbsent(day(task.dueDate!), () => [])
              .add(CalendarEvent.task(project.id, task));
        }
      }
    }
    return events;
  }

  Map<DateTime, List<CalendarEvent>> get events =>
      groupEvents(projects: projects, tasksByProject: tasksByProject);
}
