import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Returns true if the platform or user has requested reduced motion.
bool shouldReduceMotion(BuildContext context) =>
    MediaQuery.of(context).disableAnimations;

/// Extension that provides a motion-aware alternative to [Animate].
/// When reduce motion is active, effects resolve instantly to their end state.
extension ReduceMotionAnimate on Widget {
  /// Like [animate] but skips all animation when [reduceMotion] is true.
  /// Effects are applied at their final value (no transition).
  Animate animateOrSkip({
    required bool reduceMotion,
    Duration? delay,
  }) {
    if (reduceMotion) {
      return animate(adapter: ValueAdapter(1.0));
    }
    return animate(delay: delay);
  }
}
