import 'package:meta/meta.dart';
import 'package:trying_flutter/features/media_sorter/data/models/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/data/models/update_data.dart';


abstract class SelectionRepository {
  int get primarySelectedCellX;
  int get primarySelectedCellY;
  SelectionState setPrimarySelection(int row, int col, bool keepSelection);
  SelectionState getSelectionState(int sheetId);
  @useResult
  SelectionState selectAll();
  @useResult
  SheetDataUpdate setSelectionData(int sheetId, SelectionData selectionData);
}
