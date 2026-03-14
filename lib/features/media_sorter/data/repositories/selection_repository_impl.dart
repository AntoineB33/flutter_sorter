import 'dart:async';
import 'dart:math';

import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/file_sheet_local_datasource.dart';
import 'package:trying_flutter/features/media_sorter/data/services/manage_waiting_tasks.dart';
import 'package:trying_flutter/features/media_sorter/data/services/utils_service.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/selection_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/workbook_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/selection_repository.dart';

class SelectionRepositoryImpl implements SelectionRepository {
  late ManageWaitingTasks<void> _saveSelectionStatusExecutor;
  final FileSheetLocalDataSource saveDataSource;
  final SelectionCache selectionCache;
  final LoadedSheetsCache loadedSheetsCache;
  final WorkbookCache workbookCache;
  final StreamController<Failure> _errorController =
      StreamController<Failure>.broadcast();

  @override
  Stream<Failure> get failureStream => _errorController.stream;
  String get currentSheetId => workbookCache.currentSheetId;
  @override
  Point<int> get primarySelectedCell =>
      selectionCache.getSelectionData(currentSheetId).primarySelectedCell;

  SelectionRepositoryImpl(
    this.saveDataSource,
    this.selectionCache,
    this.loadedSheetsCache,
    this.workbookCache,
  ) {
    _saveSelectionStatusExecutor = ManageWaitingTasks<void>(
      Duration(seconds: 2),
      _errorController,
    );
  }

  @override
  SelectionData getSelectionData(String sheetId) {
    return selectionCache.getSelectionData(sheetId);
  }

  @override
  void selectAll() {
    SelectionData selection = selectionCache.getSelectionData(currentSheetId);
    selection.selectedCells.clear();
    for (int r = 0; r < loadedSheetsCache.rowCount(currentSheetId); r++) {
      for (int c = 0; c < loadedSheetsCache.colCount(currentSheetId); c++) {
        selection.selectedCells.add(Point(r, c));
      }
    }
  }

  @override
  Future<Either<Failure, void>> saveLastSelection() {
    return UrilsService.handleDataSourceCall(
      () => saveDataSource.saveLastSelection(selectionCache.getSelectionData(currentSheetId)),
    );
  }

  @override
  Future<Either<Failure, void>> saveAllLastSelected() {
    return UrilsService.handleDataSourceCall(
      () => saveDataSource.saveAllLastSelected(selectionCache.lastSelections),
    );
  }

  @override
  Future<Either<Failure, void>> loadLastSelection() async {
    final result = await UrilsService.handleDataSourceCall(
      () => saveDataSource.getLastSelection(),
    );
    return result.fold((failure) => Left(failure), (lastSelection) {
      selectionCache.setSelectionData(currentSheetId, lastSelection);
      return Right(null);
    });
  }

  @override
  Future<Either<Failure, void>> loadLastSelections(
    bool lastSelectionLoaded,
  ) async {
    final result = await UrilsService.handleDataSourceCall(
      () => saveDataSource.getAllLastSelected(),
    );
    return result.fold((failure) => Left(failure), (ids) {
      selectionCache.setLastSelections(
        ids,
        currentSheetId,
        lastSelectionLoaded,
      );
      bool selectionCacheChanged = false;
      bool workbookCacheChanged = false;
      for (var sheetId in workbookCache.getRecentSheetIds()) {
        if (!selectionCache.containsSheetId(sheetId)) {
          selectionCache.setSelectionData(sheetId, SelectionData.empty());
          selectionCacheChanged = true;
        }
      }
      for (var sheetId in selectionCache.getSheetIds()) {
        if (!UrilsService.isValidSheetName(sheetId)) {
          selectionCache.removeSelectionData(sheetId);
          selectionCacheChanged = true;
        } else if (!loadedSheetsCache.containsSheetId(sheetId)) {
          workbookCache.addSheetId(sheetId, 1);
          workbookCacheChanged = true;
        }
      }
      return selectionCacheChanged || workbookCacheChanged
          ? Left(
              CacheRepairedFailure(
                workbookCacheChanged: workbookCacheChanged,
                selectionCacheChanged: selectionCacheChanged,
              ),
            )
          : Right(null);
    });
  }

  @override
  void setPrimarySelection(int row, int col, bool keepSelection) {
    SelectionData selection = selectionCache.getSelectionData(currentSheetId);
    if (!keepSelection) {
      selection.selectedCells.clear();
    }
    selection.primarySelectedCell = Point(row, col);
    saveLastSelection();
  }

  @override
  void clearLastSelection(String sheetId) {
    selectionCache.setSelectionData(sheetId, SelectionData.empty());
  }
}
