import 'package:flutter/material.dart';
import '../design_system/aurora_background.dart';
import '../design_system/tokens/colors.dart';

enum BackgroundPolicy {
  neutral, // Standard surface0 (calm)
  aurora, // Premium subtle aurora (Path only)
}

class AppBackground extends StatelessWidget {
  final BackgroundPolicy policy;
  final Widget child;
  final bool debugLoud;

  const AppBackground({
    super.key,
    required this.child,
    this.policy = BackgroundPolicy.neutral,
    this.debugLoud = false,
  });

  @override
  Widget build(BuildContext context) {
    if (policy == BackgroundPolicy.aurora) {
      return AuroraBackground(
        isDark: Theme.of(context).brightness == Brightness.dark,
        debugLoud: debugLoud,
        child: child,
      );
    }

    // Neutral Policy (Default)
    // Just a solid background color container.
    // We expect the child (Scaffold) to be transparent if we want this to show,
    // OR we just rely on Scaffold's own background color if simpler.
    // However, to be "Single Source of Truth", we ideally render the bg here.

    final theme = Theme.of(context);
    final bgColor = theme.brightness == Brightness.dark
        ? AppColors.surface0Dark
        : AppColors.surface0Light;

    return Container(color: bgColor, child: child);
  }
}
