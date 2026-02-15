import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/file_sheet_local_datasource.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/data/repositories/sheet_repository_impl.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_status.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/get_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/save_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sheet_data_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/spreadsheet_mediator.dart';
import 'package:trying_flutter/features/media_sorter/presentation/utils/check_valid_strings.dart';
import 'package:trying_flutter/utils/logger.dart';
import 'dart:math';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/spreadsheet_scroll_request.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/calculation_service.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/grid_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/history_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/selection_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sort_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/tree_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/delegates/spreadsheet_keyboard_delegate.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart'; // Import AnalysisResult
import 'package:trying_flutter/features/media_sorter/presentation/controllers/spreadsheet_stream_controller.dart';

class WorkbookController extends ChangeNotifier {
  Map<String, SheetData> loadedSheetsData = {};
  Map<String, SelectionData> lastSelectionBySheet = {};
  Map<String, AnalysisResult> analysisResults = {};
  Map<String, SortStatus> sortStatusBySheet = {};
  List<String> sheetNames = [];
  String currentSheetName = "";

  final SpreadsheetMediator _mediator;

  // --- usecases ---
  final SaveSheetDataUseCase _saveSheetDataUseCase = SaveSheetDataUseCase(
    SheetRepositoryImpl(FileSheetLocalDataSource()),
  );
  final GetSheetDataUseCase _getDataUseCase = GetSheetDataUseCase(
    SheetRepositoryImpl(FileSheetLocalDataSource()),
  );
  final CalculationService calculationService = CalculationService();


  GridController get _gridController => _mediator.gridController;
  SheetDataController get _dataController => _mediator.dataController;
  SelectionController get _selectionController => _mediator.selectionController;
  TreeController get _treeController => _mediator.treeController;
  SortController get _sortController => _mediator.sortController;
  SpreadsheetStreamController get _streamController => _mediator.streamController;
  HistoryController get _historyController => _mediator.historyController;
  SpreadsheetKeyboardDelegate get _keyboardDelegate => _mediator.keyboardDelegate;

  SelectionData get selection =>
      lastSelectionBySheet[currentSheetName] ?? SelectionData.empty();

  int get tableViewRows => selection.tableViewRows;
  int get tableViewCols => selection.tableViewCols;
  AnalysisResult get result =>
      analysisResults[currentSheetName] ?? AnalysisResult.empty();
  bool get isBestSort => result.isBestSort;
  List<List<String>> get table => sheet.sheetContent.table;
  int get rowCount => table.length;
  int get colCount => table.isNotEmpty ? table[0].length : 0;
  SheetData get sheet =>
      loadedSheetsData[currentSheetName] ?? SheetData.empty();
  SheetContent get sheetContent => sheet.sheetContent;
  AnalysisResult get lastAnalysis =>
      analysisResults[currentSheetName] ?? AnalysisResult.empty();
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
  SortStatus get sortStatus => sortStatusBySheet[currentSheetName] ?? SortStatus.empty();
  bool get isFindingBestSort => sortStatus.isFindingBestSort;
  bool get isFindingBestSortAndSort => sortStatus.isFindingBestSortAndSort;
  double get scrollOffsetX => selection.scrollOffsetX;
  double get scrollOffsetY => selection.scrollOffsetY;
  Point<int> get primarySelectedCell => selection.primarySelectedCell;

  // --- setters ---
  set scrollOffsetX(double offset) {
    selection.scrollOffsetX = offset;
  }

  set scrollOffsetY(double offset) {
    selection.scrollOffsetY = offset;
  }

  void toggleNodeExpansion(NodeStruct node, bool isExpanded) {
    _treeController.toggleNodeExpansion(
      sheet,
      result,
      selection,
      lastSelectionBySheet,
      sortStatus,
      currentSheetName,
      node,
      isExpanded,
    );
  }

  void sortMedia() {
    _sortController.sortMedia(
      sheet,
      analysisResults,
      lastSelectionBySheet,
      sortStatus,
      currentSheetName,
      _gridController.row1ToScreenBottomHeight,
      _gridController.colBToScreenRightWidth,
    );
  }

  void findBestSortToggle() {
    _sortController.findBestSortToggle(
      sheet,
      analysisResults,
      lastSelectionBySheet,
      sortStatus,
      currentSheetName,
      _gridController.row1ToScreenBottomHeight,
      _gridController.colBToScreenRightWidth,
    );
  }

  void findBestSortAndSortToggle() {
    _sortController.findBestSortAndSortToggle(
      sheet,
      analysisResults,
      lastSelectionBySheet,
      sortStatus,
      currentSheetName,
      _gridController.row1ToScreenBottomHeight,
      _gridController.colBToScreenRightWidth,
    );
  }

  double getTargetTop(int row) {
    return _gridController.getTargetTop(sheet, row);
  }

