import 'package:flutter/material.dart';
import '../tokens/semantic_tokens.dart';

class GlassDivider extends StatelessWidget {
  const GlassDivider({
    super.key,
    this.thickness = 1,
    this.indent = 0,
    this.endIndent = 0,
    this.opacity,
  });

  final double thickness;
  final double indent;
  final double endIndent;
  final double? opacity;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).semanticColors;
    return Padding(
      padding: EdgeInsets.only(left: indent, right: endIndent),
      child: Container(
        height: thickness,
        color: semantic.borderSubtle.withValues(
          alpha: opacity ?? semantic.glassBorderOpacity,
        ),
      ),
    );
  }
}
