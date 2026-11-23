import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../components/app_date_field.dart';
import '../components/project_fields.dart';
import '../models/project.dart';
import '../models/project_location.dart';
import '../providers/media_provider.dart';
import '../providers/project_provider.dart';
import '../repositories/location_repository.dart';

class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key, this.project, this.projectId});

  final Project? project;
  final String? projectId;

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  DateTime? _dueDate;
  ProjectLocation? _location;
  late List<String> _imageUrls;
  bool _submitting = false;
  bool _gettingLocation = false;
  String? _errorMessage;

  bool get _isEditing => widget.project != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project?.name);
    _descriptionController =
        TextEditingController(text: widget.project?.description);
    _dueDate = widget.project?.dueDate;
    _location = widget.project?.location;
    _imageUrls = List<String>.from(widget.project?.imageUrls ?? const []);
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
      imageUrls: List<String>.from(_imageUrls),
      location: _location,
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

  Future<void> _pickLocation() async {
    setState(() => _gettingLocation = true);
    try {
      final location = await LocationRepository().currentLocation();
      if (!mounted) return;
      setState(() => _location = location);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(error.toString().replaceFirst('Bad state: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _gettingLocation = false);
    }
  }

  Future<void> _pickImage() async {
    if (_imageUrls.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Limite de cinco imagens atingido')),
      );
      return;
    }

    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
    );
    if (file == null || !mounted) return;

    final projectProvider = context.read<ProjectProvider>();
    final uid = projectProvider.uid;
    if (uid == null) return;

    final mediaProvider = context.read<MediaProvider>();
    final projectId = widget.project?.id ??
        'project-${DateTime.now().microsecondsSinceEpoch}';
    final url = await mediaProvider.upload(
      uid: uid,
      projectId: projectId,
      file: File(file.path),
    );
    if (!mounted) return;
    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                mediaProvider.errorMessage ?? 'Falha no upload da imagem')),
      );
      return;
    }
    setState(() => _imageUrls = [..._imageUrls, url]);
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
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed:
                      _submitting || _gettingLocation ? null : _pickLocation,
                  icon: _gettingLocation
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.my_location_outlined),
                  label: Text(_location == null
                      ? 'Adicionar localização GPS'
                      : 'Atualizar localização GPS'),
                ),
                if (_location != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Localização: ${_location!.latitude.toStringAsFixed(5)}, ${_location!.longitude.toStringAsFixed(5)}',
                    ),
                  ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _submitting ? null : _pickImage,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: Text('Adicionar imagens (${_imageUrls.length}/5)'),
                ),
                if (_imageUrls.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var url in _imageUrls)
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                url,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: -8,
                              top: -8,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _imageUrls.remove(url);
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.all(6),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
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
