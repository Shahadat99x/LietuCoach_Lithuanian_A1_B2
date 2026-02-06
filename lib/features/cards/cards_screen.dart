/// Cards Screen - Flashcard SRS review
///
/// Main screen for flashcard tab showing stats and review button.

import 'package:flutter/material.dart';
import '../../design_system/glass/glass.dart';
import '../../srs/srs.dart';
import '../../ui/tokens.dart';
import '../../ui/components/components.dart';
import '../path/path_screen.dart';
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
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PathScreen()));
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
                          style: AppSemanticTypography.title.copyWith(
                            color: theme.semanticColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSemanticSpacing.space8),
                        Text(
                          'Your personal collection',
                          style: AppSemanticTypography.body.copyWith(
                            color: theme.semanticColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSemanticSpacing.space24),

                        // Stats
                        SrsStatsStrip(
                          dueCount: _stats.dueToday,
                          totalCount: _stats.totalCards,
                          isLoading: _loading,
                        ),
                        const SizedBox(height: AppSemanticSpacing.space24),

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
    return GlassCard(
      preferPerformance: true,
      preset: GlassPreset.frost,
      child: Column(
        children: [
          const SizedBox(height: AppSemanticSpacing.space16),
          Icon(
            Icons.style_rounded,
            size: 48,
            color: theme.semanticColors.accentPrimary,
          ),
          const SizedBox(height: AppSemanticSpacing.space16),
          Text(
            'Review Time!',
            style: AppSemanticTypography.section.copyWith(
              color: theme.semanticColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSemanticSpacing.space12),
          Text(
            '${_stats.dueToday} cards are ready for review.',
            style: AppSemanticTypography.body.copyWith(
              color: theme.semanticColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSemanticSpacing.space24),
          PrimaryButton(
            label: 'Start Review Session',
            icon: Icons.play_arrow_rounded,
            onPressed: _startReview,
            isFullWidth: true,
          ),
          const SizedBox(height: AppSemanticSpacing.space16),
        ],
      ),
    );
  }
}
