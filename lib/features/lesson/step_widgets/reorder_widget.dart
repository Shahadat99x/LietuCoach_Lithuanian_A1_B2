import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../content/content.dart';
import '../../../ui/tokens.dart';
import '../widgets/word_chip.dart';

class ReorderWidget extends StatefulWidget {
  final ReorderStep step;
  final bool hasAnswered;
  final void Function(List<int> order) onOrderChanged;

  const ReorderWidget({
    super.key,
    required this.step,
    required this.hasAnswered,
    required this.onOrderChanged,
  });

  @override
  State<ReorderWidget> createState() => _ReorderWidgetState();
}

class _ReorderWidgetState extends State<ReorderWidget> {
  final List<int> _selectedOrder = [];
  late List<int> _shuffledIndices;

  @override
  void initState() {
    super.initState();
    // Shuffle word display order
    _shuffledIndices = List.generate(widget.step.words.length, (i) => i);
    _shuffledIndices.shuffle();
  }

  void _onWordTap(int wordIndex) {
    if (widget.hasAnswered) return;
    if (_selectedOrder.contains(wordIndex)) return;

    setState(() {
      _selectedOrder.add(wordIndex);
    });
    HapticFeedback.selectionClick();
    widget.onOrderChanged(_selectedOrder);
  }

  void _onRemoveWord(int position) {
    if (widget.hasAnswered) return;
    setState(() {
      // Remove this and all subsequent words
      while (_selectedOrder.length > position + 1) {
        _selectedOrder.removeLast();
      }
      if (_selectedOrder.length > position) {
        _selectedOrder.removeAt(position);
      }
    });
    HapticFeedback.selectionClick();
    widget.onOrderChanged(_selectedOrder);
  }

  // Helper to check for coloring (visual only, logic in Runner)
  bool _isCorrect() {
    if (_selectedOrder.length != widget.step.correctOrder.length) return false;
    for (int i = 0; i < _selectedOrder.length; i++) {
      if (_selectedOrder[i] != widget.step.correctOrder[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.semanticColors;
    final reduceMotion = AppMotion.reduceMotionOf(context);
    final isCorrect = _isCorrect();
    final trayBorderColor = widget.hasAnswered
        ? (isCorrect ? semantic.success : semantic.danger)
        : semantic.borderSubtle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Arrange the words',
          style: AppSemanticTypography.section.copyWith(
            color: semantic.textPrimary,
          ),
        ),
        const SizedBox(height: AppSemanticSpacing.space12),
        Text(
          'Tap words to build a correct sentence.',
          style: AppSemanticTypography.caption.copyWith(
            color: semantic.textSecondary,
          ),
        ),
        const SizedBox(height: AppSemanticSpacing.space24),

        // Answer area (Tray)
        // Answer area (Tray) - Chip Container Look
        AnimatedSize(
          duration: reduceMotion ? AppMotion.fast : AppMotion.normal,
          curve: AppMotion.curve(context, AppMotion.easeOut),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 64), // Reduced from 92
            padding: const EdgeInsets.symmetric(
              horizontal: AppSemanticSpacing.space12, // Tighter padding
              vertical: AppSemanticSpacing.space12,
            ),
            decoration: BoxDecoration(
              // Neutral / Ghost style for empty state, slightly elevated for content
              color: _selectedOrder.isEmpty
                  ? semantic.surfaceCard.withValues(alpha: 0.5)
                  : semantic.surfaceElevated,
              borderRadius: BorderRadius.circular(AppSemanticShape.radiusCard),
              border: Border.all(
                color: widget.hasAnswered
                    ? trayBorderColor
                    : semantic.borderSubtle,
                width: widget.hasAnswered ? 2.0 : 1.0,
              ),
              boxShadow: _selectedOrder.isEmpty
                  ? []
                  : [
                      BoxShadow(
                        color: semantic.shadowSoft.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: _selectedOrder.isEmpty
                ? Center(
                    child: Text(
                      'Tap words to build sentence',
                      style: AppSemanticTypography.body.copyWith(
                        color: semantic.textSecondary.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : Wrap(
                    spacing: AppSemanticSpacing.space8,
                    runSpacing: AppSemanticSpacing.space8,
                    children: List.generate(_selectedOrder.length, (position) {
                      final wordIndex = _selectedOrder[position];
                      return WordChip(
                        label: widget.step.words[wordIndex],
                        onTap: () => _onRemoveWord(position),
                        isSelected: true,
                      );
                    }),
                  ),
          ),
        ),
        const SizedBox(
          height: AppSemanticSpacing.space32,
        ), // More breathing room
        // Word bank - Cleaner, no heavy container
        SizedBox(
          width: double.infinity,
          child: Wrap(
            spacing:
                AppSemanticSpacing.space12, // Wider spacing for tap targets
            runSpacing: AppSemanticSpacing.space12,
            alignment: WrapAlignment.center, // Center the bank
            children: _shuffledIndices.map((wordIndex) {
              final isUsed = _selectedOrder.contains(wordIndex);
              // Hide used words completely or keep as placeholders?
              // "placeholder" style in WordChip is ghosted.
              // Let's keep ghosted to maintain layout stability.
              return WordChip(
                label: widget.step.words[wordIndex],
                isPlaceholder: isUsed,
                onTap: isUsed ? null : () => _onWordTap(wordIndex),
              );
            }).toList(),
          ),
        ),

        // Show correct answer after answering
        if (widget.hasAnswered && !isCorrect) ...[
          const SizedBox(height: AppSemanticSpacing.space24),
          Text(
            'Correct: ${widget.step.correctSentence}',
            style: AppSemanticTypography.body.copyWith(
              color: semantic.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
