/// AppListTile — consistent list tile with standardized icon size and height.
///
/// Wraps [ListTile] with consistent leading icon sizing (24px),
/// min tile height (56), and trailing chevron support.

import 'package:flutter/material.dart';
import '../../design_system/tokens/spacing.dart';

class AppListTile extends StatelessWidget {
  const AppListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.titleColor,
    this.leadingColor,
    this.showChevron = false,
  });

  final Widget title;
  final Widget? subtitle;

  /// Leading icon data. Sized to [AppSpacing.iconLg] (24).
  final IconData? leading;

  /// Custom trailing widget. If [showChevron] is true, a chevron is appended.
  final Widget? trailing;

  final VoidCallback? onTap;

  /// Override color for the leading icon (e.g. error color).
  final Color? leadingColor;

  /// Override color for the title text.
  final Color? titleColor;

  /// Whether to show a trailing chevron icon.
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget? trailingWidget;
    if (showChevron && trailing != null) {
      trailingWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          trailing!,
          const SizedBox(width: AppSpacing.xs),
          Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
        ],
      );
    } else if (showChevron) {
      trailingWidget = Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurfaceVariant,
      );
    } else {
      trailingWidget = trailing;
    }

    return ListTile(
      leading: leading != null
          ? Icon(leading, size: AppSpacing.iconLg, color: leadingColor)
          : null,
      title: title,
      subtitle: subtitle,
      trailing: trailingWidget,
      onTap: onTap,
      minTileHeight: 56,
    );
  }
}
