import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/project.dart';
import '../models/project_task.dart';
import '../providers/task_provider.dart';
import '../utils/validators.dart';

class TaskFormPage extends StatefulWidget {
  const TaskFormPage({super.key, required this.project, this.task});
  final Project project;
  final ProjectTask? task;

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _assignee;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.task?.name);
    _description = TextEditingController(text: widget.task?.description);
    _assignee = TextEditingController(text: widget.task?.assigneeName);
    _dueDate = widget.task?.dueDate;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _assignee.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_dueDate == null) {
      return;
    }
    if (widget.project.dueDate != null &&
        _dueDate!.isAfter(widget.project.dueDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('A tarefa não pode vencer depois do projeto')));
      return;
    }
    final task = ProjectTask(
      id: widget.task?.id ?? 'task-${DateTime.now().microsecondsSinceEpoch}',
      name: _name.text.trim(),
      description: _description.text.trim(),
      assigneeName: _assignee.text.trim(),
      dueDate: _dueDate,
      completed: widget.task?.completed ?? false,
      createdAt: widget.task?.createdAt,
    );
    final provider = context.read<TaskProvider>();
    if (widget.task == null)
      await provider.create(task);
    else
      await provider.update(task);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.task == null ? 'Nova tarefa' : 'Editar tarefa')),
      body: Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          TextFormField(
              key: const Key('task-name-field'),
              controller: _name,
              decoration: const InputDecoration(labelText: 'Nome'),
              validator: Validators.validateTaskName),
          const SizedBox(height: 12),
          TextFormField(
              controller: _description,
              decoration: const InputDecoration(labelText: 'Descrição'),
              validator: Validators.validateTaskDescription,
              minLines: 3,
              maxLines: 5),
          const SizedBox(height: 12),
          TextFormField(
              controller: _assignee,
              decoration: const InputDecoration(labelText: 'Responsável'),
              validator: Validators.validateAssigneeName),
          const SizedBox(height: 12),
          FormField<DateTime>(
              initialValue: _dueDate,
              validator: (value) {
                if (value == null)
                  return 'A data limite da tarefa é obrigatória';
                if (widget.project.dueDate != null)
                  return Validators.validateTaskDueDate(
                      value, widget.project.dueDate!);
                return null;
              },
              builder: (field) => InkWell(
                  onTap: () async {
                    final now = DateTime.now();
                    final value = await showDatePicker(
                        context: context,
                        initialDate: _dueDate ?? now,
                        firstDate: now,
                        lastDate:
                            widget.project.dueDate ?? DateTime(now.year + 20));
                    if (value != null)
                      setState(() {
                        _dueDate = value;
                        field.didChange(value);
                      });
                  },
                  child: InputDecorator(
                      decoration: InputDecoration(
                          labelText: 'Prazo', errorText: field.errorText),
                      child: Text(_dueDate == null
                          ? 'Selecione o prazo'
                          : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}')))),
          const SizedBox(height: 24),
          ElevatedButton(
              onPressed: _submit,
              child: Text(
                  widget.task == null ? 'Criar tarefa' : 'Salvar alterações')),
        ]),
      ),
    );
  }
}
