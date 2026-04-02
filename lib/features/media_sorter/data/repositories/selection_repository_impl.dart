
import 'package:meta/meta.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/selection_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/workbook_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/selection_repository.dart';

class SelectionRepositoryImpl implements SelectionRepository {
  final SelectionCache _selectionCache;
  final LoadedSheetsCache _loadedSheetsCache;
  final WorkbookCache _workbookCache;

  int get currentSheetId => _workbookCache.currentSheetId;
  @override
  int get primarySelectedCellX => _selectionCache.primarySelectedCellX(currentSheetId);
  @override
  int get primarySelectedCellY => _selectionCache.primarySelectedCellY(currentSheetId);
  SelectionData get selection => _selectionCache.getSelectionData(currentSheetId);

  SelectionRepositoryImpl(
    this._selectionCache,
    this._loadedSheetsCache,
    this._workbookCache,
  );

  @override
  @useResult
  UpdateUnit selectAll() {
    selection.selectedCells.clear();
    for (int r = 0; r < _loadedSheetsCache.rowCount(currentSheetId); r++) {
      for (int c = 0; c < _loadedSheetsCache.colCount(currentSheetId); c++) {
        selection.selectedCells.add(CellPosition(r, c));
      }
    }
    return SheetDataUpdate(
      currentSheetId,
      true,
      selectedCells: selection.selectedCells,
    );
  }

  @override
  SelectionData getSelectionData(int sheetId) {
    return _selectionCache.getSelectionData(sheetId);
  }

  @override
  void setPrimarySelection(int row, int col, bool keepSelection) {
    if (!keepSelection) {
      selection.selectedCells.clear();
    }
    selection.selectedCells.add(CellPosition(row, col));
  }

  @override
  void setSelectionData(int sheetId, SelectionData selectionData) {
    _selectionCache.setSelectionData(sheetId, selectionData);
  }

}
