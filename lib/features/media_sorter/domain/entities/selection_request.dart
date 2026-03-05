import 'dart:math';

import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';

class SelectionRequest {
  List<Point<int>>? selectedCells;
  Point<int>? primarySelectedCell;
  double? scrollOffsetX;
  double? scrollOffsetY;
  bool? editingMode;
  bool keepPrevSelection;

  SelectionRequest({
    this.selectedCells,
    this.primarySelectedCell,
    this.scrollOffsetX,
    this.scrollOffsetY,
    this.editingMode,
    this.keepPrevSelection = false,
  });
}