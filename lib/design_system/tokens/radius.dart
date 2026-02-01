import 'package:flutter/material.dart';

/// App border radii.
/// Source of Truth: docs/DESIGN_SYSTEM.md
abstract class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0; // Standard Card
  static const double xl = 24.0;
  static const double full = 999.0;

  static const Radius smRadius = Radius.circular(sm);
  static const Radius mdRadius = Radius.circular(md);
  static const Radius lgRadius = Radius.circular(lg);
  static const Radius xlRadius = Radius.circular(xl);
  static const Radius fullRadius = Radius.circular(full);
}
