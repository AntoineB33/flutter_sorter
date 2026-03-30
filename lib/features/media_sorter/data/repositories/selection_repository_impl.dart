import 'dart:async';
import 'dart:math';

import 'package:fpdart/fpdart.dart';
import 'package:meta/meta.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/local_data_source.dart';
import 'package:trying_flutter/features/media_sorter/data/services/manage_waiting_tasks.dart';
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
  SelectionData get selection => _selectionCache.getSelectionData(currentSheetId);
  @override
  int get primarySelectedCellX => selection.primarySelectedCellX;
  @override
  int get primarySelectedCellY => selection.primarySelectedCellY;

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
  bool containsSheetId(int sheetId) {
    return _selectionCache.containsSheetId(sheetId);
  }

  @override
  double getScrollOffsetX(int sheetId) {
    return _selectionCache.getScrollOffsetX(sheetId);
  }

  @override
  double getScrollOffsetY(int sheetId) {
    return _selectionCache.getScrollOffsetY(sheetId);
  }

  @override
  List<String> getSheetIds() {
    return _selectionCache.getSheetIds();
  }

  @override
  void setPrimarySelection(int row, int col, bool keepSelection) {
    if (!keepSelection) {
      selection.selectedCells.clear();
    }
    selection.primarySelectedCell = Point(row, col);
    saveLastSelection();
  }
}
