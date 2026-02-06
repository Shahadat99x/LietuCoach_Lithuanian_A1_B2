import 'package:flutter/material.dart';
import '../../../../srs/srs.dart';
import '../../../../ui/tokens.dart';

class PremiumGradeBar extends StatelessWidget {
  final SrsCard card;
  final Function(SrsRating) onRate;

  const PremiumGradeBar({super.key, required this.card, required this.onRate});

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).semanticColors;
    // Calculate intervals manually for display or use SRS logic if available.
    // Mimicking logic from ReviewSessionScreen for now.
    // Hard: 1 day (or less)
    // Good: Current Interval * Ease
    // Easy: Current Interval * Ease * 1.3

    final hardText = '1d';
    final goodText = _formatInterval(
      card.isNew ? 3 : (card.intervalDays * card.ease).round(),
    );
    final easyText = _formatInterval(
      card.isNew ? 7 : (card.intervalDays * card.ease * 1.3).round(),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.pagePadding,
        vertical: Spacing.m,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _GradeButton(
            label: 'Hard',
            interval: hardText,
            color: semantic.danger,
            icon: Icons.replay_rounded,
            onTap: () => onRate(SrsRating.hard),
          ),
          const SizedBox(width: Spacing.m),
          _GradeButton(
            label: 'Good',
            interval: goodText,
            color: semantic.accentPrimary,
            icon: Icons.check_circle_outline_rounded,
            onTap: () => onRate(SrsRating.good),
            isPrimary: true, // Make this one larger or more prominent?
          ),
          const SizedBox(width: Spacing.m),
          _GradeButton(
            label: 'Easy',
            interval: easyText,
            color: semantic.accentWarm,
            icon: Icons.rocket_launch_outlined,
            onTap: () => onRate(SrsRating.easy),
          ),
        ],
      ),
    );
  }

  String _formatInterval(int days) {
    if (days < 30) return '${days}d';
    if (days < 365) return '${(days / 30).round()}m';
    return '${(days / 365).round()}y';
  }
}

class _GradeButton extends StatelessWidget {
  final String label;
  final String interval;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const _GradeButton({
    required this.label,
    required this.interval,
    required this.color,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.semanticColors;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Radii.xl),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isPrimary ? color : theme.cardTheme.color,
              borderRadius: BorderRadius.circular(Radii.xl),
              border: isPrimary
                  ? null
                  : Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
              boxShadow: isPrimary
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isPrimary ? semantic.buttonPrimaryText : color,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isPrimary ? semantic.buttonPrimaryText : color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  interval,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: (isPrimary ? semantic.buttonPrimaryText : color)
                        .withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
