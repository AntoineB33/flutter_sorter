import 'dart:async';

import 'package:drift/drift.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/exceptions.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/app_database.dart';
import 'package:trying_flutter/features/media_sorter/data/models/change_set.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/local_data_source.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_data_table.dart';
import 'package:trying_flutter/features/media_sorter/data/services/spreadsheet_clipboard_service.dart';
import 'package:trying_flutter/features/media_sorter/data/store/analysis_result_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/history_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/layout_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/selection_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/sorting_progress_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/workbook_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/change_set.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/core_sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/history_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/layout_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/sort_progress_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_data_repository.dart';

class SheetDataRepositoryImpl implements SheetDataRepository {
  final ILocalDataSource dataSource;

  final LoadedSheetsCache loadedSheetsCache;
  final SelectionCache selectionCache;
  final SortProgressCache sortProgressCache;
  final AnalysisResultCache analysisResultCache;
  final WorkbookCache workbookCache;
  final LayoutCache layoutCache;
  final HistoryCache historyCache;

  int get currentSheetId => workbookCache.currentSheetId;

  late final SpreadsheetClipboardService _clipboardService =
      SpreadsheetClipboardService();

  SheetDataRepositoryImpl(
    this.dataSource,
    this.loadedSheetsCache,
    this.selectionCache,
    this.sortProgressCache,
    this.analysisResultCache,
    this.workbookCache,
    this.layoutCache,
    this.historyCache,
  );
  SelectionData get selection =>
      selectionCache.getSelectionData(currentSheetId);
  SelectionState get selectionState =>
      selectionCache.getSelectionState(currentSheetId);

  @override
  bool containsSheetId(int sheetId) {
    return loadedSheetsCache.containsSheetId(sheetId);
  }

  @override
  int rowCount(int sheetId) {
    return loadedSheetsCache.rowCount(sheetId);
  }

  @override
  int colCount(int sheetId) {
    return loadedSheetsCache.colCount(sheetId);
  }

  @override
  CoreSheetContent getSheet(int sheetId) {
    return loadedSheetsCache.getSheet(sheetId);
  }

  @override
  Future<void> copySelectionToClipboard() async {
    int startRow = selectionCache.primarySelectedCellX(currentSheetId);
    int endRow = selectionCache.primarySelectedCellX(currentSheetId);
    int startCol = selectionCache.primarySelectedCellY(currentSheetId);
    int endCol = selectionCache.primarySelectedCellY(currentSheetId);
    for (CellPosition cell in selectionState.selectedCells) {
      if (cell.rowId < startRow) startRow = cell.rowId;
      if (cell.colId < startCol) startCol = cell.colId;
      if (cell.rowId > endRow) endRow = cell.rowId;
      if (cell.colId > endCol) endCol = cell.colId;
    }
    List<List<bool>> selectedCellsTable = List.generate(
      endRow - startRow + 1,
      (_) => List.generate(endCol - startCol + 1, (_) => false),
    );
    for (CellPosition cell in selectionState.selectedCells) {
      selectedCellsTable[cell.rowId - startRow][cell.colId - startCol] = true;
    }
    if (!selectedCellsTable.every((row) => row.every((cell) => !cell))) {
      await _clipboardService.copy(
        loadedSheetsCache.getCellContent(
          currentSheetId,
          selectionCache.primarySelectedCellX(currentSheetId),
          selectionCache.primarySelectedCellY(currentSheetId),
        ),
      );
      return;
    }

    StringBuffer buffer = StringBuffer();

    for (int r = startRow; r <= endRow; r++) {
      List<String> rowData = [];
      for (int c = startCol; c <= endCol; c++) {
        rowData.add(loadedSheetsCache.getCellContent(currentSheetId, r, c));
      }
      buffer.write(rowData.join('\t')); // Tab separated for Excel compat
      if (r < endRow) buffer.write('\n');
    }

    final text = buffer.toString();
    await _clipboardService.copy(text);
  }

  @override
  Future<Either<Failure, IMap<String, SyncRequest>>> pasteSelection() async {
    final text = await _clipboardService.getText();
    if (text == null) return Left(ClipboardEmptyFailure());
    // if contains "
    if (text.contains('"')) {
      return Left(ClipboardUnsupportedCharactersFailure());
    }

    final Map<String, SyncRequest> updates = {};
    final rows = text.split('\n');
    int startRow = selectionCache.primarySelectedCellX(currentSheetId);
    int startCol = selectionCache.primarySelectedCellY(currentSheetId);
    for (int r = 0; r < rows.length; r++) {
      final columns = rows[r].split('\t');
      for (int c = 0; c < columns.length; c++) {
        String val = columns[c].replaceAll('\r', '');
        final cellUpdate = CellUpdate(
          currentSheetId,
          startRow + r,
          startCol + c,
          val,
          loadedSheetsCache.getCellContent(
            currentSheetId,
            startRow + r,
            startCol + c,
          ),
        );
        updates[cellUpdate.getKey()] = cellUpdate;
      }
    }
    return Right(updates.lock);
  }

  @override
  String getCellContent(CellPosition cell, int sheetId) {
    return loadedSheetsCache.getCellContent(sheetId, cell.rowId, cell.colId);
  }

  @override
  changeList setColumnType(int colId, ColumnType newColumnType, int sheetId) {
    loadedSheetsCache.setColumnType(sheetId, colId, newColumnType);
  }

