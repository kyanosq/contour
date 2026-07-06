import 'dart:math';

/// Pure spirit-level math: gravity vector (accelerometer, device coords)
/// → bubble offset + "is the phone upright & level" verdict.
///
/// For a portrait phone held upright, gravity is ≈ (0, -9.8, 0) in the
/// device frame of `sensors_plus` AccelerometerEvent.
class LevelReading {
  const LevelReading({
    required this.dx,
    required this.dy,
    required this.pitchDeg,
    required this.rollDeg,
  });

  /// Bubble offset, each axis in [-1, 1]; (0,0) is perfectly level.
  final double dx;
  final double dy;

  /// Forward/back tilt in degrees (0 = perfectly upright).
  final double pitchDeg;

  /// Left/right tilt in degrees.
  final double rollDeg;

  double get radial => sqrt(dx * dx + dy * dy);
}

LevelReading readLevel(double ax, double ay, double az) {
  final g = sqrt(ax * ax + ay * ay + az * az);
  if (g < 1e-6) {
    return const LevelReading(dx: 0, dy: 0, pitchDeg: 0, rollDeg: 0);
  }
  final nx = ax / g, nz = az / g;
  // Upright portrait ⇒ gravity along -Y. Deviations:
  //   roll  — gravity leaking into X
  //   pitch — gravity leaking into Z (screen facing up/down)
  final rollDeg = asin(nx.clamp(-1, 1)) * 180 / pi;
  final pitchDeg = asin(nz.clamp(-1, 1)) * 180 / pi;
  // Bubble: normalized so ~12° maps to the ring edge (1.0).
  const fullScaleDeg = 12.0;
  return LevelReading(
    dx: (rollDeg / fullScaleDeg).clamp(-1.0, 1.0),
    dy: (pitchDeg / fullScaleDeg).clamp(-1.0, 1.0),
    pitchDeg: pitchDeg,
    rollDeg: rollDeg,
  );
}

/// Hysteresis gate: level when radial < [enter], unlevel when > [exit].
/// Prevents flicker at the boundary.
class LevelGate {
  LevelGate({this.enter = 0.32, this.exit = 0.45});

  final double enter;
  final double exit;
  bool _level = false;

  bool update(LevelReading r) {
    if (_level) {
      if (r.radial > exit) _level = false;
    } else {
      if (r.radial < enter) _level = true;
    }
    return _level;
  }

  bool get isLevel => _level;
}
