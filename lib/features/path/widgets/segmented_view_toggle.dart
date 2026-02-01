import 'package:flutter/material.dart';

class SegmentedViewToggle extends StatelessWidget {
  final bool isMap;
  final ValueChanged<bool> onToggle;

  const SegmentedViewToggle({
    super.key,
    required this.isMap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    const height = 40.0;
    const padding = 4.0;
    const width = 96.0;

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Stack(
        children: [
          // Animated Background Pill
          AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            alignment: isMap ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: (width - padding * 2) / 2,
              height: height - padding * 2,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular((height - padding * 2) / 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
          // Icons Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ToggleOption(
                icon: Icons.format_list_bulleted_rounded,
                isSelected: !isMap,
                onTap: () => onToggle(false),
              ),
              _ToggleOption(
                icon: Icons.map_rounded,
                isSelected: isMap,
                onTap: () => onToggle(true),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              icon,
              key: ValueKey(isSelected),
              size: 20,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
