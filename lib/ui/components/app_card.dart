/// AppCard - Rounded card with padding and elevation

import 'package:flutter/material.dart';
import '../tokens.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.elevation,
    this.borderRadius,
    this.color,
  });

  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final double? elevation;
  final double? borderRadius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget content = Padding(
      padding: padding ?? const EdgeInsets.all(Spacing.m),
      child: child,
    );

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius ?? Radii.lg),
        child: content,
      );
    }

    return Card(
      margin: margin ?? EdgeInsets.zero,
      elevation: elevation ?? Elevations.sm,
      color: color ?? theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? Radii.lg),
      ),
      clipBehavior: Clip.antiAlias,
      child: content,
    );
  }
}
