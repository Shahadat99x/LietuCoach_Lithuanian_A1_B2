import 'package:flutter/material.dart';
import 'package:lietucoach/srs/srs.dart';
import '../../ui/tokens.dart';
import '../../ui/components/components.dart';
import '../cards/review_session_screen.dart';
import 'audio_queue_screen.dart';
import 'daily_session_service.dart';
import 'practice_planner.dart';
import '../../progress/progress.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  final _planner = PracticePlanner();
  final _sessionService = DailySessionService();
  final _progressStore = progressStore; // global getter

  // Stats
  int _streak = 0;
  int _xpToday = 0;
  int _minutesToday = 0;
  int _goalMinutes = 10;
  bool _loading = true;

  // Planner cache
  PracticePlan? _dailyPlan;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Listen to SRS changes if needed?
    // srsNotifier.addListener(_loadData);
  }
  
  // Clean up if needed

  Future<void> _loadData() async {
    setState(() => _loading = true);
    await _sessionService.init();
    
    // Refresh planner
    final plan = await _planner.planDailyMix();
    
    if (mounted) {
      setState(() {
        _streak = _sessionService.streakCount;
        _xpToday = _sessionService.xpToday;
        _minutesToday = _sessionService.minutesToday;
        _goalMinutes = _sessionService.dailyGoalMinutes;
        _dailyPlan = plan;
        _loading = false;
      });
    }
  }

  void _startDailyPractice() {
    if (_dailyPlan == null || _dailyPlan!.isEmpty) {
        // Fallback or empty state handled in UI
        return;
    }
    
    _launchSession(_dailyPlan!);
  }

  void _launchListeningMode() async {
    final plan = await _planner.planListening();
    if (plan.itemsListening.isNotEmpty) {
        _launchSession(plan);
    } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No listening content available yet.')),
        );
    }
  }

  void _launchSession(PracticePlan plan) {
    if (plan.itemsFlashcards.isNotEmpty) {
      // 1. Flashcards First
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ReviewSessionScreen(
            customCards: plan.itemsFlashcards,
            onComplete: () {
               // After cards, check listening
               if (plan.itemsListening.isNotEmpty) {
                 _navigateToListening(plan);
               } else {
                 _finishSession(plan);
               }
            },
          ),
        ),
      ).then((_) {
          // If we popped back without completing (e.g. back button), reload stats
          _loadData();
      });
    } else if (plan.itemsListening.isNotEmpty) {
      // 2. Listening Only
      _navigateToListening(plan);
    }
  }

  void _navigateToListening(PracticePlan plan) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AudioQueueScreen(
          items: plan.itemsListening,
          onSessionComplete: () {
             Navigator.of(context).pop(); // Close listening
             _finishSession(plan);
          },
        ),
      ),
    ).then((_) => _loadData());
  }

  void _finishSession(PracticePlan plan) async {
    // Record stats
    await _sessionService.recordSession(plan.estimatedMinutes);
    
    // Reload stats
    await _loadData();
    
    // Show completion dialog
    if (mounted) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                title: Text('Session Complete!'),
                content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        Icon(Icons.emoji_events, size: 48, color: Colors.orange),
                        SizedBox(height: Spacing.m),
                        Text('+${plan.estimatedMinutes} mins recorded'),
                        Text('Streak: $_streak days'),
                    ],
                ),
                actions: [
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Awesome'),
                    ),
                ],
            ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Practice'),
            Text('Daily Training', style: theme.textTheme.labelSmall), // custom style extension not avail? Use labelSmall
          ],
        ),
      ),
      body: _loading 
        ? Center(child: CircularProgressIndicator()) 
        : ListView(
            padding: EdgeInsets.all(Spacing.pagePadding),
            children: [
                // 1. Stats Row
                Row(
                    children: [
                        _StatChip(
                            icon: Icons.local_fire_department,
                            label: '$_streak day streak',
                            color: Colors.orange,
                        ),
                        SizedBox(width: Spacing.s),
                        Expanded(
                            child: _StatChip(
                                icon: Icons.timer,
                                label: '$_minutesToday / $_goalMinutes min',
                                color: Colors.blue,
                            ),
                        ),
                    ],
                ),
                SizedBox(height: Spacing.l),

                // 2. Primary CTA: Daily Mix
                AppCard(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text(
                                'Recommended for you',
                                style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                ),
                            ),
                            SizedBox(height: Spacing.s),
                            Text(
                                'Daily Training Mix',
                                style: theme.textTheme.headlineSmall,
                            ),
                            SizedBox(height: Spacing.s),
                            Text(
                                _dailyPlan?.isEmpty == true 
                                ? 'Complete a lesson to unlock practice.' 
                                : '${_dailyPlan?.estimatedMinutes ?? 5} min • Words & Listening',
                                style: theme.textTheme.bodyMedium,
                            ),
                            SizedBox(height: Spacing.m),
                            PrimaryButton(
                                label: 'Start Session',
                                onPressed: _dailyPlan?.isEmpty == true ? null : _startDailyPractice,
                                isFullWidth: true,
                            ),
                        ],
                    ),
                ),
                SizedBox(height: Spacing.l),

                // 3. Modes Grid
                Text('Practice Modes', style: theme.textTheme.titleMedium),
                SizedBox(height: Spacing.m),
                
                GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: Spacing.m,
                    mainAxisSpacing: Spacing.m,
                    childAspectRatio: 1.2,
                    children: [
                        _ModeTile(
                            icon: Icons.headphones,
                            label: 'Listening',
                            color: Colors.purple.shade100,
                            iconColor: Colors.purple,
                            onTap: _launchListeningMode,
                        ),
                        _ModeTile(
                            icon: Icons.bolt,
                            label: 'Hard Words',
                            color: Colors.red.shade100,
                            iconColor: Colors.red,
                            onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Focus mode coming soon!')),
                                );
                            }, // TODO: Implement specific planHardWords launcher
                        ),
                    ],
                ),
            ],
        ),
    );
  }
}

class _StatChip extends StatelessWidget {
    final IconData icon;
    final String label;
    final Color color;

    const _StatChip({required this.icon, required this.label, required this.color});

    @override
    Widget build(BuildContext context) {
        return Container(
            padding: EdgeInsets.symmetric(horizontal: Spacing.m, vertical: Spacing.s),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                    Icon(icon, size: 20, color: color),
                    SizedBox(width: Spacing.s),
                    Text(
                        label, 
                        style: TextStyle(fontWeight: FontWeight.bold, color: color),
                    ),
                ],
            ),
        );
    }
}

class _ModeTile extends StatelessWidget {
    final IconData icon;
    final String label;
    final Color color;
    final Color iconColor;
    final VoidCallback onTap;

    const _ModeTile({
        required this.icon, 
        required this.label, 
        required this.color, 
        required this.iconColor,
        required this.onTap,
    });

    @override
    Widget build(BuildContext context) {
        return InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
                padding: EdgeInsets.all(Spacing.m),
                decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Icon(icon, size: 32, color: iconColor),
                        SizedBox(height: Spacing.s),
                        Text(
                            label,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: iconColor.withOpacity(0.8),
                            ),
                            textAlign: TextAlign.center,
                        ),
                    ],
                ),
            ),
        );
    }
}
