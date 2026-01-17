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

    // await _saveSheetDataUseCase.clearAllData();
    await _saveSheetDataUseCase.initialize();
    String sheetName = SpreadsheetConstants.defaultSheetName;
    try {
      sheetName = await _getDataUseCase.getLastOpenedSheetName();
    } catch (e) {
      await _saveSheetDataUseCase.saveLastOpenedSheetName(sheetName);
    }
    try {
      await _getDataUseCase.getLastSelection();
    } catch (e) {
      await saveLastSelection(SelectionModel.empty());
    }

    availableSheets = await _getDataUseCase.getAllSheetNames();
    if (!_isValidSheetName(sheetName)) {
      if (availableSheets.isNotEmpty) {
        sheetName = availableSheets[0];
      } else {
        sheetName = SpreadsheetConstants.defaultSheetName;
      }
      _saveSheetDataUseCase.saveLastOpenedSheetName(sheetName);
    }
    bool availableSheetsChanged = false;
    if (!availableSheets.contains(sheetName)) {
      availableSheets.add(sheetName);
      availableSheetsChanged = true;
      debugPrint(
        "Last opened sheet $sheetName not found in available sheets, adding it.",
      );
    }
    _lastSelectedCells = await _getDataUseCase.getAllLastSelected();
    bool changed = false;
    for (var name in availableSheets) {
      if (!_lastSelectedCells.containsKey(name)) {
        _lastSelectedCells[name] = SelectionModel.empty();
        changed = true;
        debugPrint(
          "No last selected cell for sheet $name, defaulting to (0,0)",
        );
      }
    }
    if (changed) {
      _saveSheetDataUseCase.saveAllLastSelected(_lastSelectedCells);
    }
    for (var name in _lastSelectedCells.keys) {
      if (!availableSheets.contains(name)) {
        availableSheets.add(name);
        availableSheetsChanged = true;
      }
    }
    if (availableSheetsChanged) {
      _saveSheetDataUseCase.saveAllSheetNames(availableSheets);
    }

    return sheetName;
  }

  Future<void> saveLastSelection(SelectionModel selection) async {
    _saveLastSelectionExecutor.execute(() async {
      await _saveSheetDataUseCase.saveLastSelection(selection);
      await Future.delayed(Duration(milliseconds: _saveDelayMs));
    });
  }

  /// Returns a SheetModel from cache or disk.
  Future<SheetModel> loadSheet(String name) async {
    SheetModel sheet;
    if (availableSheets.contains(name)) {
      if (_loadedSheetsCache.containsKey(name)) {
        sheet = _loadedSheetsCache[name]!;
        _selectionManager.selection = lastSelectedCells[name]!;
      } else {
        _saveExecutors[name] = ManageWaitingTasks<void>();
        try {
          sheet = await _getDataUseCase.loadSheet(name);
          if (init) {
            _selectionManager.selection = await _getDataUseCase
                .getLastSelection();
          } else {
            _selectionManager.selection = lastSelectedCells[name]!;
          }
        } catch (e) {
          debugPrint("Error parsing sheet data for $name: $e");
          sheet = SheetModel.empty();
          _selectionManager.selection = SelectionModel.empty();
        }
      }
    } else {
      sheet = SheetModel.empty();
      _selectionManager.selection = SelectionModel.empty();
      availableSheets.add(name);
      _saveSheetDataUseCase.saveAllSheetNames(availableSheets);
      _saveExecutors[name] = ManageWaitingTasks<void>();
    }
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

  void setLastSelectedCells(String currentSheetName, SelectionModel selection) {
    _lastSelectedCells[currentSheetName] = selection;
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

  saveAllLastSelected(Map<String, SelectionModel> cells) {
    _saveSheetDataUseCase.saveAllLastSelected(cells);
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