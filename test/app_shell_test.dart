/// App Shell widget tests
///
/// Tests for bottom navigation and tab switching.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'package:lietucoach/main.dart';
import 'package:lietucoach/progress/progress.dart';
import 'package:lietucoach/srs/srs.dart';
import 'mock_progress_store.dart';
import 'package:hive/hive.dart';
import 'mock_srs_store.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final tempDir = Directory.systemTemp.createTempSync();
    Hive.init(tempDir.path);
  });

  setUp(() {
    final mockSrs = MockSrsStore();
    // Add dummy due card to trigger Daily Review
    mockSrs.upsertCards([
      SrsCard(
        cardId: 'card1',
        unitId: 'unit1',
        phraseId: 'phrase1',
        front: 'front',
        back: 'back',
        audioId: 'audio1',
        dueAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ]);
    setMockProgressStore(MockProgressStore());
    setMockSrsStore(mockSrs);
  });

  tearDown(() {
    setMockProgressStore(null);
    setMockSrsStore(null);
  });

  testWidgets('App Shell Navigation Flow', (WidgetTester tester) async {
    // 1. Launch App
    await tester.pumpWidget(const LietuCoachApp());
    // Wait for initial load (PathScreen)
    await tester.pump(const Duration(seconds: 2));

    // 2. Verify NavigationBar structure
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(5));
    expect(find.text('Path'), findsOneWidget);
    expect(find.text('Practice'), findsOneWidget);
    expect(find.text('Roles'), findsOneWidget);
    expect(find.text('Cards'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // 3. Verify Initial Screen (Path)
    expect(find.text('Learning Path'), findsOneWidget);

    // 4. Tap Practice tab
    await tester.tap(find.text('Practice'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Practice').first, findsOneWidget);
    expect(find.text('Daily Training'), findsOneWidget);

    // 5. Tap Roles tab
    await tester.tap(find.text('Roles'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Role Packs'), findsOneWidget);

    // 6. Tap Cards tab
    await tester.tap(find.text('Cards'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Flashcards'), findsOneWidget);

    // 7. Tap Profile tab
    await tester.tap(find.text('Profile'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Guest User'), findsOneWidget);

    // 8. Tap back to Path tab
    await tester.tap(find.text('Path'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Learning Path'), findsOneWidget);
  });
}
