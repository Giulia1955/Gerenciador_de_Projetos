import 'package:flutter/material.dart';

import '../models/project.dart';
import '../theme/app_theme.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard(
      {super.key,
      required this.project,
      required this.onTap,
      required this.onDelete});

  final Project project;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final due = project.dueDate;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.folder_open, color: AppTheme.accent),
                const Spacer(),
                IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Excluir'),
              ]),
              Text(project.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Expanded(
                  child: Text(project.description ?? 'Sem descrição',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFF94A3B8)))),
              if (due != null)
                Text('Prazo: ${due.day}/${due.month}/${due.year}',
                    style: const TextStyle(fontSize: 12)),
              if (project.updatedAt != null)
                Text(
                    'Atualizado: ${project.updatedAt!.day}/${project.updatedAt!.month} às ${project.updatedAt!.hour}:${project.updatedAt!.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF94A3B8))),
            ],
          ),
        ),
      ),
    );
  }
}
