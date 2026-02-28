import '../../core/constants/game_constants.dart';

/// Spring-based interpolation — jöle deformasyon animasyonu için.
/// Formül: F = -k * (x - target) - damping * v
class SpringPhysics {
  SpringPhysics({
    double stiffness = GameConstants.springStiffness,
    double damping = GameConstants.springDamping,
    double mass = GameConstants.springMass,
    double initialValue = 0.0,
  })  : _stiffness = stiffness,
        _damping = damping,
        _mass = mass,
        _position = initialValue,
        _target = initialValue;

  final double _stiffness;
  final double _damping;
  final double _mass;

  double _position;
  double _velocity = 0.0;
  double _target;

  double get position => _position;
  double get target => _target;

  bool get isSettled =>
      (_position - _target).abs() < GameConstants.settleTolerance &&
      _velocity.abs() < GameConstants.settleTolerance;

  void setTarget(double target) => _target = target;

  void snapTo(double value) {
    _position = value;
    _target = value;
    _velocity = 0.0;
  }

  /// Oyun tick'inde çağrılır. [dt] = saniye cinsinden delta time.
  double update(double dt) {
    if (isSettled) return _position;

    final force = -_stiffness * (_position - _target) - _damping * _velocity;
    _velocity += (force / _mass) * dt;
    _position += _velocity * dt;

    return _position;
  }
}

/// 2D spring — X ve Y ekseninde bağımsız salınım
class Spring2D {
  Spring2D({double initialX = 0.0, double initialY = 0.0})
      : x = SpringPhysics(initialValue: initialX),
        y = SpringPhysics(initialValue: initialY);

  final SpringPhysics x;
  final SpringPhysics y;

  bool get isSettled => x.isSettled && y.isSettled;

  void setTarget(double tx, double ty) {
    x.setTarget(tx);
    y.setTarget(ty);
  }

  (double, double) update(double dt) {
    return (x.update(dt), y.update(dt));
  }
}
