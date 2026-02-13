/// LockedBadge — unified "LOCKED" visual treatment.
///
/// A small pill showing a lock icon + "LOCKED" text.
/// Used in RoleCard, PracticeModeGrid, and PathUnitCard.

import 'package:flutter/material.dart';
import '../../design_system/glass/glass.dart';
import '../../design_system/tokens/semantic_tokens.dart';
import '../../design_system/tokens/typography.dart';

class LockedBadge extends StatelessWidget {
  const LockedBadge({super.key, this.showLabel = true});

  /// Whether to show the "LOCKED" text label alongside the lock icon.
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).semanticColors;

    return GlassPill(
      minHeight: 0,
      selected: false,
      preferPerformance: true,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSemanticSpacing.space8,
        vertical: AppSemanticSpacing.space4,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock_rounded,
            size: AppDisabledStyle.lockIconSize,
            color: semantic.textSecondary,
          ),
          if (showLabel) ...[
            const SizedBox(width: AppSemanticSpacing.space4),
            Text(
              'LOCKED',
              style: AppTypography.caption.copyWith(
                color: semantic.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
