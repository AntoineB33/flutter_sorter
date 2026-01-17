import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_model.dart';
import 'package:trying_flutter/features/media_sorter/data/models/selection_model.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/get_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/save_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/manage_waiting_tasks.dart';

class SheetDataManager {
  final GetSheetDataUseCase _getDataUseCase;
  final SaveSheetDataUseCase _saveSheetDataUseCase;

  // Cache and State
  Map<String, SheetModel> _loadedSheetsCache = {};
  Map<String, SelectionModel> _lastSelectedCells = {};
  List<String> availableSheets = [];
  
  // Execution Throttlers
  final Map<String, ManageWaitingTasks<void>> _saveExecutors = {};
  final ManageWaitingTasks<void> _saveLastSelectionExecutor = ManageWaitingTasks<void>();
  final int _saveDelayMs = 500;

  SheetDataManager({
    required GetSheetDataUseCase getDataUseCase,
    required SaveSheetDataUseCase saveSheetDataUseCase,
  })  : _getDataUseCase = getDataUseCase,
        _saveSheetDataUseCase = saveSheetDataUseCase;

  /// Initializes storage, validates names, and returns the name of the sheet to load.
  Future<String> initialize() async {
    await _saveSheetDataUseCase.initialize();
    
    String sheetName;
    try {
      sheetName = await _getDataUseCase.getLastOpenedSheetName();
    } catch (e) {
      sheetName = ""; // Will be corrected below
    }

    // Load available sheets
    availableSheets = await _getDataUseCase.getAllSheetNames();

    // Validate Sheet Name
    if (!_isValidSheetName(sheetName)) {
      if (availableSheets.isNotEmpty) {
        sheetName = availableSheets[0];
      } else {
        sheetName = SpreadsheetConstants.defaultSheetName;
      }
      await _saveSheetDataUseCase.saveLastOpenedSheetName(sheetName);
    }

    // Ensure sheet is in the list
    if (!availableSheets.contains(sheetName)) {
      availableSheets.add(sheetName);
      await _saveSheetDataUseCase.saveAllSheetNames(availableSheets);
    }

    // Initialize Selections
    _lastSelectedCells = await _getDataUseCase.getAllLastSelected();
    bool selectionChanged = false;
    for (var name in availableSheets) {
      if (!_lastSelectedCells.containsKey(name)) {
        _lastSelectedCells[name] = SelectionModel.empty();
        selectionChanged = true;
      }
    }
    if (selectionChanged) {
      await _saveSheetDataUseCase.saveAllLastSelected(_lastSelectedCells);
    }

    return sheetName;
  }

  /// Returns a SheetModel from cache or disk.
  Future<SheetModel> loadSheet(String name) async {
    // Ensure executor exists for this sheet
    if (!_saveExecutors.containsKey(name)) {
      _saveExecutors[name] = ManageWaitingTasks<void>();
    }

    // Ensure name is in available list
    if (!availableSheets.contains(name)) {
      availableSheets.add(name);
      await _saveSheetDataUseCase.saveAllSheetNames(availableSheets);
    }

    // Check Cache
    if (_loadedSheetsCache.containsKey(name)) {
      return _loadedSheetsCache[name]!;
    }

    // Load from Disk
    SheetModel sheet;
    try {
      sheet = await _getDataUseCase.loadSheet(name);
    } catch (e) {
      debugPrint("Error parsing sheet data for $name: $e");
      sheet = SheetModel.empty();
    }

    _loadedSheetsCache[name] = sheet;
    return sheet;
  }

  /// Saves the sheet to disk with throttling.
  void scheduleSheetSave(String name, SheetModel sheet) {
    // Update cache immediately
    _loadedSheetsCache[name] = sheet;

    // Schedule disk write
    if (_saveExecutors.containsKey(name)) {
      _saveExecutors[name]!.execute(() async {
        await _saveSheetDataUseCase.saveSheet(name, sheet);
        await Future.delayed(Duration(milliseconds: _saveDelayMs));
      });
    }
  }

  /// Saves the last selection with throttling.
  void scheduleSelectionSave(SelectionModel selection, String currentSheetName) {
    // Update local cache
    _lastSelectedCells[currentSheetName] = selection;
    
    _saveLastSelectionExecutor.execute(() async {
      await _saveSheetDataUseCase.saveLastSelection(selection);
      await _saveSheetDataUseCase.saveAllLastSelected(_lastSelectedCells);
      await Future.delayed(Duration(milliseconds: _saveDelayMs));
    });
  }

  Future<void> saveLastOpenedSheetName(String name) async {
    await _saveSheetDataUseCase.saveLastOpenedSheetName(name);
  }

  SelectionModel getLastSelectionFor(String name) {
    return _lastSelectedCells[name] ?? SelectionModel.empty();
  }
  
  Future<SelectionModel> fetchLatestSelectionFromDisk() async {
      return await _getDataUseCase.getLastSelection();
  }

  bool _isValidSheetName(String name) {
    return name.isNotEmpty &&
        !name.contains(RegExp(r'[\\/:*?"<>|]')) &&
        name != SpreadsheetConstants.noSPNameFound;
  }
}