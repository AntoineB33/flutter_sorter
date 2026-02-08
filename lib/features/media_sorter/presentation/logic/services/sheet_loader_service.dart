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
}
