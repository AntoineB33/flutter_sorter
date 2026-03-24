import 'dart:math';

class SelectionData {
  final List<Point<int>> selectedCells;
  int primarySelectedCellX;
  int primarySelectedCellY;

  SelectionData({
    required this.selectedCells,
    required this.primarySelectedCellX,
    required this.primarySelectedCellY,
  });

  SelectionData.empty()
      : selectedCells = [],
        primarySelectedCellX = 0,
        primarySelectedCellY = 0;
}