import 'package:flutter/foundation.dart';

enum RoleDialogueMode { learn, play }

enum RolePlaybackSpeed { normal, slow }

class RoleDialoguePlayerController extends ChangeNotifier {
  RoleDialoguePlayerController({required int totalTurns})
    : _totalTurns = totalTurns,
      _audioAvailability = List<bool>.filled(totalTurns, true);

  final int _totalTurns;
  List<bool> _audioAvailability;

  RoleDialogueMode _mode = RoleDialogueMode.learn;
  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _autoAdvance = true;
  RolePlaybackSpeed _playbackSpeed = RolePlaybackSpeed.normal;

  int get totalTurns => _totalTurns;
  RoleDialogueMode get mode => _mode;
  int get currentIndex => _currentIndex;
  bool get isPlaying => _isPlaying;
  bool get autoAdvance => _autoAdvance;
  RolePlaybackSpeed get playbackSpeed => _playbackSpeed;
  String get currentVariant =>
      _playbackSpeed == RolePlaybackSpeed.slow ? 'slow' : 'normal';

  bool get canGoPrev => _currentIndex > 0;
  bool get canGoNext => _currentIndex < _totalTurns - 1;
  bool get hasAnyMissingAudio => _audioAvailability.contains(false);
  bool get isAllAudioMissing => !_audioAvailability.contains(true);
  bool get hasAudioForCurrent => isAudioAvailableAt(_currentIndex);

  String get lineCounter => '${_currentIndex + 1} / $_totalTurns';

  bool isAudioAvailableAt(int index) {
    if (index < 0 || index >= _audioAvailability.length) return false;
    return _audioAvailability[index];
  }

  void setMode(RoleDialogueMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }

  void setCurrentIndex(int index) {
    if (_totalTurns == 0) return;
    final clamped = index.clamp(0, _totalTurns - 1);
    if (_currentIndex == clamped) return;
    _currentIndex = clamped;
    notifyListeners();
  }

  void next() => setCurrentIndex(_currentIndex + 1);

  void previous() => setCurrentIndex(_currentIndex - 1);

  void setPlaying(bool value) {
    if (_isPlaying == value) return;
    _isPlaying = value;
    notifyListeners();
  }

  void setAutoAdvance(bool value) {
    if (_autoAdvance == value) return;
    _autoAdvance = value;
    notifyListeners();
  }

  void togglePlaybackSpeed() {
    _playbackSpeed = _playbackSpeed == RolePlaybackSpeed.normal
        ? RolePlaybackSpeed.slow
        : RolePlaybackSpeed.normal;
    notifyListeners();
  }

  void setAudioAvailability(List<bool> values) {
    if (values.length != _totalTurns) return;
    _audioAvailability = List<bool>.from(values);
    notifyListeners();
  }

  void markAudioMissing(int index) {
    if (index < 0 || index >= _audioAvailability.length) return;
    if (_audioAvailability[index] == false) return;
    _audioAvailability[index] = false;
    notifyListeners();
  }
}
