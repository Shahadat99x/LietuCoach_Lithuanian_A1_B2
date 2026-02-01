import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../ui/tokens.dart';
import '../../models/map_ui_models.dart';
import 'path_connector_painter.dart';
import 'path_node_widget.dart';

class PathSectionLayout extends StatelessWidget {
  final PathMapUnitSection section;
  final Function(PathMapNode node) onNodeTap;

  const PathSectionLayout({
    super.key,
    required this.section,
    required this.onNodeTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nodes = section.nodes;

    // Spacing Config
    const double nodeSize = 72.0;
    const double verticalSpacing = 40.0; // Between nodes

    // Total height calculation for Painter
    final totalHeight = nodes.length * (nodeSize + verticalSpacing);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Unit Header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.l),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [_buildHeaderChip(context)],
          ),
        ),

        // Path Stack
        SizedBox(
          height: totalHeight,
          child: Stack(
            children: [
              // Connector Layer
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: PathConnectorPainter(
                      nodes: nodes,
                      nodeSize: nodeSize,
                      spacing: verticalSpacing,
                      getOffset: _getNodeOffset,
                      completeColor: theme.colorScheme.primary.withValues(
                        alpha: 0.5,
                      ),
                      lockedColor: theme.colorScheme.outlineVariant,
                    ),
                  ),
                ),
              ),

              // Nodes Layer
              ...List.generate(nodes.length, (index) {
                final node = nodes[index];
                final offset = _getNodeOffset(index);
                final top = index * (nodeSize + verticalSpacing);

                return Positioned(
                  top: top,
                  left: 0,
                  right: 0,
                  height: nodeSize + 20, // Allow space for pulse/shadow
                  child: Center(
                    child: Transform.translate(
                      offset: Offset(offset, 0),
                      child: PathNodeWidget(
                        node: node,
                        onTap: () => onNodeTap(node),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderChip(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.m,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            section.subTitle,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: Spacing.s),
          Text(
            section.title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: Spacing.s),
          // Progress Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(Radii.sm),
            ),
            child: Text(
              '${section.progressCount}/${section.totalCount}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Sine wave offset for curve
  double _getNodeOffset(int index) {
    // Wider curve: 80px amplitude
    // Period: 4 nodes per full wave?
    // i * pi / 2 = 90 deg per node.
    // 0, 1, 0, -1, 0 pattern.
    return 70.0 * math.sin(index * math.pi / 2.5);
  }
}
