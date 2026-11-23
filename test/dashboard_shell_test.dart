import 'package:apk_auth/theme/app_theme.dart';
import 'package:apk_auth/view/dashboard_shell.dart';
import 'package:apk_auth/providers/project_provider.dart';
import 'package:apk_auth/providers/task_provider.dart';
import 'package:apk_auth/providers/wisdom_provider.dart';
import 'package:apk_auth/repositories/project_repository.dart';
import 'package:apk_auth/repositories/task_repository.dart';
import 'package:apk_auth/repositories/wisdom_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('dashboard starts on projects and has exactly three tabs',
      (tester) async {
    final firestore = FakeFirebaseFirestore();
    final projectRepository = ProjectRepository(firestore);
    final taskRepository = TaskRepository(firestore);
    final projectProvider = ProjectProvider(
      repository: projectRepository,
      authStateChanges: Stream<String?>.value('uid-1'),
    );
    await tester.pump();

    final taskProvider = TaskProvider(
      taskRepository: taskRepository,
      projectRepository: projectRepository,
    );
    final wisdomProvider = WisdomProvider(
      repository: WisdomRepository(
        fetchZen: () async => throw StateError('offline'),
        fetchAdvice: () async => throw StateError('offline'),
      ),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ProjectProvider>.value(value: projectProvider),
          Provider<TaskRepository>.value(value: taskRepository),
          ChangeNotifierProvider<TaskProvider>.value(value: taskProvider),
          ChangeNotifierProvider<WisdomProvider>.value(value: wisdomProvider),
        ],
        child: MaterialApp(theme: AppTheme.dark, home: const DashboardShell()),
      ),
    );

    expect(find.text('NightOwlner'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Projetos'), findsWidgets);
    expect(find.text('Calendário'), findsWidgets);
    expect(find.text('Perfil'), findsWidgets);

    await tester.tap(find.text('Calendário').last);
    await tester.pump();
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Calendário'),
      ),
      findsOneWidget,
    );

    projectProvider.dispose();
    taskProvider.dispose();
    wisdomProvider.dispose();
  });
}
