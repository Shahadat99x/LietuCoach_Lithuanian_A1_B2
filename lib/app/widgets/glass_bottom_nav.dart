import 'package:flutter/material.dart';
import '../../design_system/glass/glass.dart';
import '../../design_system/tokens/motion.dart';
import '../../design_system/tokens/semantic_tokens.dart';

class GlassBottomNavItem {
  const GlassBottomNavItem({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.semanticsLabel,
  });

  final Widget icon;
  final Widget? selectedIcon;
  final String label;
  final String? semanticsLabel;
}

class GlassBottomNav extends StatelessWidget {
  const GlassBottomNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.horizontalMargin = AppSemanticSpacing.space12,
    this.bottomSpacing = AppSemanticSpacing.space8,
    this.height = 62, // Reduced from 72 for slimmer profile
    this.borderRadius = AppSemanticShape.radiusHero,
    this.preferPerformance = true,
  });

  final List<GlassBottomNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final double horizontalMargin;
  final double bottomSpacing;
  final double height;
  final double borderRadius;
  final bool preferPerformance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.maybeOf(context);
    final semantic = theme.semanticColors;
    final isDark = theme.brightness == Brightness.dark;
    final reduceMotion = AppMotion.reduceMotionOf(context);

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final indicatorOpacity = isDark ? 0.14 : 0.08; // Reduced opacity
    final animationDuration = AppMotion.duration(
      context,
      AppMotion.normal,
      reduced: AppMotion.fast,
    );
    final bottomInset = mediaQuery?.viewPadding.bottom ?? 0.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalMargin,
        0,
        horizontalMargin,
        bottomInset + bottomSpacing,
      ),
      child: GlassSurface(
        borderRadius: BorderRadius.circular(borderRadius),
        blurSigma: 18, // Slightly more blur
        preset: GlassPreset.frost,
        preferPerformance: preferPerformance,
        useRepaintBoundary: true,
        overlayOpacity: isDark ? 0.6 : 0.4, // Custom transparency (less opaque)
        child: SizedBox(
          height: height,
          child: LayoutBuilder(
            builder: (context, constraints) {
              const indicatorHorizontalInset = 8.0;
              const indicatorHeight = 40.0; // Reduced from 46

              final itemWidth = constraints.maxWidth / items.length;
              final indicatorWidth = itemWidth - (indicatorHorizontalInset * 2);
              final clampedIndicatorWidth = indicatorWidth < 0
                  ? 0.0
                  : indicatorWidth;
              final alignmentX = items.length == 1
                  ? 0.0
                  : ((selectedIndex / (items.length - 1)) * 2) - 1;

              return Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedAlign(
                    duration: animationDuration,
                    curve: AppMotion.curve(context, AppMotion.easeOut),
                    alignment: Alignment(alignmentX, 0),
                    child: IgnorePointer(
                      child: TweenAnimationBuilder<double>(
                        key: ValueKey(selectedIndex),
                        tween: Tween(begin: 0.72, end: 1.0),
                        duration: animationDuration,
                        curve: AppMotion.curve(context, AppMotion.easeOut),
                        builder: (context, opacity, child) {
                          return Opacity(opacity: opacity, child: child);
                        },
                        child: SizedBox(
                          width: clampedIndicatorWidth,
                          height: indicatorHeight,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: semantic.accentPrimary.withValues(
                                alpha: indicatorOpacity,
                              ),
                              // Removed border for cleaner look
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      for (var i = 0; i < items.length; i++)
                        Expanded(
                          child: _GlassBottomNavTapItem(
                            item: items[i],
                            selected: i == selectedIndex,
                            reduceMotion: reduceMotion,
                            onTap: () => onSelected(i),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GlassBottomNavTapItem extends StatelessWidget {
  const _GlassBottomNavTapItem({
    required this.item,
    required this.selected,
    required this.reduceMotion,
    required this.onTap,
  });

  final GlassBottomNavItem item;
  final bool selected;
  final bool reduceMotion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.semanticColors;
    final iconColor = selected
        ? semantic.accentPrimary
        : semantic.textSecondary;
    final labelColor = selected ? semantic.textPrimary : semantic.textSecondary;

    return Semantics(
      container: true,
      button: true,
      selected: selected,
      label: item.semanticsLabel ?? item.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSemanticSpacing.space4,
                vertical: AppSemanticSpacing.space8,
              ),
              child: Center(
                child: SizedBox(
                  height: 48,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 26,
                        child: Center(
                          child: AnimatedScale(
                            scale: selected
                                ? AppMotion.scaleValue(
                                    context,
                                    AppMotion.scaleActive + 0.02,
                                  )
                                : AppMotion.scaleRest,
                            duration: reduceMotion
                                ? AppMotion.instant
                                : AppMotion.normal,
                            curve: AppMotion.curve(context, AppMotion.easeOut),
                            child: IconTheme(
                              data: IconThemeData(
                                size: selected ? 26 : 24,
                                color: iconColor,
                              ),
                              child: selected
                                  ? (item.selectedIcon ?? item.icon)
                                  : item.icon,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      SizedBox(
                        height: 14,
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: reduceMotion
                                ? AppMotion.instant
                                : AppMotion.normal,
                            curve: AppMotion.curve(context, AppMotion.easeOut),
                            style: theme.textTheme.labelSmall!.copyWith(
                              color: labelColor,
                              fontSize: 11.5,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                            ),
                            child: Text(
                              item.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
