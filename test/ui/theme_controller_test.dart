import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lietucoach/ui/theme/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('ThemeController defaults to system mode with no saved value', () async {
    final prefs = await SharedPreferences.getInstance();
    final controller = ThemeController(prefs: prefs);

    await controller.load();

    expect(controller.mode, AppThemeMode.system);
    expect(controller.themeMode, ThemeMode.system);
  });

  test('ThemeController setMode persists and notifies', () async {
    final prefs = await SharedPreferences.getInstance();
    final controller = ThemeController(prefs: prefs);
    int notifications = 0;
    controller.addListener(() => notifications++);

    await controller.setMode(AppThemeMode.dark);
    expect(controller.mode, AppThemeMode.dark);
    expect(prefs.getString(ThemeController.modeKey), 'dark');

    await controller.setMode(AppThemeMode.light);
    expect(controller.mode, AppThemeMode.light);
    expect(prefs.getString(ThemeController.modeKey), 'light');

    await controller.setMode(AppThemeMode.system);
    expect(controller.mode, AppThemeMode.system);
    expect(prefs.getString(ThemeController.modeKey), 'system');
    expect(notifications, 3);
  });

  test('ThemeController loads from stored enum string', () async {
    SharedPreferences.setMockInitialValues({ThemeController.modeKey: 'dark'});
    final prefs = await SharedPreferences.getInstance();
    final controller = ThemeController(prefs: prefs);

    await controller.load();

    expect(controller.mode, AppThemeMode.dark);
    expect(controller.themeMode, ThemeMode.dark);
  });

  test('ThemeController migrates legacy dark_mode bool', () async {
    SharedPreferences.setMockInitialValues({
      ThemeController.legacyDarkModeKey: true,
    });
    final prefs = await SharedPreferences.getInstance();
    final controller = ThemeController(prefs: prefs);

    await controller.load();

    expect(controller.mode, AppThemeMode.dark);
    expect(prefs.getString(ThemeController.modeKey), 'dark');
    expect(prefs.containsKey(ThemeController.legacyDarkModeKey), isFalse);
  });
}
