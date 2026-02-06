import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../design_system/glass/glass.dart';
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
    final semantic = theme.semanticColors;
    final nodes = section.nodes;

    const double nodeSize = 76.0;
    const double verticalSpacing = 42.0;

    // Total height calculation for Painter
    final totalHeight = nodes.length * (nodeSize + verticalSpacing);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Unit Header
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSemanticSpacing.space24,
          ),
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
                      completeColor: semantic.accentPrimary.withValues(
                        alpha: theme.brightness == Brightness.dark ? 0.5 : 0.42,
                      ),
                      lockedColor: semantic.borderSubtle.withValues(
                        alpha: 0.92,
                      ),
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
                  height: nodeSize + 28,
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
    final semantic = theme.semanticColors;
    return GlassPill(
      selected: true,
      minHeight: 0,
      preferPerformance: true,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSemanticSpacing.space16,
        vertical: AppSemanticSpacing.space8,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            section.subTitle,
            style: AppSemanticTypography.caption.copyWith(
              color: semantic.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: AppSemanticSpacing.space12),
          Text(
            section.title,
            style: AppSemanticTypography.body.copyWith(
              color: semantic.textPrimary,
            ),
          ),
          const SizedBox(width: AppSemanticSpacing.space12),
          // Progress Badge
          GlassPill(
            minHeight: 0,
            selected: false,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSemanticSpacing.space8,
              vertical: AppSemanticSpacing.space4,
            ),
            child: Text(
              '${section.progressCount}/${section.totalCount}',
              style: AppSemanticTypography.caption.copyWith(
                color: semantic.textSecondary,
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
