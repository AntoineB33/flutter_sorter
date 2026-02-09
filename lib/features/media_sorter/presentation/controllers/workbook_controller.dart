import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/file_sheet_local_datasource.dart';
import 'package:trying_flutter/features/media_sorter/data/models/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/data/repositories/sheet_repository_impl.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/get_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/save_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sheet_data_controller.dart';
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

  // Delegates
  final SpreadsheetKeyboardDelegate _keyboardDelegate;

  SelectionData get selection => lastSelectionBySheet[currentSheetName] ?? SelectionData.empty();
  
  int get tableViewRows => selection.tableViewRows;
  int get tableViewCols => selection.tableViewCols;
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
    _treeController.toggleNodeExpansion(sheet, result, selection, lastSelectionBySheet, currentSheetName, node, isExpanded);
  }

  void sortMedia() {
    _sortController.calculate(sheet, selection, lastSelectionBySheet, currentSheetName);
  }

  void findBestSortToggle() {
    _sortController.findBestSortToggle(sheet, result, selection, lastSelectionBySheet, currentSheetName);
  }

  double getTargetTop(int row) {
    return _gridController.getTargetTop(sheet, row);
  }
  double getTargetLeft(int col) {
    return _gridController.getTargetLeft(sheet, col);
  }

  void updateRowColCount({
    double ? visibleHeight,
    double ? visibleWidth,
    bool notify = true,
    bool save = true,}) {
    _selectionController.updateRowColCount(
      sheet,
      selection,
      lastSelectionBySheet,
      currentSheetName,
      visibleHeight: visibleHeight,
      visibleWidth: visibleWidth,
      notify: notify,
      save: save,
    );
  }

  void saveLastSelection() {
    _selectionController.saveLastSelection(lastSelectionBySheet, currentSheetName);
  }

  KeyEventResult handleKeyboard(BuildContext context, KeyEvent event) {
    return _keyboardDelegate.handle(context, event, selection, selection.editingMode, sheet, lastSelectionBySheet, _gridController.row1ToScreenBottomHeight, _gridController.colBToScreenRightWidth, currentSheetName);
  }

  double getRowHeight(int row) {
    return _gridController.getRowHeight(sheet, row);
  }

  void selectAll() {
    _selectionController.selectAll(selection, lastSelectionBySheet, currentSheetName, rowCount, colCount);
  }

  bool isCellEditing(int row, int col) {
    return _selectionController.isCellEditing(selection, row, col);
  }

  String getCellContent(int row, int col) {
    return _dataController.getCellContent(sheet.sheetContent.table, row, col);
  }

  bool isRowValid(int row) {
    return _gridController.isRowValid(sheet.sheetContent, result.isMedium, row);
  }

  bool isPrimarySelectedCell(int row, int col) {
    return _selectionController.isPrimarySelectedCell(selection, row, col);
  }

  bool isCellSelected(int row, int col) {
    return _selectionController.isCellSelected(selection, row, col);
  }

  void stopEditing({bool updateHistory = true, bool notify = true}) {
    _selectionController.stopEditing(sheet, selection, lastSelectionBySheet, currentSheetName);
  }

  void setPrimarySelection(int row, int col, bool keepSelection, bool scrollTo) {
    _selectionController.setPrimarySelection(selection, lastSelectionBySheet, currentSheetName, row, col, keepSelection, scrollTo: scrollTo);
  }

  void startEditing({String? initialInput}) {
    _selectionController.startEditing(sheet, selection, lastSelectionBySheet, currentSheetName, _gridController.row1ToScreenBottomHeight, _gridController.colBToScreenRightWidth, initialInput: initialInput);
  }

  void onChanged(String newValue) {
    _selectionController.onChanged(sheet, selection, lastSelectionBySheet, _gridController.row1ToScreenBottomHeight, _gridController.colBToScreenRightWidth, currentSheetName, newValue);
  }

  void updateCell(int row, int col, String newValue) {
    _dataController.updateCell(sheet, selection, lastSelectionBySheet, _gridController.row1ToScreenBottomHeight, _gridController.colBToScreenRightWidth, currentSheetName, row, col, newValue);
  }

  void setColumnType(int col, ColumnType type) {
    _dataController.setColumnType(sheet, selection, lastSelectionBySheet, currentSheetName, col, type);
  }

  void applyDefaultColumnSequence() {
    _dataController.applyDefaultColumnSequence(sheet, selection, lastSelectionBySheet, currentSheetName);
  }

  WorkbookController(
    this._gridController,
    this._historyController,
    this._selectionController,
    this._dataController,
    this._treeController,
    this._streamController,
    this._sortController,
    this._keyboardDelegate,
  ) {
    _gridController.updateRowColCount = _selectionController.updateRowColCount;
    _gridController.canBeSorted = _sortController.canBeSorted;
    _gridController.getCellContent = _dataController.getCellContent;
    _historyController.updateCell = _dataController.updateCell;
    _historyController.setColumnType = _dataController.setColumnType;
    _historyController.saveAndCalculate = _dataController.saveAndCalculate;
    _selectionController.commitHistory = _historyController.commitHistory;
    _selectionController.discardPendingChanges = _historyController.discardPendingChanges;
    _selectionController.onChanged = _dataController.onChanged;
    _selectionController.updateMentionsContext = _treeController.updateMentionsRoot;
    _selectionController.triggerScrollTo = _streamController.triggerScrollTo;
    _selectionController.getNewRowColCount = _gridController.getNewRowColCount;
    _dataController.recordColumnTypeChange = _historyController.recordColumnTypeChange;
    _dataController.commitHistory = _historyController.commitHistory;
    _dataController.calculate = _sortController.calculate;
    _dataController.onAnalysisComplete = onAnalysisComplete;
    _dataController.recordCellChange = _historyController.recordCellChange;
    _dataController.adjustRowHeightAfterUpdate = _gridController.adjustRowHeightAfterUpdate;
    _sortController.stopEditing = _selectionController.stopEditing;
    _sortController.setTable = _dataController.setTable;
    _sortController.onAnalysisComplete = onAnalysisComplete;
    _keyboardDelegate.startEditing = _selectionController.startEditing;
    _keyboardDelegate.setPrimarySelection = _selectionController.setPrimarySelection;
    _keyboardDelegate.copySelectionToClipboard = _dataController.copySelectionToClipboard;
    _keyboardDelegate.pasteSelection = _dataController.pasteSelection;
    _keyboardDelegate.delete = _dataController.delete;
    _keyboardDelegate.undo = _historyController.undo;
    _keyboardDelegate.redo = _historyController.redo;
    _treeController.onCellSelected = _selectionController.setPrimarySelection;
    _treeController.getCellContent = _dataController.getCellContent;

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
    if (lastOpenedSheetName != null && !CheckValidStrings.isValidSheetName(lastOpenedSheetName)) {
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
      if (!CheckValidStrings.isValidSheetName(name)) {
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

    _dataController.saveAndCalculate(sheet, selection, lastSelectionBySheet, currentSheetName, save: false);
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
    _treeController.populateAllTrees(selection, lastSelectionBySheet, currentSheetName, sheet, result, rowCount, colCount);
  }
}
