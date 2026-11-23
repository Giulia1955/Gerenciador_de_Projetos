import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/project_task.dart';
import '../repositories/project_repository.dart';
import '../repositories/task_repository.dart';

class TaskProvider extends ChangeNotifier {
  TaskProvider({required this.taskRepository, required this.projectRepository});

  final TaskRepository taskRepository;
  final ProjectRepository projectRepository;
  StreamSubscription<List<ProjectTask>>? _subscription;
  String? _uid;
  String? _projectId;
  List<ProjectTask> _tasks = const [];
  bool _loading = false;
  String? _error;

  List<ProjectTask> get tasks => _tasks;
  bool get isLoading => _loading;
  String? get errorMessage => _error;

  Future<void> load(String uid, String projectId) async {
    await _subscription?.cancel();
    _uid = uid;
    _projectId = projectId;
    _loading = true;
    notifyListeners();
    _subscription = taskRepository.watchTasks(uid, projectId).listen((tasks) {
      _tasks = tasks;
      _loading = false;
      _error = null;
      notifyListeners();
    }, onError: (Object error) {
      _error = error.toString();
      _loading = false;
      notifyListeners();
    });
  }

  Future<void> create(ProjectTask task) =>
      _run(() => taskRepository.createTask(_uid!, _projectId!, task));
  Future<void> update(ProjectTask task) =>
      _run(() => taskRepository.updateTask(_uid!, _projectId!, task));
  Future<void> setCompleted(String taskId, bool completed) => _run(() =>
      taskRepository.setTaskCompleted(_uid!, _projectId!, taskId, completed));
  Future<void> delete(String taskId) =>
      _run(() => taskRepository.deleteTask(_uid!, _projectId!, taskId));

  Future<void> _run(Future<void> Function() operation) async {
    try {
      await operation();
      await projectRepository.touchProject(_uid!, _projectId!);
    } catch (error) {
      _error = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
