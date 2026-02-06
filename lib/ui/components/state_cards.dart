import 'package:flutter/material.dart';
import '../../design_system/glass/glass.dart';
import '../tokens.dart';
import 'app_card.dart';
import 'buttons.dart';

class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    super.key,
    required this.title,
    required this.description,
    this.icon,
    this.customIcon,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.accentColor,
    this.useGlass = true,
    this.animateEntrance = true,
  });

  final String title;
  final String description;
  final IconData? icon;
  final Widget? customIcon;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final Color? accentColor;
  final bool useGlass;
  final bool animateEntrance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.semanticColors;
    final accent = accentColor ?? semantic.accentPrimary;

    final iconNode =
        customIcon ??
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent.withValues(alpha: 0.16),
            border: Border.all(color: accent.withValues(alpha: 0.35)),
          ),
          child: Icon(
            icon ?? Icons.auto_awesome_rounded,
            color: accent,
            size: 34,
          ),
        );

    final body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        iconNode,
        const SizedBox(height: AppSemanticSpacing.space16),
        Text(
          title,
          style: AppSemanticTypography.section.copyWith(
            color: semantic.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSemanticSpacing.space8),
        Text(
          description,
          style: AppSemanticTypography.body.copyWith(
            color: semantic.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        if (primaryActionLabel != null && onPrimaryAction != null) ...[
          const SizedBox(height: AppSemanticSpacing.space24),
          PrimaryButton(
            label: primaryActionLabel!,
            onPressed: onPrimaryAction,
            isFullWidth: true,
          ),
        ],
        if (secondaryActionLabel != null && onSecondaryAction != null) ...[
          const SizedBox(height: AppSemanticSpacing.space8),
          TextButton(
            onPressed: onSecondaryAction,
            child: Text(secondaryActionLabel!),
          ),
        ],
      ],
    );

    final card = useGlass
        ? GlassCard(
            preferPerformance: true,
            padding: const EdgeInsets.all(AppSemanticSpacing.space24),
            child: body,
          )
        : AppCard(
            padding: const EdgeInsets.all(AppSemanticSpacing.space24),
            child: body,
          );

    final reduceMotion = AppMotion.reduceMotionOf(context);
    if (!animateEntrance || reduceMotion) {
      return card;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.slow,
      curve: AppMotion.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 8),
            child: child,
          ),
        );
      },
      child: card,
    );
  }
}

class CaughtUpState extends StatelessWidget {
  const CaughtUpState({
    super.key,
    this.nextReadyHint,
    required this.primaryActionLabel,
    required this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  final String? nextReadyHint;
  final String primaryActionLabel;
  final VoidCallback onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).semanticColors;
    final message = nextReadyHint == null
        ? 'Nothing due right now. Keep your streak warm.'
        : 'Nothing due right now. New reviews $nextReadyHint.';

    return EmptyStateCard(
      icon: Icons.check_circle_rounded,
      accentColor: semantic.success,
      title: 'You are all caught up',
      description: message,
      primaryActionLabel: primaryActionLabel,
      onPrimaryAction: onPrimaryAction,
      secondaryActionLabel: secondaryActionLabel,
      onSecondaryAction: onSecondaryAction,
    );
  }
}

class ComingSoonCard extends StatelessWidget {
  const ComingSoonCard({
    super.key,
    this.title = 'More coming soon',
    this.description = 'We are building the next set of scenarios.',
    this.primaryActionLabel,
    this.onPrimaryAction,
  });

  final String title;
  final String description;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).semanticColors;
    return EmptyStateCard(
      icon: Icons.auto_awesome_rounded,
      accentColor: semantic.accentWarm,
      title: title,
      description: description,
      primaryActionLabel: primaryActionLabel,
      onPrimaryAction: onPrimaryAction,
    );
  }
}
