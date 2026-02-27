import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/file_sheet_local_datasource.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/data/repositories/sheet_repository_impl.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_status.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sheet_data/get_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sheet_data/save_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/history_service.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sheet_data/sheet_data_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/analysis_data_store.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/loaded_sheets_data_store.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/selection_data_store.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/sort_status_data_store.dart';
import 'package:trying_flutter/features/media_sorter/presentation/utils/check_valid_strings.dart';
import 'package:trying_flutter/utils/logger.dart';
import 'dart:math';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/spreadsheet_scroll_request.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/calculation_service.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/grid_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/history/history_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/selection/selection_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sort/sort_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/tree/tree_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/managers/spreadsheet_keyboard_delegate.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart'; // Import AnalysisResult
import 'package:trying_flutter/features/media_sorter/presentation/controllers/spreadsheet_stream_controller.dart';

class WorkbookController extends ChangeNotifier {
  final HistoryService historyService;

  final LoadedSheetsDataStore loadedSheetsDataStore;
  final AnalysisDataStore analysisDataStore;
  final SelectionDataStore selectionDataStore;
  final SortStatusDataStore sortStatusDataStore;

  // --- usecases ---
  final SaveSheetDataUseCase saveSheetDataUseCase;
  final GetSheetDataUseCase getDataUseCase;
  final CalculationService calculationService = CalculationService();

  List<List<String>> get table => sheet.sheetContent.table;
  int get rowCount => table.length;
  int get colCount => table.isNotEmpty ? table[0].length : 0;
  SheetData get sheet => loadedSheetsDataStore.currentSheet;
  SheetContent get sheetContent => sheet.sheetContent;
  // bool get editingMode => selectionController.editingMode;
  // int get tableViewRows => selectionController.tableViewRows;
  // int get tableViewCols => selectionController.tableViewCols;
  // Point<int> get primarySelectedCell =>
  //     selectionController.primarySelectedCell;

  WorkbookController({
    required this.historyService,
    required this.saveSheetDataUseCase,
    required this.getDataUseCase,
    required this.loadedSheetsDataStore,
    required this.analysisDataStore,
    required this.selectionDataStore,
    required this.sortStatusDataStore,
  }) {
    init();
  }

