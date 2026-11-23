import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/project_task.dart';

class TaskRepository {
  TaskRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _tasks(
    String uid,
    String projectId,
  ) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('projects')
        .doc(projectId)
        .collection('tasks');
  }

  Stream<List<ProjectTask>> watchTasks(String uid, String projectId) {
    return _tasks(uid, projectId).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return ProjectTask.fromMap(data);
          }).toList(growable: false),
        );
  }

  Future<void> createTask(
    String uid,
    String projectId,
    ProjectTask task,
  ) async {
    final now = DateTime.now().toUtc();
    await _tasks(uid, projectId).doc(task.id).set(
          task.copyWith(createdAt: now, updatedAt: now).toMap(),
        );
  }

  Future<void> updateTask(
    String uid,
    String projectId,
    ProjectTask task,
  ) async {
    await _tasks(uid, projectId).doc(task.id).set(
          task.copyWith(updatedAt: DateTime.now().toUtc()).toMap(),
          SetOptions(merge: true),
        );
  }

  Future<void> deleteTask(
    String uid,
    String projectId,
    String taskId,
  ) {
    return _tasks(uid, projectId).doc(taskId).delete();
  }

  Future<void> setTaskCompleted(
    String uid,
    String projectId,
    String taskId,
    bool completed,
  ) {
    return _tasks(uid, projectId).doc(taskId).set(
      {
        'completed': completed,
        'updatedAt': Timestamp.fromDate(DateTime.now().toUtc()),
      },
      SetOptions(merge: true),
    );
  }
}
