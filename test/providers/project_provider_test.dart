import 'dart:async';

import 'package:apk_auth/models/project.dart';
import 'package:apk_auth/providers/project_provider.dart';
import 'package:apk_auth/repositories/project_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProjectProvider', () {
    late FakeFirebaseFirestore firestore;
    late ProjectRepository repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repository = ProjectRepository(firestore);
    });

    test('loads projects and exposes loading, success, and empty states',
        () async {
      final authStates = StreamController<String?>();
      final provider = ProjectProvider(
        repository: repository,
        authStateChanges: authStates.stream,
      );

      expect(provider.status, ProjectProviderStatus.loading);

      authStates.add('uid-1');
      await pumpEventQueue();
      expect(provider.status, ProjectProviderStatus.empty);
      expect(provider.projects, isEmpty);

      await repository.createProject(
        'uid-1',
        const Project(id: 'project-1', ownerId: 'uid-1', name: 'Website'),
      );
      await pumpEventQueue();

      expect(provider.status, ProjectProviderStatus.success);
      expect(provider.projects.single.name, 'Website');

      await authStates.close();
      provider.dispose();
    });

    test('creates and deletes projects for the authenticated uid', () async {
      final authStates = StreamController<String?>();
      final provider = ProjectProvider(
        repository: repository,
        authStateChanges: authStates.stream,
      );

      authStates.add('uid-1');
      await pumpEventQueue();

      await provider.createProject(
        const Project(id: 'project-1', ownerId: '', name: 'Website'),
      );
      await pumpEventQueue();

      expect(provider.projects.single.ownerId, 'uid-1');

      await provider.deleteProject('project-1');
      await pumpEventQueue();

      expect(provider.status, ProjectProviderStatus.empty);

      await authStates.close();
      provider.dispose();
    });

    test('updates projects for the authenticated uid', () async {
      final authStates = StreamController<String?>();
      final provider = ProjectProvider(
        repository: repository,
        authStateChanges: authStates.stream,
      );

      authStates.add('uid-1');
      await pumpEventQueue();

      await provider.createProject(
        const Project(id: 'project-1', ownerId: '', name: 'Website'),
      );
      await pumpEventQueue();

      await provider.updateProject(
        const Project(id: 'project-1', ownerId: '', name: 'Updated website'),
      );
      await pumpEventQueue();

      expect(provider.projects.single.name, 'Updated website');
      expect(provider.projects.single.ownerId, 'uid-1');

      await authStates.close();
      provider.dispose();
    });

    test('ignores old subscriptions after the authenticated uid changes',
        () async {
      final authStates = StreamController<String?>();
      final uid1Projects = StreamController<List<Project>>();
      final uid2Projects = StreamController<List<Project>>();
      final provider = ProjectProvider(
        repository: _UidStreamRepository({
          'uid-1': uid1Projects.stream,
          'uid-2': uid2Projects.stream,
        }),
        authStateChanges: authStates.stream,
      );

      authStates.add('uid-1');
      await pumpEventQueue();
      authStates.add('uid-2');
      await pumpEventQueue();

      uid1Projects.add([
        const Project(id: 'old', ownerId: 'uid-1', name: 'Old user'),
      ]);
      await pumpEventQueue();

      expect(provider.uid, 'uid-2');
      expect(provider.projects, isEmpty);
      expect(provider.status, ProjectProviderStatus.loading);

      uid2Projects.add([
        const Project(id: 'new', ownerId: 'uid-2', name: 'New user'),
      ]);
      await pumpEventQueue();

      expect(provider.projects.single.name, 'New user');

      uid1Projects.addError(StateError('old subscription error'));
      await pumpEventQueue();

      expect(provider.status, ProjectProviderStatus.success);
      expect(provider.errorMessage, isNull);

      await uid1Projects.close();
      await uid2Projects.close();
      await authStates.close();
      provider.dispose();
    });

    test('exposes stream and operation errors', () async {
      final authStates = StreamController<String?>();
      final projects = StreamController<List<Project>>();
      final provider = ProjectProvider(
        repository: _StreamErrorRepository(projects.stream),
        authStateChanges: authStates.stream,
      );

      authStates.add('uid-1');
      await pumpEventQueue();
      projects.addError(StateError('Firestore unavailable'));
      await pumpEventQueue();

      expect(provider.status, ProjectProviderStatus.error);
      expect(provider.errorMessage, contains('Firestore unavailable'));

      await projects.close();
      await authStates.close();
      provider.dispose();
    });

    test('throws StateError for CRUD operations without an authenticated uid',
        () async {
      final authStates = StreamController<String?>();
      final provider = ProjectProvider(
        repository: repository,
        authStateChanges: authStates.stream,
      );

      for (final operation in <Future<void> Function()>[
        () => provider.createProject(
              const Project(id: 'project-1', ownerId: '', name: 'Website'),
            ),
        () => provider.updateProject(
              const Project(id: 'project-1', ownerId: '', name: 'Website'),
            ),
        () => provider.deleteProject('project-1'),
      ]) {
        await expectLater(operation, throwsA(isA<StateError>()));
        expect(provider.status, ProjectProviderStatus.error);
        expect(provider.errorMessage, contains('Nenhum usuário autenticado'));
      }

      await authStates.close();
      provider.dispose();
    });

    test('cancels auth and project subscriptions on dispose', () async {
      var authCancelled = false;
      var projectsCancelled = false;
      final authStates = StreamController<String?>(
        onCancel: () => authCancelled = true,
      );
      final projects = StreamController<List<Project>>(
        onCancel: () => projectsCancelled = true,
      );
      final provider = ProjectProvider(
        repository: _StreamErrorRepository(projects.stream),
        authStateChanges: authStates.stream,
      );

      authStates.add('uid-1');
      await pumpEventQueue();
      provider.dispose();

      expect(authCancelled, isTrue);
      expect(projectsCancelled, isTrue);
    });
  });
}

class _StreamErrorRepository extends ProjectRepository {
  _StreamErrorRepository(this._projects) : super(FakeFirebaseFirestore());

  final Stream<List<Project>> _projects;

  @override
  Stream<List<Project>> watchProjects(String uid) => _projects;
}

class _UidStreamRepository extends ProjectRepository {
  _UidStreamRepository(this._streams) : super(FakeFirebaseFirestore());

  final Map<String, Stream<List<Project>>> _streams;

  @override
  Stream<List<Project>> watchProjects(String uid) {
    return _streams[uid]!;
  }
}
