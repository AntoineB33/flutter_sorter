import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';

class SelectionData {
  final List<CellPosition> selectedCells;
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