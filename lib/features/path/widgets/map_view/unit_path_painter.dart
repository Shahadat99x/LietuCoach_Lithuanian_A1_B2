import 'package:flutter/material.dart';
import '../../../../ui/tokens.dart';

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
      ..strokeWidth =
          4.0 // "Soft" but visible
      ..strokeCap = StrokeCap.round
      ..color = AppColors.surfaceVariantDark.withOpacity(
        0.2,
      ); // Default path color

    final centerX = size.width / 2;

    // We need to draw segments connecting nodes.
    // Node center Y = index * (nodeSize + spacing) + nodeSize / 2

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

      // Control points for S-curve
      final controlY1 = start.dy + (end.dy - start.dy) / 2;
      final controlY2 = start.dy + (end.dy - start.dy) / 2;

      path.cubicTo(start.dx, controlY1, end.dx, controlY2, end.dx, end.dy);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant UnitPathPainter oldDelegate) {
    return oldDelegate.nodeCount != nodeCount;
  }
}
