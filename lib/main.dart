import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/media_provider.dart';
import 'providers/project_provider.dart';
import 'providers/task_provider.dart';
import 'providers/wisdom_provider.dart';
import 'repositories/project_repository.dart';
import 'repositories/storage_repository.dart';
import 'repositories/task_repository.dart';
import 'repositories/wisdom_repository.dart';
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
        Provider<StorageRepository>(
          create: (_) => StorageRepository(FirebaseStorage.instance),
        ),
        ChangeNotifierProvider<MediaProvider>(
          create: (context) => MediaProvider(
            repository: context.read<StorageRepository>(),
          ),
        ),
        Provider<TaskRepository>(
          create: (_) => TaskRepository(FirebaseFirestore.instance),
        ),
        ChangeNotifierProvider<TaskProvider>(
          create: (context) => TaskProvider(
            taskRepository: context.read<TaskRepository>(),
            projectRepository: context.read<ProjectRepository>(),
          ),
        ),
        Provider<WisdomRepository>(
          create: (_) => WisdomRepository(),
        ),
        ChangeNotifierProvider<WisdomProvider>(
          create: (context) => WisdomProvider(
            repository: context.read<WisdomRepository>(),
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
