import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lietucoach/features/common/services/asset_audio_resolver.dart';
import '../../design_system/glass/glass.dart';
import '../../ui/tokens.dart';
import 'domain/role_model.dart';
import 'role_takeaways_screen.dart';
import 'service/role_progress_service.dart';
import 'widgets/role_dialogue_player_controller.dart';
import 'widgets/role_exercise_runner.dart';

class RoleDialoguePlayerScreen extends StatefulWidget {
  const RoleDialoguePlayerScreen({
    super.key,
    required this.dialogue,
    required this.pack,
  });

  final RoleDialogue dialogue;
  final RolePack pack;

  @override
  State<RoleDialoguePlayerScreen> createState() =>
      _RoleDialoguePlayerScreenState();
}

class _RoleDialoguePlayerScreenState extends State<RoleDialoguePlayerScreen> {
  final AudioPlayer _player = AudioPlayer();
  final ScrollController _scrollController = ScrollController();

  late final RoleDialoguePlayerController _controller;
  late final List<GlobalKey> _turnKeys;
  int _playSession = 0;
  bool _showEnglish = true;
  bool _audioProbeFinished = false;
  bool _hasShownPlaySkipNotice = false;
  DateTime? _lastMissingLineSnackAt;

  @override
  void initState() {
    super.initState();
    _controller = RoleDialoguePlayerController(
      totalTurns: widget.dialogue.turns.length,
    );
    _controller.addListener(_onControllerChanged);
    _turnKeys = List<GlobalKey>.generate(
      widget.dialogue.turns.length,
      (_) => GlobalKey(),
    );

    _loadSettings();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _probeAudioAvailability();
      _scrollToCurrent(animated: false);
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _player.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadSettings() async {
    final showTranslation = await roleProgressService
        .getTranslationPreference();
    if (!mounted) return;
    setState(() {
      _showEnglish = showTranslation;
    });
  }

  Future<void> _probeAudioAvailability() async {
    final bundle = DefaultAssetBundle.of(context);
    await assetAudioResolver.ensureInitialized(bundle);
    final paths = widget.dialogue.turns
        .map((turn) => turn.audioNormalPath)
        .toList(growable: false);
    final availability = await assetAudioResolver.existsMany(
      paths,
      bundle: bundle,
    );

    _controller.setAudioAvailability(availability);
    if (kDebugMode) {
      debugPrint(
        'RoleDialoguePlayer: audio availability ${availability.where((value) => value).length}/${availability.length}',
      );
    }
    if (!mounted) return;
    setState(() {
      _audioProbeFinished = true;
    });
  }

  Future<void> _stopPlayback() async {
    _playSession++;
    try {
      await _player.stop();
      if (kDebugMode) {
        debugPrint('RoleDialoguePlayer: stop playback (session $_playSession)');
      }
    } catch (_) {
      // no-op
    }
    _controller.setPlaying(false);
  }

  Future<void> _playPause() async {
    if (_controller.isPlaying) {
      await _stopPlayback();
      return;
    }

    if (_controller.mode == RoleDialogueMode.learn) {
      if (!_controller.hasAudioForCurrent) {
        _showMissingLineSnack();
        return;
      }
      await _playCurrentLine();
      return;
    }

    if (_controller.isAllAudioMissing) {
      if (kDebugMode) {
        debugPrint('RoleDialoguePlayer: all lines missing audio, cannot play.');
      }
      return;
    }
    _hasShownPlaySkipNotice = false;
    await _playFromCurrent();
  }

  Future<void> _playCurrentLine() async {
    final session = ++_playSession;
    _controller.setPlaying(true);
    _scrollToCurrent();
    await _playLine(_controller.currentIndex, session: session);
    if (!mounted || session != _playSession) return;
    _controller.setPlaying(false);
  }

  Future<void> _playFromCurrent() async {
    final session = ++_playSession;
    _controller.setPlaying(true);
    var reachedEnd = true;

    for (
      int i = _controller.currentIndex;
      i < widget.dialogue.turns.length;
      i++
    ) {
      if (!mounted || session != _playSession) {
        reachedEnd = false;
        break;
      }
      if (!_controller.isPlaying || _controller.mode != RoleDialogueMode.play) {
        reachedEnd = false;
        break;
      }

      _controller.setCurrentIndex(i);
      _scrollToCurrent();

      if (!_controller.isAudioAvailableAt(i)) {
        if (kDebugMode) {
          debugPrint(
            'RoleDialoguePlayer: skip line $i (missing asset: ${widget.dialogue.turns[i].audioNormalPath})',
          );
        }
        _showPlaySkipNoticeOnce();
        await Future.delayed(AppMotion.fast);
        continue;
      }

      await _playLine(i, session: session);
    }

    if (!mounted || session != _playSession) return;
    _controller.setPlaying(false);
    if (kDebugMode) {
      debugPrint(
        'RoleDialoguePlayer: play session $session finished (reachedEnd=$reachedEnd)',
      );
    }
  }

  Future<void> _playFromTappedIndex(int index) async {
    await _stopPlayback();
    _controller.setCurrentIndex(index);
    _scrollToCurrent();

    if (_controller.mode == RoleDialogueMode.learn) {
      if (_controller.hasAudioForCurrent) {
        await _playCurrentLine();
      } else {
        _showMissingLineSnack();
      }
      return;
    }

    _hasShownPlaySkipNotice = false;
    await _playFromCurrent();
  }

  Future<void> _playLine(int index, {required int session}) async {
    if (!mounted || session != _playSession) return;
    final turn = widget.dialogue.turns[index];

    try {
      if (kDebugMode) {
        debugPrint(
          'RoleDialoguePlayer: play line $index path=${turn.audioNormalPath}',
        );
      }
      await _player.stop();
      await _player.setAsset(turn.audioNormalPath);
      final speed = _controller.playbackSpeed == RolePlaybackSpeed.slow
          ? 0.85
          : 1.0;
      await _player.setSpeed(speed);
      await _player.play();
      if (kDebugMode) {
        debugPrint('RoleDialoguePlayer: completed line $index');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          'RoleDialoguePlayer: failed line $index path=${turn.audioNormalPath} error=$e',
        );
      }
      _controller.markAudioMissing(index);
      if (_controller.mode == RoleDialogueMode.play) {
        _showPlaySkipNoticeOnce();
      }
    }
  }

