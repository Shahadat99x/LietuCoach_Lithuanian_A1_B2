import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A premium "Aurora" background with layered radial gradients.
/// Option B: Subtle "mesh/blob" gradients for depth.
class AuroraBackground extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const AuroraBackground({super.key, required this.child, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    // Colors configuration (Subtle premium tints)
    // Adjust opacity for subtlety (0.06 - 0.12)
    const double opacity = 0.08;

    // Top-Left (Cool Mint/Blue)
    final Color color1 = isDark
        ? const Color(0xFF004D40) // Dark Teal
        : const Color(0xFFB2DFDB); // Light Teal

    // Center-Right (Soft Purple/Blue)
    final Color color2 = isDark
        ? const Color(0xFF1A237E) // Dark Indigo
        : const Color(0xFFE1BEE7); // Light Purple

    // Bottom-Left (Warm Amber/Yellow)
    final Color color3 = isDark
        ? const Color(0xFFE65100) // Dark Orange
        : const Color(0xFFFFE082); // Light Amber

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
          child: _AuroraBlob(color: color1.withOpacity(opacity), radius: 300),
        ),

        // 3. Blob 2: Center Right (Purple/Blue)
        Positioned(
          top: 200,
          right: -50,
          child: _AuroraBlob(color: color2.withOpacity(opacity), radius: 350),
        ),

        // 4. Blob 3: Bottom Left (Warm)
        Positioned(
          bottom: -50,
          left: -50,
          child: _AuroraBlob(color: color3.withOpacity(opacity), radius: 400),
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
          colors: [color, color.withOpacity(0.0)],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}
