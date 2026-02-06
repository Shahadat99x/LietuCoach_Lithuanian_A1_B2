import 'package:flutter/material.dart';
import '../../../../ui/components/components.dart';

class EmptyCardsView extends StatelessWidget {
  final VoidCallback onStartPath;

  const EmptyCardsView({super.key, required this.onStartPath});

  @override
  Widget build(BuildContext context) {
    return EmptyStateCard(
      icon: Icons.style_outlined,
      title: 'Your deck starts on Path',
      description: 'Finish a lesson to unlock your first cards.',
      primaryActionLabel: 'Start Unit 1',
      onPrimaryAction: onStartPath,
    );
  }
}
