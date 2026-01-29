/// LietuCoach - Lithuanian Language Learning App
///
/// Main entry point with theme configuration, progress, SRS, and auth initialization.

import 'package:flutter/material.dart';
import 'app/app_shell.dart';
import 'auth/auth.dart';
import 'config/env.dart';
import 'config/hive_init.dart';
import 'progress/progress.dart';
import 'srs/srs.dart';
import 'sync/sync.dart';
import 'ui/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment config
  await Env.init();
  
  // Initialize Hive and Adapters
  await initHive();

  // Initialize local stores
  await initProgressStore();
  await initSrsStore();

  // Initialize auth (Supabase) - gracefully handles missing config
  await authService.init();

  // Initialize sync service
  await initSyncService();

  runApp(const LietuCoachApp());
}

class LietuCoachApp extends StatelessWidget {
  const LietuCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LietuCoach',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: const AppShell(),
    );
  }
}
