import 'package:flutter/material.dart';

/// Centralized motion tokens and adaptive reduce-motion helpers.
abstract final class AppMotion {
  // Durations
  static const Duration instant = Duration.zero;
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration normal = Duration(milliseconds: 180);
  static const Duration slow = Duration(milliseconds: 260);
  static const Duration emphasis = Duration(milliseconds: 420);
  static const Duration ambient = Duration(milliseconds: 1600);

  // Curves
  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve easeInOut = Curves.easeInOutCubic;
  static const Curve emphasisOut = Curves.easeOutBack;

  // Scale
  static const double scaleRest = 1.0;
  static const double scalePress = 0.98;
  static const double scaleActive = 1.06;

  // Slide/Fade distances
  static const double fadeOffsetSmall = 0.03; // 3% of parent size
  static const double fadeOffsetMedium = 0.05;

  static bool reduceMotionOf(BuildContext context) {
    final mediaQuery = MediaQuery.maybeOf(context);
    if (mediaQuery == null) return false;
    return mediaQuery.disableAnimations || mediaQuery.accessibleNavigation;
  }

  static Duration duration(
    BuildContext context,
    Duration regular, {
    Duration reduced = fast,
  }) {
    return reduceMotionOf(context) ? reduced : regular;
  }

  static Curve curve(BuildContext context, Curve regular) {
    return reduceMotionOf(context) ? Curves.linear : regular;
  }

  static double scaleValue(
    BuildContext context,
    double regular, {
    double reduced = scaleRest,
  }) {
    return reduceMotionOf(context) ? reduced : regular;
  }

  static Offset slideOffset(
    BuildContext context, {
    double dy = fadeOffsetSmall,
  }) {
    return reduceMotionOf(context) ? Offset.zero : Offset(0, dy);
  }
}