  void _showMissingLineSnack() {
    if (!mounted) return;
    final now = DateTime.now();
    final lastShown = _lastMissingLineSnackAt;
    if (lastShown != null && now.difference(lastShown).inMilliseconds < 1200) {
      return;
    }
    _lastMissingLineSnackAt = now;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Audio missing for this line.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _autoPlayCurrentLineIfLearnMode() async {
    if (_controller.mode != RoleDialogueMode.learn) return;
    if (!_controller.hasAudioForCurrent) {
      _showMissingLineSnack();
      return;
    }
    await _playCurrentLine();
  }

  void _showPlaySkipNoticeOnce() {
    if (!mounted || _hasShownPlaySkipNotice) return;
    _hasShownPlaySkipNotice = true;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Some lines are missing audio. Skipping them.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _scrollToCurrent({bool animated = true}) {
    final index = _controller.currentIndex;
    if (index < 0 || index >= _turnKeys.length) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final contextToShow = _turnKeys[index].currentContext;
      if (contextToShow == null) return;

      Scrollable.ensureVisible(
        contextToShow,
        duration: animated ? AppMotion.normal : AppMotion.instant,
        curve: AppMotion.curve(context, AppMotion.easeOut),
        alignment: 0.2,
      );
    });
  }

  Future<void> _setMode(RoleDialogueMode mode) async {
    if (_controller.mode == mode) return;
    await _stopPlayback();
    _controller.setMode(mode);
    _scrollToCurrent();
  }

  Future<void> _goPreviousLine() async {
    await _stopPlayback();
    _controller.previous();
    _scrollToCurrent();
    await _autoPlayCurrentLineIfLearnMode();
  }

  Future<void> _goNextLine() async {
    await _stopPlayback();
    _controller.next();
    _scrollToCurrent();
    await _autoPlayCurrentLineIfLearnMode();
  }

  Future<void> _repeatCurrentLine() async {
    await _stopPlayback();
    if (!_controller.hasAudioForCurrent) {
      _showMissingLineSnack();
      return;
    }
    await _playCurrentLine();
  }

  void _toggleTranslation() {
    setState(() {
      _showEnglish = !_showEnglish;
    });
    roleProgressService.setTranslationPreference(_showEnglish);
  }

