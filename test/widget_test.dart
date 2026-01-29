/// Default widget test for LietuCoach

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lietucoach/main.dart';
import 'package:lietucoach/progress/progress.dart';
import 'package:lietucoach/srs/srs.dart';
import 'mock_progress_store.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'mock_srs_store.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final tempDir = await getTemporaryDirectory();
    Hive.init(tempDir.path);
  });

  setUp(() {
    setMockProgressStore(MockProgressStore());
    setMockSrsStore(MockSrsStore());
  });

  tearDown(() {
    setMockProgressStore(null);
    setMockSrsStore(null);
  });

  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LietuCoachApp());
    await tester.pumpAndSettle();

    // Verify app launches to the Path screen
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Learning Path'), findsOneWidget);
  });
}
