import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apk_auth/models/project.dart';
import 'package:apk_auth/models/project_task.dart';
import 'package:apk_auth/repositories/project_repository.dart';
import 'package:apk_auth/repositories/task_repository.dart';

void main() {
  group('ProjectRepository', () {
    late FakeFirebaseFirestore firestore;
    late ProjectRepository repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repository = ProjectRepository(firestore);
    });

    test('creates, lists, updates, and deletes projects under the explicit uid', () async {
      const project = Project(
        id: 'project-1',
        ownerId: 'uid-1',
        name: 'Website',
      );

      await repository.createProject('uid-1', project);

      final initial = await repository.watchProjects('uid-1').first;
      expect(initial.map((item) => item.id), ['project-1']);

      await repository.updateProject(
        'uid-1',
        project.copyWith(name: 'Mobile app'),
      );
      final updated = await repository.watchProjects('uid-1').first;
      expect(updated.single.name, 'Mobile app');
      expect(updated.single.updatedAt, isNotNull);

      await repository.deleteProject('uid-1', 'project-1');
      final deleted = await repository.watchProjects('uid-1').first;
      expect(deleted, isEmpty);

      expect(
        (await firestore
                .collection('users')
                .doc('uid-1')
                .collection('projects')
                .get())
            .docs,
        isEmpty,
      );
    });
  });

  group('TaskRepository', () {
    late FakeFirebaseFirestore firestore;
    late TaskRepository repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repository = TaskRepository(firestore);
    });

    test('creates, lists, updates, completes, and deletes tasks', () async {
      const task = ProjectTask(
        id: 'task-1',
        name: 'Write tests',
      );

      await repository.createTask('uid-1', 'project-1', task);

      final initial = await repository.watchTasks('uid-1', 'project-1').first;
      expect(initial.map((item) => item.id), ['task-1']);

      await repository.updateTask(
        'uid-1',
        'project-1',
        task.copyWith(name: 'Run tests'),
      );
      var tasks = await repository.watchTasks('uid-1', 'project-1').first;
      expect(tasks.single.name, 'Run tests');
      expect(tasks.single.updatedAt, isNotNull);

      await repository.setTaskCompleted(
        'uid-1',
        'project-1',
        'task-1',
        true,
      );
      tasks = await repository.watchTasks('uid-1', 'project-1').first;
      expect(tasks.single.completed, isTrue);

      await repository.deleteTask('uid-1', 'project-1', 'task-1');
      tasks = await repository.watchTasks('uid-1', 'project-1').first;
      expect(tasks, isEmpty);
    });
  });
}
