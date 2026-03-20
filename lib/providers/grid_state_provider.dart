import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/game_screen/cell_render_data.dart';

class GridStateNotifier extends Notifier<Map<(int, int), CellRenderData>> {
  @override
  Map<(int, int), CellRenderData> build() => const {};

  void updateCells(Map<(int, int), CellRenderData> newCells) {
    state = newCells;
  }
}

final gridStateProvider =
    NotifierProvider<GridStateNotifier, Map<(int, int), CellRenderData>>(
  GridStateNotifier.new,
);
