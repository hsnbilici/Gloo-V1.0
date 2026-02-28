import 'package:flutter/material.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../../game/shapes/gel_shape.dart';

class ShapePreview extends StatelessWidget {
  const ShapePreview({super.key, required this.shape, required this.color});

  final GelShape shape;
  final GelColor color;

  static const double _cellSize = 13.0;
  static const double _gap = 2.0;

  @override
  Widget build(BuildContext context) {
    final displayColor = color.displayColor;
    return SizedBox(
      width: shape.colCount * (_cellSize + _gap) - _gap,
      height: shape.rowCount * (_cellSize + _gap) - _gap,
      child: Stack(
        children: shape.cells.map((cell) {
          return Positioned(
            left: cell.$2 * (_cellSize + _gap),
            top: cell.$1 * (_cellSize + _gap),
            child: Container(
              width: _cellSize,
              height: _cellSize,
              decoration: BoxDecoration(
                color: displayColor,
                borderRadius: BorderRadius.circular(UIConstants.radiusXs),
                boxShadow: [
                  BoxShadow(
                    color: displayColor.withValues(alpha: 0.6),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
