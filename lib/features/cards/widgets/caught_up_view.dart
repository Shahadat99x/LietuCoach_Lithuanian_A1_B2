import 'package:flutter/material.dart';
import '../../../../ui/tokens.dart';
import '../../../../ui/components/components.dart';

class CaughtUpView extends StatelessWidget {
  final DateTime? nextDue;
  final VoidCallback onLearnMore;

  const CaughtUpView({super.key, this.nextDue, required this.onLearnMore});

  String _formatNextDue(DateTime? nextDue) {
    if (nextDue == null) return 'soon';

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

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: AppEmptyState(
        title: 'All Caught Up!',
        message:
            'Great job! New reviews will be ready\n${_formatNextDue(nextDue)}.',
        customIcon: Container(
          padding: const EdgeInsets.all(Spacing.xl),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_rounded,
            size: 64,
            color: Colors.green,
          ),
        ),
        ctaLabel: 'Learn New Words',
        onCta: onLearnMore,
      ),
    );
  }
}
