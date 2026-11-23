import 'package:apk_auth/models/project.dart';
import 'package:apk_auth/models/project_task.dart';
import 'package:apk_auth/providers/calendar_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('groups project and task deadlines by day', () {
    final date = DateTime(2026, 11, 22);
    final events = CalendarProvider.groupEvents(
      projects: [
        Project(id: 'p1', ownerId: 'u1', name: 'Projeto', dueDate: date),
      ],
      tasksByProject: {
        'p1': [
          ProjectTask(id: 't1', name: 'Tarefa', dueDate: date),
        ],
      },
    );

    expect(events[date]?.length, 2);
    expect(events[date]!.where((event) => event.isProject).length, 1);
    expect(events[date]!.where((event) => event.isTask).length, 1);
  });
}
