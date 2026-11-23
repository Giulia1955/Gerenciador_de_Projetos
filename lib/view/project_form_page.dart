import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
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
  bool _submitting = false;
  String? _errorMessage;

  bool get _isEditing => widget.project != null;

  ProjectLocation? _location;
  final List<Blob> _images = [];
  late final String _projectId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project?.name);
    _descriptionController =
        TextEditingController(text: widget.project?.description);
    _dueDate = widget.project?.dueDate;
    _location = widget.project?.location;
    _images.addAll(widget.project?.images ?? const []);
    _projectId = widget.project?.id ??
        widget.projectId ??
        'project-${DateTime.now().microsecondsSinceEpoch}';
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
      id: _projectId,
      ownerId: provider.uid ?? '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: _dueDate,
      images: _images,
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
    try {
      final location = await LocationRepository().currentLocation();
      if (mounted) {
        setState(() => _location = location);
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Bad state: ', ''))),
      );
    }
  }

  Future<void> _pickImage() async {
    if (_images.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Máximo de cinco imagens por projeto')),
      );
      return;
    }

    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 1600,
    );
    if (file == null) return;

    final bytes = await File(file.path).readAsBytes();
    if (!mounted) return;

    final blob = context.read<MediaProvider>().process(bytes);
    if (blob != null) {
      setState(() => _images.add(blob));
    } else if (mounted) {
      final mediaProvider = context.read<MediaProvider>();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mediaProvider.errorMessage ?? 'Falha ao processar a imagem')),
      );
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
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _submitting ? null : _pickImage,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: Text(_images.isEmpty
                      ? 'Adicionar imagem'
                      : 'Adicionar imagem (${_images.length}/5)'),
                ),
                if (_images.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 110,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _images
                          .map((blob) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    blob.bytes,
                                    width: 150,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ))
                          .toList(growable: false),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _submitting ? null : _pickLocation,
                  icon: const Icon(Icons.my_location),
                  label: const Text('Usar localização atual'),
                ),
                if (_location != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${_location!.latitude.toStringAsFixed(5)}, ${_location!.longitude.toStringAsFixed(5)}',
                    textAlign: TextAlign.center,
                  ),
                ],
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 16),
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
