import 'package:apk_auth/models/project_task.dart';
import 'package:apk_auth/providers/task_provider.dart';
import 'package:apk_auth/repositories/project_repository.dart';
import 'package:apk_auth/repositories/task_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TaskProvider creates, completes, and deletes project tasks', () async {
    final firestore = FakeFirebaseFirestore();
    final provider = TaskProvider(
      taskRepository: TaskRepository(firestore),
      projectRepository: ProjectRepository(firestore),
    );

    await provider.load('uid-1', 'project-1');
    await provider.create(
      const ProjectTask(id: 'task-1', name: 'Escrever testes'),
    );
    await pumpEventQueue();

    expect(provider.tasks.single.name, 'Escrever testes');

    await provider.setCompleted('task-1', true);
    await pumpEventQueue();
    expect(provider.tasks.single.completed, isTrue);

    await provider.delete('task-1');
    await pumpEventQueue();
    expect(provider.tasks, isEmpty);

    provider.dispose();
  });
}
