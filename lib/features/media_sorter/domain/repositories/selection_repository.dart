import 'package:trying_flutter/features/media_sorter/data/models/sheet_data_table.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/cell_position.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/history_data.dart';

abstract class SelectionRepository {
  int get primarySelectedCellX;
  int get primarySelectedCellY;
    Set<CellPosition> get selectedCells;
  void setPrimarySelection(int row, int col, bool keepSelection);
  
  void selectAll();
}
