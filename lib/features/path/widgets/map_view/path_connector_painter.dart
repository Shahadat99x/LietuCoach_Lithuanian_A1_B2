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

    final completedPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..color = completeColor;

    final upcomingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..color = lockedColor;

    for (int i = 0; i < nodes.length - 1; i++) {
      final nextNode = nodes[i + 1];
      final isNextUnlocked = nextNode.state != PathNodeState.locked;

      final currentY = i * (nodeSize + spacing) + nodeSize / 2;
      final nextY = (i + 1) * (nodeSize + spacing) + nodeSize / 2;

      final currentX = centerX + getOffset(i);
      final nextX = centerX + getOffset(i + 1);

      final start = Offset(currentX, currentY);
      final end = Offset(nextX, nextY);

      final path = Path();
      path.moveTo(start.dx, start.dy);

      final controlY1 = start.dy + (end.dy - start.dy) * 0.5;
      final controlY2 = start.dy + (end.dy - start.dy) * 0.5;
      path.cubicTo(start.dx, controlY1, end.dx, controlY2, end.dx, end.dy);

      if (isNextUnlocked) {
        canvas.drawPath(path, completedPaint);
      } else {
        _drawDashedPath(canvas, path, upcomingPaint);
      }
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashLength = 16.0;
    const gapLength = 10.0;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + dashLength)
            .clamp(0.0, metric.length)
            .toDouble();
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant PathConnectorPainter oldDelegate) {
    if (oldDelegate.nodes.length != nodes.length ||
        oldDelegate.nodeSize != nodeSize ||
        oldDelegate.spacing != spacing ||
        oldDelegate.completeColor != completeColor ||
        oldDelegate.lockedColor != lockedColor) {
      return true;
    }

    for (var i = 0; i < nodes.length; i++) {
      final oldNode = oldDelegate.nodes[i];
      final newNode = nodes[i];
      if (oldNode.state != newNode.state || oldNode.type != newNode.type) {
        return true;
      }
    }
    return false;
  }
}
