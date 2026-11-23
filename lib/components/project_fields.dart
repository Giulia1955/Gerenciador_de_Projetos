import 'package:flutter/material.dart';

import '../utils/validators.dart';

class ProjectFields extends StatelessWidget {
  const ProjectFields({
    super.key,
    required this.nameController,
    required this.descriptionController,
    this.enabled = true,
  });

  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          key: const Key('project-name-field'),
          controller: nameController,
          enabled: enabled,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Nome do projeto',
            hintText: 'Ex.: Aplicativo acadêmico',
          ),
          validator: Validators.validateProjectName,
          maxLength: 80,
        ),
        const SizedBox(height: 16),
        TextFormField(
          key: const Key('project-description-field'),
          controller: descriptionController,
          enabled: enabled,
          decoration: const InputDecoration(
            labelText: 'Descrição',
            hintText: 'Descreva o objetivo do projeto',
            alignLabelWithHint: true,
          ),
          validator: Validators.validateProjectDescription,
          minLines: 4,
          maxLines: 6,
          maxLength: 500,
        ),
      ],
    );
  }
}
