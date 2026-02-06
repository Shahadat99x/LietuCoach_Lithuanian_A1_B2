import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../srs/srs.dart';
import '../../../../ui/tokens.dart';

class ReviewCard extends StatelessWidget {
  final SrsCard card;
  final bool isFlipped;
  final VoidCallback onPlayAudio;
  final VoidCallback? onTap;

  // Added onFlip param purely for consistency if passed explicitly,
  // but onTap handles the interaction in the CardStack.
  final VoidCallback? onFlip;

  const ReviewCard({
    super.key,
    required this.card,
    required this.isFlipped,
    required this.onPlayAudio,
    this.onTap,
    this.onFlip,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? onFlip, // Use onTap preferentially, fallback to onFlip
      child: AnimatedSwitcher(
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
            ? _CardSide(
                key: const ValueKey('back'),
                isFront: false,
                card: card,
                onPlayAudio: onPlayAudio,
              )
            : _CardSide(
                key: const ValueKey('front'),
                isFront: true,
                card: card,
                onPlayAudio: onPlayAudio,
              ),
      ),
    );
  }
}

class _CardSide extends StatelessWidget {
  final bool isFront;
  final SrsCard card;
  final VoidCallback onPlayAudio;

  const _CardSide({
    super.key,
    required this.isFront,
    required this.card,
    required this.onPlayAudio,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.semanticColors;

    // Premium styling: Surface1 (Card Color) with subtle border/shadow
    // In Dark Mode: Surface1 is slightly lighter than background.
    // In Light Mode: Surface1 is white.
    final cardColor = theme.cardTheme.color; // Should be Surface1
    final textColor = theme.colorScheme.onSurface;
    final subTextColor = theme.colorScheme.onSurfaceVariant;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(Radii.xxl), // 24px premium
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: semantic.shadowSoft,
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(Spacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isFront) ...[
            // --- FRONT CONTENT ---
            const Spacer(),

            // Term
            Text(
              card.front,
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: Spacing.l),

            // Audio Button
            IconButton.filledTonal(
              onPressed: onPlayAudio,
              icon: const Icon(Icons.volume_up_rounded),
              iconSize: 32,
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(Spacing.m),
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
              ),
            ),

            const Spacer(),

            // Hint
            Text(
              'Tap to flip',
              style: theme.textTheme.labelMedium?.copyWith(
                color: subTextColor.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: Spacing.s),
          ] else ...[
            // --- BACK CONTENT ---
            const Spacer(),

            // Front (Small context)
            Text(
              card.front,
              style: theme.textTheme.titleMedium?.copyWith(color: subTextColor),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: Spacing.s),
            const Divider(indent: 48, endIndent: 48),
            const SizedBox(height: Spacing.s),

            // Back (Translation)
            Text(
              card.back,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),

            // TODO: Add POS/Forms/Example if available in SrsCard model in future
            const Spacer(),

            // Audio Replay (Small)
            IconButton(
              onPressed: onPlayAudio,
              icon: const Icon(Icons.volume_up_rounded),
              color: subTextColor,
            ),
          ],
        ],
      ),
    );
  }
}