  void _toggleSpeed() {
    _controller.togglePlaybackSpeed();
  }

  void _onContinueToExercises() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RoleExerciseRunner(
          dialogue: widget.dialogue,
          onComplete: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => RoleTakeawaysScreen(
                  dialogue: widget.dialogue,
                  pack: widget.pack,
                  onFinish: () => Navigator.of(context).pop(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final turns = widget.dialogue.turns;
    final visibleCount = _controller.mode == RoleDialogueMode.learn
        ? (_controller.currentIndex + 1).clamp(0, turns.length)
        : turns.length;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.dialogue.title),
        actions: [
          IconButton(
            icon: Icon(
              _showEnglish ? Icons.translate : Icons.translate_outlined,
            ),
            onPressed: _toggleTranslation,
            tooltip: 'Toggle translation',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.pagePadding,
              Spacing.s,
              Spacing.pagePadding,
              0,
            ),
            child: _buildModeSwitch(),
          ),
          if (_audioProbeFinished && _controller.isAllAudioMissing)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.pagePadding,
                Spacing.s,
                Spacing.pagePadding,
                0,
              ),
              child: _buildAudioBanner(),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(Spacing.pagePadding),
              itemCount: visibleCount + 1,
              itemBuilder: (context, index) {
                if (index == visibleCount) {
                  return const SizedBox(height: 92);
                }

                final turn = turns[index];
                final isActive = index == _controller.currentIndex;
                final isUser = turn.speaker == 'B';
                final showAvatar =
                    index == 0 || turns[index - 1].speaker != turn.speaker;

                return _buildChatBubble(
                  key: _turnKeys[index],
                  turn: turn,
                  isUser: isUser,
                  isActive: isActive,
                  isLearnMode: _controller.mode == RoleDialogueMode.learn,
                  showAvatar: showAvatar,
                  onTap: () => _playFromTappedIndex(index),
                );
              },
            ),
          ),
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildModeSwitch() {
    return GlassCard(
      preset: GlassPreset.solid,
      padding: const EdgeInsets.all(AppSemanticSpacing.space4),
      child: Row(
        children: [
          Expanded(
            child: GlassPill(
              selected: _controller.mode == RoleDialogueMode.learn,
              onTap: () => _setMode(RoleDialogueMode.learn),
              preset: GlassPreset.frost,
              child: Text(
                'Learn',
                style: AppSemanticTypography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSemanticSpacing.space8),
          Expanded(
            child: GlassPill(
              selected: _controller.mode == RoleDialogueMode.play,
              onTap: () => _setMode(RoleDialogueMode.play),
              preset: GlassPreset.frost,
              child: Text(
                'Play',
                style: AppSemanticTypography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioBanner() {
    final theme = Theme.of(context);
    final semantic = theme.semanticColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSemanticSpacing.space12),
      decoration: BoxDecoration(
        color: semantic.accentWarm.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppSemanticShape.radiusControl),
        border: Border.all(color: semantic.accentWarm.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.volume_off_rounded, size: 16, color: semantic.accentWarm),
          const SizedBox(width: AppSemanticSpacing.space8),
          Expanded(
            child: Text(
              'Audio unavailable for this dialogue.',
              style: AppSemanticTypography.caption.copyWith(
                color: semantic.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    final theme = Theme.of(context);
    final semantic = theme.semanticColors;
    final canStartPlayback = _controller.mode == RoleDialogueMode.play
        ? !_controller.isAllAudioMissing
        : _controller.hasAudioForCurrent;
    final canPlay = _controller.isPlaying || canStartPlayback;
    final speedLabel = _controller.playbackSpeed == RolePlaybackSpeed.normal
        ? '1.0x'
        : '0.85x';

    return Container(
      padding: const EdgeInsets.fromLTRB(
        Spacing.pagePadding,
        AppSemanticSpacing.space4,
        Spacing.pagePadding,
        AppSemanticSpacing.space4,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: semantic.shadowSoft.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: AppSemanticSpacing.space4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: IconButton(
                    onPressed: _repeatCurrentLine,
                    icon: const Icon(Icons.replay_rounded, size: 22),
                    tooltip: 'Repeat line',
                  ),
                ),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: IconButton(
                    onPressed: _controller.canGoPrev ? _goPreviousLine : null,
                    icon: const Icon(Icons.skip_previous_rounded, size: 24),
                    tooltip: 'Previous line',
                  ),
                ),
                SizedBox(
                  width: 64,
                  height: 64,
                  child: FilledButton(
                    onPressed: canPlay ? _playPause : null,
                    style: FilledButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: EdgeInsets.zero,
                    ),
                    child: Icon(
                      _controller.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 32,
                    ),
                  ),
                ),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: IconButton(
                    onPressed: _controller.canGoNext ? _goNextLine : null,
                    icon: const Icon(Icons.skip_next_rounded, size: 24),
                    tooltip: 'Next line',
                  ),
                ),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: IconButton(
                    onPressed: _onContinueToExercises,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 22),
                    tooltip: 'Continue to exercises',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSemanticSpacing.space4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${_controller.lineCounter} • $speedLabel',
                  style: AppSemanticTypography.caption.copyWith(
                    color: semantic.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: AppSemanticSpacing.space8),
                GlassPill(
                  onTap: _toggleSpeed,
                  minHeight: 34,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSemanticSpacing.space8,
                    vertical: AppSemanticSpacing.space4,
                  ),
                  preset: GlassPreset.frost,
                  child: const Icon(Icons.speed_rounded, size: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble({
    required Key key,
    required DialogueTurn turn,
    required bool isUser,
    required bool isActive,
    required bool isLearnMode,
    required bool showAvatar,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final semantic = theme.semanticColors;
    final isLearnActive = isLearnMode && isActive;

    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser)
            if (showAvatar) ...[
              CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.secondaryContainer,
                child: Icon(
                  Icons.support_agent_rounded,
                  size: 20,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: Spacing.s),
            ] else
              const SizedBox(width: 40),
          Flexible(
            child: GestureDetector(
              onTap: onTap,
              child: AnimatedContainer(
                duration: AppMotion.normal,
                curve: AppMotion.easeOut,
                padding: const EdgeInsets.all(Spacing.m),
                decoration: BoxDecoration(
                  color: isLearnActive
                      ? semantic.accentPrimary.withValues(alpha: 0.18)
                      : isActive
                      ? semantic.accentPrimary.withValues(alpha: 0.14)
                      : (isUser
                            ? theme.colorScheme.primary.withValues(alpha: 0.1)
                            : theme.colorScheme.surfaceContainerHigh),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: isUser
                        ? const Radius.circular(16)
                        : const Radius.circular(4),
                    bottomRight: isUser
                        ? const Radius.circular(4)
                        : const Radius.circular(16),
                  ),
                  border: isActive
                      ? Border.all(
                          color: semantic.accentPrimary,
                          width: isLearnActive ? 1.8 : 1.5,
                        )
                      : Border.all(
                          color: semantic.borderSubtle.withValues(alpha: 0.7),
                        ),
                  boxShadow: [
                    if (isActive)
                      BoxShadow(
                        color: semantic.accentPrimary.withValues(
                          alpha: isLearnActive ? 0.24 : 0.18,
                        ),
                        blurRadius: isLearnActive ? 12 : 10,
                        offset: const Offset(0, 3),
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isLearnActive) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: Spacing.xs),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSemanticSpacing.space8,
                          vertical: AppSemanticSpacing.space4,
                        ),
                        decoration: BoxDecoration(
                          color: semantic.accentPrimary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(
                            AppSemanticShape.radiusFull,
                          ),
                        ),
                        child: Text(
                          'Now',
                          style: AppSemanticTypography.caption.copyWith(
                            color: semantic.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                    Text(
                      turn.ltText,
                      style: AppSemanticTypography.body.copyWith(
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: semantic.textPrimary,
                      ),
                    ),
                    if (_showEnglish || turn.enText.isEmpty) ...[
                      const SizedBox(height: Spacing.xs),
                      Text(
                        turn.enText,
                        style: AppSemanticTypography.caption.copyWith(
                          color: semantic.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (isUser)
            if (showAvatar) ...[
              const SizedBox(width: Spacing.s),
              CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.tertiaryContainer,
                child: Icon(
                  Icons.person_rounded,
                  size: 20,
                  color: theme.colorScheme.onTertiaryContainer,
                ),
              ),
            ] else
              const SizedBox(width: 40),
        ],
      ),
    );
  }
}
