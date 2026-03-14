import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/exceptions.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/i_file_sheet_local_datasource.dart';
import 'package:trying_flutter/features/media_sorter/data/services/manage_waiting_tasks.dart';
import 'package:trying_flutter/features/media_sorter/data/services/spreadsheet_clipboard_service.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/selection_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/workbook_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_data_repository.dart';

class SheetDataRepositoryImpl implements SheetDataRepository {
  final LoadedSheetsCache loadedSheetsCache;
  final SelectionCache selectionCache;
  final WorkbookCache workbookCache;

  final StreamController<Failure> _errorController =
      StreamController<Failure>.broadcast();

  Stream<Failure> get failureStream => _errorController.stream;

  late final SpreadsheetClipboardService _clipboardService =
      SpreadsheetClipboardService();

  final IFileSheetLocalDataSource dataSource;

  final Map<String, ManageWaitingTasks<void>> _saveSheetDataExecutor = {};

  SheetDataRepositoryImpl(
    this.loadedSheetsCache,
    this.selectionCache,
    this.workbookCache,
    this.dataSource,
  );
  SelectionData get selection =>
      selectionCache.getSelectionData(workbookCache.currentSheetId);

  @override
  bool containsSheetId(String sheetId) {
    return loadedSheetsCache.containsSheetId(sheetId);
  }

  @override
  int rowCount(String sheetId) {
    return loadedSheetsCache.rowCount(sheetId);
  }

  @override
  int colCount(String sheetId) {
    return loadedSheetsCache.colCount(sheetId);
  }

  @override
  SheetData getSheet(String sheetId) {
    return loadedSheetsCache.getSheet(sheetId);
  }

  @override
  Future<void> copySelectionToClipboard() async {
    int startRow = selection.primarySelectedCell.x;
    int endRow = selection.primarySelectedCell.x;
    int startCol = selection.primarySelectedCell.y;
    int endCol = selection.primarySelectedCell.y;
    for (Point<int> cell in selection.selectedCells) {
      if (cell.x < startRow) startRow = cell.x;
      if (cell.y < startCol) startCol = cell.y;
      if (cell.x > endRow) endRow = cell.x;
      if (cell.y > endCol) endCol = cell.y;
    }
    List<List<bool>> selectedCellsTable = List.generate(
      endRow - startRow + 1,
      (_) => List.generate(endCol - startCol + 1, (_) => false),
    );
    for (Point<int> cell in selection.selectedCells) {
      selectedCellsTable[cell.x - startRow][cell.y - startCol] = true;
    }
    if (!selectedCellsTable.every((row) => row.every((cell) => !cell))) {
      await _clipboardService.copy(
        loadedSheetsCache.getCellContent(
          workbookCache.currentSheetId,
          selectionCache
              .getSelectionData(workbookCache.currentSheetId)
              .primarySelectedCell
              .x,
          selectionCache
              .getSelectionData(workbookCache.currentSheetId)
              .primarySelectedCell
              .y,
        ),
      );
      return;
    }

    StringBuffer buffer = StringBuffer();

    for (int r = startRow; r <= endRow; r++) {
      List<String> rowData = [];
      for (int c = startCol; c <= endCol; c++) {
        rowData.add(
          loadedSheetsCache.getCellContent(workbookCache.currentSheetId, r, c),
        );
      }
      buffer.write(rowData.join('\t')); // Tab separated for Excel compat
      if (r < endRow) buffer.write('\n');
    }

    final text = buffer.toString();
    await _clipboardService.copy(text);
  }

  @override
  Future<Either<Failure, List<CellUpdate>>> pasteSelection() async {
    final text = await _clipboardService.getText();
    if (text == null) return Left(ClipboardEmptyFailure());
    // if contains "
    if (text.contains('"')) {
      debugPrint('Paste data contains unsupported characters.');
      return Left(ClipboardUnsupportedCharactersFailure());
    }

    final List<CellUpdate> updates = [];
    final rows = text.split('\n');
    int startRow = selectionCache
        .getSelectionData(workbookCache.currentSheetId)
        .primarySelectedCell
        .x;
    int startCol = selectionCache
        .getSelectionData(workbookCache.currentSheetId)
        .primarySelectedCell
        .y;
    for (int r = 0; r < rows.length; r++) {
      final columns = rows[r].split('\t');
      for (int c = 0; c < columns.length; c++) {
        String val = columns[c].replaceAll('\r', '');
        updates.add(
          CellUpdate(
            startRow + r,
            startCol + c,
            val,
            loadedSheetsCache.getCellContent(
              workbookCache.currentSheetId,
              startRow + r,
              startCol + c,
            ),
          ),
        );
      }
    }
    update(updates, workbookCache.currentSheetId);
    return Right(updates);
  }

  void scheduleSheetSave(String sheetId) {
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
  String getCellContent(Point<int> cell, String sheetId) {
    return loadedSheetsCache.getCellContent(sheetId, cell.x, cell.y);
  }

  @override
  List<CellUpdate> setCellContent(Point<int> cell, String newVal) {
    CellUpdate cellUpdate = CellUpdate(
      cell.x,
      cell.y,
      newVal,
      loadedSheetsCache.getCellContent(
        workbookCache.currentSheetId,
        cell.x,
        cell.y,
      ),
    );
    update([cellUpdate], workbookCache.currentSheetId);
    return [cellUpdate];
  }

  @override
  Future<Either<Failure, void>> loadSheet(String sheetId) async {
    if (!loadedSheetsCache.containsSheetId(sheetId)) {
      try {
        SheetData sheet = await dataSource.getSheet(sheetId);
        loadedSheetsCache.setSheet(sheetId, sheet);
      } on CacheException catch (e) {
        loadedSheetsCache.setSheet(sheetId, SheetData.empty());
        return Left(CacheFailure(e));
      }
    }
    return Right(null);
  }

  @override
  Future<void> addNewSheet(String sheetId) async {
    loadedSheetsCache.setSheet(sheetId, SheetData.empty());
    scheduleSheetSave(sheetId);
  }

  @override
  List<CellUpdate> delete(List<Point<int>> cells) {
    List<CellUpdate> updates = [];
    for (Point<int> cell in cells) {
      updates.add(
        CellUpdate(
          cell.x,
          cell.y,
          '',
          loadedSheetsCache.getCellContent(
            workbookCache.currentSheetId,
            cell.x,
            cell.y,
          ),
        ),
      );
    }
    update(updates, workbookCache.currentSheetId);
    return updates;
  }

  @override
  void update(List<UpdateUnit> updates, String sheetId) {
    loadedSheetsCache.update(updates, sheetId);
    scheduleSheetSave(workbookCache.currentSheetId);
  }
}
