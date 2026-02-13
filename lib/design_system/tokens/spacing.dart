/// App spacing system.
/// Base unit: 4px
/// Source of Truth: docs/DESIGN_SYSTEM.md
abstract class AppSpacing {
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double s = 12.0;
  static const double m = 16.0; // Default standard padding
  static const double l = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;

  // Semantic aliases
  static const double space4 = xxs;
  static const double space8 = xs;
  static const double space12 = s;
  static const double space16 = m;
  static const double space24 = xl;

  // Icon sizes
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
}
