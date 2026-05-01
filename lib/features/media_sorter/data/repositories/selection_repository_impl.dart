import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/selection_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/workbook_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/cell_position.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/change_set.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/selection_repository.dart';

class SelectionRepositoryImpl implements SelectionRepository {
  final SelectionCache _selectionCache;
  final LoadedSheetsCache _loadedSheetsCache;
  final WorkbookCache _workbookCache;

  int get currentSheetId => _workbookCache.currentSheetId;
  @override
  int get primarySelectedCellX =>
      _selectionCache.primarySelectedCellX(currentSheetId);
  @override
  int get primarySelectedCellY =>
      _selectionCache.primarySelectedCellY(currentSheetId);
  List<SelectionState> get selection =>
      _selectionCache.getSelectionData(currentSheetId).selectionStates;
  SelectionState get selectionState =>
      _selectionCache.getSelectionState(currentSheetId);

  SelectionRepositoryImpl(
    this._selectionCache,
    this._loadedSheetsCache,
    this._workbookCache,
  );

  @override
  SelectionState selectAll() {
    SelectionState selection = SelectionState.empty();
    selection.selectedCells.clear();
    for (int r = 0; r < _loadedSheetsCache.rowCount(currentSheetId); r++) {
      for (int c = 0; c < _loadedSheetsCache.colCount(currentSheetId); c++) {
        selection.selectedCells.add(CellPosition(r, c));
      }
    }
    return selection;
  }

  @override
  SelectionState getSelectionState(int sheetId) {
    return _selectionCache.getSelectionState(sheetId);
  }

  @override
  List<SyncRequest> setPrimarySelection(int row, int col, bool keepSelection) {
    return SelectionState(primarySelection: CellPosition(row, col), selectedCells: keepSelection ? selectionState.selectedCells : {CellPosition(row, col)});
  }

  @override
  SheetDataUpdate setSelectionData(int sheetId, SelectionData selectionData) {
    _selectionCache.setSelectionData(sheetId, selectionData);
    return SheetDataUpdate(sheetId, true, selectionHistory: selectionData);
  }
}
