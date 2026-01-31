import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../ui/tokens.dart';
// import '../../ui/components/components.dart'; // Unused
// import '../../ui/components/audio_play_button.dart'; // Unused
import 'domain/role_model.dart';
import 'role_takeaways_screen.dart';
import 'widgets/role_exercise_runner.dart'; // Phase 4
import 'service/role_progress_service.dart';

class RoleDialoguePlayerScreen extends StatefulWidget {
  final RoleDialogue dialogue;
  final RolePack pack;

  const RoleDialoguePlayerScreen({
    super.key,
    required this.dialogue,
    required this.pack,
  });

  @override
  State<RoleDialoguePlayerScreen> createState() =>
      _RoleDialoguePlayerScreenState();
}

class _RoleDialoguePlayerScreenState extends State<RoleDialoguePlayerScreen> {
  final AudioPlayer _player = AudioPlayer();
  final ScrollController _scrollController = ScrollController();

  int _currentTurnIndex = -1; // -1 = stopped, 0..N = playing line
  bool _isPlaying = false;
  bool _showEnglish = true; // Phase 3: Default ON
  bool _isAutoPlaying = false;
  final Set<int> _missingAudioIndices = {};

  @override
  void initState() {
    super.initState();
    // Optional: auto-play start? Prompt says "do NOT auto-play immediately"
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (_isAutoPlaying) {
          _playNextTurn();
        } else {
          setState(() {
            _isPlaying = false;
            // Keep current turn index highlighted until explicit stop or new play
          });
        }
      }
    });
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final show = await roleProgressService.getTranslationPreference();
    if (mounted) {
      setState(() => _showEnglish = show);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _playTurn(int index, {bool autoPlay = false}) async {
    if (index >= widget.dialogue.turns.length) {
      // End of dialogue
      setState(() {
        _isAutoPlaying = false;
        _isPlaying = false;
        _currentTurnIndex = widget.dialogue.turns.length; // Past end
      });
      return;
    }

    setState(() {
      _currentTurnIndex = index;
      _isPlaying = true;
      _isAutoPlaying = autoPlay;
    });

    _scrollToTurn(index);

    final turn = widget.dialogue.turns[index];
    try {
      await _player.setAsset(turn.audioNormalPath);
      await _player.play();
    } catch (e) {
      // Audio might be missing, handle gracefully
      debugPrint('Audio missing: ${turn.audioNormalPath}');
      if (mounted) {
        setState(() {
          _missingAudioIndices.add(index);
        });

        if (autoPlay) {
          // Skip to next after short delay
          await Future.delayed(const Duration(seconds: 2));
          if (mounted && _isAutoPlaying) _playNextTurn();
        } else {
          setState(() => _isPlaying = false);
        }
      }
    }
  }

  void _playNextTurn() {
    _playTurn(_currentTurnIndex + 1, autoPlay: true);
  }

  void _onPlayPause() {
    if (_isPlaying) {
      _player.pause();
      setState(() {
        _isPlaying = false;
        _isAutoPlaying = false;
      });
    } else {
      // If we are at the end, restart. Otherwise continue.
      int nextIndex = _currentTurnIndex;
      if (nextIndex < 0 || nextIndex >= widget.dialogue.turns.length) {
        nextIndex = 0;
      }
      _playTurn(nextIndex, autoPlay: true);
    }
  }

  void _scrollToTurn(int index) {
    if (_scrollController.hasClients) {
      // Calculate approximate position or use item extent?
      // For variable height list, ensureVisible is better but tricky with ListView builder.
      // We'll simplisticly wait a frame and scroll to bottom if it is nearly at bottom,
      // or try to keep active item in view.
      // Since it's chat, auto-scroll to bottom usually makes sense if we add items,
      // but here all items exist.
      // Let's scroll to active item.
      // This requires knowing the height. Simple autoscroll:
      // _scrollController.animateTo(...)
      // Better: use scrollable_positioned_list if available, but I don't see it in pubspec.
      // Hack: Scroll to specific offset estimated? No.
      // Let's just scroll minimal amount to ensure it is visible if it's way off?
      // Actually standard behavior: don't auto-scroll aggressively unless it's "streamed".
      // Highlight is enough.
    }
  }

  void _onToggleTranslation() {
    setState(() {
      _showEnglish = !_showEnglish;
    });
    roleProgressService.setTranslationPreference(_showEnglish);
  }

  void _onContinue() {
    // Navigate to Exercise Runner (Phase 4)
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RoleExerciseRunner(
          dialogue: widget.dialogue,
          onComplete: () {
            // Proceed to Takeaways
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => RoleTakeawaysScreen(
                  dialogue: widget.dialogue,
                  pack: widget.pack,
                  onFinish: () {
                    Navigator.of(context).pop(); // Perform final pop to Detail
                  },
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

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.dialogue.title),
        actions: [
          IconButton(
            icon: Icon(
              _showEnglish ? Icons.translate : Icons.translate_outlined,
            ),
            onPressed: _onToggleTranslation,
            tooltip: 'Toggle translation',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(Spacing.pagePadding),
              itemCount: turns.length + 1, // +1 for spacer at bottom
              itemBuilder: (context, i) {
                if (i == turns.length)
                  return const SizedBox(height: 100); // Space for play controls

                final turn = turns[i];
                final isActive = i == _currentTurnIndex;
                final isUser = turn.speaker == "B"; // Assumption: B is me

                return _buildChatBubble(turn, isUser, isActive, i);
              },
            ),
          ),

          // Bottom Controls
          Container(
            padding: const EdgeInsets.all(Spacing.m),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Replay
                    IconButton(
                      onPressed:
                          _currentTurnIndex >= 0 &&
                              _currentTurnIndex < turns.length
                          ? () => _playTurn(_currentTurnIndex, autoPlay: false)
                          : null,
                      icon: const Icon(Icons.replay_10_rounded),
                      tooltip: 'Replay line',
                    ),
                    const SizedBox(width: Spacing.l),

                    // Play/Pause (Compact)
                    Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: _onPlayPause,
                        icon: Icon(
                          _isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 32,
                          color: theme.colorScheme.onPrimary,
                        ),
                        tooltip: _isPlaying ? 'Pause' : 'Play',
                      ),
                    ),

                    const SizedBox(width: Spacing.l),

                    // Next / Continue
                    IconButton(
                      onPressed: _onContinue,
                      icon: const Icon(Icons.skip_next_rounded),
                      tooltip: 'Next / Finish',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(
    DialogueTurn turn,
    bool isUser,
    bool isActive,
    int index,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
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
          ],
          Flexible(
            child: GestureDetector(
              onTap: () => _playTurn(index, autoPlay: false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(Spacing.m),
                decoration: BoxDecoration(
                  color: isActive
                      ? theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.3,
                        )
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
                      ? Border.all(color: theme.colorScheme.primary, width: 2)
                      : Border.all(
                          color: theme.colorScheme.outlineVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                  boxShadow: [
                    if (isActive)
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      turn.ltText,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (_showEnglish || turn.enText.isEmpty) ...[
                      const SizedBox(height: Spacing.xs),
                      Text(
                        turn.enText,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    if (_missingAudioIndices.contains(index)) ...[
                      const SizedBox(height: Spacing.xs),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.volume_off_rounded,
                            size: 14,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(width: Spacing.xxs),
                          Text(
                            'No Audio',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (isUser) ...[
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
          ],
        ],
      ),
    );
  }
}
