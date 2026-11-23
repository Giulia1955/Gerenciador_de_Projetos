import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/project_provider.dart';
import 'repositories/project_repository.dart';
import 'theme/app_theme.dart';
import 'view/auth_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<ProjectRepository>(
          create: (_) => ProjectRepository(FirebaseFirestore.instance),
        ),
        ChangeNotifierProvider<ProjectProvider>(
          create: (context) => ProjectProvider(
            repository: context.read<ProjectRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const AuthPage(),
      ),
    ),
  );
}
