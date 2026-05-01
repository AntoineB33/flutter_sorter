import 'package:trying_flutter/features/media_sorter/domain/models/change_set.dart';

abstract class SelectionRepository {
  int get primarySelectedCellX;
  int get primarySelectedCellY;
  SelectionState setPrimarySelection(int row, int col, bool keepSelection);
  SelectionState getSelectionState(int sheetId);
  
  SelectionState selectAll();
  
  List<SyncRequest> setSelectionData(int sheetId, SelectionData selectionData);
}
