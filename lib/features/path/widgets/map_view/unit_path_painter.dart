import 'package:flutter/material.dart';

class UnitPathPainter extends CustomPainter {
  final int nodeCount;
  final double nodeSize;
  final double spacing;
  final Function(int index) getOffset;

  UnitPathPainter({
    required this.nodeCount,
    required this.nodeSize,
    required this.spacing,
    required this.getOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFB3E5FC); // Light blue for dots

    final centerX = size.width / 2;

    for (int i = 0; i < nodeCount - 1; i++) {
      final currentY = i * (nodeSize + spacing) + nodeSize / 2;
      final nextY = (i + 1) * (nodeSize + spacing) + nodeSize / 2;

      final currentX = centerX + getOffset(i);
      final nextX = centerX + getOffset(i + 1);

      final start = Offset(currentX, currentY);
      final end = Offset(nextX, nextY);

      // Draw Curve
      final path = Path();
      path.moveTo(start.dx, start.dy);

      final controlY1 = start.dy + (end.dy - start.dy) / 2;
      final controlY2 = start.dy + (end.dy - start.dy) / 2;

      path.cubicTo(start.dx, controlY1, end.dx, controlY2, end.dx, end.dy);

      // Dash the path
      final dashWidth = 1.0;
      final dashSpace = 12.0;
      double distance = 0.0;

      for (final metric in path.computeMetrics()) {
        while (distance < metric.length) {
          final pos = metric.getTangentForOffset(distance);
          if (pos != null) {
            canvas.drawCircle(
              pos.position,
              3.0,
              paint..style = PaintingStyle.fill,
            );
          }

          distance += dashSpace;
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant UnitPathPainter oldDelegate) {
    return oldDelegate.nodeCount != nodeCount;
  }
}
