import 'dart:ui'; // For PathMetric
import 'package:flutter/material.dart';

class PathPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final Color color;

  PathPainter({required this.start, required this.end, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (color == Colors.transparent) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw dashed path
    final path = Path();
    path.moveTo(start.dx, start.dy);

    // Quadratic Bezier? Or Cubic?
    // Control points to make it smooth.
    // Simple S-curve: Control point 1 at (start.x, mid.y), Control point 2 at (end.x, mid.y)
    final double midY = (start.dy + end.dy) / 2;

    path.cubicTo(
      start.dx,
      midY, // Control 1: Vertical down from start
      end.dx,
      midY, // Control 2: Vertical up from end (effectively)
      end.dx,
      end.dy,
    );

    // Draw dashed line
    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final Path dashPath = Path();
    final dashWidth = 10.0;
    final dashSpace = 8.0;
    double distance = 0.0;

    for (final PathMetric metric in path.computeMetrics()) {
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(PathPainter oldDelegate) {
    return oldDelegate.start != start ||
        oldDelegate.end != end ||
        oldDelegate.color != color;
  }
}
