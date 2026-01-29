/// Cards Screen - Flashcard SRS review
///
/// Main screen for flashcard tab showing stats and review button.

import 'package:flutter/material.dart';
import '../../srs/srs.dart';
import '../../ui/tokens.dart';
import '../../ui/components/components.dart';
import 'review_session_screen.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> with WidgetsBindingObserver {
  SrsStats _stats = SrsStats.empty();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadStats();
    // Also listen to SRS updates
    srsNotifier.addListener(_onSrsUpdate);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    srsNotifier.removeListener(_onSrsUpdate);
    super.dispose();
  }

  void _onSrsUpdate() {
    _loadStats();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadStats();
    }
  }

  Future<void> _loadStats() async {
    final stats = await srsStore.getStats();
    if (mounted) {
      setState(() {
        _stats = stats;
        _loading = false;
      });
    }
  }

  void _startReview() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const ReviewSessionScreen()))
        .then((_) => _loadStats()); // Refresh on return
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: Spacing.m),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.pagePadding,
              ),
              child: Text('Flashcards', style: theme.textTheme.headlineLarge),
            ),
            const SizedBox(height: Spacing.s),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.pagePadding,
              ),
              child: Text(
                'Spaced repetition review',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: Spacing.l),

            // Stats cards
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.pagePadding,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: AppCard(
                      child: Column(
                        children: [
                          Text(
                            _loading ? '-' : '${_stats.dueToday}',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Text('Due Today', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.s),
                  Expanded(
                    child: AppCard(
                      child: Column(
                        children: [
                          Text(
                            _loading ? '-' : '${_stats.totalCards}',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                          Text('Total Cards', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.l),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.pagePadding,
              ),
              child: PrimaryButton(
                label: 'Start Review',
                onPressed: _stats.dueToday > 0 ? _startReview : null,
                isFullWidth: true,
              ),
            ),
            const SizedBox(height: Spacing.l),

            if (_stats.totalCards == 0) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.pagePadding,
                ),
                child: AppCard(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: Spacing.s),
                          Text(
                            'No Cards Yet',
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: Spacing.s),
                      const Text(
                        'Complete lessons to add vocabulary cards for review.',
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (_stats.dueToday == 0 &&
                _stats.totalCards > 0 &&
                _stats.nextDue != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.pagePadding,
                ),
                child: AppCard(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: Spacing.s),
                          Text(
                            'All Caught Up!',
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: Spacing.s),
                      Text('Next review: ${_formatNextDue(_stats.nextDue!)}'),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatNextDue(DateTime nextDue) {
    final now = DateTime.now();
    final difference = nextDue.difference(now);

    if (difference.inDays > 0) {
      return 'in ${difference.inDays} day${difference.inDays == 1 ? '' : 's'}';
    } else if (difference.inHours > 0) {
      return 'in ${difference.inHours} hour${difference.inHours == 1 ? '' : 's'}';
    } else {
      return 'soon';
    }
  }
}
