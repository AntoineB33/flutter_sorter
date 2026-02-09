import 'dart:math';
import 'package:trying_flutter/features/media_sorter/data/datasources/file_sheet_local_datasource.dart';
import 'package:trying_flutter/features/media_sorter/data/models/selection_data.dart';
import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/data/repositories/sheet_repository_impl.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/get_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/manage_waiting_tasks.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/save_sheet_data_usecase.dart';

class SelectionController extends ChangeNotifier {
  final ManageWaitingTasks<void> _saveLastSelectionExecutor =
      ManageWaitingTasks<void>();
  late void Function(SheetData sheet) commitHistory;
  late void Function(SheetData sheet) discardPendingChanges;
  late void Function(SheetData sheet, SelectionData selection, Map<String, SelectionData> lastSelectionBySheet, double row1ToScreenBottomHeight, double colBToScreenRightWidth, String currentSheetName, String newValue) onChanged;
  late String Function(List<List<String>> table, int row, int col) getCellContent;
  late void Function(int, int) updateMentionsContext;
  late void Function(int row, int col) triggerScrollTo;
  late (int, int) Function(SelectionData selection, SheetData sheet, int rowCount, int colCount,
    double? visibleHeight,
    double? visibleWidth,) getNewRowColCount;

  final GetSheetDataUseCase _getDataUseCase = GetSheetDataUseCase(
    SheetRepositoryImpl(FileSheetLocalDataSource()),
  );
  final SaveSheetDataUseCase _saveSheetDataUseCase = SaveSheetDataUseCase(
    SheetRepositoryImpl(FileSheetLocalDataSource()),
  );

  // --- getters ---
  // List<Point<int>> get selectedCells => selection.selectedCells;
  // Point<int> get primarySelectedCell => selection.primarySelectedCell;
  // double get scrollOffsetX => selection.scrollOffsetX;
  // double get scrollOffsetY => selection.scrollOffsetY;
  // int get tableViewRows => selection.tableViewRows;
  // int get tableViewCols => selection.tableViewCols;
  // bool get editingMode => selection.editingMode;

  // --- setters ---
  // set primarySelectedCell(Point<int> cell) {
  //   selection.primarySelectedCell = cell;
  // }

  // set scrollOffsetX(double offset) {
  //   selection.scrollOffsetX = offset;
  // }

  // set scrollOffsetY(double offset) {
  //   selection.scrollOffsetY = offset;
  // }

  // set tableViewRows(int rows) {
  //   selection.tableViewRows = rows;
  // }

  // set tableViewCols(int cols) {
  //   selection.tableViewCols = cols;
  // }

  // set previousContent(String content) {
  //   selection.previousContent = content;
  // }

  // set editingMode(bool isEditing) {
  //   selection.editingMode = isEditing;
  // }
  
  int rowCount(SheetContent content) => content.table.length;
  int colCount(SheetContent content) => content.table.isNotEmpty ? content.table[0].length : 0;

  SelectionController();

  Future<Map<String, SelectionData>> getAllLastSelected() async {
    try {
      return await _getDataUseCase.getAllLastSelected();
    } catch (e) {
      debugPrint("Error getting all last selected cells: $e");
      return {};
    }
  }


  void updateRowColCount(SheetData sheet, SelectionData selection, Map<String, SelectionData> lastSelectionBySheet, String currentSheetName, {
    double ? visibleHeight,
    double ? visibleWidth,
    bool notify = true,
    bool save = true,}) {
    var (targetRows, targetCols) = getNewRowColCount(
      selection,
      sheet,
      rowCount(sheet.sheetContent),
      colCount(sheet.sheetContent),
      visibleHeight,
      visibleWidth,
    );
    if (targetRows != selection.tableViewRows ||
        targetCols != selection.tableViewCols) {
      selection.tableViewRows = targetRows;
      selection.tableViewCols = targetCols;
      if (notify) {
        notifyListeners();
      }
    }
    if (save) {
      saveLastSelection(lastSelectionBySheet, currentSheetName);
    }
  }

