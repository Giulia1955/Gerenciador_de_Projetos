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

  test('normalizes project and task deadlines for calendar lookup', () {
    final projectDate = DateTime(2026, 11, 22, 18, 45);
    final taskDate = DateTime(2026, 11, 22, 8, 15);
    final lookupDate = DateTime(2026, 11, 22);
    final events = CalendarProvider.groupEvents(
      projects: [
        Project(
          id: 'p1',
          ownerId: 'u1',
          name: 'Projeto',
          dueDate: projectDate,
        ),
      ],
      tasksByProject: {
        'p1': [
          ProjectTask(id: 't1', name: 'Tarefa', dueDate: taskDate),
        ],
      },
    );

    expect(events.keys, contains(lookupDate));
    expect(events[lookupDate], hasLength(2));
    expect(events[lookupDate]!.where((event) => event.isProject), hasLength(1));
    expect(events[lookupDate]!.where((event) => event.isTask), hasLength(1));
  });
}
