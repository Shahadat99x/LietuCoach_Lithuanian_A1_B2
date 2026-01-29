import 'package:flutter_test/flutter_test.dart';
import 'package:lietucoach/content/content_repository.dart';
import 'package:lietucoach/packs/packs.dart';
import 'package:lietucoach/content/content_source.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([MockSpec<PadPackService>(), MockSpec<ContentSource>()])
import 'reproduce_regression_test.mocks.dart';

void main() {
  group('Regression: Content Access', () {
    late MockPadPackService mockPadService;
    late MockContentSource mockAssetSource;
    late ContentRepository repository;

    setUp(() {
      mockPadService = MockPadPackService();
      mockAssetSource = MockContentSource();
      repository = ContentRepository(
        padService: mockPadService,
        assetSource: mockAssetSource,
      );
    });

    test(
      'isUnitAvailable should return true if PAD is missing but assets exist (Fallback)',
      () async {
        // Simulate PAD reporting "not installed" (typical for debug builds or pre-download)
        when(
          mockPadService.getPackStatus(any),
        ).thenAnswer((_) async => PackStatus.notInstalled);

        // Simulate Asset Source confirming existence (e.g. unit_01 bundled)
        when(mockAssetSource.exists(any)).thenAnswer((_) async => true);

        final isAvailable = await repository.isUnitAvailable('unit_01');

        // Verification
        expect(
          isAvailable,
          isTrue,
          reason: 'Unit 01 should be available via assets fallback',
        );

        // Verify correct path was checked
        verify(
          mockAssetSource.exists('content/a1/unit_01/unit.json'),
        ).called(1);
      },
    );
  });
}
