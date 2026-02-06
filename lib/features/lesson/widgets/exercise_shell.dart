import 'package:flutter/material.dart';
import '../../../ui/tokens.dart';
import '../../../ui/components/components.dart';

/// ExerciseShell - The unified template for all lesson and exam steps.
///
/// Features:
/// - Top App Bar with Close button and Progress Bar
/// - Scrollable Content Area
/// - Sticky Bottom Area (Footer) for Actions/Feedback
class ExerciseShell extends StatelessWidget {
  final double progress;
  final String? title;
  final VoidCallback onClose;
  final Widget content;
  final Widget? footer;
  final bool allowScroll;

  const ExerciseShell({
    super.key,
    required this.progress,
    this.title,
    required this.onClose,
    required this.content,
    this.footer,
    this.allowScroll = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reduceMotion = AppMotion.reduceMotionOf(context);
    final switchDuration = reduceMotion ? AppMotion.fast : AppMotion.normal;

    // Use a SafeArea that handles the bottom notch but leaves room for the footer
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.s,
                vertical: Spacing.s,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: onClose,
                    color: theme.colorScheme.onSurfaceVariant,
                    iconSize: 28,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Expanded(
                    child: ProgressBar(
                      value: progress,
                      height: 12,
                      // Premium feel: slightly thicker, rounder
                      borderRadius: Radii.full,
                    ),
                  ),
                  if (title != null) ...[
                    const SizedBox(width: Spacing.m),
                    Text(
                      title!,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ] else
                    const SizedBox(
                      width: Spacing.m,
                    ), // Balance the close button roughly
                ],
              ),
            ),

            // Content
            Expanded(
              child: allowScroll
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.pagePadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: Spacing.pagePadding),
                          content,
                          const SizedBox(
                            height: Spacing.xxl,
                          ), // Safe space at bottom
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(Spacing.pagePadding),
                      child: content,
                    ),
            ),

            // Bottom Sticky Area
            AnimatedSwitcher(
              duration: switchDuration,
              transitionBuilder: (child, animation) {
                final slideAnimation =
                    Tween<Offset>(
                      begin: AppMotion.slideOffset(
                        context,
                        dy: AppMotion.fadeOffsetMedium,
                      ),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: AppMotion.curve(context, AppMotion.easeOut),
                      ),
                    );

                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: slideAnimation,
                    child: child,
                  ),
                );
              },
              child: footer ?? const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
