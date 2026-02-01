import 'package:flutter/material.dart';
import '../../ui/tokens.dart';
import '../cards/review_session_screen.dart';
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
      // If empty, navigate to Path? Or maybe just show a toast for now.
      // Better: navigate to home tab if possible, or show message.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Go to Path to unlock more content!')),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No listening content available yet.')),
      );
    }
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
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Session Complete!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, size: 48, color: Colors.orange),
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
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Spacing.xs),

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
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Text(
                    'Daily Goal: $_minutesToday / $_goalMinutes min',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.local_fire_department,
                    size: 16,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Text(
                    '$_streak days',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.l),

            // Hero
            DailyTrainingHero(plan: _dailyPlan, onStart: _startDailyPractice),
            const SizedBox(height: Spacing.xl),

            // Modes Grid
            Text(
              'Practice Modes',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Spacing.m),

            PracticeModeGrid(
              onListeningTap: _launchListeningMode,
              onSpeakingTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Speaking mode specific unlock needed!'),
                  ),
                );
              },
              onWordsTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Focus mode coming soon!')),
                );
              },
              onMistakesTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mistake review coming soon!')),
                );
              },
            ),

            const SizedBox(height: Spacing.xl),
          ],
        ),
      ),
    );
  }
}
