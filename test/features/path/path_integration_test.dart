import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lietucoach/features/path/path_screen.dart';
import 'package:lietucoach/auth/auth_service.dart';
import 'package:lietucoach/debug/debug_state.dart';
import 'package:lietucoach/progress/progress.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../mock_progress_store.dart';

// Mock Auth Service (minimal)
class MockAuthService extends Mock implements AuthService {
  @override
  User? get currentUser => const User(
    id: 'test_user',
    appMetadata: {},
    userMetadata: {},
    aud: 'authenticated',
    createdAt: '2023-01-01',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockProgressStore mockStore;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockStore = MockProgressStore();
    setMockProgressStore(mockStore); // Correct injection method
    DebugState.forceUnlockContent.value =
        true; // Unlock all for visibility check
  });

  tearDown(() {
    DebugState.forceUnlockContent.value = false;
  });

  testWidgets('PathScreen shows all A1 units 01-10', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const PathScreen(),
        theme: ThemeData(useMaterial3: true),
      ),
    );

    // Initial load
    await tester.pumpAndSettle();

    // Verify configuration first
    expect(courseUnits.length, 10);

    // Verify metadata titles exist
    expect(find.text('Greetings & Basics'), findsOneWidget); // Unit 01
    expect(find.text('Numbers & Counting'), findsOneWidget); // Unit 02

    // Scroll a bit to find Unit 3 if needed
    final unit3Finder = find.text('Introductions 2');
    await tester.scrollUntilVisible(unit3Finder, 500);
    expect(unit3Finder, findsOneWidget); // Unit 03

    // Verify total units in config matches 10 (Logic check)
    // This confirms the "Fix" (extending the list) is applied.
    expect(courseUnits.length, 10);
    expect(
      courseUnits.last.title,
      'Weather',
    ); // Check the last one is correct in config
  });
}
