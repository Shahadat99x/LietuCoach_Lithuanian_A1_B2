/// Cards Screen - Flashcard SRS review
///
/// Main screen for flashcard tab showing stats and review button.

import 'package:flutter/material.dart';
import '../../srs/srs.dart';
import '../../ui/tokens.dart';
import '../../ui/components/components.dart';
import 'review_session_screen.dart';
import 'widgets/srs_stats_strip.dart';
import 'widgets/caught_up_view.dart';
import 'widgets/empty_cards_view.dart';

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

  void _goToPath() {
    // TODO: Navigation to Path tab.
    // For now, we interact via a snackbar or just pop if this was pushed (it's a tab though).
    // Ideally we use a TabController or a global navigation service.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Switching to Path tab (Simulated)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCaughtUp = _stats.dueToday == 0 && _stats.totalCards > 0;
    final isEmpty = _stats.totalCards == 0;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(Spacing.pagePadding),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        Text(
                          'Flashcards',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: Spacing.xs),
                        Text(
                          'Your personal collection',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: Spacing.l),

                        // Stats
                        SrsStatsStrip(
                          dueCount: _stats.dueToday,
                          totalCount: _stats.totalCards,
                          isLoading: _loading,
                        ),
                        const SizedBox(height: Spacing.xl),

                        // Action or Empty State
                        if (isEmpty)
                          EmptyCardsView(onStartPath: _goToPath)
                        else if (isCaughtUp)
                          CaughtUpView(
                            nextDue: _stats.nextDue,
                            onLearnMore: _goToPath,
                          )
                        else ...[
                          // Review Available
                          _buildReviewCallToAction(theme),
                        ],
                      ]),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildReviewCallToAction(ThemeData theme) {
    return AppCard(
      // Standard Surface2 for calm feel (Step 4)
      color: theme.colorScheme.surfaceContainerHighest,
      child: Column(
        children: [
          const SizedBox(height: Spacing.m),
          Icon(Icons.style_rounded, size: 48, color: theme.colorScheme.primary),
          const SizedBox(height: Spacing.m),
          Text(
            'Review Time!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: Spacing.s),
          Text(
            '${_stats.dueToday} cards are ready for review.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.l),
          PrimaryButton(
            label: 'Start Review Session',
            icon: Icons.play_arrow_rounded,
            onPressed: _startReview,
            isFullWidth: true,
          ),
          const SizedBox(height: Spacing.m),
        ],
      ),
    );
  }
}
