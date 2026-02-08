import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:trying_flutter/features/media_sorter/core/utility/get_names.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/data/models/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sorting_rule.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/calculation_service.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/sorting_service.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/get_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/layout_calculator.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/parse_paste_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/save_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/manage_waiting_tasks.dart';
import 'package:trying_flutter/features/media_sorter/presentation/constants/page_constants.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/selection_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sort_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/services/spreadsheet_clipboard_service.dart';
import 'package:trying_flutter/features/media_sorter/presentation/utils/get_default_sizes.dart';

class SheetDataController extends ChangeNotifier {
  // --- states ---
  final Map<String, ManageWaitingTasks<void>> _saveExecutors = {};
  void Function(
    UpdateHistory? currentUpdateHistory,
    int col,
    ColumnType prevType,
    ColumnType newType,
  ) recordColumnTypeChange;
  void Function(SheetData sheet) commitHistory;
  void Function(SheetContent sheetContent, int rowCount, int colCount, Function(AnalysisResult, Point<int>) onAnalysisComplete, SelectionData selection) calculate;
  void Function(
    AnalysisResult result,
    Point<int> primarySelectedCell,
  ) onAnalysisComplete;
  void Function(
    SheetData sheet,
    UpdateHistory? currentUpdateHistory,
    int row,
    int col,
    String prevValue,
    String newValue,
    bool onChange,
    bool keepPrevious,
  ) recordCellChange;
  void Function(
    int row,
    int col,
    String newValue,
    String prevValue,
  ) adjustRowHeightAfterUpdate;
  bool Function() canBeSorted;

  
  late final SpreadsheetClipboardService _clipboardService;  
  final ParsePasteDataUseCase _parsePasteDataUseCase = ParsePasteDataUseCase();
  
  int rowCount(SheetContent content) => content.table.length;
  int colCount(SheetContent content) => content.table.isNotEmpty ? content.table[0].length : 0;
      
  final CalculationService calculationService = CalculationService();

  // --- usecases ---
  final SaveSheetDataUseCase _saveSheetDataUseCase;

  // getters
  // SheetData get currentSheet => sheet;
  // Map<String, ManageWaitingTasks<void>> get saveExecutors => _saveExecutors;
  // ManageWaitingTasks<void> get saveLastSelectionExecutor =>
  //     _saveLastSelectionExecutor;
  // SheetContent get sheetContent => sheet.sheetContent;
  // int get rowCount => sheet.sheetContent.table.length;
  // int get colCount => rowCount > 0 ? sheet.sheetContent.table[0].length : 0;
  // ManageWaitingTasks<AnalysisResult> get calculateExecutor =>
  //     _calculateExecutor;

  SheetDataController({
    required GetSheetDataUseCase getDataUseCase,
    required SaveSheetDataUseCase saveSheetDataUseCase,
    required this.recordColumnTypeChange,
    required this.commitHistory,
    required this.calculate,
    required this.onAnalysisComplete,
    required this.recordCellChange,
    required this.adjustRowHeightAfterUpdate,
    required this.canBeSorted,
  }) : _saveSheetDataUseCase = saveSheetDataUseCase;

  void scheduleSheetSave(SheetData sheet, String sheetName, int saveDelayMs) {
    _saveExecutors[sheetName]!.execute(() async {
      await _saveSheetDataUseCase.saveSheet(sheetName, sheet);
      await Future.delayed(Duration(milliseconds: saveDelayMs));
    });
  }

  void createSaveExecutor(String name) {
    _saveExecutors[name] = ManageWaitingTasks<void>();
  }

  void onChanged(SheetData sheet, SelectionData selection, String currentSheetName, String newValue) {
    updateCell(
      sheet,
      selection.primarySelectedCell.x,
      selection.primarySelectedCell.y,
      newValue,
      onChange: true,
    );
    notifyListeners();
    saveAndCalculate(sheet, selection, currentSheetName);
  }

  
  void saveAndCalculate(SheetData sheet, SelectionData selection, String currentSheetName, {bool save = true, bool updateHistory = false}) {
    if (save) {
      if (updateHistory) {
        commitHistory(sheet);
      }
      scheduleSheetSave(sheet, currentSheetName, SpreadsheetConstants.saveDelayMs);
    }
    calculate(
      sheet.sheetContent,
      rowCount(sheet.sheetContent),
      colCount(sheet.sheetContent),
      onAnalysisComplete,
      selection,
    );
  }


