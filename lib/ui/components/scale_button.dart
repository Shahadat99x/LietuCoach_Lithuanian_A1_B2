import 'package:flutter/material.dart';
import '../../design_system/tokens/motion.dart';

/// A wrapper that scales down content when pressed.
/// Used for premium card interactions.
class ScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration duration;
  final double scale;

  const ScaleButton({
    super.key,
    required this.child,
    this.onTap,
    this.duration = AppMotion.fast,
    this.scale = AppMotion.scalePress,
  });

  @override
  State<ScaleButton> createState() => _ScaleButtonState();
}

class _ScaleButtonState extends State<ScaleButton> {
  bool _pressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      setState(() => _pressed = true);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      setState(() => _pressed = false);
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      setState(() => _pressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = AppMotion.reduceMotionOf(context);
    final effectiveScale = _pressed
        ? AppMotion.scaleValue(context, widget.scale)
        : AppMotion.scaleRest;
    final effectiveDuration = reduceMotion
        ? AppMotion.instant
        : widget.duration;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: effectiveScale,
        duration: effectiveDuration,
        curve: AppMotion.curve(context, AppMotion.easeOut),
        alignment: Alignment.center,
        child: widget.child,
      ),
    );
  }
}

/// Press animation wrapper that does not own tap callbacks.
/// Useful for widgets that already manage their own onTap logic (InkWell/Button).
class PressScale extends StatefulWidget {
  const PressScale({
    super.key,
    required this.child,
    this.enabled = true,
    this.scale = AppMotion.scalePress,
    this.duration = AppMotion.fast,
  });

  final Widget child;
  final bool enabled;
  final double scale;
  final Duration duration;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _pressed = false;

  void _setPressed(bool pressed) {
    if (!widget.enabled) return;
    if (_pressed == pressed) return;
    setState(() => _pressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = AppMotion.reduceMotionOf(context);
    final effectiveScale = _pressed
        ? AppMotion.scaleValue(context, widget.scale)
        : AppMotion.scaleRest;
    final effectiveDuration = reduceMotion
        ? AppMotion.instant
        : widget.duration;

    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: effectiveScale,
        duration: effectiveDuration,
        curve: AppMotion.curve(context, AppMotion.easeOut),
        alignment: Alignment.center,
        child: widget.child,
      ),
    );
  }
}