  Future<void> init() async {
    await saveSheetDataUseCase.clearAllData();

    // --- get current sheet name and all sheet names ---
    List<String> recentSheetIds;
    bool saveRecentSheetIds = false;
    try {
      recentSheetIds = await getDataUseCase.recentSheetIds();
    } catch (e) {
      debugPrint("Error getting recent sheet names: $e");
    }
    try {
      loadedSheetsDataStore.sheetNames = await getDataUseCase
          .getAllSheetNames();
    } catch (e) {
      debugPrint("Error initializing AllSheetsController: $e");
      loadedSheetsDataStore.sheetNames = [];
    }
    if (lastOpenedSheetName != null &&
        !CheckValidStrings.isValidSheetName(lastOpenedSheetName)) {
      debugPrint("Invalid last opened sheet name '$lastOpenedSheetName'.");
      lastOpenedSheetName = null;
    }
    for (var name in loadedSheetsDataStore.sheetNames) {
      if (!CheckValidStrings.isValidSheetName(name)) {
        debugPrint(
          "Invalid sheet name '$name' found in sheet names list, removing it.",
        );
        loadedSheetsDataStore.sheetNames.remove(name);
        saveRecentSheetIds = true;
      }
    }
    if (lastOpenedSheetName == null) {
      if (loadedSheetsDataStore.sheetNames.isNotEmpty) {
        lastOpenedSheetName = loadedSheetsDataStore.sheetNames[0];
      } else {
        lastOpenedSheetName = SpreadsheetConstants.defaultSheetName;
        loadedSheetsDataStore.sheetNames = [lastOpenedSheetName];
      }
      saveRecentSheetIds = true;
    } else if (!loadedSheetsDataStore.sheetNames.contains(
      lastOpenedSheetName,
    )) {
      logger.e(
        "Last opened sheet name '$lastOpenedSheetName' not found in sheet names list, adding it.",
      );
      loadedSheetsDataStore.sheetNames.add(lastOpenedSheetName);
      saveRecentSheetIds = true;
    }
    loadedSheetsDataStore.currentSheetId = lastOpenedSheetName;

    // --- get last selection by sheet ---
    await selectionController.getAllLastSelected();
    bool saveLastSelectionBySheet = selectionController.completeMissing(
      loadedSheetsDataStore.sheetNames,
    );
    for (var name in selectionDataStore.lastSelectionBySheet.keys.toList()) {
      if (!CheckValidStrings.isValidSheetName(name)) {
        debugPrint(
          "Last selection found for sheet '$name' which is not in sheet names list, removing it.",
        );
        selectionDataStore.lastSelectionBySheet.remove(name);
        saveLastSelectionBySheet = true;
      } else if (!loadedSheetsDataStore.sheetNames.contains(name)) {
        loadedSheetsDataStore.sheetNames.add(name);
        saveRecentSheetIds = true;
        debugPrint("No sheet data saved for selection of sheet $name");
      }
    }

    // --- get sort status by sheet ---
    await sortController.loadAllSortStatus();
    bool saveCalculationStatusBySheet = false;
    for (var name in sortController.sortStatusBySheet.keys.toList()) {
      if (!CheckValidStrings.isValidSheetName(name)) {
        debugPrint(
          "Sort status found for sheet '$name' which is not in sheet names list, removing it.",
        );
        sortController.sortStatusBySheet.remove(name);
        saveCalculationStatusBySheet = true;
      } else if (!loadedSheetsDataStore.sheetNames.contains(name)) {
        loadedSheetsDataStore.sheetNames.add(name);
        saveRecentSheetIds = true;
        selectionDataStore.lastSelectionBySheet[name] = SelectionData.empty();
        saveLastSelectionBySheet = true;
        debugPrint("No sheet data saved for sort status of sheet $name");
      }
    }

    // --- get last selection for current sheet ---
    selectionController.loadLastSelection();

    // --- save any correction if needed ---
    if (saveRecentSheetIds) {
      await saveSheetDataUseCase.saveRecentSheetIds(
        loadedSheetsDataStore.currentSheetId,
      );
    }
    if (saveRecentSheetIds) {
      await saveSheetDataUseCase.saveRecentSheetIds(
        loadedSheetsDataStore.sheetNames,
      );
    }
    if (saveLastSelectionBySheet) {
      await selectionController.saveAllLastSelected();
    }
    if (saveCalculationStatusBySheet) {
      sortController.saveAllSortStatus(loadedSheetsDataStore.currentSheetId);
    }
    await loadSheetByName(loadedSheetsDataStore.currentSheetId, init: true);
    for (var name in sortStatusDataStore.sortStatusBySheet.keys.toList()) {
      if (!sortStatusDataStore.getSortStatus(name).resultCalculated ||
          !sortStatusDataStore.getSortStatus(name).validSortFound) {
        if (!analysisDataStore.analysisResults.containsKey(name)) {
          await sortController.loadAnalysisResult(name);
        }
        sortController.calculate(name);
      } else if (!sortStatusDataStore.getSortStatus(name).isFindingBestSort) {
        await sortController.loadAnalysisResult(name);
        sortController.findBestSortToggle();
      } else if (!sortStatusDataStore
          .getSortStatus(name)
          .sortWhileFindingBestSort) {
        await sortController.loadAnalysisResult(name);
        sortController.findBestSortAndSortToggle(
          _dataController.sheet(name),
          selectionController.lastSelectionBySheet,
          name,
          _gridController.row1ToScreenBottomHeight,
          _gridController.colBToScreenRightWidth,
        );
      }
    }
  }

  Future<void> loadSheetByName(
    String name, {
    bool init = false,
    SelectionData? lastSelection,
  }) async {
    if (!init) {
      selectionController.saveAllLastSelected();
      saveSheetDataUseCase.saveRecentSheetIds(name);
    }

    if (sheetNames.contains(name)) {
      if (!_dataController.loadedSheetsData.containsKey(name)) {
        _dataController.createSaveExecutor(name);
        try {
          _dataController.loadedSheetsData[name] = await getDataUseCase
              .loadSheet(name);
        } catch (e) {
          logger.e("Error parsing sheet data for $name: $e");
          _dataController.loadedSheetsData[name] = SheetData.empty();
          selectionController.clearLastSelection(name);
        }
        await sortController.loadAnalysisResult(name);
      }
    } else {
      _dataController.loadedSheetsData[name] = SheetData.empty();
      sortController.analysisResults[name] = AnalysisResult.empty();
      selectionController.clearLastSelection(name);
      sheetNames.add(name);
      saveSheetDataUseCase.saveRecentSheetIds(sheetNames);
      _dataController.createSaveExecutor(name);
    }
    currentSheetName = name;
    if (!init) {
      selectionController.saveLastSelection(name);
    }

    // Trigger Controller updates
    selectionController.updateRowColCount(
      sheet,
      currentSheetName,
      visibleHeight:
          selectionController.scrollOffsetX +
          _gridController.row1ToScreenBottomHeight,
      visibleWidth:
          selectionController.scrollOffsetY +
          _gridController.colBToScreenRightWidth,
      notify: false,
    );

    _streamController.scrollToOffset(
      x: selectionController.scrollOffsetX,
      y: selectionController.scrollOffsetY,
      animate: true,
    );
    notifyListeners();
  }

  List<String> getRecentSheetNames() {
    return loadedSheetsDataStore.recentSheetIds.map((id) => loadedSheetsDataStore.getSheet(id).sheetName).toList();
  }
}
