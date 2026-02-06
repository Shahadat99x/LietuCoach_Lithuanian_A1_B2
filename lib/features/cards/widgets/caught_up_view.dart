import 'package:flutter/material.dart';
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
    return CaughtUpState(
      nextReadyHint: _formatNextDue(nextDue),
      primaryActionLabel: 'Go to Path',
      onPrimaryAction: onLearnMore,
    );
  }
}
