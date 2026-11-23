import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/task_tile.dart';
import '../models/project.dart';
import '../models/project_task.dart';
import '../providers/project_provider.dart';
import '../providers/task_provider.dart';
import 'project_form_page.dart';
import 'task_form_page.dart';

class ProjectDetailPage extends StatefulWidget {
  const ProjectDetailPage({super.key, required this.project});
  final Project project;

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uid = context.read<ProjectProvider>().uid;
    if (uid != null) {
      context.read<TaskProvider>().load(uid, widget.project.id);
    }
  }

  Future<void> _deleteTask(ProjectTask task) async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
                title: const Text('Excluir tarefa'),
                content: Text('Excluir “${task.name}”?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar')),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Excluir'))
                ]));
    if (confirmed == true && mounted) {
      await context.read<TaskProvider>().delete(task.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    return Scaffold(
      appBar: AppBar(title: Text(project.name), actions: [
        IconButton(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ProjectFormPage(project: project))),
            icon: const Icon(Icons.edit_outlined))
      ]),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => TaskFormPage(project: project))),
          icon: const Icon(Icons.add_task),
          label: const Text('Nova tarefa')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text(project.description ?? 'Sem descrição'),
        const SizedBox(height: 12),
        Text(project.dueDate == null
            ? 'Sem prazo'
            : 'Prazo: ${project.dueDate!.day}/${project.dueDate!.month}/${project.dueDate!.year}'),
        if (project.location != null) ...[
          Text(
              'Localização: ${project.location!.latitude.toStringAsFixed(5)}, ${project.location!.longitude.toStringAsFixed(5)}'),
        ],
        if (project.imageUrls.isNotEmpty) ...[
          const SizedBox(height: 16),
          SizedBox(
              height: 160,
              child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: project.imageUrls
                      .map((url) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(url,
                                  width: 220, fit: BoxFit.cover))))
                      .toList())),
        ],
        const SizedBox(height: 20),
        const Text('Tarefas',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Consumer<TaskProvider>(builder: (_, taskProvider, __) {
          if (taskProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (taskProvider.tasks.isEmpty) {
            return const Card(
                child: ListTile(
                    leading: Icon(Icons.task_alt_outlined),
                    title: Text('Nenhuma tarefa ainda')));
          }
          return Column(
              children: taskProvider.tasks
                  .map((task) => TaskTile(
                      task: task,
                      onEdit: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  TaskFormPage(project: project, task: task))),
                      onToggle: () =>
                          taskProvider.setCompleted(task.id, !task.completed),
                      onDelete: () => _deleteTask(task)))
                  .toList());
        }),
      ]),
    );
  }
}
