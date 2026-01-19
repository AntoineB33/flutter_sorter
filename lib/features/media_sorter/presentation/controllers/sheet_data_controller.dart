import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_model.dart';
import 'package:trying_flutter/features/media_sorter/data/models/selection_model.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/get_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/save_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/manage_waiting_tasks.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/spreadsheet_controller.dart';
import 'package:trying_flutter/utils/logger.dart';

class SheetDataController extends ChangeNotifier {
  // --- states ---
  SheetModel sheet = SheetModel.empty();
  String sheetName = "";
  List<String> availableSheets = [];
  Map<String, SheetModel> loadedSheetsData = {};
  Map<String, SelectionModel> lastSelectedCells = {};
  final Map<String, ManageWaitingTasks<void>> _saveExecutors = {};
  final ManageWaitingTasks<void> _saveLastSelectionExecutor = ManageWaitingTasks<void>();

  // --- helpers ---
  final SpreadsheetController controller;
  final GetSheetDataUseCase _getDataUseCase;
  final SaveSheetDataUseCase _saveSheetDataUseCase;

  SheetDataController(
    this.controller, {
    required GetSheetDataUseCase getDataUseCase,
    required SaveSheetDataUseCase saveSheetDataUseCase,
  })  : _getDataUseCase = getDataUseCase,
        _saveSheetDataUseCase = saveSheetDataUseCase;

  bool isValidSheetName(String name) {
    return name.isNotEmpty &&
        !name.contains(RegExp(r'[\\/:*?"<>|]')) &&
        name != SpreadsheetConstants.noSPNameFound;
  }

  Future<void> init() async {
    controller.setLoading(true);

    // await _saveSheetDataUseCase.clearAllData();
    await _saveSheetDataUseCase.initialize();
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
    if (!isValidSheetName(sheetName)) {
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
    lastSelectedCells = await _getDataUseCase.getAllLastSelected();
    bool changed = false;
    for (var name in availableSheets) {
      if (!lastSelectedCells.containsKey(name)) {
        lastSelectedCells[name] = SelectionModel.empty();
        changed = true;
        debugPrint(
          "No last selected cell for sheet $name, defaulting to (0,0)",
        );
      }
    }
    if (changed) {
      _saveSheetDataUseCase.saveAllLastSelected(lastSelectedCells);
    }
    for (var name in lastSelectedCells.keys) {
      if (!availableSheets.contains(name)) {
        availableSheets.add(name);
        availableSheetsChanged = true;
      }
    }
    if (availableSheetsChanged) {
      _saveSheetDataUseCase.saveAllSheetNames(availableSheets);
    }

    await loadSheetByName(sheetName, init: true);
  }

  Future<void> loadSheetByName(String name, {bool init = false}) async {
    if (!controller.isLoading) {
      controller.setLoading(true);
    }

    if (!init) {
      lastSelectedCells[sheetName] = controller.selection;
      _saveSheetDataUseCase.saveAllLastSelected(lastSelectedCells);
      _saveSheetDataUseCase.saveLastOpenedSheetName(name);
    }

    if (availableSheets.contains(name)) {
      if (loadedSheetsData.containsKey(name)) {
        sheet = loadedSheetsData[name]!;
        controller.setSelection(lastSelectedCells[name]!);
      } else {
        _saveExecutors[name] = ManageWaitingTasks<void>();
        try {
          sheet = await _getDataUseCase.loadSheet(name);
          if (init) {
            controller.setSelection(await _getDataUseCase.getLastSelection());
          } else {
            controller.setSelection(lastSelectedCells[name]!);
          }
        } catch (e) {
          logger.e("Error parsing sheet data for $name: $e");
          sheet = SheetModel.empty();
          controller.setSelection(SelectionModel.empty());
        }
      }
    } else {
      sheet = SheetModel.empty();
      controller.setSelection(SelectionModel.empty());
      availableSheets.add(name);
      _saveSheetDataUseCase.saveAllSheetNames(availableSheets);
      _saveExecutors[name] = ManageWaitingTasks<void>();
    }
    
    if (!init) {
      await saveLastSelection(controller.selection);
    }
    
    loadedSheetsData[name] = sheet;
    sheetName = name;

    // Trigger Controller updates
    controller.updateRowColCount(
        visibleHeight: controller.visibleWindowHeight,
        visibleWidth: controller.visibleWindowWidth,
        notify: false);
        
    controller.scrollToOffset(
      x: controller.selection.scrollOffsetX,
      y: controller.selection.scrollOffsetY,
      animate: false,
    );
    
    controller.saveAndCalculate(save: false);
    controller.notify();
  }

  Future<void> saveLastSelection(SelectionModel selection) async {
    _saveLastSelectionExecutor.execute(() async {
      await _saveSheetDataUseCase.saveLastSelection(selection);
      await Future.delayed(Duration(milliseconds: controller.saveDelayMs));
    });
  }

  Future<void> saveSheetDirect(String sheetName, SheetModel sheet) async {
    await _saveSheetDataUseCase.saveSheet(sheetName, sheet);
  }

  void scheduleSheetSave(int saveDelayMs) {
    _saveExecutors[sheetName]!.execute(() async {
      await _saveSheetDataUseCase.saveSheet(sheetName, sheet);
      await Future.delayed(Duration(milliseconds: saveDelayMs));
    });
  }
}