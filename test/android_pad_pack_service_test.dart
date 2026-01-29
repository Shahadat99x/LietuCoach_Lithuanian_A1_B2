import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lietucoach/packs/packs.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AndroidPadPackService Gating', () {
    const channel = MethodChannel('app.lietucoach/pad');
    final log = <MethodCall>[];

    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            log.add(methodCall);
            if (methodCall.method == 'getPackStatus') return 'installed';
            return null;
          });
      log.clear();
    });

    test('should NOT call native when usePad is false', () async {
      final service = AndroidPadPackService(usePad: false);

      final status = await service.getPackStatus('test_pack');
      final path = await service.getPackPath('test_pack');

      expect(status, PackStatus.notSupported);
      expect(path, isNull);
      expect(log, isEmpty);
    });

    test('should call native when usePad is true', () async {
      final service = AndroidPadPackService(usePad: true);

      final status = await service.getPackStatus('test_pack');

      expect(status, PackStatus.installed);
      expect(log.length, 1);
      expect(log.first.method, 'getPackStatus');
    });

    test(
      'requestDownload should throw PlatformException when usePad is false',
      () async {
        final service = AndroidPadPackService(usePad: false);

        expect(
          () => service.requestDownload('test_pack'),
          throwsA(
            isA<PlatformException>().having(
              (e) => e.code,
              'code',
              'PAD_DISABLED',
            ),
          ),
        );
        expect(log, isEmpty);
      },
    );
  });
}
