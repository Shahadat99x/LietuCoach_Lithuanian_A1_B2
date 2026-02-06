import 'package:flutter/material.dart';

/// App typography hierarchy.
/// Source of Truth: docs/DESIGN_SYSTEM.md
abstract class AppTypography {
  static const String fontFamily = 'Nunito';

  // Weights
  static const FontWeight wRegular = FontWeight.w400;
  static const FontWeight wMedium = FontWeight.w500;
  static const FontWeight wSemiBold = FontWeight.w600;
  static const FontWeight wBold = FontWeight.w700;
  static const FontWeight wExtraBold = FontWeight.w800;

  // Mobile Hierarchy
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: wBold,
    height: 1.25,
    letterSpacing: -0.5,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: wBold,
    height: 1.3,
    letterSpacing: -0.2,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: wSemiBold,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: wMedium,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: wMedium,
    height: 1.5,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: wBold,
    height: 1.2,
    letterSpacing: 0.2, // Uppercase or control text often needs tracking
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: wMedium,
    height: 1.4,
    letterSpacing: 0.2,
  );

  // Semantic aliases
  static const TextStyle title = titleLarge;
  static const TextStyle section = titleMedium;
  static const TextStyle body = bodyMedium;
}
