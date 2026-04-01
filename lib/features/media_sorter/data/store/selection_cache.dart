import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';

class SelectionCache {
  final Map<int, SelectionData> _lastSelections = {};

  
  int primarySelectedCellX(int sheetId) {
    return getSelectionData(sheetId).primSelHistory[
      getSelectionData(sheetId).primSelHistoryId].rowId;
  }
  
  int primarySelectedCellY(int sheetId) {
    return getSelectionData(sheetId).primSelHistory[
      getSelectionData(sheetId).primSelHistoryId].colId;
  }

  Map<String, SelectionData> get lastSelections =>
      Map.unmodifiable(_lastSelections);

  bool containsSheetId(int sheetId) {
    return _lastSelections.containsKey(sheetId);
  }

  CellPosition getPrimSel(int sheetId) {
    return _lastSelections[sheetId]!.primSelHistory[
            _lastSelections[sheetId]!.primSelHistoryId];
  }

  List<int> getSheetIds() {
    return _lastSelections.keys.toList();
  }

  Set<CellPosition> getSelectedCells(int sheetId) {
    return _lastSelections[sheetId]?.selectedCells ?? <CellPosition>{};
  }

  SelectionData getSelectionData(int sheetId) {
    return _lastSelections[sheetId] ??= SelectionData.empty();
  }

  void setLastSelections(
    Map<int, SelectionData> lastSelections,
    int currentSheetId,
  ) {
    SelectionData? currentSheetSelection = _lastSelections[currentSheetId];
    _lastSelections
      ..clear()
      ..addAll(lastSelections);
    if (currentSheetSelection != null) {
      _lastSelections[currentSheetId] = currentSheetSelection;
    }
  }

  void setSelectionData(int sheetId, SelectionData selectionData) {
    _lastSelections[sheetId] = selectionData;
  }
}
