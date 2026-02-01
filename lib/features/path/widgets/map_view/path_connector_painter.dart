import 'package:flutter/material.dart';
import '../../models/map_ui_models.dart';

class PathConnectorPainter extends CustomPainter {
  final List<PathMapNode> nodes;
  final double nodeSize;
  final double spacing;
  final Function(int index) getOffset;
  final Color completeColor;
  final Color lockedColor;

  PathConnectorPainter({
    required this.nodes,
    required this.nodeSize,
    required this.spacing,
    required this.getOffset,
    required this.completeColor,
    required this.lockedColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.isEmpty) return;

    final centerX = size.width / 2;

    // Stroke styles
    final solidPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth =
          6.0 // Premium Thickness
      ..strokeCap = StrokeCap.round
      ..color = completeColor;

    final dottedPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..color = lockedColor;

    for (int i = 0; i < nodes.length - 1; i++) {
      final nextNode = nodes[i + 1];

      // Determine segment state
      // A segment is "complete" if the NEXT node is reachable (unlocked/current/completed)
      // Strictly speaking: if I am completed, the path to next is completed?
      // Or if next node is unlocked, the path to it is solid.
      // Let's go with: If next node is NOT locked, draw solid.
      final isNextUnlocked = nextNode.state != PathNodeState.locked;
      final paint = isNextUnlocked ? solidPaint : dottedPaint;
      final isDotted = !isNextUnlocked;

      final currentY = i * (nodeSize + spacing) + nodeSize / 2;
      final nextY = (i + 1) * (nodeSize + spacing) + nodeSize / 2;

      final currentX = centerX + getOffset(i);
      final nextX = centerX + getOffset(i + 1);

      final start = Offset(currentX, currentY);
      final end = Offset(nextX, nextY);

      final path = Path();
      path.moveTo(start.dx, start.dy);

      // Curvier Bezier
      // Control points should be vertically between nodes to create S-curve
      final controlY1 = start.dy + (end.dy - start.dy) * 0.5;
      final controlY2 = start.dy + (end.dy - start.dy) * 0.5;

      // Horizontal offset influence?
      // Standard vertical cubic is usually fine if X changes.
      path.cubicTo(start.dx, controlY1, end.dx, controlY2, end.dx, end.dy);

      if (isDotted) {
        _drawDashedPath(canvas, path, paint);
      } else {
        canvas.drawPath(path, paint);
      }
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    // const dashWidth = 0.0; // Dots (unused)
    const dashSpace = 14.0;
    double distance = 0.0;

    // Use path metrics to place dots
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

  @override
  bool shouldRepaint(covariant PathConnectorPainter oldDelegate) {
    // Ideally compare list equality or hash
    return oldDelegate.nodes.length != nodes.length ||
        oldDelegate.nodes.first.state != nodes.first.state;
    // Simplified check; in prod maybe check hash of states
  }
}
