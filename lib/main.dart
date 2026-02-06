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
import 'ui/theme/theme_controller.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/onboarding/onboarding_screen.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize environment config
  await Env.init();

  // Initialize Hive and Adapters
  await initHive();

  // Initialize local stores
  await initProgressStore();
  await initSrsStore();

  // Initialize auth (Supabase)
  await authService.init();

  // Initialize sync service
  await initSyncService();

  // Check Onboarding
  final prefs = await SharedPreferences.getInstance();
  final seenOnboarding = prefs.getBool('seen_onboarding') ?? false;
  final themeController = ThemeController(prefs: prefs);
  await themeController.load();

  // ... (inside main)
  // FlutterNativeSplash.remove(); // Removed from here

  runApp(
    LietuCoachApp(
      showOnboarding: !seenOnboarding,
      themeController: themeController,
    ),
  );
}

class LietuCoachApp extends StatefulWidget {
  final bool showOnboarding;
  final ThemeController? themeController;

  const LietuCoachApp({
    super.key,
    this.showOnboarding = false,
    this.themeController,
  });

  @override
  State<LietuCoachApp> createState() => _LietuCoachAppState();
}

class _LietuCoachAppState extends State<LietuCoachApp> {
  late final ThemeController _themeController;

  @override
  void initState() {
    super.initState();
    _themeController = widget.themeController ?? ThemeController();

    // Remove splash screen once the widget tree is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
  }

  @override
  void dispose() {
    if (widget.themeController == null) {
      _themeController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeControllerScope(
      controller: _themeController,
      child: AnimatedBuilder(
        animation: _themeController,
        builder: (context, _) {
          return MaterialApp(
            title: 'LietuCoach',
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: _themeController.themeMode,
            home: widget.showOnboarding
                ? const OnboardingScreen()
                : const AppShell(),
          );
        },
      ),
    );
  }
}
