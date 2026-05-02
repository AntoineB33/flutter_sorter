import 'package:drift/drift.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/app_database.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_data_table.dart';
import 'package:trying_flutter/features/media_sorter/data/store/current_change_list.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/selection_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/workbook_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/cell_position.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/history_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/selection_repository.dart';

class SelectionRepositoryImpl implements SelectionRepository {
  final SelectionCache _selectionCache;
  final LoadedSheetsCache _loadedSheetsCache;
  final WorkbookCache _workbookCache;

  final CurrentChangeList currentChange;

  int get currentSheetId => _workbookCache.currentSheetId;
  @override
  int get primarySelectedCellX =>
      _selectionCache.primarySelectedCellX(currentSheetId);
  @override
  int get primarySelectedCellY =>
      _selectionCache.primarySelectedCellY(currentSheetId);
    @override
  Set<CellPosition> get selectedCells =>
      _selectionCache.getSelectionState(currentSheetId).selectedCells.value;
  List<HistoryUnit> get selection =>
      _selectionCache.getSelectionData(currentSheetId).updateHistories;
  SheetDataTablesCompanion get selectionState =>
      _selectionCache.getSelectionState(currentSheetId);

  SelectionRepositoryImpl(
    this._selectionCache,
    this._loadedSheetsCache,
    this._workbookCache,
    this.currentChange,
  );

  @override
  void selectAll() {
    SheetDataTablesCompanion companion = SheetDataTablesCompanion(
      selectedCells: Value({}),
    );
    for (int r = 0; r < _loadedSheetsCache.rowCount(currentSheetId); r++) {
      for (int c = 0; c < _loadedSheetsCache.colCount(currentSheetId); c++) {
        companion.selectedCells.value.add(CellPosition(r, c));
      }
    }
    currentChange.changeListWithHist.add(
      SyncRequestWithHist(
        SheetDataWrapper(companion),
        SheetDataWrapper(
          SheetDataTablesCompanion(
            sheetId: Value(currentSheetId),
            selectedCells: Value(selectionState.selectedCells.value.toSet()),
          ),
        ),
        DataBaseOperationType.update,
      ),
    );
  }

  @override
  SheetDataTablesCompanion getSelectionState(int sheetId) {
    return _selectionCache.getSelectionState(sheetId);
  }

  @override
  List<SyncRequest> setPrimarySelection(int row, int col, bool keepSelection) {
    return SelectionState(primarySelection: CellPosition(row, col), selectedCells: keepSelection ? selectionState.selectedCells : {CellPosition(row, col)});
  }

  @override
  void setSelectionData(int sheetId, HistoryData selectionData) {
    _selectionCache.setSelectionData(sheetId, selectionData);
    return SheetDataUpdate(sheetId, true, selectionHistory: selectionData);
  }
}
