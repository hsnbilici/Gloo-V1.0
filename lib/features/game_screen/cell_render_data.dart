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
    this.isSynthesisResult = false,
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
  final bool isSynthesisResult;

  CellRenderData copyWith({
    GelColor? color,
    CellType? type,
    int? iceLayer,
    GelColor? lockedColor,
    bool? isPreview,
    bool? previewValid,
    GelColor? previewSlotColor,
    bool? isRecentlyPlaced,
    int? waveDistance,
    bool? isInteractive,
    bool? isNearlyFullRow,
    bool? isCompletionPreview,
    bool? isSynthesisResult,
  }) {
    return CellRenderData(
      color: color ?? this.color,
      type: type ?? this.type,
      iceLayer: iceLayer ?? this.iceLayer,
      lockedColor: lockedColor ?? this.lockedColor,
      isPreview: isPreview ?? this.isPreview,
      previewValid: previewValid ?? this.previewValid,
      previewSlotColor: previewSlotColor ?? this.previewSlotColor,
      isRecentlyPlaced: isRecentlyPlaced ?? this.isRecentlyPlaced,
      waveDistance: waveDistance ?? this.waveDistance,
      isInteractive: isInteractive ?? this.isInteractive,
      isNearlyFullRow: isNearlyFullRow ?? this.isNearlyFullRow,
      isCompletionPreview: isCompletionPreview ?? this.isCompletionPreview,
      isSynthesisResult: isSynthesisResult ?? this.isSynthesisResult,
    );
  }

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
          isCompletionPreview == other.isCompletionPreview &&
          isSynthesisResult == other.isSynthesisResult;

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
        isSynthesisResult,
      );
}
