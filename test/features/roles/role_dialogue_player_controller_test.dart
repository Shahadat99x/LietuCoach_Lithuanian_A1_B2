import 'package:flutter_test/flutter_test.dart';
import 'package:lietucoach/features/roles/widgets/role_dialogue_player_controller.dart';

void main() {
  group('RoleDialoguePlayerController', () {
    test('defaults to learn mode at first line', () {
      final controller = RoleDialoguePlayerController(totalTurns: 4);

      expect(controller.mode, RoleDialogueMode.learn);
      expect(controller.currentIndex, 0);
      expect(controller.isPlaying, isFalse);
      expect(controller.lineCounter, '1 / 4');
    });

    test('keeps index clamped to valid range', () {
      final controller = RoleDialoguePlayerController(totalTurns: 3);

      controller.setCurrentIndex(10);
      expect(controller.currentIndex, 2);

      controller.setCurrentIndex(-10);
      expect(controller.currentIndex, 0);
    });

    test('tracks audio availability flags', () {
      final controller = RoleDialoguePlayerController(totalTurns: 3);

      controller.setAudioAvailability([true, false, true]);
      expect(controller.hasAnyMissingAudio, isTrue);
      expect(controller.isAllAudioMissing, isFalse);
      expect(controller.isAudioAvailableAt(1), isFalse);

      controller.markAudioMissing(0);
      controller.markAudioMissing(2);
      expect(controller.isAllAudioMissing, isTrue);
    });

    test('switches mode without resetting current line', () {
      final controller = RoleDialoguePlayerController(totalTurns: 5);
      controller.setCurrentIndex(3);

      controller.setMode(RoleDialogueMode.play);
      expect(controller.mode, RoleDialogueMode.play);
      expect(controller.currentIndex, 3);

      controller.setMode(RoleDialogueMode.learn);
      expect(controller.mode, RoleDialogueMode.learn);
      expect(controller.currentIndex, 3);
    });
  });
}
