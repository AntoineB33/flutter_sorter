import 'package:trying_flutter/features/media_sorter/domain/models/cell_position.dart';

abstract class SelectionRepository {
  int get primarySelectedCellX;
  int get primarySelectedCellY;
    Set<CellPosition> get selectedCells;
  void setPrimarySelection(int row, int col, bool keepSelection);
  
  void selectAll();
}
