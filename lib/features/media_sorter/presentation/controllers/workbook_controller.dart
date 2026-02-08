import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/file_sheet_local_datasource.dart';
import 'package:trying_flutter/features/media_sorter/data/models/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/data/repositories/sheet_repository_impl.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sorting_rule.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/get_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/manage_waiting_tasks.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/save_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sheet_data_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/utils/check_valid_strings.dart';
import 'package:trying_flutter/utils/logger.dart';
import 'dart:math';
import 'package:trying_flutter/features/media_sorter/data/datasources/file_sheet_local_datasource.dart';
import 'package:trying_flutter/features/media_sorter/data/models/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/data/repositories/sheet_repository_impl.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/spreadsheet_scroll_request.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/calculation_service.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/sorting_service.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/get_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/parse_paste_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/save_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/grid_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/history_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/selection_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sheet_data_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sort_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/tree_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/delegates/spreadsheet_keyboard_delegate.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/services/sheet_loader_service.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/services/spreadsheet_clipboard_service.dart';
import 'package:trying_flutter/features/media_sorter/presentation/utils/check_valid_strings.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart'; // Import AnalysisResult
import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/core/utility/get_names.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/spreadsheet_stream_controller.dart';

class WorkbookController extends ChangeNotifier {
  Map<String, SheetData> loadedSheetsData = {};
  Map<String, SelectionData> lastSelectionBySheet = {};
  Map<String, AnalysisResult> analysisResults = {};
  List<String> sheetNames = [];
  String currentSheetName = "";

  
  final GridController _gridController;
  final HistoryController _historyController;
  final SelectionController _selectionController;
  final SheetDataController _dataController;
  final TreeController _treeController;
  final SpreadsheetStreamController _streamController;
  final SortController _sortController;

  // --- usecases ---
  final SaveSheetDataUseCase _saveSheetDataUseCase = SaveSheetDataUseCase(
    SheetRepositoryImpl(FileSheetLocalDataSource()),
  );
  final GetSheetDataUseCase _getDataUseCase = GetSheetDataUseCase(
    SheetRepositoryImpl(FileSheetLocalDataSource()),
  );
  final CalculationService calculationService = CalculationService();
  final ParsePasteDataUseCase _parsePasteDataUseCase = ParsePasteDataUseCase();

  SelectionData get selection => lastSelectionBySheet[currentSheetName] ?? SelectionData.empty();
  
  AnalysisResult get result => analysisResults[currentSheetName] ?? AnalysisResult.empty();
  List<List<String>> get table => sheet.sheetContent.table;
  int get rowCount => table.length;
  int get colCount => table.isNotEmpty ? table[0].length : 0;
  SheetData get sheet => loadedSheetsData[currentSheetName] ?? SheetData.empty();
  SheetContent get sheetContent => sheet.sheetContent;
  AnalysisResult get lastAnalysis => analysisResults[currentSheetName] ?? AnalysisResult.empty();
  NodeStruct get errorRoot => lastAnalysis.errorRoot;
  NodeStruct get warningRoot => lastAnalysis.warningRoot;
  NodeStruct get categoriesRoot => lastAnalysis.categoriesRoot;
  NodeStruct get distPairsRoot => lastAnalysis.distPairsRoot;
  Stream<SpreadsheetScrollRequest> get scrollStream =>
      _streamController.scrollStream;
  // bool get editingMode => _selectionController.editingMode;
  // int get tableViewRows => _selectionController.tableViewRows;
  // int get tableViewCols => _selectionController.tableViewCols;
  // Point<int> get primarySelectedCell =>
  //     _selectionController.primarySelectedCell;
  String get previousContent => selection.previousContent;
  bool get findingBestSort => _sortController.findingBestSort;

  // --- Helper ---
  late final SheetLoaderService _sheetLoaderService;

  // Delegates
  late final SpreadsheetKeyboardDelegate _keyboardDelegate;

  // Services
  late final SpreadsheetClipboardService _clipboardService;

  WorkbookController(
    this._gridController,
    this._historyController,
    this._selectionController,
    this._dataController,
    this._treeController,
    this._streamController,
    this._sortController,) {
    final SheetRepositoryImpl sheetRepository = SheetRepositoryImpl(
      FileSheetLocalDataSource(),
    );
    init();
  }

