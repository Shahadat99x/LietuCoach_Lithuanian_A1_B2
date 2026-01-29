import 'package:flutter_test/flutter_test.dart';
import 'package:lietucoach/content/content.dart';
import 'package:lietucoach/content/content_source.dart';
import 'package:mockito/mockito.dart';

class MockContentSource extends Mock implements ContentSource {
  @override
  Future<bool> exists(String path) async => false;
  @override
  Future<String> loadString(String path) async => throw Exception('Not found');
  @override
  String get rootPrefix => 'mock/';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ContentRepository Failure Handling', () {
    test('loadUnit returns failure when content is missing', () async {
      // Use a mock source that always says files don't exist
      final mockSource = MockContentSource();
      final repo = ContentRepository(assetSource: mockSource);

      final result = await repo.loadUnit('unit_99');

      expect(result.isFailure, true);
      expect(result.failure, isA<ContentNotFound>());
      expect(result.failure.unitId, 'unit_99');
    });

    test('getLesson returns null when unit is missing', () async {
      final mockSource = MockContentSource();
      final repo = ContentRepository(assetSource: mockSource);

      final lesson = await repo.getLesson('unit_99', 'lesson_01');

      expect(lesson, isNull);
    });
  });
}
