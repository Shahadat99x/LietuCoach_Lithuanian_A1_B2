import 'package:flutter/material.dart';
import '../../design_system/tokens/spacing.dart';
import '../../ui/tokens.dart';
import '../../ui/components/components.dart';
import '../cards/review_session_screen.dart';
import '../path/path_screen.dart';
import '../path/widgets/lock_bottom_sheet.dart';
import 'audio_queue_screen.dart';
import 'practice_planner.dart';
import 'practice_stats_service.dart';
import 'widgets/daily_training_hero.dart';
import 'widgets/practice_mode_grid.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  final _planner = PracticePlanner();
  final _statsService = practiceStatsService; // global singleton

  // Stats
  int _streak = 0;
  int _minutesToday = 0;
  int _goalMinutes = 10;
  bool _loading = true;

  // Planner cache
  PracticePlan? _dailyPlan;

  @override
  void initState() {
    super.initState();
    _loadData();
    _statsService.addListener(_onStatsChanged);
  }

  @override
  void dispose() {
    _statsService.removeListener(_onStatsChanged);
    super.dispose();
  }

  void _onStatsChanged() {
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    // Refresh planner
    final plan = await _planner.planDailyMix();
    final stats = await _statsService.stats;

    if (mounted) {
      setState(() {
        _streak = stats.currentStreak;
        _minutesToday = stats.minutesToday;
        _goalMinutes = stats.dailyGoalMinutes;
        _dailyPlan = plan;
        _loading = false;
      });
    }
  }

  void _startDailyPractice() {
    if (_dailyPlan == null || _dailyPlan!.isEmpty) {
      _showLockedModeSheet(
        title: 'Nothing to practice yet',
        message: 'Finish a lesson on Path to unlock your next session.',
      );
      return;
    }
    _launchSession(_dailyPlan!, isDailyMix: true);
  }

  void _launchListeningMode() async {
    final plan = await _planner.planListening();
    if (plan.itemsListening.isNotEmpty) {
      _launchSession(plan, isDailyMix: false);
    } else {
      _showLockedModeSheet(
        title: 'No listening items yet',
        message: 'Finish a lesson, then come back for audio practice.',
      );
    }
  }

  void _showLockedModeSheet({
    required String title,
    required String message,
    String actionLabel = 'Go to Path',
  }) {
    LockBottomSheet.show(
      context,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const PathScreen()));
      },
    );
  }

  void _launchSession(PracticePlan plan, {required bool isDailyMix}) {
    if (plan.itemsFlashcards.isNotEmpty) {
      // 1. Flashcards First
      Navigator.of(context)
          .push(
            MaterialPageRoute(
              builder: (_) => ReviewSessionScreen(
                customCards: plan.itemsFlashcards,
                onComplete: () {
                  // After cards, check listening
                  if (plan.itemsListening.isNotEmpty) {
                    _navigateToListening(plan, isDailyMix);
                  } else {
                    _finishSession(plan, isDailyMix);
                  }
                },
              ),
            ),
          )
          .then((_) {
            _loadData();
          });
    } else if (plan.itemsListening.isNotEmpty) {
      // 2. Listening Only
      _navigateToListening(plan, isDailyMix);
    }
  }

  void _navigateToListening(PracticePlan plan, bool isDailyMix) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => AudioQueueScreen(
              items: plan.itemsListening,
              onSessionComplete: () {
                Navigator.of(context).pop(); // Close listening
                _finishSession(plan, isDailyMix);
              },
            ),
          ),
        )
        .then((_) => _loadData());
  }

  void _finishSession(PracticePlan plan, bool isDailyMix) async {
    // Record stats
    await _statsService.recordPracticeEvent(
      type: isDailyMix
          ? PracticeEventType.dailyMixCompletion
          : PracticeEventType.listeningSession,
      minutesDelta: plan.estimatedMinutes,
      // XP logic: 10xp for completion
      xpDelta: 10,
    );

    // Show completion dialog
    if (mounted) {
      final semantic = Theme.of(context).semanticColors;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Session Complete!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.emoji_events, size: 48, color: semantic.accentWarm),
              const SizedBox(height: Spacing.m),
              Text('+${plan.estimatedMinutes} mins recorded'),
              Text('Streak: $_streak days'),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.semanticColors;

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Spacing.pagePadding),
          children: [
            // Header
            Text(
              'Practice',
              style: AppSemanticTypography.title.copyWith(
                color: semantic.textPrimary,
              ),
            ),
            const SizedBox(height: AppSemanticSpacing.space8),

            // Stats Row (Integrated)
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: Spacing.xs,
                horizontal: 0,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: AppSpacing.iconSm,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Text(
                    'Daily Goal: $_minutesToday / $_goalMinutes min',
                    style: AppSemanticTypography.caption.copyWith(
                      color: semantic.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.local_fire_department,
                    size: AppSpacing.iconSm,
                    color: semantic.accentWarm,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Text(
                    '$_streak days',
                    style: AppSemanticTypography.caption.copyWith(
                      color: semantic.accentWarm,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSemanticSpacing.space24),

            // Hero
            DailyTrainingHero(plan: _dailyPlan, onStart: _startDailyPractice),
            const SizedBox(height: AppSemanticSpacing.space24),

            // Modes Grid
            AppSectionHeader(
              title: 'Practice Modes',
              uppercase: false,
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: AppSemanticSpacing.space16),

            PracticeModeGrid(
              onListeningTap: _launchListeningMode,
              onSpeakingTap: () {
                _showLockedModeSheet(
                  title: 'Speaking is locked',
                  message: 'Finish a lesson to unlock speaking practice.',
                );
              },
              onWordsTap: () {
                _showLockedModeSheet(
                  title: 'Word focus is locked',
                  message: 'Finish a lesson to unlock difficult words.',
                );
              },
              onMistakesTap: () {
                _showLockedModeSheet(
                  title: 'Mistake review is locked',
                  message: 'Do a few lessons first, then this will unlock.',
                );
              },
            ),

            const SizedBox(height: AppSemanticSpacing.space24),
          ],
        ),
      ),
    );
  }
}
