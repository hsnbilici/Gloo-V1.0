import 'package:flutter/material.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/game_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../../game/shapes/gel_shape.dart';
import 'shape_preview.dart';

class ShapeHand extends StatelessWidget {
  const ShapeHand({
    super.key,
    required this.hand,
    required this.selectedSlot,
    required this.onSlotTap,
    this.onDragStarted,
    this.onDragEnd,
    this.nextShapeSilhouette,
  });

  final List<(GelShape, GelColor)?> hand;
  final int? selectedSlot;
  final void Function(int) onSlotTap;
  final void Function(int index)? onDragStarted;
  final void Function(int index, bool wasAccepted)? onDragEnd;

  /// Sıradaki elin ilk şekil silueti (renksiz ipucu).
  final GelShape? nextShapeSilhouette;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.025),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ...List.generate(GameConstants.shapesInHand, (i) {
          final slot = hand[i];
          final isSelected = selectedSlot == i;

          if (slot == null) {
            return Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(UIConstants.radiusMd),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.06),
                  width: 1,
                ),
              ),
            );
          }

          final (shape, color) = slot;
          final slotWidget = AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: isSelected
                  ? color.displayColor.withValues(alpha: 0.18)
                  : Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(UIConstants.radiusMd),
              border: Border.all(
                color: isSelected
                    ? color.displayColor.withValues(alpha: 0.85)
                    : Colors.white.withValues(alpha: 0.12),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.displayColor.withValues(alpha: 0.35),
                        blurRadius: 14,
                        spreadRadius: 2,
                      )
                    ]
                  : null,
            ),
            child: Center(
              child: ShapePreview(shape: shape, color: color),
            ),
          );

          return GestureDetector(
            onTap: () => onSlotTap(i),
            child: Draggable<int>(
              data: i,
              onDragStarted: () => onDragStarted?.call(i),
              onDragEnd: (details) => onDragEnd?.call(i, details.wasAccepted),
              feedback: Material(
                color: Colors.transparent,
                child: Opacity(
                  opacity: 0.75,
                  child: Transform.scale(
                    scale: 1.8,
                    child: ShapePreview(shape: shape, color: color),
                  ),
                ),
              ),
              childWhenDragging: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: color.displayColor.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(UIConstants.radiusMd),
                  border: Border.all(
                    color: color.displayColor.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
              ),
              child: slotWidget,
            ),
          );
          }),
          if (nextShapeSilhouette != null)
            _buildSilhouette(nextShapeSilhouette!),
        ],
      ),
    );
  }

  Widget _buildSilhouette(GelShape shape) {
    const cellSize = 7.0;
    const gap = 1.5;
    final w = shape.colCount * (cellSize + gap) - gap;
    final h = shape.rowCount * (cellSize + gap) - gap;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'NEXT',
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            color: kMuted.withValues(alpha: 0.4),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 3),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
              width: 1,
            ),
          ),
          child: Center(
            child: SizedBox(
              width: w,
              height: h,
              child: Stack(
                children: [
                  for (final cell in shape.cells)
                    Positioned(
                      left: cell.$2 * (cellSize + gap),
                      top: cell.$1 * (cellSize + gap),
                      child: Container(
                        width: cellSize,
                        height: cellSize,
                        decoration: BoxDecoration(
                          color: kMuted.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