  void increaseColumnCount(int col, int rowCount, int colCount, SheetContent sheetContent) {
    if (col >= colCount) {
      final needed = col + 1 - colCount;
      for (var r = 0; r < rowCount; r++) {
        sheetContent.table[r].addAll(List.filled(needed, '', growable: true));
      }
      sheetContent.columnTypes.addAll(
        List.filled(needed, ColumnType.attributes),
      );
    }
  }
  void decreaseRowCount(int row, int rowCount, SheetContent sheetContent) {
    if (row == rowCount - 1) {
      while (row >= 0 &&
          !sheetContent.table[row].any((cell) => cell.isNotEmpty)) {
        sheetContent.table.removeLast();
        row--;
      }
    }
  }
  
  void updateCell(SheetData sheet, int row, int col, String newValue, {
    bool onChange = false,
    bool historyNavigation = false,
    bool keepPrevious = false,
  }) {
    String prevValue = '';
    int rowCount = this.rowCount(sheet.sheetContent);
    int colCount = this.colCount(sheet.sheetContent);
    if (newValue.isNotEmpty || (row < rowCount && col < colCount)) {
      if (row >= rowCount) {
        final needed = row + 1 - rowCount;
        sheet.sheetContent.table.addAll(
          List.generate(
            needed,
            (_) => List.filled(colCount, '', growable: true),
          ),
        );
      }
      increaseColumnCount(col, rowCount, colCount, sheet.sheetContent);
      prevValue = sheet.sheetContent.table[row][col];
      sheet.sheetContent.table[row][col] = newValue;
    }

    // Clean up empty rows/cols at the end
    if (newValue.isEmpty &&
        row < rowCount &&
        col < colCount &&
        (row == rowCount - 1 || col == colCount - 1) &&
        prevValue.isNotEmpty) {
      decreaseRowCount(row, rowCount, sheet.sheetContent);
      if (col == colCount - 1) {
        int colId = col;
        bool canRemove = true;
        while (canRemove && colId >= 0) {
          for (var r = 0; r < rowCount; r++) {
            if (sheet.sheetContent.table[r][colId].isNotEmpty) {
              canRemove = false;
              break;
            }
          }
          if (canRemove) {
            for (var r = 0; r < rowCount; r++) {
              sheet.sheetContent.table[r].removeLast();
            }
            colId--;
          }
        }
      }
    }
    
    if (!historyNavigation) {
      recordCellChange(
        sheet,
        sheet.currentUpdateHistory,
        row,
        col,
        prevValue,
        newValue,
        onChange,
        keepPrevious,
      );
    }

    // Delegate layout calculation to GridManager
    adjustRowHeightAfterUpdate(row, col, newValue, prevValue);
  }


  void setColumnType(SheetData sheet, SelectionData selection, String currentSheetName, int col, ColumnType type, {bool updateHistory = true}) {
    ColumnType previousType = GetNames.getColumnType(
      sheet.sheetContent,
      col,
    );
    if (updateHistory) {
      recordColumnTypeChange(sheet.currentUpdateHistory, col, previousType, type);
    }
    if (type == ColumnType.attributes) {
      if (col < colCount(sheet.sheetContent)) {
        sheet.sheetContent.columnTypes[col] = type;
        if (col == sheet.sheetContent.columnTypes.length - 1) {
          while (col > 0) {
            col--;
            if (sheet.sheetContent.columnTypes[col] !=
                ColumnType.attributes) {
              break;
            }
          }
          sheet.sheetContent.columnTypes = sheet.sheetContent
              .columnTypes
              .sublist(0, col + 1);
        }
      }
    } else {
      increaseColumnCount(col, rowCount(sheet.sheetContent), colCount(sheet.sheetContent), sheet.sheetContent);
      sheet.sheetContent.columnTypes[col] = type;
    }
    notifyListeners();
    saveAndCalculate(sheet, selection, currentSheetName, updateHistory: true);
  }

