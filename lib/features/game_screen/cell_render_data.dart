import 'package:flutter/foundation.dart';

import '../../core/constants/color_constants.dart';
import '../../game/world/cell_type.dart';

@immutable
class CellRenderData {
  const CellRenderData({
    required this.color,
    required this.type,
    required this.iceLayer,
    this.lockedColor,
    this.isPreview = false,
    this.previewValid = false,
    this.previewSlotColor,
    this.isRecentlyPlaced = false,
    this.waveDistance = -1,
    this.isInteractive = false,
    this.isNearlyFullRow = false,
    this.isCompletionPreview = false,
  });

  final GelColor? color;
  final CellType type;
  final int iceLayer;
  final GelColor? lockedColor;
  final bool isPreview;
  final bool previewValid;
  final GelColor? previewSlotColor;
  final bool isRecentlyPlaced;
  final int waveDistance;
  final bool isInteractive;
  final bool isNearlyFullRow;
  final bool isCompletionPreview;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CellRenderData &&
          color == other.color &&
          type == other.type &&
          iceLayer == other.iceLayer &&
          lockedColor == other.lockedColor &&
          isPreview == other.isPreview &&
          previewValid == other.previewValid &&
          previewSlotColor == other.previewSlotColor &&
          isRecentlyPlaced == other.isRecentlyPlaced &&
          waveDistance == other.waveDistance &&
          isInteractive == other.isInteractive &&
          isNearlyFullRow == other.isNearlyFullRow &&
          isCompletionPreview == other.isCompletionPreview;

  @override
  int get hashCode => Object.hash(
        color,
        type,
        iceLayer,
        lockedColor,
        isPreview,
        previewValid,
        previewSlotColor,
        isRecentlyPlaced,
        waveDistance,
        isInteractive,
        isNearlyFullRow,
        isCompletionPreview,
      );
}