  @override
  Future<Either<Failure, Unit>> loadSheet(int sheetId) async {
    if (!loadedSheetsCache.containsSheetId(sheetId)) {
      try {
        final sheetData = await dataSource.getSheetDataEntity(sheetId);
        final cells = await dataSource.getSheetCellEntities(sheetId);
        final cellMap = {
          for (var cell in cells)
            CellPosition(cell.row, cell.col): cell.content,
        };
        final columnTypes = await dataSource.getSheetColumnTypeEntities(
          sheetId,
        );
        final columnTypeMap = {
          for (var colType in columnTypes)
            colType.columnIndex: colType.columnType,
        };
        final sheetDataTable = CoreSheetContent(
          id: sheetId,
          title: sheetData.title,
          lastOpened: sheetData.lastOpened,
          cells: cellMap,
          columnTypes: columnTypeMap,
          usedRows: sheetData.usedRows,
          usedCols: sheetData.usedCols,
        );
        loadedSheetsCache.setSheet(sheetId, sheetDataTable);
        final rowsBottomPos = await dataSource.getRowsBottomPosEntities(
          sheetId,
        );
        final colRightPos = await dataSource.getColRightPosEntities(sheetId);
        final rowsManuallyAdjustedHeightTable = await dataSource
            .getRowsManuallyAdjustedHeightEntities(sheetId);
        final colManuallyAdjustedWidthTable = await dataSource
            .getColsManuallyAdjustedWidthEntities(sheetId);
        final layoutDataTable = LayoutData(
          rowsBottomPos: rowsBottomPos.map((pos) => pos.bottomPos).toList(),
          colRightPos: colRightPos.map((pos) => pos.rightPos).toList(),
          rowsManuallyAdjusted: rowsManuallyAdjustedHeightTable
              .map((pos) => pos.manuallyAdjusted)
              .toList(),
          colsManuallyAdjusted: colManuallyAdjustedWidthTable
              .map((pos) => pos.manuallyAdjusted)
              .toList(),
          colHeaderHeight: sheetData.colHeaderHeight,
          rowHeaderWidth: sheetData.rowHeaderWidth,
          scrollOffsetX: sheetData.scrollOffsetX,
          scrollOffsetY: sheetData.scrollOffsetY,
        );
        layoutCache.setLayout(sheetId, layoutDataTable);
        selectionCache.setSelectionData(sheetId, sheetData.selectionHistory);
        final sortProgression = SortProgressData(
          bestDistFound: sheetData.bestDistFound,
          bestSortFound: sheetData.bestSortFound,
          possibleIntsById: sheetData.possibleInts,
          cursors: sheetData.cursors,
          validAreasById: sheetData.validAreas,
          sortIndex: sheetData.sortIndex,
        );
        sortProgressCache.update(sheetId, sortProgression);
        analysisResultCache.updateResults(sheetId, sheetData.analysisResult);
        final historyTable = await dataSource.getUpdateHistoriesEntities(
          sheetId,
        );
        historyCache.setUpdateHistories(
          sheetId,
          HistoryData(
            updateHistories: historyTable
                .map(
                  (e) => UpdateData(
                    e.chronoId,
                    sheetId,
                    e.updates,
                    true,
                    timestamp: e.timestamp,
                  ),
                )
                .toList(),
            historyIndex: sheetData.historyIndex,
          ),
        );
        return const Right(unit);
      } on CacheException catch (e) {
        // The UI will receive this clean Failure object
        return Left(DatabaseFailure(e.message));
      }
    }
    return Right(unit);
  }

  @override
  changeList addNewSheet(int sheetId, String title) {
    loadedSheetsCache.setSheet(sheetId, CoreSheetContent.empty(title));
    final changeList = changeList();
    changeList.addUpdate(
      SheetDataUpdate(
        sheetId,
        true,
        newName: title,
        lastOpened: loadedSheetsCache.getSheet(sheetId).lastOpened,
        usedRows: loadedSheetsCache.getSheet(sheetId).usedRows,
        usedCols: loadedSheetsCache.getSheet(sheetId).usedCols,
      ),
    );
    return changeList;
  }

  @override
  changeList delete() {
    final updates = changeList();
    for (CellPosition cellPos
        in selectionCache.getSelectionState(currentSheetId).selectedCells) {
      final cellUpdate = CellUpdate(
        currentSheetId,
        cellPos.rowId,
        cellPos.colId,
        '',
        loadedSheetsCache.getCellContent(
          currentSheetId,
          cellPos.rowId,
          cellPos.colId,
        ),
      );
      updates.addUpdate(cellUpdate);
    }
    return updates;
  }

  @override
  changeList update(IMap<String, SyncRequest> updates, int sheetId) {
    return loadedSheetsCache.update(updates, sheetId);
  }

  @override
  changeList setCellContent(String newValue, int sheetId) {
    final int rowId = selectionCache.primarySelectedCellX(sheetId);
    final int colId = selectionCache.primarySelectedCellY(sheetId);
    final syncRequest = SyncRequest(
      SheetCellWrapper(
        SheetCellsTableCompanion(
          sheetId: Value(sheetId),
          row: Value(rowId),
          col: Value(colId),
          content: Value(newValue),
        ),
      ),
      DataBaseOperationType.update,
    );
    return changeListImpl()..addUpdate(syncRequest);
  }
}
