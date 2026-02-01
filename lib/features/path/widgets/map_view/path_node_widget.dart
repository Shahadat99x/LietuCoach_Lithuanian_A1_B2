import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../ui/components/components.dart';
import '../../models/map_ui_models.dart';

class PathNodeWidget extends StatefulWidget {
  final PathMapNode node;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const PathNodeWidget({
    super.key,
    required this.node,
    required this.onTap,
    this.onLongPress,
  });

  @override
  State<PathNodeWidget> createState() => _PathNodeWidgetState();
}

class _PathNodeWidgetState extends State<PathNodeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseScale;
  late Animation<double> _pulseOpacity;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _pulseScale = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _pulseOpacity = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    if (widget.node.state == PathNodeState.current) {
      _pulseController.repeat();
    }
  }

  @override
  void didUpdateWidget(PathNodeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.node.state != oldWidget.node.state) {
      if (widget.node.state == PathNodeState.current) {
        _pulseController.repeat();
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = widget.node.state;
    final isLocked = state == PathNodeState.locked;
    final isCurrent = state == PathNodeState.current;
    final isCompleted = state == PathNodeState.completed;
    // final isExam = widget.node.type == PathNodeType.exam; // Unused

    // Visual Config
    final size = isCurrent ? 80.0 : 72.0;
    final Color fillColor;
    final Color iconColor;
    final Color borderColor;

    // Icon selection
    final IconData icon = widget.node.isExam
        ? Icons.emoji_events_rounded
        : _getIconForType(widget.node.type);

    // Colors
    if (isCompleted) {
      fillColor = theme.colorScheme.primaryContainer;
      iconColor = theme.colorScheme.primary;
      borderColor = theme.colorScheme.primary;
    } else if (isCurrent) {
      fillColor = theme.colorScheme.primary;
      iconColor = theme.colorScheme.onPrimary;
      borderColor = Colors.white; // Or transparent if solid
    } else {
      // Locked
      fillColor = theme.colorScheme.surfaceContainerHighest; // Grey
      iconColor = theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5);
      borderColor = Colors.transparent;
    }

    return ScaleButton(
      onTap: _handleTap,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Current Pulse Ring
          if (isCurrent)
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: size * _pulseScale.value,
                  height: size * _pulseScale.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(
                        alpha: _pulseOpacity.value,
                      ),
                      width: 4,
                    ),
                  ),
                );
              },
            ),

          // Main Node
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: fillColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor,
                width: isCompleted ? 4 : 0,
              ),
              boxShadow: !isLocked
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        offset: const Offset(0, 6),
                        blurRadius: 0, // Solid 3D shadow
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              size: isCurrent ? 36 : 30, // Bigger icon for current
              color: iconColor,
            ),
          ),

          // Check Badge for Completed
          if (isCompleted)
            Positioned(
              right: -4,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary, // Or secondary
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.check, size: 14, color: Colors.white),
              ),
            ),

          // Crown for Current/Start
        ],
      ),
    );
  }

  IconData _getIconForType(PathNodeType type) {
    switch (type) {
      case PathNodeType.lesson:
        return Icons.menu_book_rounded;
      case PathNodeType.speaking:
        return Icons.record_voice_over_rounded;
      case PathNodeType.review:
        return Icons.replay_rounded;
      case PathNodeType.exam:
        return Icons.emoji_events_rounded;
    }
  }
}
