import 'package:apk_auth/models/project_task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProjectTask', () {
    test('fromMap and toMap round trip with completed and timestamps', () {
      final due = DateTime.utc(2026, 12, 5, 10);
      final updated = DateTime.utc(2026, 11, 21, 14);
      final created = DateTime.utc(2026, 11, 2, 9);
      final task = ProjectTask.fromMap({
        'id': 'task-1',
        'name': 'Design models',
        'description': 'Create the data classes',
        'assigneeName': 'Giulia',
        'dueDate': Timestamp.fromDate(due),
        'completed': true,
        'updatedAt': Timestamp.fromDate(updated),
        'createdAt': Timestamp.fromDate(created),
      });

      expect(task.id, 'task-1');
      expect(task.name, 'Design models');
      expect(task.description, 'Create the data classes');
      expect(task.assigneeName, 'Giulia');
      expect(task.dueDate, due);
      expect(task.completed, isTrue);
      expect(task.updatedAt, updated);
      expect(task.createdAt, created);

      final mapped = task.toMap();
      expect(mapped['dueDate'], isA<Timestamp>());
      expect(mapped['completed'], isTrue);
      expect(mapped['updatedAt'], isA<Timestamp>());
      expect(mapped['createdAt'], isA<Timestamp>());
      expect(ProjectTask.fromMap(mapped), task);
    });

    test('accepts DateTime, numeric timestamps and null values', () {
      final due = DateTime.utc(2027, 2, 3);
      final task = ProjectTask.fromMap({
        'id': 'task-2',
        'name': 'Test models',
        'description': null,
        'assigneeName': null,
        'dueDate': due,
        'completed': false,
        'updatedAt': due.millisecondsSinceEpoch,
        'createdAt': null,
      });

      expect(task.dueDate, due);
      expect(task.completed, isFalse);
      expect(task.updatedAt, due);
      expect(task.createdAt, isNull);
      expect(task.copyWith(name: 'Updated test').name, 'Updated test');
    });
  });
}
