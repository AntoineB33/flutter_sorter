import 'package:trying_flutter/features/media_sorter/data/models/sheet_data_table.dart';

abstract class SelectionRepository {
  int get primarySelectedCellX;
  int get primarySelectedCellY;
  List<SyncRequestWithHist> setPrimarySelection(int row, int col, bool keepSelection);
  void getSelectionState(int sheetId);
  
  void selectAll();
  
  void setSelectionData(int sheetId, SelectionData selectionData);
}
