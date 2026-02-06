import 'package:flutter/material.dart';
import '../../../../design_system/glass/glass.dart';
import '../../../../ui/tokens.dart';
import '../../../../ui/components/components.dart';

class LockBottomSheet extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onAction;
  final String? actionLabel;

  const LockBottomSheet({
    super.key,
    required this.title,
    required this.message,
    this.onAction,
    this.actionLabel,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => LockBottomSheet(
        title: title,
        message: message,
        onAction: onAction,
        actionLabel: actionLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.semanticColors;

    return GlassSurface(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(Radii.xl)),
      blurSigma: 14,
      preferPerformance: true,
      padding: const EdgeInsets.all(Spacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: semantic.borderSubtle,
              borderRadius: BorderRadius.circular(Radii.full),
            ),
          ),
          const SizedBox(height: Spacing.xl),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: semantic.accentWarm.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: semantic.accentWarm.withValues(alpha: 0.32),
              ),
            ),
            child: Icon(
              Icons.lock_rounded,
              size: 32,
              color: semantic.accentWarm,
            ),
          ),
          const SizedBox(height: Spacing.l),
          Text(
            title,
            style: AppSemanticTypography.section.copyWith(
              color: semantic.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.m),
          Text(
            message,
            style: AppSemanticTypography.body.copyWith(
              color: semantic.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.xl),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              onPressed: () => Navigator.pop(context),
              label: 'Got it',
            ),
          ),
          if (onAction != null && actionLabel != null) ...[
            const SizedBox(height: Spacing.s),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onAction!();
              },
              child: Text(actionLabel!),
            ),
          ],
          const SizedBox(height: Spacing.m),
        ],
      ),
    );
  }
}