  Future<void> pasteSelection(SheetData sheet, SelectionData selection, String currentSheetName) async {
    final text = await _clipboardService.getText();
    if (text == null) return;
    // if contains "
    if (text.contains('"')) {
      debugPrint('Paste data contains unsupported characters.');
      return;
    }

    final List<CellUpdate> updates = _parsePasteDataUseCase.pasteText(
      text,
      selection.primarySelectedCell.x,
      selection.primarySelectedCell.y,
    );
    setTable(sheet, selection, currentSheetName, updates);
  }

  void setTable(SheetData sheet, SelectionData selection, String currentSheetName, List<CellUpdate> updates) {
    sheet.currentUpdateHistory = null;
    for (var update in updates) {
      updateCell(sheet, update.row, update.col, update.value, keepPrevious: true);
    }
    notifyListeners();
    saveAndCalculate(sheet, selection, currentSheetName, updateHistory: true);
  }

  void delete(SheetData sheet, SelectionData selection, String currentSheetName) {
    for (Point<int> cell in selection.selectedCells) {
      updateCell(sheet, cell.x, cell.y, '', keepPrevious: true);
    }
    updateCell(
      sheet,
      selection.primarySelectedCell.x,
      selection.primarySelectedCell.y,
      '',
      keepPrevious: true,
    );
    notifyListeners();
    saveAndCalculate(sheet, selection, currentSheetName, updateHistory: true);
  }

  void applyDefaultColumnSequence(SheetData sheet, SelectionData selection, String currentSheetName) {
    setColumnType(sheet, selection, currentSheetName, 1, ColumnType.dependencies);
    setColumnType(sheet, selection, currentSheetName, 2, ColumnType.dependencies);
    setColumnType(sheet, selection, currentSheetName, 3, ColumnType.dependencies);
    setColumnType(sheet, selection, currentSheetName, 7, ColumnType.urls);
    setColumnType(sheet, selection, currentSheetName, 8, ColumnType.dependencies);
  }
  String getCellContent(List<List<String>> table, int row, int col) {
    if (row < table.length && col < table[row].length) {
      return table[row][col];
    }
    return '';
  }
  Future<void> copySelectionToClipboard(SheetData sheet, SelectionData selection, String currentSheetName) async {
    int startRow = selection.primarySelectedCell.x;
    int endRow = selection.primarySelectedCell.x;
    int startCol = selection.primarySelectedCell.y;
    int endCol = selection.primarySelectedCell.y;
    for (Point<int> cell in selection.selectedCells) {
      if (cell.x < startRow) startRow = cell.x;
      if (cell.y < startCol) startCol = cell.y;
      if (cell.x > endRow) endRow = cell.x;
      if (cell.y > endCol) endCol = cell.y;
    }
    List<List<bool>> selectedCellsTable = List.generate(
      endRow - startRow + 1,
      (_) => List.generate(endCol - startCol + 1, (_) => false),
    );
    for (Point<int> cell in selection.selectedCells) {
      selectedCellsTable[cell.x - startRow][cell.y - startCol] = true;
    }
    if (!selectedCellsTable.every((row) => row.every((cell) => !cell))) {
      await _clipboardService.copy(
        getCellContent(
          sheet.sheetContent.table,
          selection.primarySelectedCell.x,
          selection.primarySelectedCell.y,
        ),
      );
      return;
    }

    StringBuffer buffer = StringBuffer();

    for (int r = startRow; r <= endRow; r++) {
      List<String> rowData = [];
      for (int c = startCol; c <= endCol; c++) {
        rowData.add(getCellContent(sheet.sheetContent.table, r, c));
      }
      buffer.write(rowData.join('\t')); // Tab separated for Excel compat
      if (r < endRow) buffer.write('\n');
    }

    final text = buffer.toString();
    await _clipboardService.copy(text);
  }

  bool isRowValid(SheetContent sheetContent, List<bool> isMedium, int rowId) {
    if (canBeSorted()) {
      return isMedium[rowId];
    }
    if (rowId == 0) {
      return false;
    }
    for (int srcColId = 0; srcColId < colCount(sheetContent); srcColId++) {
      if (GetNames.isSourceColumn(sheetContent.columnTypes[srcColId]) && getCellContent(sheetContent.table, rowId, srcColId).isNotEmpty) {
        return true;
      }
    }
    return false;
  }


}
