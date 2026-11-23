import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/owl_wisdom_pill.dart';
import '../components/project_card.dart';
import '../providers/project_provider.dart';
import '../providers/wisdom_provider.dart';
import '../theme/app_theme.dart';
import 'project_detail_page.dart';
import 'project_form_page.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<WisdomProvider>().load();
  }

  Future<void> _deleteProject(BuildContext context, String projectId, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir projeto'),
        content: Text('Excluir “$name” e todas as suas tarefas?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<ProjectProvider>().deleteProject(projectId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ProjectFormPage())),
        icon: const Icon(Icons.add),
        label: const Text('Novo projeto'),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              sliver: SliverToBoxAdapter(child: Row(children: const [Expanded(child: Text('NightOwlner', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800))), _AnimatedOwl()])),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(child: OwlWisdomPill(provider: context.watch<WisdomProvider>())),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 96),
              sliver: SliverToBoxAdapter(child: const Text('Meus projetos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
            ),
            Consumer<ProjectProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const SliverFillRemaining(hasScrollBody: false, child: Center(child: CircularProgressIndicator()));
                }
                if (provider.status == ProjectProviderStatus.error) {
                  return SliverFillRemaining(hasScrollBody: false, child: Center(child: Text(provider.errorMessage ?? 'Não foi possível carregar os projetos')));
                }
                if (provider.status == ProjectProviderStatus.empty) {
                  return SliverFillRemaining(hasScrollBody: false, child: _EmptyProjects(onCreate: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ProjectFormPage()))));
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final project = provider.projects[index];
                      return ProjectCard(
                        project: project,
                        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ProjectDetailPage(project: project))),
                        onDelete: () => _deleteProject(context, project.id, project.name),
                      );
                    }, childCount: provider.projects.length),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisExtent: 210, crossAxisSpacing: 12, mainAxisSpacing: 12),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyProjects extends StatelessWidget {
  const _EmptyProjects({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(20), child: Card(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.folder_open_outlined, size: 54, color: AppTheme.accent), const SizedBox(height: 12), const Text('Nenhum projeto ainda', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)), const SizedBox(height: 8), const Text('Crie seu primeiro projeto para organizar prazos e tarefas.', textAlign: TextAlign.center), const SizedBox(height: 12), FilledButton.icon(onPressed: onCreate, icon: const Icon(Icons.add), label: const Text('Criar projeto'))]))));
  }
}

class _AnimatedOwl extends StatefulWidget {
  const _AnimatedOwl();

  @override
  State<_AnimatedOwl> createState() => _AnimatedOwlState();
}

class _AnimatedOwlState extends State<_AnimatedOwl>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.94, end: 1.04).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 54,
        height: 54,
        decoration: const BoxDecoration(
          color: AppTheme.deepBlue,
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 38,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.accent,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            const Positioned(
              top: 14,
              child: Row(
                children: [
                  Icon(Icons.circle, size: 10, color: AppTheme.deepBlue),
                  SizedBox(width: 8),
                  Icon(Icons.circle, size: 10, color: AppTheme.deepBlue),
                ],
              ),
            ),
            Positioned(
              bottom: 12,
              child: Container(
                width: 8,
                height: 5,
                decoration: const BoxDecoration(
                  color: AppTheme.deepBlue,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
