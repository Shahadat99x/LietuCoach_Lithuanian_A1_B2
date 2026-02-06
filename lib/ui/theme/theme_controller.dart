import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { system, light, dark }

extension AppThemeModeLabel on AppThemeMode {
  String get label {
    switch (this) {
      case AppThemeMode.system:
        return 'System';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
    }
  }
}

class ThemeController extends ChangeNotifier {
  ThemeController({
    SharedPreferences? prefs,
    AppThemeMode initialMode = AppThemeMode.system,
  }) : _prefs = prefs,
       _mode = initialMode;

  static const String modeKey = 'app_theme_mode_v1';
  static const String legacyDarkModeKey = 'dark_mode';

  final SharedPreferences? _prefs;
  AppThemeMode _mode;

  AppThemeMode get mode => _mode;

  ThemeMode get themeMode {
    switch (_mode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  Future<void> load() async {
    final prefs = await _resolvePrefs();
    final previous = _mode;

    if (prefs.containsKey(modeKey)) {
      final rawMode = prefs.getString(modeKey);
      _mode = _decode(rawMode);
    } else if (prefs.containsKey(legacyDarkModeKey)) {
      final legacy = prefs.getBool(legacyDarkModeKey) ?? false;
      _mode = legacy ? AppThemeMode.dark : AppThemeMode.light;
      await prefs.setString(modeKey, _mode.name);
      await prefs.remove(legacyDarkModeKey);
    } else {
      _mode = AppThemeMode.system;
    }

    if (previous != _mode) {
      notifyListeners();
    }
  }

  Future<void> setMode(AppThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();

    final prefs = await _resolvePrefs();
    await prefs.setString(modeKey, _mode.name);
  }

  AppThemeMode _decode(String? raw) {
    return switch (raw) {
      'light' => AppThemeMode.light,
      'dark' => AppThemeMode.dark,
      _ => AppThemeMode.system,
    };
  }

  Future<SharedPreferences> _resolvePrefs() async {
    return _prefs ?? SharedPreferences.getInstance();
  }
}

class ThemeControllerScope extends InheritedNotifier<ThemeController> {
  const ThemeControllerScope({
    super.key,
    required ThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static ThemeController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<ThemeControllerScope>();
    assert(scope != null, 'ThemeControllerScope not found in widget tree.');
    return scope!.notifier!;
  }
}
