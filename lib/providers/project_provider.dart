import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/project.dart';
import '../repositories/project_repository.dart';

enum ProjectProviderStatus { loading, success, empty, error }

class ProjectProvider extends ChangeNotifier {
  ProjectProvider({
    required ProjectRepository repository,
    Stream<String?>? authStateChanges,
  })  : _repository = repository,
        _authStateChanges =
            authStateChanges ?? FirebaseAuth.instance.authStateChanges().map(
                  (user) => user?.uid,
                ) {
    initialize();
  }

  final ProjectRepository _repository;
  final Stream<String?> _authStateChanges;

  StreamSubscription<String?>? _authSubscription;
  StreamSubscription<List<Project>>? _projectsSubscription;

  String? _uid;
  ProjectProviderStatus _status = ProjectProviderStatus.loading;
  List<Project> _projects = const [];
  String? _errorMessage;
  bool _disposed = false;

  String? get uid => _uid;
  ProjectProviderStatus get status => _status;
  List<Project> get projects => _projects;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == ProjectProviderStatus.loading;

  void initialize() {
    if (_authSubscription != null) return;
    _authSubscription = _authStateChanges.listen(
      _onAuthStateChanged,
      onError: (Object error) {
        _setError(error);
      },
    );
  }

  void _onAuthStateChanged(String? uid) {
    if (_disposed || uid == _uid) return;

    _uid = uid;
    _projectsSubscription?.cancel();
    _projectsSubscription = null;

    if (uid == null) {
      _projects = const [];
      _errorMessage = null;
      _status = ProjectProviderStatus.empty;
      notifyListeners();
      return;
    }

    _projects = const [];
    _errorMessage = null;
    _status = ProjectProviderStatus.loading;
    notifyListeners();

    _projectsSubscription = _repository.watchProjects(uid).listen(
      (projects) {
        if (_disposed) return;
        _projects = projects;
        _errorMessage = null;
        _status = projects.isEmpty
            ? ProjectProviderStatus.empty
            : ProjectProviderStatus.success;
        notifyListeners();
      },
      onError: (Object error) {
        _setError(error);
      },
    );
  }

  void _setError(Object error) {
    if (_disposed) return;
    _errorMessage = error.toString();
    _status = ProjectProviderStatus.error;
    notifyListeners();
  }

  Future<void> createProject(Project project) async {
    final uid = _uid;
    if (uid == null) {
      _setError(StateError('Nenhum usuário autenticado'));
      return;
    }

    try {
      await _repository.createProject(uid, project);
    } catch (error) {
      _setError(error);
      rethrow;
    }
  }

  Future<void> updateProject(Project project) async {
    final uid = _uid;
    if (uid == null) {
      _setError(StateError('Nenhum usuário autenticado'));
      return;
    }

    try {
      await _repository.updateProject(uid, project);
    } catch (error) {
      _setError(error);
      rethrow;
    }
  }

  Future<void> deleteProject(String projectId) async {
    final uid = _uid;
    if (uid == null) {
      _setError(StateError('Nenhum usuário autenticado'));
      return;
    }

    try {
      await _repository.deleteProject(uid, projectId);
    } catch (error) {
      _setError(error);
      rethrow;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _authSubscription?.cancel();
    _projectsSubscription?.cancel();
    super.dispose();
  }
}
