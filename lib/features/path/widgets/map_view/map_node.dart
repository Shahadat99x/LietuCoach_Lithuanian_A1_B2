import 'package:flutter/material.dart';
import '../../../../ui/tokens.dart';

class MapNode extends StatefulWidget {
  final int index;
  final bool isUnlocked;
  final bool isCompleted;
  final bool isCurrent;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  final IconData? icon;

  const MapNode({
    super.key,
    required this.index,
    required this.isUnlocked,
    required this.isCompleted,
    required this.isCurrent,
    required this.onTap,
    this.onLongPress,
    this.icon,
  });

  @override
  State<MapNode> createState() => _MapNodeState();
}

class _MapNodeState extends State<MapNode> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isCurrent) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(MapNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCurrent != oldWidget.isCurrent) {
      if (widget.isCurrent) {
        _pulseController.repeat(reverse: true);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Colors
    final Color outerRingColor = widget.isCurrent
        ? theme.colorScheme.primary.withOpacity(0.3)
        : Colors.transparent;

    final Color nodeColor = widget.isUnlocked
        ? (widget.isCompleted ? AppColors.success : theme.colorScheme.primary)
        : theme.colorScheme.surfaceContainerHighest;

    final Color iconColor = widget.isUnlocked
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurfaceVariant;

    final double size = 72.0;

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulse Ring
          if (widget.isCurrent)
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Container(
                  width: size * _pulseAnimation.value,
                  height: size * _pulseAnimation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: outerRingColor,
                  ),
                );
              },
            ),

          // Main Node
          Container(
            width: size * 0.9, // Slightly smaller than pulse
            height: size * 0.9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: nodeColor,
              boxShadow: widget.isUnlocked
                  ? [
                      BoxShadow(
                        color: nodeColor.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: Icon(
              widget.icon ??
                  (widget.isCompleted
                      ? Icons.check_rounded
                      : (widget.isUnlocked
                            ? Icons.star_rounded
                            : Icons.lock_rounded)),
              color: widget.isCompleted ? Colors.white : iconColor,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}
