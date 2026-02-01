import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../audio/audio.dart';
import '../../ui/tokens.dart';
import '../../ui/components/components.dart';
import 'practice_planner.dart';

class AudioQueueScreen extends StatefulWidget {
  final List<PracticeItem> items;
  final VoidCallback onSessionComplete;

  const AudioQueueScreen({
    super.key,
    required this.items,
    required this.onSessionComplete,
  });

  @override
  State<AudioQueueScreen> createState() => _AudioQueueScreenState();
}

class _AudioQueueScreenState extends State<AudioQueueScreen> {
  final AudioProvider _audioProvider = LocalFileAudioProvider();

  int _currentIndex = 0;
  bool _showingMeaning = false;
  bool _isPlaying = false;
  bool _autoPlay = false;

  @override
  void initState() {
    super.initState();
    _audioProvider.init();
    // Start first audio after short delay to allow UI to settle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_autoPlay) _playCurrent();
    });
  }

  @override
  void dispose() {
    _audioProvider.dispose();
    super.dispose();
  }

  Future<void> _playCurrent() async {
    if (widget.items.isEmpty) return;

    setState(() => _isPlaying = true);

    final item = widget.items[_currentIndex];
    await _audioProvider.play(audioId: item.audioId);

    if (mounted) {
      setState(() => _isPlaying = false);
      if (_autoPlay && !_showingMeaning) {
        // Optional: auto-reveal meaning after audio?
        // For now, keep it manual or auto-show if desired.
      }
    }
  }

  void _next() {
    if (_currentIndex < widget.items.length - 1) {
      setState(() {
        _currentIndex++;
        _showingMeaning = false;
      });
      if (_autoPlay) _playCurrent();
    } else {
      widget.onSessionComplete();
    }
  }

  void _toggleMeaning() {
    setState(() {
      _showingMeaning = !_showingMeaning;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return Scaffold(body: Center(child: Text('No listening items.')));
    }

    final item = widget.items[_currentIndex];
    final progress = (_currentIndex + 1) / widget.items.length;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Listening Practice'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            // Confirm exit?
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(_autoPlay ? Icons.play_circle : Icons.pause_circle),
            tooltip: 'Auto-play',
            onPressed: () {
              setState(() => _autoPlay = !_autoPlay);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Auto-play ${_autoPlay ? "ON" : "OFF"}'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(Spacing.m),
              child: ProgressBar(value: progress),
            ),

            Spacer(),

            // Content Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: Spacing.m),
              padding: const EdgeInsets.all(Spacing.l),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: theme.colorScheme.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Lithuanian Text
                  Text(
                    item.ltText,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: Spacing.l),

                  // Audio Control
                  IconButton.filled(
                    onPressed: _isPlaying ? null : _playCurrent,
                    iconSize: 48,
                    icon: _isPlaying
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: theme.colorScheme.onPrimary,
                              strokeWidth: 3,
                            ),
                          )
                        : Icon(Icons.volume_up_rounded),
                  ),
                  const SizedBox(height: Spacing.l),

                  // Hidden/Revealed Meaning
                  AnimatedCrossFade(
                    firstChild: TextButton.icon(
                      onPressed: _toggleMeaning,
                      icon: Icon(Icons.visibility),
                      label: Text('Show Meaning'),
                    ),
                    secondChild: Column(
                      children: [
                        Text(
                          item.enText,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: Spacing.s),
                        TextButton.icon(
                          onPressed: _toggleMeaning,
                          icon: Icon(Icons.visibility_off),
                          label: Text('Hide'),
                        ),
                      ],
                    ),
                    crossFadeState: _showingMeaning
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                ],
              ),
            ),

            Spacer(),

            // Footer Controls
            Padding(
              padding: const EdgeInsets.all(Spacing.m),
              child: Row(
                children: [
                  // Previous? Maybe no previous in strict queue
                  Spacer(),
                  PrimaryButton(
                    label: _currentIndex < widget.items.length - 1
                        ? 'Next'
                        : 'Finish',
                    onPressed: _next,
                    icon: Icons.arrow_forward_rounded,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
