/// Review Session Screen - Flashcard review flow
///
/// Shows due cards with flip animation and rating buttons.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../audio/audio.dart';
import '../../srs/srs.dart';
import '../../ui/tokens.dart';
import '../../ui/components/components.dart';
import 'widgets/review_card_system/card_stack.dart';
import 'widgets/review_card_system/premium_grade_bar.dart';

class ReviewSessionScreen extends StatefulWidget {
  final List<SrsCard>? customCards;
  final VoidCallback? onComplete;

  const ReviewSessionScreen({super.key, this.customCards, this.onComplete});

  @override
  State<ReviewSessionScreen> createState() => _ReviewSessionScreenState();
}

class _ReviewSessionScreenState extends State<ReviewSessionScreen> {
  late final LocalFileAudioProvider _audioProvider;
  List<SrsCard> _cards = [];
  int _currentIndex = 0;
  bool _loading = true;
  bool _isFlipped = false;
  int _reviewedCount = 0;

  @override
  void initState() {
    super.initState();
    _audioProvider = LocalFileAudioProvider();
    _audioProvider.init();
    _loadCards();
  }

  @override
  void dispose() {
    _audioProvider.dispose();
    super.dispose();
  }

  Future<void> _loadCards() async {
    final cards = widget.customCards ?? await srsStore.getDueCards(limit: 10);
    if (mounted) {
      setState(() {
        _cards = cards;
        _loading = false;
      });
    }
  }

  void _flipCard() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  Future<void> _rateCard(SrsRating rating) async {
    // Haptic feedback
    HapticFeedback.lightImpact();

    final currentCard = _cards[_currentIndex];
    await srsStore.updateAfterReview(currentCard.cardId, rating);

    setState(() {
      _reviewedCount++;
      _isFlipped = false;
    });

    // Move to next card or complete
    if (_currentIndex < _cards.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      // Session complete
      _showCompletionDialog();
    }
  }

  Future<void> _playAudio() async {
    if (_cards.isEmpty) return;
    final card = _cards[_currentIndex];
    await _audioProvider.play(audioId: card.audioId);
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Session Complete!'),
        content: Text(
          'You reviewed $_reviewedCount card${_reviewedCount == 1 ? '' : 's'}.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to cards screen
              if (widget.onComplete != null) {
                widget.onComplete!();
              }
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Review')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_cards.isEmpty || _currentIndex >= _cards.length) {
      // Show completion or empty state
      return Scaffold(
        appBar: AppBar(title: const Text('Review')),
        body: AppEmptyState(
          title: 'All Caught Up!',
          message:
              'You have no cards due for review properly. Great job keeping up!',
          icon: Icons.check_circle_outline_rounded,
          ctaLabel: 'Return to Path',
          onCta: () => Navigator.of(context).pop(),
        ),
      );
    }

    final currentCard = _cards[_currentIndex];
    final progress = (_currentIndex + 1) / _cards.length;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface, // Neutral background
      appBar: AppBar(
        title: Text('Review (${_currentIndex + 1}/${_cards.length})'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
            minHeight: 4,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: Spacing.m),

            // CARD STACK
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.m),
                child: CardStack(
                  cards: _cards,
                  currentIndex: _currentIndex,
                  isFlipped: _isFlipped,
                  onFlip: _flipCard,
                  onPlayAudio: _playAudio,
                  onSwipe: (direction) {
                    SrsRating rating;
                    switch (direction) {
                      case SwipeDirection.left:
                        rating = SrsRating.hard;
                        break;
                      case SwipeDirection.right:
                        rating = SrsRating.good;
                        break;
                      case SwipeDirection.up:
                        rating = SrsRating.easy;
                        break;
                    }
                    _rateCard(rating);
                  },
                ),
              ),
            ),

            // GRADE BAR (Only when flipped)
            // Or should we allow rating anytime? Usually only after flip.
            // Requirement logic: "left=Hard, right=Good" usually works always in Tinder,
            // but for SRS, seeing the answer is key.
            // Let's show "Tap to flip" hint if not flipped, GradeBar if flipped.
            const SizedBox(height: Spacing.m),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isFlipped
                  ? PremiumGradeBar(card: currentCard, onRate: _rateCard)
                  : Padding(
                      padding: const EdgeInsets.all(Spacing.l),
                      child: Text(
                        'Tap card to flip • Swipe for shortcuts',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
            ),

            const SizedBox(height: Spacing.l),
          ],
        ),
      ),
    );
  }
}
