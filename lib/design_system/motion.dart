import 'package:flutter/material.dart';

/// App motion constants.
/// Source of Truth: docs/DESIGN_SYSTEM.md
abstract class AppMotion {
  // Durations
  static const Duration tap = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration med = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 600); // Success pops

  // Curves
  static const Curve tapCurve = Curves.easeInOut;
  static const Curve hoverCurve = Curves.easeOut;
  static const Curve pageEnter = Curves.fastOutSlowIn;
  static const Curve pop = Curves.elasticOut;
}
