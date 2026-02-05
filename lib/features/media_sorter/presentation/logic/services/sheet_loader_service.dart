import 'package:trying_flutter/features/media_sorter/data/models/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/get_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/manage_waiting_tasks.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/save_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/grid_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/selection_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sheet_data_controller.dart';
import 'package:trying_flutter/utils/logger.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/spreadsheet_stream_controller.dart';

class SheetLoaderService {
  // --- dependencies ---
  final GridController _gridController;
  final SelectionController _selectionController;
  final SheetDataController _dataController;
  final SpreadsheetStreamController _streamController;

  final SaveSheetDataUseCase _saveSheetDataUseCase;
  final GetSheetDataUseCase _getDataUseCase;

  void Function() notifyListeners;
  void Function({
    double? visibleHeight,
    double? visibleWidth,
    bool notify,
    bool save,
  })
  updateRowColCount;
  void Function({bool save, bool updateHistory}) saveAndCalculate;

  SheetLoaderService(
    this._gridController,
    this._selectionController,
    this._dataController,
    this._streamController,
    this._saveSheetDataUseCase,
    this._getDataUseCase,
    this.notifyListeners,
    this.updateRowColCount,
    this.saveAndCalculate,
  );

  Future<void> loadSheetByName(
    String name, {
    bool init = false,
    SelectionData? lastSelection,
  }) async {
    if (!init) {
      _dataController.lastSelectionBySheet[_dataController.sheetName] =
          _selectionController.selection;
      _saveSheetDataUseCase.saveAllLastSelected(
        _dataController.lastSelectionBySheet,
      );
      _saveSheetDataUseCase.saveLastOpenedSheetName(name);
    }

    if (_dataController.sheetNames.contains(name)) {
      if (_dataController.loadedSheetsData.containsKey(name)) {
        _dataController.sheet = _dataController.loadedSheetsData[name]!;
        _selectionController.selection =
            _dataController.lastSelectionBySheet[name]!;
      } else {
        _dataController.saveExecutors[name] = ManageWaitingTasks<void>();
        try {
          _dataController.sheet = await _getDataUseCase.loadSheet(name);
          if (!init) {
            _selectionController.selection =
                _dataController.lastSelectionBySheet[name]!;
          }
        } catch (e) {
          logger.e("Error parsing sheet data for $name: $e");
          _dataController.sheet = SheetData.empty();
          _selectionController.selection = SelectionData.empty();
        }
      }
    } else {
      _dataController.sheet = SheetData.empty();
      _selectionController.selection = SelectionData.empty();
      _dataController.sheetNames.add(name);
      _saveSheetDataUseCase.saveAllSheetNames(_dataController.sheetNames);
      _dataController.saveExecutors[name] = ManageWaitingTasks<void>();
    }

    if (!init) {
      _dataController.saveLastSelection(_selectionController.selection);
    }

    _dataController.loadedSheetsData[name] = _dataController.sheet;
    _dataController.sheetName = name;

    // Trigger Controller updates
    updateRowColCount(
      visibleHeight:
          _selectionController.selection.scrollOffsetX +
          _gridController.row1ToScreenBottomHeight,
      visibleWidth:
          _selectionController.selection.scrollOffsetY +
          _gridController.colBToScreenRightWidth,
      notify: false,
    );

    _streamController.scrollToOffset(
      x: _selectionController.selection.scrollOffsetX,
      y: _selectionController.selection.scrollOffsetY,
      animate: true,
    );

    saveAndCalculate(save: false);
    notifyListeners();
  }
}
