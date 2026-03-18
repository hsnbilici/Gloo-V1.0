import 'package:flutter/material.dart';

/// Returns the correct back arrow icon for the given text direction.
IconData directionalBackIcon(TextDirection direction) {
  return direction == TextDirection.rtl
      ? Icons.arrow_forward_rounded
      : Icons.arrow_back_rounded;
}

/// Returns (begin, end) Alignment for gradients based on text direction.
(Alignment, Alignment) directionalGradientAlignment(
  TextDirection direction,
) {
  if (direction == TextDirection.rtl) {
    return (Alignment.centerRight, Alignment.centerLeft);
  }
  return (Alignment.centerLeft, Alignment.centerRight);
}
