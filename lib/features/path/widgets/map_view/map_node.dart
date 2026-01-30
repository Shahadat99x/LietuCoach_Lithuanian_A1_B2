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
    // Size constants
    final double size = widget.isCurrent ? 80.0 : 72.0;

    // State Colors (Reference Style)
    Color backgroundColor;
    Color iconColor;
    Color borderColor;

    if (widget.isCompleted) {
      backgroundColor = const Color(0xFFE8F5E9); // Light Green
      iconColor = const Color(0xFF43A047); // Green (Darker for Icon)
      borderColor = const Color(0xFF43A047);
    } else if (widget.isUnlocked) {
      // Current or Unlocked but not done
      backgroundColor = const Color(0xFFE8F5E9);
      iconColor = const Color(0xFF43A047);
      borderColor = const Color(0xFF43A047);

      if (widget.isCurrent) {
        backgroundColor = const Color(0xFF4CAF50); // Filled for current?
        iconColor = Colors.white;
        borderColor = Colors.white; // Border ring handles the other color
      }
    } else {
      // Locked
      backgroundColor = const Color(0xFFF5F5F5); // Grey
      iconColor = const Color(0xFFBDBDBD); // Light Grey
      borderColor = Colors.transparent;
    }

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Pulse Ring (Current only)
          if (widget.isCurrent)
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Container(
                  width: size * _pulseAnimation.value,
                  height: size * _pulseAnimation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                  ),
                );
              },
            ),

          // Main Node Circle
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor,
              border: Border.all(
                color: borderColor.withOpacity(0.3),
                width: widget.isUnlocked ? 4 : 0,
              ),
              boxShadow: widget.isUnlocked
                  ? [
                      BoxShadow(
                        color: borderColor.withOpacity(0.4),
                        offset: const Offset(0, 4),
                        blurRadius: 0, // Solid shadow "3D" effect
                      ),
                    ]
                  : null,
            ),
            child: Icon(widget.icon ?? Icons.star, color: iconColor, size: 32),
          ),

          // Badges
          if (widget.isCompleted)
            Positioned(
              right: 0,
              bottom: 0,
              child: _StatusBadge(
                color: const Color(0xFF4CAF50),
                icon: Icons.check,
              ),
            ),

          if (!widget.isUnlocked)
            Positioned(
              right: 8, // Locked nodes usually smaller looking, badge closer?
              bottom: 0,
              child: _StatusBadge(
                color: Colors.white,
                icon: Icons.lock,
                iconColor: const Color(0xFFBDBDBD),
                shadowColor: Colors.black12,
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final Color color;
  final IconData icon;
  final Color iconColor;
  final Color? shadowColor;

  const _StatusBadge({
    required this.color,
    required this.icon,
    this.iconColor = Colors.white,
    this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          if (shadowColor != null)
            BoxShadow(
              color: shadowColor!,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Icon(icon, size: 14, color: iconColor),
    );
  }
}
