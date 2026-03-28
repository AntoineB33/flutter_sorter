import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';

abstract class SelectionRepository {
  int get primarySelectedCellX;
  int get primarySelectedCellY;
  bool containsSheetId(int sheetId);
  double getScrollOffsetX(int sheetId);
  double getScrollOffsetY(int sheetId);
  List<int> getSheetIds();
  void saveLastSelection();
  void saveAllLastSelected();
  void setPrimarySelection(int row, int col, bool keepSelection);
  void clearLastSelection();
  void clearSheetSelection(int sheetId);
  SelectionData getSelectionData(int sheetId);
  UpdateUnit selectAll();
  void setSelectionData(int sheetId, SelectionData selectionData);
  void removeSelectionData(int sheetId);
}
