import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lietucoach/auth/auth.dart';
import 'package:lietucoach/features/profile/profile_screen.dart';
import 'package:lietucoach/ui/theme.dart';
import 'package:lietucoach/ui/theme/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

User _fakeUser() {
  return User.fromJson({
    'id': '00000000-0000-0000-0000-000000000001',
    'aud': 'authenticated',
    'email': 'tester@example.com',
    'app_metadata': <String, dynamic>{},
    'user_metadata': <String, dynamic>{'full_name': 'Tester'},
    'created_at': DateTime.now().toIso8601String(),
  })!;
}

Future<void> _pumpProfile(
  WidgetTester tester, {
  AuthService? authOverride,
}) async {
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
            home: ProfileScreen(authServiceOverride: authOverride),
          );
        },
      ),
    ),
  );

  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    authService.setAuthStateForTest(AuthState.unauthenticated());
  });

  tearDown(() {
    authService.setAuthStateForTest(AuthState.unauthenticated());
  });

  testWidgets('Delete account entry is hidden when signed out', (tester) async {
    await _pumpProfile(tester);

    expect(find.text('Delete account'), findsNothing);
  });

  testWidgets('Delete account entry is shown when signed in', (tester) async {
    final testAuth = AuthService();
    testAuth.setAuthStateForTest(AuthState.authenticated(_fakeUser()));
    expect(testAuth.isAuthenticated, isTrue);

    await _pumpProfile(tester, authOverride: testAuth);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Delete account'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Delete account'), findsOneWidget);
  });
}