  double getTargetLeft(int col) {
    return _gridController.getTargetLeft(sheet, col);
  }

  void updateRowColCount({
    double? visibleHeight,
    double? visibleWidth,
    bool notify = true,
    bool save = true,
  }) {
    _selectionController.updateRowColCount(
      sheet,
      lastSelectionBySheet,
      currentSheetName,
      visibleHeight: visibleHeight,
      visibleWidth: visibleWidth,
      notify: notify,
      save: save,
    );
  }

  void saveLastSelection() {
    _selectionController.saveLastSelection(
      lastSelectionBySheet,
      currentSheetName,
    );
  }

  KeyEventResult handleKeyboard(BuildContext context, KeyEvent event) {
    return _keyboardDelegate.handle(
      context,
      event,
      selection,
      selection.editingMode,
      sheet,
      analysisResults,
      lastSelectionBySheet,
      sortStatus,
      _gridController.row1ToScreenBottomHeight,
      _gridController.colBToScreenRightWidth,
      currentSheetName,
    );
  }

  double getRowHeight(int row) {
    return _gridController.getRowHeight(sheet, row);
  }

  void selectAll() {
    _selectionController.selectAll(
      selection,
      lastSelectionBySheet,
      currentSheetName,
      rowCount,
      colCount,
    );
  }

  bool isCellEditing(int row, int col) {
    return _selectionController.isCellEditing(selection, row, col);
  }

  String getCellContent(int row, int col) {
    return _dataController.getCellContent(sheet.sheetContent.table, row, col);
  }

  bool isRowValid(int row) {
    return _gridController.isRowValid(sheet, row, result, sortStatus);
  }

  bool isPrimarySelectedCell(int row, int col) {
    return _selectionController.isPrimarySelectedCell(selection, row, col);
  }

  bool isCellSelected(int row, int col) {
    return _selectionController.isCellSelected(selection, row, col);
  }

  void stopEditing({bool updateHistory = true, bool notify = true}) {
    _selectionController.stopEditing(
      sheet,
      lastSelectionBySheet,
      currentSheetName,
    );
  }

  void setPrimarySelection(
    int row,
    int col,
    bool keepSelection,
    bool scrollTo,
  ) {
    _selectionController.setPrimarySelection(
      selection,
      lastSelectionBySheet,
      currentSheetName,
      row,
      col,
      keepSelection,
      scrollTo: scrollTo,
    );
  }

  void startEditing({String? initialInput}) {
    _selectionController.startEditing(
      sheet,
      analysisResults,
      lastSelectionBySheet,
      sortStatus,
      currentSheetName,
      _gridController.row1ToScreenBottomHeight,
      _gridController.colBToScreenRightWidth,
      initialInput: initialInput,
    );
  }

  void onChanged(String newValue) {
    _selectionController.onChanged(
      sheet,
      analysisResults,
      selection,
      lastSelectionBySheet,
      sortStatus,
      _gridController.row1ToScreenBottomHeight,
      _gridController.colBToScreenRightWidth,
      currentSheetName,
      newValue,
    );
  }

  void updateCell(int row, int col, String newValue) {
    _dataController.updateCell(
      sheet,
      lastSelectionBySheet,
      _gridController.row1ToScreenBottomHeight,
      _gridController.colBToScreenRightWidth,
      currentSheetName,
      row,
      col,
      newValue,
    );
  }

  void setColumnType(int col, ColumnType type) {
    _dataController.setColumnType(
      sheet,
      analysisResults,
      lastSelectionBySheet,
      sortStatus,
      currentSheetName,
      col,
      type,
    );
  }

  void applyDefaultColumnSequence() {
    _dataController.applyDefaultColumnSequence(
      sheet,
      analysisResults,
      selection,
      lastSelectionBySheet,
      sortStatus,
      currentSheetName,
    );
  }

  WorkbookController(
    this._mediator,
  ) {
    _dataController.onAnalysisComplete = onAnalysisComplete;
    _sortController.onAnalysisComplete = onAnalysisComplete;

    _historyController.addListener(() {
      notifyListeners();
    });
    _selectionController.addListener(() {
      notifyListeners();
    });
    _dataController.addListener(() {
      notifyListeners();
    });
    _sortController.addListener(() {
      notifyListeners();
    });
    _treeController.addListener(() {
      notifyListeners();
    });

    init();
  }

