import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/project.dart';

class ProjectRepository {
  ProjectRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _projects(String uid) {
    return _firestore.collection('users').doc(uid).collection('projects');
  }

  Stream<List<Project>> watchProjects(String uid) {
    return _projects(uid).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) {
                final data = doc.data();
                data['id'] = doc.id;
                return Project.fromMap(data);
              })
              .toList(growable: false),
        );
  }

  Future<void> createProject(String uid, Project project) async {
    final now = DateTime.now().toUtc();
    await _projects(uid).doc(project.id).set(
          project
              .copyWith(
                ownerId: uid,
                createdAt: now,
                updatedAt: now,
              )
              .toMap(),
        );
  }

  Future<void> updateProject(String uid, Project project) async {
    await _projects(uid).doc(project.id).set(
          project
              .copyWith(ownerId: uid, updatedAt: DateTime.now().toUtc())
              .toMap(),
          SetOptions(merge: true),
        );
  }

  Future<void> deleteProject(String uid, String projectId) {
    return _projects(uid).doc(projectId).delete();
  }
}
