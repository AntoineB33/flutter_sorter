import 'package:trying_flutter/features/media_sorter/data/models/selection_model.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_model.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/get_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/manage_waiting_tasks.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/save_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/grid_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/selection_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sheet_data_controller.dart';
import 'package:trying_flutter/utils/logger.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/spreadsheet_stream_controller.dart';

typedef OnTreeCellSelected = void Function(
  int row,
  int col,
  bool keepSelection,
  bool updateMentions,
);

class SheetLoaderService {
  // --- dependencies ---
  final GridController _gridController;
  final SelectionController _selectionController;
  final SheetDataController _dataController;
  final SpreadsheetStreamController _streamController;


  final SaveSheetDataUseCase _saveSheetDataUseCase;
  final GetSheetDataUseCase _getDataUseCase;

  Function notifyListeners;
  Function updateRowColCount;
  Function saveAndCalculate;

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
    SelectionModel? lastSelection,
  }) async {
    if (!init) {
      _dataController.lastSelectedCells[_dataController.sheetName] =
          _selectionController.selection;
      _saveSheetDataUseCase.saveAllLastSelected(
        _dataController.lastSelectedCells,
      );
      _saveSheetDataUseCase.saveLastOpenedSheetName(name);
    }

    if (_dataController.availableSheets.contains(name)) {
      if (_dataController.loadedSheetsData.containsKey(name)) {
        _dataController.sheet = _dataController.loadedSheetsData[name]!;
        _selectionController.selection =
            _dataController.lastSelectedCells[name]!;
      } else {
        _dataController.saveExecutors[name] = ManageWaitingTasks<void>();
        try {
          _dataController.sheet = await _getDataUseCase.loadSheet(name);
          if (!init) {
            _selectionController.selection =
                _dataController.lastSelectedCells[name]!;
          }
        } catch (e) {
          logger.e("Error parsing sheet data for $name: $e");
          _dataController.sheet = SheetModel.empty();
          _selectionController.selection = SelectionModel.empty();
        }
      }
    } else {
      _dataController.sheet = SheetModel.empty();
      _selectionController.selection = SelectionModel.empty();
      _dataController.availableSheets.add(name);
      _saveSheetDataUseCase.saveAllSheetNames(_dataController.availableSheets);
      _dataController.saveExecutors[name] = ManageWaitingTasks<void>();
    }

    if (!init) {
      _dataController.saveLastSelection(_selectionController.selection);
    }

    _dataController.loadedSheetsData[name] = _dataController.sheet;
    _dataController.sheetName = name;

    // Trigger Controller updates
    updateRowColCount(
      visibleHeight: _gridController.visibleWindowHeight,
      visibleWidth: _gridController.visibleWindowWidth,
      notify: false,
    );

    _streamController.scrollToOffset(
      x: _selectionController.selection.scrollOffsetX,
      y: _selectionController.selection.scrollOffsetY,
      animate: false,
    );

    saveAndCalculate(save: false);
    notifyListeners();
  }
}