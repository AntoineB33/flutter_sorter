import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/file_sheet_local_datasource.dart';
import 'package:trying_flutter/features/media_sorter/data/models/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/data/repositories/sheet_repository_impl.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/get_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/save_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/all_sheets_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/utils/check_valid_strings.dart';
import 'package:trying_flutter/utils/logger.dart';

class WorkbookController extends ChangeNotifier {
  Map<String, SheetData> loadedSheetsData = {};
  Map<String, SelectionData> lastSelectionBySheet = {};
  List<String> sheetNames = [];
  String sheetName = "";

  late SaveSheetDataUseCase _saveSheetDataUseCase;
  late GetSheetDataUseCase _getDataUseCase;

  WorkbookController() {
    final SheetRepositoryImpl sheetRepository = SheetRepositoryImpl(
      FileSheetLocalDataSource(),
    );
    _saveSheetDataUseCase = SaveSheetDataUseCase(sheetRepository);
    _getDataUseCase = GetSheetDataUseCase(sheetRepository);
    init();
  }

  Future<void> init() async {
    await _saveSheetDataUseCase.clearAllData();
    await _saveSheetDataUseCase.initialize();
    String? lastOpenedSheetName;
    try {
      lastOpenedSheetName = await _getDataUseCase.getLastOpenedSheetName();
    } catch (e) {
      debugPrint("Error getting last opened sheet name: $e");
    }
    try {
      sheetNames = await _getDataUseCase.getAllSheetNames();
    } catch (e) {
      debugPrint("Error initializing AllSheetsController: $e");
      sheetNames = [];
    }
    if (lastOpenedSheetName == null) {
      if (sheetNames.isNotEmpty) {
        lastOpenedSheetName = sheetNames[0];
      } else {
        lastOpenedSheetName = SpreadsheetConstants.defaultSheetName;
        sheetNames = [lastOpenedSheetName];
      }
      await _saveSheetDataUseCase.saveLastOpenedSheetName(lastOpenedSheetName);
    } else if (!sheetNames.contains(lastOpenedSheetName)) {
      logger.e(
        "Last opened sheet name '$lastOpenedSheetName' not found in sheet names list, adding it.",
      );
      sheetNames.add(lastOpenedSheetName);
      await _saveSheetDataUseCase.saveAllSheetNames(sheetNames);
    }
    sheetName = lastOpenedSheetName;
    try {
      lastSelectionBySheet = await _getDataUseCase.getAllLastSelected();
    } catch (e) {
      debugPrint("Error getting all last selected cells: $e");
    }
    bool changed = false;
    for (var name in sheetNames) {
      if (!lastSelectionBySheet.containsKey(name)) {
        lastSelectionBySheet[name] = SelectionData.empty();
        changed = true;
        debugPrint(
          "No last selected cell for sheet $name, defaulting to (0,0)",
        );
      }
    }
    if (changed) {
      _saveSheetDataUseCase.saveAllLastSelected(
        _dataController.lastSelectionBySheet,
      );
    }
    for (var name in _dataController.lastSelectionBySheet.keys) {
      if (!_dataController.sheetNames.contains(name)) {
        _dataController.sheetNames.add(name);
        availableSheetsChanged = true;
      }
    }
    try {
      _selectionController.selection = await _getDataUseCase.getLastSelection();
    } catch (e) {
      _selectionController.selection = SelectionData.empty();
      await _dataController.saveLastSelection(_selectionController.selection);
    }

    if (!CheckValidStrings.isValidSheetName(currentSheetId)) {
      if (_dataController.sheetNames.isNotEmpty) {
        _dataController.sheetName = _dataController.sheetNames[0];
      } else {
        _dataController.sheetName = SpreadsheetConstants.defaultSheetName;
      }
      _saveSheetDataUseCase.saveLastOpenedSheetName(_dataController.sheetName);
    }
    bool availableSheetsChanged = false;
    if (!_dataController.sheetNames.contains(_dataController.sheetName)) {
      _dataController.sheetNames.add(_dataController.sheetName);
      availableSheetsChanged = true;
      debugPrint(
        "Last opened sheet ${_dataController.sheetName} not found in available sheets, adding it.",
      );
    }
    if (availableSheetsChanged) {
      _saveSheetDataUseCase.saveAllSheetNames(_dataController.sheetNames);
    }

    loadSheetByName(_dataController.sheetName, init: true);
  }
}
