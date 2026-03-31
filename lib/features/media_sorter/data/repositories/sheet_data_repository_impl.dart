import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/exceptions.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/local_data_source.dart';
import 'package:trying_flutter/features/media_sorter/data/services/add_update.dart';
import 'package:trying_flutter/features/media_sorter/data/services/manage_waiting_tasks.dart';
import 'package:trying_flutter/features/media_sorter/data/services/spreadsheet_clipboard_service.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/selection_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/sorting_progress_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/workbook_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/core_sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/layout_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_progress_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_data_repository.dart';

class SheetDataRepositoryImpl implements SheetDataRepository {
  final ILocalDataSource dataSource;

  final LoadedSheetsCache loadedSheetsCache;
  final SelectionCache selectionCache;
  final SortProgressCache sortProgressCache;
  final WorkbookCache workbookCache;

  final StreamController<Failure> _errorController =
      StreamController<Failure>.broadcast();

  @override
  Stream<Failure> get failureStream => _errorController.stream;

  int get currentSheetId => workbookCache.currentSheetId;

  late final SpreadsheetClipboardService _clipboardService =
      SpreadsheetClipboardService();

  final Map<int, ManageWaitingTasks<void>> _saveSheetDataExecutor = {};

  SheetDataRepositoryImpl(
    this.dataSource,
    this.loadedSheetsCache,
    this.selectionCache,
    this.sortProgressCache,
    this.workbookCache,
  );
  SelectionData get selection =>
      selectionCache.getSelectionData(currentSheetId);

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
    int startRow = selection.primarySelectedCellX;
    int endRow = selection.primarySelectedCellX;
    int startCol = selection.primarySelectedCellY;
    int endCol = selection.primarySelectedCellY;
    for (CellPosition cell in selection.selectedCells) {
      if (cell.x < startRow) startRow = cell.x;
      if (cell.y < startCol) startCol = cell.y;
      if (cell.x > endRow) endRow = cell.x;
      if (cell.y > endCol) endCol = cell.y;
    }
    List<List<bool>> selectedCellsTable = List.generate(
      endRow - startRow + 1,
      (_) => List.generate(endCol - startCol + 1, (_) => false),
    );
    for (CellPosition cell in selection.selectedCells) {
      selectedCellsTable[cell.x - startRow][cell.y - startCol] = true;
    }
    if (!selectedCellsTable.every((row) => row.every((cell) => !cell))) {
      await _clipboardService.copy(
        loadedSheetsCache.getCellContent(
          currentSheetId,
          selectionCache.getSelectionData(currentSheetId).primarySelectedCellX,
          selectionCache.getSelectionData(currentSheetId).primarySelectedCellY,
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
  Future<Either<Failure, Map<String, UpdateUnit>>> pasteSelection() async {
    final text = await _clipboardService.getText();
    if (text == null) return Left(ClipboardEmptyFailure());
    // if contains "
    if (text.contains('"')) {
      return Left(ClipboardUnsupportedCharactersFailure());
    }

    final Map<String, UpdateUnit> updates = {};
    final rows = text.split('\n');
    int startRow = selectionCache
        .getSelectionData(currentSheetId)
        .primarySelectedCellX;
    int startCol = selectionCache
        .getSelectionData(currentSheetId)
        .primarySelectedCellY;
    for (int r = 0; r < rows.length; r++) {
      final columns = rows[r].split('\t');
      for (int c = 0; c < columns.length; c++) {
        String val = columns[c].replaceAll('\r', '');
        final cellUpdate = CellUpdate(startRow + r, startCol + c, val);
        updates[cellUpdate.getKey()] = cellUpdate;
      }
    }
    return Right(updates);
  }

  void scheduleSheetSave(int sheetId) {
    if (!_saveSheetDataExecutor.containsKey(sheetId)) {
      _saveSheetDataExecutor[sheetId] = ManageWaitingTasks<void>(
        Duration(seconds: 2),
        _errorController,
      );
    }
    _saveSheetDataExecutor[sheetId]!.execute(() async {
      await dataSource.saveSheet(sheetId, loadedSheetsCache.getSheet(sheetId));
    });
  }

  void dispose() {
    for (var executor in _saveSheetDataExecutor.values) {
      executor.dispose();
    }
    _errorController.close();
  }

  @override
  String getCellContent(CellPosition cell, int sheetId) {
    return loadedSheetsCache.getCellContent(sheetId, cell.x, cell.y);
  }

  @override
  ColumnType getColumnType(int colId, int sheetId) {
    return loadedSheetsCache.getColumnType(sheetId, colId);
  }

  @override
  String getSheetTitle(int sheetId) {
    return loadedSheetsCache.getSheetName(sheetId);
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
        );
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
          rowsManuallyAdjustedHeight: rowsManuallyAdjustedHeightTable
              .map((pos) => pos.manuallyAdjusted)
              .toList(),
          colsManuallyAdjustedWidth: colManuallyAdjustedWidthTable
              .map((pos) => pos.manuallyAdjusted)
              .toList(),
          colHeaderHeight: sheetData.colHeaderHeight,
          rowHeaderWidth: sheetData.rowHeaderWidth,
          scrollOffsetX: sheetData.scrollOffsetX,
          scrollOffsetY: sheetData.scrollOffsetY,
        );
        loadedSheetsCache.setSheet(sheetId, sheetDataTable);
        final selectionData = SelectionData(
          primarySelectedCellX: sheetData.primarySelectedCellX ?? 0,
          primarySelectedCellY: sheetData.primarySelectedCellY ?? 0,
          selectedCells: sheetData.selectedCells ?? Set<CellPosition>(),
        );
        selectionCache.setSelectionData(sheetId, selectionData);
        final sortProgression = SortProgressData(
          bestDistFound: sheetData.bestDistFound ?? [],
          bestSortFound: sheetData.bestSortFound ?? [],
          possibleIntsById: sheetData.possibleInts ?? [],
          cursors: sheetData.cursors ?? [],
          validAreasById: sheetData.validAreas ?? [],
          sortIndex: sheetData.sortIndex ?? 0,
        );
        sortProgressCache.update(sheetId, sortProgression);
        return const Right(unit);
      } on CacheException catch (e) {
        // The UI will receive this clean Failure object
        return Left(DatabaseFailure(e.message));
      }
    }
    return Right(unit);
  }

  @override
  Future<void> addNewSheet(int sheetId) async {
    loadedSheetsCache.setSheet(sheetId, CoreSheetContent.empty());
    scheduleSheetSave(sheetId);
  }

  @override
  Map<String, UpdateUnit> delete() {
    Map<String, UpdateUnit> updates = {};
    for (CellPosition cellPos
        in selectionCache.getSelectionData(currentSheetId).selectedCells) {
      final cellUpdate = CellUpdate(
        currentSheetId,
        cellPos.rowId,
        cellPos.colId,
        '',
      );
      AddUpdate.addUpdate(updates, cellUpdate);
    }
    return updates;
  }

  @override
  void update(Map<String, UpdateUnit> updates, int sheetId) {
    loadedSheetsCache.update(updates, sheetId);
    scheduleSheetSave(sheetId);
  }
}
