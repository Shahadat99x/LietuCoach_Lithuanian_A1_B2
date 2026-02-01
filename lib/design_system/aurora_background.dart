import 'package:flutter/material.dart';

/// A premium "Aurora" background with layered radial gradients.
/// Option B: Subtle "mesh/blob" gradients for depth.
class AuroraBackground extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final bool debugLoud;

  const AuroraBackground({
    super.key,
    required this.child,
    this.isDark = false,
    this.debugLoud = false,
  });

  @override
  Widget build(BuildContext context) {
    // Colors configuration (Subtle premium tints)
    // Adjust opacity for subtlety (0.06 - 0.12)
    // Tuned to 0.08 for maximum premium subtlety (Step 2)
    // DEBUG: If debugLoud is true, use high opacity (0.8)
    final double opacity = debugLoud ? 0.8 : (isDark ? 0.04 : 0.08);

    // Top-Left (Cyan/Mint - Cool Atmosphere)
    final Color color1 = debugLoud
        ? Colors.cyanAccent
        : (isDark
              ? const Color(0xFF00695C) // Dark Teal
              : const Color(0xFFB2DFDB)); // Light Teal

    // Center-Right (Deep Blue/Indigo - Knowledge)
    final Color color2 = debugLoud
        ? Colors.purpleAccent
        : (isDark
              ? const Color(0xFF311B92) // Deep Indigo
              : const Color(0xFFE8EAF6)); // Light Indigo (very subtle)

    // Bottom-Left (Soft Amber - Warmth)
    final Color color3 = debugLoud
        ? Colors.yellowAccent
        : (isDark
              ? const Color(0xFFE65100).withValues(alpha: 0.5) // Dark Orange
              : const Color(0xFFFFECB3)); // Light Amber

    return Stack(
      children: [
        // 1. Base Layer (Subtle Linear Gradient)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF121212), const Color(0xFF1E1E1E)]
                  : [
                      const Color(0xFFF9FAFB),
                      const Color(0xFFF3F4F6),
                    ], // Very light gray-white
            ),
          ),
        ),

        // 2. Blob 1: Top Left (Cool)
        Positioned(
          top: -100,
          left: -100,
          child: _AuroraBlob(
            color: color1.withValues(alpha: opacity),
            radius: 300,
          ),
        ),

        // 3. Blob 2: Center Right (Purple/Blue)
        Positioned(
          top: 200,
          right: -50,
          child: _AuroraBlob(
            color: color2.withValues(alpha: opacity),
            radius: 350,
          ),
        ),

        // 4. Blob 3: Bottom Left (Warm)
        Positioned(
          bottom: -50,
          left: -50,
          child: _AuroraBlob(
            color: color3.withValues(alpha: opacity),
            radius: 400,
          ),
        ),

        // 5. Content
        child,
      ],
    );
  }
}

class _AuroraBlob extends StatelessWidget {
  final Color color;
  final double radius;

  const _AuroraBlob({required this.color, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0.0)],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}
