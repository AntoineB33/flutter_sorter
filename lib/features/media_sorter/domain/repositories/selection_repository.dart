import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';

abstract class SelectionRepository {
  int get primarySelectedCellX;
  int get primarySelectedCellY;
  void setPrimarySelection(int row, int col, bool keepSelection);
  SelectionData getSelectionData(int sheetId);
  UpdateUnit selectAll();
  void setSelectionData(int sheetId, SelectionData selectionData);
}