  Future<void> init() async {
    // await _saveSheetDataUseCase.clearAllData();

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
    if (lastOpenedSheetName != null &&
        !CheckValidStrings.isValidSheetName(lastOpenedSheetName)) {
      debugPrint("Invalid last opened sheet name '$lastOpenedSheetName'.");
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
    lastSelectionBySheet.addAll(
      await _selectionController.getAllLastSelected(),
    );
    bool saveLastSelectionBySheet = _selectionController.completeMissing(
      lastSelectionBySheet,
      sheetNames,
    );
    for (var name in lastSelectionBySheet.keys.toList()) {
      if (!CheckValidStrings.isValidSheetName(name)) {
        debugPrint(
          "Last selection found for sheet '$name' which is not in sheet names list, removing it.",
        );
        lastSelectionBySheet.remove(name);
        saveLastSelectionBySheet = true;
      } else if (!sheetNames.contains(name)) {
        sheetNames.add(name);
        saveAllSheetNames = true;
        debugPrint("No sheet data saved for selection of sheet $name");
      }
    }

    // --- get sort status by sheet ---
    sortStatusBySheet.addAll(
      await _sortController.getAllSortStatus(),
    );
    bool saveCalculationStatusBySheet = _sortController.completeMissing(
      sortStatusBySheet,
      sheetNames,
    );
    for (var name in sortStatusBySheet.keys.toList()) {
      if (!CheckValidStrings.isValidSheetName(name)) {
        debugPrint(
          "Sort status found for sheet '$name' which is not in sheet names list, removing it.",
        );
        sortStatusBySheet.remove(name);
        saveCalculationStatusBySheet = true;
      } else if (!sheetNames.contains(name)) {
        sheetNames.add(name);
        saveAllSheetNames = true;
        debugPrint("No sheet data saved for sort status of sheet $name");
      }
    }

    // --- get last selection for current sheet ---
    _selectionController.getLastSelection(
      lastSelectionBySheet,
      currentSheetName,
    );

    // --- save any correction if needed ---
    if (saveLastOpenedSheetName) {
      await _saveSheetDataUseCase.saveLastOpenedSheetName(currentSheetName);
    }
    if (saveAllSheetNames) {
      await _saveSheetDataUseCase.saveAllSheetNames(sheetNames);
    }
    if (saveLastSelectionBySheet) {
      await _selectionController.saveAllLastSelected(lastSelectionBySheet);
    }
    if (saveCalculationStatusBySheet) {
      _sortController.saveAllSortStatus(sortStatusBySheet);
    }
    await loadSheetByName(currentSheetName, init: true);
    for (var name in sheetNames) {
      if (!sortStatusBySheet[name]!.resultCalculated || !sortStatusBySheet[name]!.validSortCalculated) {
        await loadAnalysisResult(name);
        _sortController.calculate(
          loadedSheetsData[name]!,
          analysisResults,
          lastSelectionBySheet,
          sortStatus,
          name,
          init: true,
        );
      } else if (!sortStatusBySheet[name]!.isFindingBestSort) {
        await loadAnalysisResult(name);
        _sortController.findBestSortToggle(loadedSheetsData[name]!, analysisResults, lastSelectionBySheet, sortStatus, name, _gridController.row1ToScreenBottomHeight, _gridController.colBToScreenRightWidth);
      } else if (!sortStatusBySheet[name]!.isFindingBestSortAndSort) {
        await loadAnalysisResult(name);
        _sortController.findBestSortAndSortToggle(loadedSheetsData[name]!, analysisResults, lastSelectionBySheet, sortStatus, name, _gridController.row1ToScreenBottomHeight, _gridController.colBToScreenRightWidth);
      }
    }
  }

  Future<void> loadAnalysisResult(String name) async {
    try {
      analysisResults[name] = await _getDataUseCase.getAnalysisResult(name);
    } catch (e) {
      logger.e("Error getting analysis result for $name: $e");
      analysisResults[name] = AnalysisResult.empty();
    }
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
        await loadAnalysisResult(name);
      }
    } else {
      loadedSheetsData[name] = SheetData.empty();
      analysisResults[name] = AnalysisResult.empty();
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
      sheet,
      lastSelectionBySheet,
      currentSheetName,
      visibleHeight:
          selection.scrollOffsetX + _gridController.row1ToScreenBottomHeight,
      visibleWidth:
          selection.scrollOffsetY + _gridController.colBToScreenRightWidth,
      notify: false,
    );

    _streamController.scrollToOffset(
      x: selection.scrollOffsetX,
      y: selection.scrollOffsetY,
      animate: true,
    );
    notifyListeners();
  }

  /// Call this when the Controller finishes a calculation.
  /// The Manager takes ownership of updating the tree state.
  void onAnalysisComplete(
    AnalysisResult result,
    Point<int> primarySelectedCell,
  ) {
    // Reset specific roots
    _treeController.updateMentionsRoot(
      primarySelectedCell.x,
      primarySelectedCell.y,
    );
    _treeController.clearSearchRoot();
    _treeController.populateAllTrees(
      selection,
      lastSelectionBySheet,
      sortStatus,
      currentSheetName,
      sheet,
      result,
      rowCount,
      colCount,
    );
  }

  bool canBeSorted() {
    return _sortController.canBeSorted(sheet, result, sortStatus);
  }

  bool sorted() {
    return false;
  }
}
