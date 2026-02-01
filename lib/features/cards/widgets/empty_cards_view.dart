import 'package:flutter/material.dart';
import '../../../../ui/components/components.dart';

class EmptyCardsView extends StatelessWidget {
  final VoidCallback onStartPath;

  const EmptyCardsView({super.key, required this.onStartPath});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      // Standardize the container style instructions?
      // AppEmptyState is usually centered on screen.
      // But here it is inside a SliverList -> AppCard.
      // If AppEmptyState returns a Center, it might break the Card layout?
      // AppEmptyState has Center(Padding(Column)).
      // If I wrap AppEmptyState in AppCard, it might look odd if it has a background?
      // AppEmptyState doesn't have a background.
      // Let's check AppEmptyState.dart source again.
      // It returns Center(...).
      // Here we want it inside a Card.
      // I will implement it such that AppEmptyState is the content.
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: AppEmptyState(
        title: 'Start Your Collection',
        message:
            'Complete lessons on the Path to unlock\nvocabulary cards for review.',
        icon: Icons.style_outlined,
        ctaLabel: 'Go to Path',
        onCta: onStartPath,
      ),
    );
  }
}
