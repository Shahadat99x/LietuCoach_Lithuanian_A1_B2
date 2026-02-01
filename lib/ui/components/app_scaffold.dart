/// AppScaffold - Consistent page wrapper
///
/// Provides SafeArea, optional AppBar, and consistent padding.

import 'package:flutter/material.dart';
import '../tokens.dart';
import '../app_background.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final bool showAppBar;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final BackgroundPolicy backgroundPolicy;

  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.showAppBar = false,
    this.actions,
    this.floatingActionButton,
    this.padding,
    this.backgroundColor,
    this.backgroundPolicy = BackgroundPolicy.neutral,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = body;

    if (padding != null || padding == null && !showAppBar) {
      content = Padding(
        padding:
            padding ??
            const EdgeInsets.symmetric(horizontal: Spacing.pagePadding),
        child: content,
      );
    }

    final scaffold = Scaffold(
      backgroundColor:
          backgroundColor ??
          Colors
              .transparent, // Default to transparent to let AppBackground show through
      appBar: showAppBar
          ? AppBar(
              title: title != null ? Text(title!) : null,
              actions: actions,
              backgroundColor: backgroundColor != null
                  ? Colors.transparent
                  : null,
              elevation: 0,
            )
          : null,
      body: SafeArea(child: content),
      floatingActionButton: floatingActionButton,
    );

    return AppBackground(policy: backgroundPolicy, child: scaffold);
  }
}
