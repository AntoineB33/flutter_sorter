import 'dart:async';
import 'dart:math';

import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/i_file_sheet_local_datasource.dart';
import 'package:trying_flutter/features/media_sorter/data/services/manage_waiting_tasks.dart';
import 'package:trying_flutter/features/media_sorter/core/utility/utils_service.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/selection_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/workbook_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/selection_repository.dart';

class SelectionRepositoryImpl implements SelectionRepository {
  late ManageWaitingTasks<void> _saveLastSelectionExecutor;
  late ManageWaitingTasks<void> _saveAllLastSelectedExecutor;
  final IFileSheetLocalDataSource _saveDataSource;
  final SelectionCache _selectionCache;
  final LoadedSheetsCache _loadedSheetsCache;
  final WorkbookCache _workbookCache;
  final StreamController<Failure> _errorController =
      StreamController<Failure>.broadcast();

  @override
  Stream<Failure> get failureStream => _errorController.stream;
  String? get currentSheetId => _workbookCache.currentSheetId;
  SelectionData? get selection => currentSheetId != null ?
      _selectionCache.getSelectionData(currentSheetId!) : null;
  @override
  Point<int>? get primarySelectedCell =>
      selection?.primarySelectedCell;

  SelectionRepositoryImpl(
    this._saveDataSource,
    this._selectionCache,
    this._loadedSheetsCache,
    this._workbookCache,
  ) {
    _saveLastSelectionExecutor = ManageWaitingTasks<void>(
      Duration(seconds: 2),
      _errorController,
    );
    _saveAllLastSelectedExecutor = ManageWaitingTasks<void>(
      Duration(seconds: 2),
      _errorController,
    );
  }

  @override
  void setSelectionData(String sheetId, SelectionData selectionData) {
    _selectionCache.setSelectionData(sheetId, selectionData);
    saveAllLastSelected();
  }
  
  @override
  void removeSelectionData(String sheetId) {
    _selectionCache.removeSelectionData(sheetId);
    saveAllLastSelected();
  }

  @override
  void selectAll() {
    if (selection == null) return;
    selection!.selectedCells.clear();
    for (int r = 0; r < _loadedSheetsCache.rowCount(currentSheetId!); r++) {
      for (int c = 0; c < _loadedSheetsCache.colCount(currentSheetId!); c++) {
        selection!.selectedCells.add(Point(r, c));
      }
    }
    saveLastSelection();
  }

  @override
  Future<Either<Failure, void>> loadLastSelections(
    bool lastSelectionLoaded,
  ) async {
    final result = await UtilsService.handleDataSourceCall(
      () => _saveDataSource.getAllLastSelected(),
    );
    return result.fold((failure) => Left(failure), (ids) {
      _selectionCache.setLastSelections(
        ids,
        currentSheetId,
      );
      saveAllLastSelected();
      return Right(null);
    });
  }

  @override
  SelectionData getSelectionData(String sheetId) {
    return _selectionCache.getSelectionData(sheetId);
  }

  @override
  void saveLastSelection() {
    _saveLastSelectionExecutor.execute(() async {
      await _saveDataSource.saveLastSelection(
        selection,
      );
    });
  }

  void dispose() {
    _saveLastSelectionExecutor.dispose();
    _saveAllLastSelectedExecutor.dispose();
    _errorController.close();
  }

  @override
  void saveAllLastSelected() {
    _saveAllLastSelectedExecutor.execute(() async {
      await _saveDataSource.saveAllLastSelected(_selectionCache.lastSelections);
    });
  }

  @override
  Future<Either<Failure, void>> loadLastSelection() async {
    final result = await UtilsService.handleDataSourceCall(
      () => _saveDataSource.getLastSelection(),
    );
    return result.fold((failure) => Left(failure), (lastSelection) {
      setSelectionData(currentSheetId, lastSelection);
      return Right(null);
    });
  }

  @override
  bool containsSheetId(String sheetId) {
    return _selectionCache.containsSheetId(sheetId);
  }

  @override
  double getScrollOffsetX(String sheetId) {
    return _selectionCache.getScrollOffsetX(sheetId);
  }

  @override
  double getScrollOffsetY(String sheetId) {
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

  @override
  void clearLastSelection() {
    setSelectionData(currentSheetId, SelectionData.empty());
  }

  @override
  void clearSheetSelection(String sheetId) {
    setSelectionData(sheetId, SelectionData.empty());
  }
}
