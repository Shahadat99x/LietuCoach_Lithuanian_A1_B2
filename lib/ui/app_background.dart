import 'package:flutter/material.dart';
import '../design_system/aurora_background.dart';
import '../design_system/tokens/semantic_tokens.dart';

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
    final theme = Theme.of(context);
    final semantic = theme.semanticColors;

    if (policy == BackgroundPolicy.aurora) {
      return AuroraBackground(
        isDark: theme.brightness == Brightness.dark,
        debugLoud: debugLoud,
        child: child,
      );
    }

    // Neutral Policy (Default)
    // Just a solid background color container.
    // We expect the child (Scaffold) to be transparent if we want this to show,
    // OR we just rely on Scaffold's own background color if simpler.
    // However, to be "Single Source of Truth", we ideally render the bg here.

    if (theme.brightness == Brightness.dark) {
      return Container(color: semantic.bg, child: child);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: semantic.bg,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [semantic.bg, semantic.bgElevated.withValues(alpha: 0.98)],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.9, -0.95),
                  radius: 1.15,
                  colors: [
                    semantic.accentPrimary.withValues(alpha: 0.035),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.95, -0.75),
                  radius: 1.2,
                  colors: [
                    semantic.accentWarm.withValues(alpha: 0.028),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