  Future<void> init() async {
    await _saveSheetDataUseCase.clearAllData();

    // --- get current sheet name and all sheet names ---
    String? lastOpenedSheetName;
    bool saveLastOpenedSheetName = false;
    bool saveAllSheetNames = false;
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
    if (lastOpenedSheetName != null && !CheckValidStrings.isValidSheetName(lastOpenedSheetName!)) {
      debugPrint(
        "Invalid last opened sheet name '$lastOpenedSheetName'.",
      );
      lastOpenedSheetName = null;
    }
    for (var name in sheetNames) {
      if (!CheckValidStrings.isValidSheetName(name)) {
        debugPrint(
          "Invalid sheet name '$name' found in sheet names list, removing it.",
        );
        sheetNames.remove(name);
        saveAllSheetNames = true;
      }
    }
    if (lastOpenedSheetName == null) {
      if (sheetNames.isNotEmpty) {
        lastOpenedSheetName = sheetNames[0];
      } else {
        lastOpenedSheetName = SpreadsheetConstants.defaultSheetName;
        sheetNames = [lastOpenedSheetName];
      }
      saveLastOpenedSheetName = true;
    } else if (!sheetNames.contains(lastOpenedSheetName)) {
      logger.e(
        "Last opened sheet name '$lastOpenedSheetName' not found in sheet names list, adding it.",
      );
      sheetNames.add(lastOpenedSheetName);
      saveAllSheetNames = true;
    }
    currentSheetName = lastOpenedSheetName;

    // --- get last selection by sheet ---
    lastSelectionBySheet = await _selectionController.getAllLastSelected();
    bool saveLastSelectionBySheet = _selectionController.completeMissing(lastSelectionBySheet, sheetNames);
    for (var name in lastSelectionBySheet.keys.toList()) {
      if (CheckValidStrings.isValidSheetName(name)) {
        debugPrint(
          "Last selection found for sheet '$name' which is not in sheet names list, removing it.",
        );
        lastSelectionBySheet.remove(name);
        saveLastSelectionBySheet = true;
      } else if (!sheetNames.contains(name)) {
        sheetNames.add(name);
        saveAllSheetNames = true;
        debugPrint(
          "No sheet data saved for selection of sheet $name",
        );
      }
    }
    
    // --- get last selection for current sheet ---
    _selectionController.getLastSelection(lastSelectionBySheet, currentSheetName);

    // --- save any correction if needed ---
    if (saveLastOpenedSheetName) {
      await _saveSheetDataUseCase.saveLastOpenedSheetName(currentSheetName);
    }
    if (saveAllSheetNames) {
      await _saveSheetDataUseCase.saveAllSheetNames(sheetNames);
    }
    if (saveLastSelectionBySheet) {
      _selectionController.saveAllLastSelected(lastSelectionBySheet);
    }

    loadSheetByName(currentSheetName, init: true);
  }

  
  Future<void> loadSheetByName(
    String name, {
    bool init = false,
    SelectionData? lastSelection,
  }) async {
    if (!init) {
      _selectionController.saveAllLastSelected(lastSelectionBySheet);
      _saveSheetDataUseCase.saveLastOpenedSheetName(name);
    }

    if (sheetNames.contains(name)) {
      if (!loadedSheetsData.containsKey(name)) {
        _dataController.createSaveExecutor(name);
        try {
          loadedSheetsData[name] = await _getDataUseCase.loadSheet(name);
        } catch (e) {
          logger.e("Error parsing sheet data for $name: $e");
          loadedSheetsData[name] = SheetData.empty();
          _selectionController.clearLastSelection(lastSelectionBySheet, name);
        }
      }
    } else {
      loadedSheetsData[name] = SheetData.empty();
      _selectionController.clearLastSelection(lastSelectionBySheet, name);
      sheetNames.add(name);
      _saveSheetDataUseCase.saveAllSheetNames(sheetNames);
      _dataController.createSaveExecutor(name);
    }
    currentSheetName = name;
    if (!init) {
      _selectionController.saveLastSelection(lastSelectionBySheet, name);
    }

    // Trigger Controller updates
    _selectionController.updateRowColCount(
      sheet, selection, lastSelectionBySheet, currentSheetName,
      visibleHeight:
          selection.scrollOffsetX +
          _gridController.row1ToScreenBottomHeight,
      visibleWidth:
          selection.scrollOffsetY +
          _gridController.colBToScreenRightWidth,
      notify: false,
    );

    _streamController.scrollToOffset(
      x: selection.scrollOffsetX,
      y: selection.scrollOffsetY,
      animate: true,
    );

    _dataController.saveAndCalculate(sheet, selection, currentSheetName, save: false);
    notifyListeners();
  }

  /// Call this when the Controller finishes a calculation.
  /// The Manager takes ownership of updating the tree state.
  void onAnalysisComplete(
    AnalysisResult result,
    Point<int> primarySelectedCell,
  ) {
    // Reset specific roots
    _treeController.updateMentionsRoot(primarySelectedCell.x, primarySelectedCell.y);
    _treeController.clearSearchRoot();
    _treeController.populateAllTrees(selection, sheet, result, rowCount, colCount);
  }

  void toggleNodeExpansion(NodeStruct node, bool isExpanded) {
    _treeController.toggleNodeExpansion(sheet, result, selection, node, isExpanded);
  }
}
