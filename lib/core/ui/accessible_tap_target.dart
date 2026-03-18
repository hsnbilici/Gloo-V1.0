import 'package:flutter/material.dart';

/// WCAG 2.1 uyumlu minimum 44x44dp tap target wrapper.
class AccessibleTapTarget extends StatelessWidget {
  const AccessibleTapTarget({
    super.key,
    required this.onTap,
    required this.semanticLabel,
    required this.child,
    this.minSize = 44.0,
  });

  final VoidCallback? onTap;
  final String semanticLabel;
  final Widget child;
  final double minSize;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minSize,
          minHeight: minSize,
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Center(child: child),
        ),
      ),
    );
  }
}
