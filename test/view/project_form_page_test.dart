import 'package:apk_auth/models/project.dart';
import 'package:apk_auth/providers/project_provider.dart';
import 'package:apk_auth/repositories/project_repository.dart';
import 'package:apk_auth/view/project_form_page.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('create form validates fields', (tester) async {
    final repository = ProjectRepository(FakeFirebaseFirestore());
    final provider = ProjectProvider(
      repository: repository,
      authStateChanges: Stream<String?>.value('uid-1'),
    );
    await tester.pump();

    await tester.pumpWidget(
      ChangeNotifierProvider<ProjectProvider>.value(
        value: provider,
        child: const MaterialApp(home: ProjectFormPage()),
      ),
    );

    expect(find.text('Novo projeto'), findsOneWidget);

    await tester.tap(find.text('Salvar projeto'));
    await tester.pump();
    expect(find.text('O nome do projeto é obrigatório'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('project-name-field')),
      'Site pessoal',
    );
    await tester.enterText(
      find.byKey(const Key('project-description-field')),
      'Descrição completa do projeto',
    );

    expect(find.byKey(const Key('project-due-date-field')), findsOneWidget);
    provider.dispose();
  });

  testWidgets('edit form initializes values', (tester) async {
    final repository = ProjectRepository(FakeFirebaseFirestore());
    final provider = ProjectProvider(
      repository: repository,
      authStateChanges: Stream<String?>.value('uid-1'),
    );
    await tester.pump();

    const project = Project(
      id: 'project-1',
      ownerId: 'uid-1',
      name: 'Projeto antigo',
      description: 'Descrição antiga',
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<ProjectProvider>.value(
        value: provider,
        child: const MaterialApp(
          home: ProjectFormPage(project: project),
        ),
      ),
    );

    expect(find.text('Editar projeto'), findsOneWidget);
    expect(find.text('Projeto antigo'), findsOneWidget);
    expect(find.text('Descrição antiga'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('project-name-field')),
      'Projeto novo',
    );
    expect(find.text('Projeto novo'), findsOneWidget);

    provider.dispose();
  });
}