  bool completeMissing(Map<String, SelectionData> lastSelectionBySheet, List<String> sheetNames) {
    bool saveLastSelectionBySheet = false;
    for (var name in sheetNames) {
      if (!lastSelectionBySheet.containsKey(name)) {
        lastSelectionBySheet[name] = SelectionData.empty();
        saveLastSelectionBySheet = true;
        debugPrint(
          "No last selection saved for sheet $name",
        );
      }
    }
    return saveLastSelectionBySheet;
  }

  Future<void> getLastSelection(Map<String, SelectionData> lastSelectionBySheet, String sheetName) async {
    try {
      lastSelectionBySheet[sheetName] = await _getDataUseCase.getLastSelection();
    } catch (e) {
      debugPrint("Error getting last selection for current sheet: $e");
      lastSelectionBySheet[sheetName] = SelectionData.empty();
    }
  }

  void clearLastSelection(Map<String, SelectionData> lastSelectionBySheet, String sheetName) {
    lastSelectionBySheet[sheetName] = SelectionData.empty();
  }

  void saveAllLastSelected(Map<String, SelectionData> lastSelectionBySheet) {
    _saveSheetDataUseCase.saveAllLastSelected(
      lastSelectionBySheet,
    );
  }

  Future<void> saveLastSelection(Map<String, SelectionData> lastSelectionBySheet, String sheetName) async {
    _saveLastSelectionExecutor.execute(() async {
      await _saveSheetDataUseCase.saveLastSelection(
        lastSelectionBySheet[sheetName]!,
      );
      await Future.delayed(
        Duration(milliseconds: SpreadsheetConstants.saveDelayMs),
      );
    });
  }

  bool isCellSelected(SelectionData selection, int row, int col) {
    return selection.selectedCells.any((cell) => cell.x == row && cell.y == col);
  }

  bool isPrimarySelectedCell(SelectionData selection, int row, int col) {
    return row == selection.primarySelectedCell.x && col == selection.primarySelectedCell.y;
  }

  bool isCellEditing(SelectionData selection, int row, int col) =>
      selection.editingMode &&
      selection.primarySelectedCell.x == row &&
      selection.primarySelectedCell.y == col;

      
  void setPrimarySelection(
    SelectionData selection,
    Map<String, SelectionData> lastSelectionBySheet,
    String currentSheetName,
    int row,
    int col,
    bool keepSelection, {
    bool scrollTo = true,
  }) {
    if (!keepSelection) {
      selection.selectedCells.clear();
    }
    selection.primarySelectedCell = Point(row, col);
    saveLastSelection(lastSelectionBySheet, currentSheetName);

    updateMentionsContext(row, col);

    // Request scroll to visible
    if (scrollTo) {
      triggerScrollTo(row, col);
    }
    notifyListeners();
  }

  void stopEditing(SheetData sheet, SelectionData selection, Map<String, SelectionData> lastSelectionBySheet, String currentSheetName, {bool updateHistory = true, bool notify = true}) {
    selection.editingMode = false;
    saveLastSelection(lastSelectionBySheet, currentSheetName);
    if (notify) {
      notifyListeners();
    }
    if (updateHistory && sheet.currentUpdateHistory != null) {
      commitHistory(sheet);
    } else {
      discardPendingChanges(sheet);
    }
  }

  void startEditing(SheetData sheet, SelectionData selection, Map<String, SelectionData> lastSelectionBySheet, String currentSheetName, double row1ToScreenBottomHeight, double colBToScreenRightWidth, {String? initialInput}) {
    selection.previousContent = getCellContent(sheet.sheetContent.table,
      selection.primarySelectedCell.x,
      selection.primarySelectedCell.y,
    );
    if (initialInput != null) {
      onChanged(sheet, selection, lastSelectionBySheet, row1ToScreenBottomHeight, colBToScreenRightWidth, currentSheetName, initialInput);
    }
    selection.editingMode = true;
    saveLastSelection(lastSelectionBySheet, currentSheetName);
    notifyListeners();
  }
  
  void selectAll(SelectionData selection, Map<String, SelectionData> lastSelectionBySheet, String currentSheetName, int rowCount, int colCount) {
    selection.selectedCells.clear();
    for (int r = 0; r < rowCount; r++) {
      for (int c = 0; c < colCount; c++) {
        selection.selectedCells.add(Point(r, c));
      }
    }
    setPrimarySelection(selection, lastSelectionBySheet, currentSheetName, 0, 0, true);
  }
}
