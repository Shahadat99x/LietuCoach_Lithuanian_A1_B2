/// AppScaffold - Consistent page wrapper
///
/// Provides SafeArea, optional AppBar, and consistent padding.

import 'package:flutter/material.dart';
import '../tokens.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.showAppBar = false,
    this.actions,
    this.floatingActionButton,
    this.padding,
  });

  final Widget body;
  final String? title;
  final bool showAppBar;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    Widget content = body;

    if (padding != null ||
        padding == null && !showAppBar) {
      content = Padding(
        padding: padding ??
            const EdgeInsets.symmetric(horizontal: Spacing.pagePadding),
        child: content,
      );
    }

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: title != null ? Text(title!) : null,
              actions: actions,
            )
          : null,
      body: SafeArea(child: content),
      floatingActionButton: floatingActionButton,
    );
  }
}
