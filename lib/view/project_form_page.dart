import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/app_date_field.dart';
import '../components/project_fields.dart';
import '../models/project.dart';
import '../providers/project_provider.dart';

class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key, this.project});

  final Project? project;

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  DateTime? _dueDate;
  bool _submitting = false;
  String? _errorMessage;

  bool get _isEditing => widget.project != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project?.name);
    _descriptionController =
        TextEditingController(text: widget.project?.description);
    _dueDate = widget.project?.dueDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting || !_formKey.currentState!.validate()) return;

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    final provider = context.read<ProjectProvider>();
    final project = Project(
      id: widget.project?.id ??
          'project-${DateTime.now().microsecondsSinceEpoch}',
      ownerId: provider.uid ?? '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: _dueDate,
      imageUrls: widget.project?.imageUrls ?? const [],
      location: widget.project?.location,
      createdAt: widget.project?.createdAt,
    );

    try {
      if (_isEditing) {
        await provider.updateProject(project);
      } else {
        await provider.createProject(project);
      }
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Não foi possível salvar o projeto. Verifique sua conexão e tente novamente.';
      });
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar projeto' : 'Novo projeto'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProjectFields(
                  nameController: _nameController,
                  descriptionController: _descriptionController,
                  enabled: !_submitting,
                ),
                const SizedBox(height: 16),
                AppDateField(
                  key: const Key('project-due-date-field'),
                  value: _dueDate,
                  enabled: !_submitting,
                  onChanged: (value) => setState(() => _dueDate = value),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    _submitting
                        ? 'Salvando...'
                        : _isEditing
                            ? 'Salvar alterações'
                            : 'Salvar projeto',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
