import 'package:flutter/material.dart';
import '../../../../srs/srs.dart';
import '../../../../ui/tokens.dart';
import 'review_card.dart';

enum SwipeDirection { left, right, up }

class CardStack extends StatefulWidget {
  final List<SrsCard> cards;
  final int currentIndex;
  final bool isFlipped;
  final VoidCallback onFlip;
  final VoidCallback onPlayAudio;
  final Function(SwipeDirection) onSwipe;

  const CardStack({
    super.key,
    required this.cards,
    required this.currentIndex,
    required this.isFlipped,
    required this.onFlip,
    required this.onPlayAudio,
    required this.onSwipe,
  });

  @override
  State<CardStack> createState() => _CardStackState();
}

class _CardStackState extends State<CardStack>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  Offset _dragOffset = Offset.zero;
  double _dragRotation = 0.0;
  bool _isDragging = false;
  Size _screenSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _screenSize = MediaQuery.of(context).size;
  }

  void _onPanStart(DragStartDetails details) {
    if (widget.isFlipped) return; // Disable swipe if flipped? Or allow?
    // Generally standard to allow swipe even if flipped, but maybe preventing accidental hard swipe while reading back is good?
    // Let's allow swipe from back too to be fluid.

    setState(() {
      _isDragging = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
      // Rotation proportional to horizontal drag
      _dragRotation =
          _dragOffset.dx / _screenSize.width * 0.5; // Max 0.5 rad (~30 deg)
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });

    final double threshold = _screenSize.width * 0.3;
    final double verticalThreshold = _screenSize.height * 0.2;

    if (_dragOffset.dx > threshold) {
      _animateAway(SwipeDirection.right);
    } else if (_dragOffset.dx < -threshold) {
      _animateAway(SwipeDirection.left);
    } else if (_dragOffset.dy < -verticalThreshold) {
      _animateAway(SwipeDirection.up);
    } else {
      _resetPosition();
    }
  }

  void _resetPosition() {
    _animController.value = 0.0; // Reset logic needed
    // Actually we need to animate _dragOffset back to zero.
    // For simplicity, using physics simulation or just simple tween state.
    // Since we are using setState for drag, let's use a specialized method or just snap back for now (MVP).
    // Ideal: Tween animation from current offset to zero.

    setState(() {
      _dragOffset = Offset.zero;
      _dragRotation = 0.0;
    });
  }

  Future<void> _animateAway(SwipeDirection direction) async {
    // Animate off screen
    double endX = 0;
    double endY = 0;

    switch (direction) {
      case SwipeDirection.left:
        endX = -_screenSize.width * 1.5;
        endY = _dragOffset.dy; // Continue trajectory
        break;
      case SwipeDirection.right:
        endX = _screenSize.width * 1.5;
        endY = _dragOffset.dy;
        break;
      case SwipeDirection.up:
        endX = _dragOffset.dx;
        endY = -_screenSize.height * 1.5;
        break;
    }

    // Animate the throw
    final startOffset = _dragOffset;
    final animationDuration = const Duration(milliseconds: 200);

    final ticker = createTicker((elapsed) {
      final t = (elapsed.inMilliseconds / animationDuration.inMilliseconds)
          .clamp(0.0, 1.0);
      final curveValue = Curves.easeOut.transform(t);

      setState(() {
        _dragOffset = Offset.lerp(startOffset, Offset(endX, endY), curveValue)!;
      });
    });

    ticker.start();
    await Future.delayed(animationDuration);
    ticker.dispose();

    // Trigger callback
    widget.onSwipe(direction);

    // Reset immediately for new card. Snap back.
    setState(() {
      _dragOffset = Offset.zero;
      _dragRotation = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentIndex >= widget.cards.length) {
      return const SizedBox.shrink();
    }

    // Display order:
    // 1. Next Next Card (Bottom)
    // 2. Next Card
    // 3. Current Card (Top)

    final int index = widget.currentIndex;
    final int maxIndex = widget.cards.length - 1;

    return Stack(
      children: [
        // Background Card (Index + 2)
        if (index + 2 <= maxIndex) _buildBackgroundCard(2),

        // Next Card (Index + 1)
        if (index + 1 <= maxIndex) _buildBackgroundCard(1),

        // Active Card (Index)
        Positioned.fill(
          child: GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            child: Transform.translate(
              offset: _dragOffset,
              child: Transform.rotate(
                angle: _dragRotation,
                child: ReviewCard(
                  key: ValueKey(
                    widget.cards[index].cardId,
                  ), // Important for animation reset
                  card: widget.cards[index],
                  isFlipped: widget.isFlipped,
                  onFlip: widget
                      .onFlip, // We need to fix ReviewCard to accept this or handle tap
                  onPlayAudio: widget.onPlayAudio,
                  onTap: widget.onFlip, // Map tap to flip
                ),
              ),
            ),
          ),
        ),

        // Overlay indicators (Like Tinder "NOPE"/"LIKE")
        if (_isDragging) _buildDragOverlay(),
      ],
    );
  }

  Widget _buildBackgroundCard(int depth) {
    // depth 1: scale 0.95, y 10
    // depth 2: scale 0.90, y 20
    final double scale = 1.0 - (depth * 0.05);
    final double dy = depth * 15.0; // Vertical offset

    return Positioned.fill(
      top: dy,
      child: Transform.scale(
        scale: scale,
        alignment: Alignment.topCenter,
        child: Opacity(
          opacity: 1.0 - (depth * 0.2), // Fade out deeper cards
          child: ReviewCard(
            card: widget.cards[widget.currentIndex + depth],
            isFlipped: false,
            onPlayAudio: () {}, // No audio for bg cards
            onTap: null, // No interaction
          ),
        ),
      ),
    );
  }

  Widget _buildDragOverlay() {
    final theme = Theme.of(context);
    final semantic = theme.semanticColors;

    // Simple colored application or icon based on _dragOffset
    Color color = Colors.transparent;
    IconData? icon;
    Alignment alignment = Alignment.center;

    if (_dragOffset.dx > 50) {
      // Right (Good)
      color = semantic.successContainer;
      icon = Icons.check_circle_outline;
      alignment = Alignment.centerLeft;
    } else if (_dragOffset.dx < -50) {
      // Left (Hard)
      color = semantic.dangerContainer;
      icon = Icons.error_outline;
      alignment = Alignment.centerRight;
    } else if (_dragOffset.dy < -50) {
      // Up (Easy)
      color = theme.colorScheme.secondaryContainer;
      icon = Icons.rocket_launch_outlined;
      alignment = Alignment.bottomCenter;
    }

    if (icon == null) return const SizedBox.shrink();

    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: Container(
          margin: const EdgeInsets.all(32), // Inset to avoid edges
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: color,
          ),
          child: Icon(icon, size: 80, color: semantic.textPrimary),
        ),
      ),
    );
  }
}
