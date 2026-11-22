import 'package:apk_auth/theme/app_theme.dart';
import 'package:apk_auth/view/dashboard_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('dashboard starts on projects and has exactly three tabs',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark, home: const DashboardShell()),
    );

    expect(find.text('NightOwlner'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Projetos'), findsWidgets);
    expect(find.text('Calendário'), findsWidgets);
    expect(find.text('Perfil'), findsWidgets);

    await tester.tap(find.text('Calendário').last);
    await tester.pump();
    expect(find.text('Seu calendário está vazio'), findsOneWidget);
  });
}
