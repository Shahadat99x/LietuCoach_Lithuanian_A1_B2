import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../ui/components/components.dart';
import '../../../../ui/tokens.dart';
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
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: AppMotion.ambient,
    );

    _pulseScale = Tween<double>(begin: 1.0, end: 1.16).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.0, 0.7, curve: AppMotion.easeOut),
      ),
    );

    _pulseOpacity = Tween<double>(begin: 0.32, end: 0.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.0, 0.7, curve: AppMotion.easeOut),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = AppMotion.reduceMotionOf(context);
    _syncPulse();
  }

  void _syncPulse() {
    if (widget.node.state == PathNodeState.current && !_reduceMotion) {
      _pulseController.repeat();
      return;
    }
    _pulseController.stop();
    _pulseController.reset();
  }

  @override
  void didUpdateWidget(PathNodeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.node.state != oldWidget.node.state) {
      _syncPulse();
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
    final semantic = theme.semanticColors;
    final state = widget.node.state;
    final isLocked = state == PathNodeState.locked;
    final isCurrent = state == PathNodeState.current;
    final isCompleted = state == PathNodeState.completed;
    final isExam = widget.node.isExam;
    final baseSize = isExam ? 74.0 : 72.0;
    final size = isCurrent ? baseSize + 8 : baseSize;

    final IconData icon = widget.node.isExam
        ? Icons.workspace_premium_rounded
        : _getIconForType(widget.node.type);

    // Determine base fill color and gradient
    final Color fillColor;
    final Gradient? gradient;
    final Color iconColor;
    final Color borderColor;

    if (isCompleted) {
      final baseColor = isExam ? semantic.accentWarm : semantic.accentPrimary;
      fillColor = baseColor;
      gradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [baseColor.withValues(alpha: 0.9), baseColor],
      );
      iconColor = semantic.buttonPrimaryText;
      borderColor = semantic.bgElevated.withValues(alpha: 0.5);
    } else if (isCurrent) {
      final baseColor = isExam ? semantic.accentWarm : semantic.accentPrimary;
      fillColor = baseColor;
      gradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [baseColor.withValues(alpha: 0.8), baseColor],
      );
      iconColor = semantic.buttonPrimaryText;
      borderColor = semantic.bgElevated.withValues(alpha: 0.8);
    } else {
      fillColor = semantic.surfaceElevated;
      gradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          semantic.surfaceElevated.withValues(alpha: 0.8),
          semantic.surfaceElevated,
        ],
      );
      iconColor = isLocked
          ? semantic.textTertiary.withValues(
              alpha: AppDisabledStyle.lockedOpacity,
            )
          : semantic.textTertiary;
      borderColor = semantic.borderSubtle;
    }

    final radius = isExam ? BorderRadius.circular(22) : null;

    return ScaleButton(
      onTap: _handleTap,
      child: Semantics(
        label: widget.node.label,
        button: true,
        enabled: true, // Keep enabled for tap-to-show-lock-message
        child: SizedBox(
          width: 88,
          height: 88,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (isCurrent && !_reduceMotion)
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: size * _pulseScale.value,
                      height: size * _pulseScale.value,
                      decoration: BoxDecoration(
                        shape: isExam ? BoxShape.rectangle : BoxShape.circle,
                        borderRadius: radius,
                        border: Border.all(
                          color: semantic.accentPrimary.withValues(
                            alpha: _pulseOpacity.value,
                          ),
                          width: 2, // Thinner, more elegant pulse
                        ),
                      ),
                    );
                  },
                ),
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: fillColor,
                  gradient: gradient,
                  shape: isExam ? BoxShape.rectangle : BoxShape.circle,
                  borderRadius: radius,
                  border: Border.all(
                    color: borderColor,
                    width: isCurrent
                        ? 2
                        : 1.5, // Slightly bolder border generally
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: semantic.shadowSoft.withValues(
                        alpha: isLocked
                            ? (theme.brightness == Brightness.dark ? 0.1 : 0.05)
                            : (theme.brightness == Brightness.dark
                                  ? 0.4
                                  : 0.18),
                      ),
                      offset: const Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Inner highlight 'shine'
                    if (!isLocked)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: size / 2,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: isExam
                                ? BoxShape.rectangle
                                : BoxShape.circle,
                            borderRadius: isExam
                                ? const BorderRadius.vertical(
                                    top: Radius.circular(22),
                                  )
                                : null,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(alpha: 0.15),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    Icon(icon, size: isCurrent ? 34 : 30, color: iconColor),
                  ],
                ),
              ),
              if (isCompleted)
                Positioned(
                  right: -2,
                  bottom: 2,
                  child: _NodeBadge(
                    icon: Icons.check_rounded,
                    color: semantic.success,
                    background: semantic.bgElevated,
                  ),
                ),
              if (isLocked)
                Positioned(
                  right: -2,
                  bottom: 2,
                  child: _NodeBadge(
                    icon: Icons.lock_rounded,
                    color: semantic.textSecondary,
                    background: semantic.bgElevated,
                  ),
                ),
            ],
          ),
        ),
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
        return Icons.workspace_premium_rounded;
    }
  }
}

class _NodeBadge extends StatelessWidget {
  const _NodeBadge({
    required this.icon,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.45), width: 1),
        boxShadow: [
          BoxShadow(
            color: Theme.of(
              context,
            ).semanticColors.shadowSoft.withValues(alpha: 0.22),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, size: 14, color: color),
    );
  }
}
