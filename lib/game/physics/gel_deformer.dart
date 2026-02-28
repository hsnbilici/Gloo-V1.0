import 'dart:math' as math;
import 'dart:ui';

import '../../core/constants/game_constants.dart';
import 'spring_physics.dart';

/// Jel kapsülün Bézier kontrol noktalarını spring fiziğiyle deformasyon uygular.
class GelDeformer {
  GelDeformer({required this.center, required this.radius})
      : _springs = List.generate(
          GameConstants.bezierControlPoints,
          (i) {
            final angle = i * 2 * math.pi / GameConstants.bezierControlPoints;
            return Spring2D(
              initialX: center.dx + radius * math.cos(angle),
              initialY: center.dy + radius * math.sin(angle),
            );
          },
        );

  final Offset center;
  final double radius;
  final List<Spring2D> _springs;

  bool get isSettled => _springs.every((s) => s.isSettled);

  void applyForce(Offset direction, double magnitude) {
    for (int i = 0; i < _springs.length; i++) {
      final angle = i * 2 * math.pi / GameConstants.bezierControlPoints;
      final pointDir = Offset(math.cos(angle), math.sin(angle));
      final dot = pointDir.dx * direction.dx + pointDir.dy * direction.dy;
      final deform = dot.clamp(0.0, 1.0) * magnitude * radius * 0.4;

      _springs[i].setTarget(
        center.dx + math.cos(angle) * (radius + deform),
        center.dy + math.sin(angle) * (radius + deform),
      );
    }
  }

  void resetToCircle() {
    for (int i = 0; i < _springs.length; i++) {
      final angle = i * 2 * math.pi / GameConstants.bezierControlPoints;
      _springs[i].setTarget(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
    }
  }

  Path buildPath(double dt) {
    final points = <Offset>[];
    for (final spring in _springs) {
      final (x, y) = spring.update(dt);
      points.add(Offset(x, y));
    }

    final path = Path();
    if (points.isEmpty) return path;

    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length; i++) {
      final p1 = points[i];
      final p2 = points[(i + 1) % points.length];
      final ctrl = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
      path.quadraticBezierTo(p1.dx, p1.dy, ctrl.dx, ctrl.dy);
    }
    path.close();

    return path;
  }
}
