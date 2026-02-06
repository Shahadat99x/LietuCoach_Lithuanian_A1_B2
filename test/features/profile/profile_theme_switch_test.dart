import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lietucoach/features/profile/profile_screen.dart';
import 'package:lietucoach/ui/theme.dart';
import 'package:lietucoach/ui/theme/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Profile appearance sheet switches theme modes', (
    WidgetTester tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final controller = ThemeController(prefs: prefs);
    await controller.load();

    await tester.pumpWidget(
      ThemeControllerScope(
        controller: controller,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            return MaterialApp(
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: controller.themeMode,
              home: const ProfileScreen(),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Appearance'), findsOneWidget);

    Future<void> selectMode(String label, AppThemeMode mode) async {
      await tester.tap(find.text('Appearance'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(label).last);
      await tester.pumpAndSettle();

      expect(controller.mode, mode);
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, controller.themeMode);
    }

    await selectMode('Dark', AppThemeMode.dark);
    await selectMode('Light', AppThemeMode.light);
    await selectMode('System', AppThemeMode.system);
  });
}
