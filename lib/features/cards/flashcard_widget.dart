/// Flashcard Widget - Flip animation card
///
/// Shows front (Lithuanian) and back (English) with flip.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../ui/tokens.dart';

class FlashcardWidget extends StatelessWidget {
  final String front;
  final String back;
  final bool isFlipped;
  final VoidCallback onPlayAudio;

  const FlashcardWidget({
    super.key,
    required this.front,
    required this.back,
    required this.isFlipped,
    required this.onPlayAudio,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        final rotate = Tween(begin: math.pi, end: 0.0).animate(animation);
        return AnimatedBuilder(
          animation: rotate,
          child: child,
          builder: (context, child) {
            final isBack = rotate.value < math.pi / 2;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(isBack ? 0 : rotate.value),
              child: child,
            );
          },
        );
      },
      child: isFlipped
          ? _CardBack(key: const ValueKey('back'), text: back)
          : _CardFront(
              key: const ValueKey('front'),
              text: front,
              onPlayAudio: onPlayAudio,
            ),
    );
  }
}

class _CardFront extends StatelessWidget {
  final String text;
  final VoidCallback onPlayAudio;

  const _CardFront({super.key, required this.text, required this.onPlayAudio});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: theme.textTheme.displaySmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.l),
          IconButton.filled(
            onPressed: onPlayAudio,
            icon: const Icon(Icons.volume_up),
            iconSize: 32,
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: Spacing.m),
          Text(
            'Lithuanian',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer.withValues(
                alpha: 0.7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  final String text;

  const _CardBack({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: theme.textTheme.displaySmall?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.m),
          Text(
            'English',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSecondaryContainer.withValues(
                alpha: 0.7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
