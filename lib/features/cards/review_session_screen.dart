/// Review Session Screen - Flashcard review flow
///
/// Shows due cards with flip animation and rating buttons.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../audio/audio.dart';
import '../../srs/srs.dart';
import '../../ui/tokens.dart';
import '../../ui/components/components.dart';
import 'flashcard_widget.dart';

class ReviewSessionScreen extends StatefulWidget {
  final List<SrsCard>? customCards;
  final VoidCallback? onComplete;

  const ReviewSessionScreen({
    super.key,
    this.customCards,
    this.onComplete,
  });

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

    if (_cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Review')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 64, color: Colors.green),
              const SizedBox(height: Spacing.m),
              Text('No cards due!', style: theme.textTheme.headlineSmall),
              const SizedBox(height: Spacing.l),
              PrimaryButton(
                label: 'Go Back',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      );
    }

    final currentCard = _cards[_currentIndex];
    final progress = (_currentIndex + 1) / _cards.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Review (${_currentIndex + 1}/${_cards.length})'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.all(Spacing.m),
              child: ProgressBar(value: progress),
            ),

            // Flashcard
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.m),
                child: GestureDetector(
                  onTap: _flipCard,
                  child: FlashcardWidget(
                    front: currentCard.front,
                    back: currentCard.back,
                    isFlipped: _isFlipped,
                    onPlayAudio: _playAudio,
                  ),
                ),
              ),
            ),

            // Flip hint
            if (!_isFlipped)
              Padding(
                padding: const EdgeInsets.only(bottom: Spacing.s),
                child: Text(
                  'Tap card to reveal',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),

            // Rating buttons (only show when flipped)
            if (_isFlipped)
              Padding(
                padding: const EdgeInsets.all(Spacing.m),
                child: Row(
                  children: [
                    Expanded(
                      child: _RatingButton(
                        label: 'Hard',
                        subtitle: '1 day',
                        color: Colors.red.shade400,
                        onPressed: () => _rateCard(SrsRating.hard),
                      ),
                    ),
                    const SizedBox(width: Spacing.s),
                    Expanded(
                      child: _RatingButton(
                        label: 'Good',
                        subtitle:
                            '${currentCard.isNew ? 3 : (currentCard.intervalDays * currentCard.ease).round()} days',
                        color: Colors.green.shade400,
                        onPressed: () => _rateCard(SrsRating.good),
                      ),
                    ),
                    const SizedBox(width: Spacing.s),
                    Expanded(
                      child: _RatingButton(
                        label: 'Easy',
                        subtitle:
                            '${currentCard.isNew ? 7 : (currentCard.intervalDays * currentCard.ease * 1.3).round()} days',
                        color: Colors.blue.shade400,
                        onPressed: () => _rateCard(SrsRating.easy),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: Spacing.m),
          ],
        ),
      ),
    );
  }
}

class _RatingButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onPressed;

  const _RatingButton({
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: Spacing.m),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(subtitle, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
