import 'package:flutter/material.dart';

import '../../core/constants/color_constants.dart';

/// 4-eksenli radar/örümcek grafik widget'ı — oyuncu beceri profilini gösterir.
/// Eksenler: üst (gridEfficiency), sağ (synthesisSkill), alt (comboSkill), sol (pressureResilience).
class SkillRadarChart extends StatelessWidget {
  const SkillRadarChart({
    super.key,
    required this.gridEfficiency,
    required this.synthesisSkill,
    required this.comboSkill,
    required this.pressureResilience,
    required this.labels,
  });

  /// 0.0–1.0 arası değerler
  final double gridEfficiency;
  final double synthesisSkill;
  final double comboSkill;
  final double pressureResilience;

  /// 4 lokalize etiket: [top, right, bottom, left]
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    assert(labels.length == 4, 'labels must have exactly 4 entries');

    const double chartSize = 200;
    const double labelFontSize = 10;
    const TextStyle labelStyle = TextStyle(
      color: kMuted,
      fontSize: labelFontSize,
      fontWeight: FontWeight.w600,
    );

    return Semantics(
      label: '${labels[0]} ${(gridEfficiency * 100).round()}%, '
          '${labels[1]} ${(synthesisSkill * 100).round()}%, '
          '${labels[2]} ${(comboSkill * 100).round()}%, '
          '${labels[3]} ${(pressureResilience * 100).round()}%',
      child: SizedBox(
        width: chartSize,
        height: chartSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Painter: rings, axes, filled area
            CustomPaint(
              size: const Size(chartSize, chartSize),
              painter: _RadarPainter(
                gridEfficiency: gridEfficiency,
                synthesisSkill: synthesisSkill,
                comboSkill: comboSkill,
                pressureResilience: pressureResilience,
              ),
            ),

            // Top label
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  labels[0],
                  style: labelStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // Right label
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Center(
                child: Text(
                  labels[1],
                  style: labelStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // Bottom label
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  labels[2],
                  style: labelStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // Left label
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Center(
                child: Text(
                  labels[3],
                  style: labelStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  const _RadarPainter({
    required this.gridEfficiency,
    required this.synthesisSkill,
    required this.comboSkill,
    required this.pressureResilience,
  });

  final double gridEfficiency;
  final double synthesisSkill;
  final double comboSkill;
  final double pressureResilience;

  // 4 cardinal direction unit vectors: top, right, bottom, left
  static const List<Offset> _directions = [
    Offset(0, -1),
    Offset(1, 0),
    Offset(0, 1),
    Offset(-1, 0),
  ];

  static const List<double> _ringLevels = [0.33, 0.66, 1.0];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // 30px padding reserved for labels on each side
    final radius = (size.width < size.height ? size.width : size.height) / 2 - 30;

    final gridPaint = Paint()
      ..color = kMuted.withValues(alpha: 0.20)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw grid rings
    for (final level in _ringLevels) {
      final path = Path();
      for (var i = 0; i < _directions.length; i++) {
        final point = center + _directions[i] * (radius * level);
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // Draw axis lines from center to each corner
    for (final dir in _directions) {
      final tip = center + dir * radius;
      canvas.drawLine(center, tip, gridPaint);
    }

    // Draw filled data area
    final values = [gridEfficiency, synthesisSkill, comboSkill, pressureResilience];

    final dataPath = Path();
    for (var i = 0; i < _directions.length; i++) {
      final v = values[i].clamp(0.0, 1.0);
      final point = center + _directions[i] * (radius * v);
      if (i == 0) {
        dataPath.moveTo(point.dx, point.dy);
      } else {
        dataPath.lineTo(point.dx, point.dy);
      }
    }
    dataPath.close();

    // Fill
    canvas.drawPath(
      dataPath,
      Paint()
        ..color = kCyan.withValues(alpha: 0.15)
        ..style = PaintingStyle.fill,
    );

    // Stroke
    canvas.drawPath(
      dataPath,
      Paint()
        ..color = kCyan.withValues(alpha: 0.60)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_RadarPainter old) =>
      old.gridEfficiency != gridEfficiency ||
      old.synthesisSkill != synthesisSkill ||
      old.comboSkill != comboSkill ||
      old.pressureResilience != pressureResilience;
}
