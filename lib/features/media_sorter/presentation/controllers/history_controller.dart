import 'dart:math';
import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_status.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update.dart';

// --- Manager Class ---
class HistoryController extends ChangeNotifier {
  int rowCount(SheetContent content) => content.table.length;
  int colCount(SheetContent content) =>
      content.table.isNotEmpty ? content.table[0].length : 0;

  HistoryController();

  void discardPendingChanges(SheetData sheet) {
    sheet.currentUpdateHistory = null;
  }

  /// Commits the `currentUpdateHistory` to the Sheet's permanent history stack.
  void commitHistory(SheetData sheet) {
    if (sheet.historyIndex < sheet.updateHistories.length - 1) {
      sheet.updateHistories = sheet.updateHistories.sublist(
        0,
        sheet.historyIndex + 1,
      );
    }
    sheet.updateHistories.add(sheet.currentUpdateHistory!);
    sheet.historyIndex++;
    if (sheet.historyIndex == SpreadsheetConstants.historyMaxLength) {
      sheet.updateHistories.removeAt(0);
      sheet.historyIndex--;
    }
    sheet.currentUpdateHistory = null;
  }

  /// Adds a cell change to the current temporary history object.
  /// Handles the logic for continuous typing (keeping the very first previous value).
  void recordCellChange(
    SheetData sheet,
    int row,
    int col,
    String prevValue,
    String newValue,
    bool onChange,
    bool keepPrevious,
  ) {
    String previousValue = onChange && sheet.currentUpdateHistory != null
        ? sheet.currentUpdateHistory!.updatedCells![0].previousValue
        : prevValue;
    if (!keepPrevious) {
      sheet.currentUpdateHistory = null;
    }
    sheet.currentUpdateHistory ??= UpdateHistory(
      key: UpdateHistory.updateCellContent,
      timestamp: DateTime.now(),
    );
    sheet.currentUpdateHistory!.updatedCells!.add(
      CellUpdateHistory(
        cell: Point(row, col),
        previousValue: previousValue,
        newValue: newValue,
      ),
    );
  }

  /// Sets up a history record for a column type change.
  void recordColumnTypeChange(
    SheetData sheet,
    int col,
    ColumnType prevType,
    ColumnType newType,
  ) {
    sheet.currentUpdateHistory ??= UpdateHistory(
      key: UpdateHistory.updateColumnType,
      timestamp: DateTime.now(),
    );
    sheet.currentUpdateHistory!.updatedColumnTypes!.add(
      ColumnTypeUpdateHistory(
        colId: col,
        previousColumnType: prevType,
        newColumnType: newType,
      ),
    );
  }

  void undo(
    SheetData sheet,
    Map<String, AnalysisResult> analysisResults,
    SelectionData selection,
    Map<String, SelectionData> lastSelectionBySheet,
    SortStatus sortStatus,
    String currentSheetName,
    double row1ToScreenBottomHeight,
    double colBToScreenRightWidth,
  ) {
    if (sheet.historyIndex < 0 || sheet.updateHistories.isEmpty) {
      return;
    }
    final lastUpdate = sheet.updateHistories[sheet.historyIndex];
    if (lastUpdate.key == UpdateHistory.updateCellContent) {
      for (var cellUpdate in lastUpdate.updatedCells!) {
        updateCell(
          sheet,
          lastSelectionBySheet,
          row1ToScreenBottomHeight,
          colBToScreenRightWidth,
          currentSheetName,
          cellUpdate.cell.x,
          cellUpdate.cell.y,
          cellUpdate.previousValue,
          historyNavigation: true,
        );
      }
    } else if (lastUpdate.key == UpdateHistory.updateColumnType) {
      for (var typeUpdate in lastUpdate.updatedColumnTypes!) {
        setColumnType(
          sheet,
          analysisResults,
          lastSelectionBySheet,
          sortStatus,
          currentSheetName,
          typeUpdate.colId!,
          typeUpdate.previousColumnType!,
          updateHistory: false,
        );
      }
    }
    sheet.historyIndex--;
    notifyListeners();
    saveAndCalculate(
      sheet,
      analysisResults,
      lastSelectionBySheet,
      sortStatus,
      currentSheetName,
    );
  }

  void redo(
    SheetData sheet,
    Map<String, AnalysisResult> analysisResults,
    SelectionData selection,
    Map<String, SelectionData> lastSelectionBySheet,
    SortStatus sortStatus,
    String currentSheetName,
    double row1ToScreenBottomHeight,
    double colBToScreenRightWidth,
  ) {
    if (sheet.historyIndex + 1 == sheet.updateHistories.length) {
      return;
    }
    final nextUpdate = sheet.updateHistories[sheet.historyIndex + 1];
    if (nextUpdate.key == UpdateHistory.updateCellContent) {
      for (var cellUpdate in nextUpdate.updatedCells!) {
        updateCell(
          sheet,
          lastSelectionBySheet,
          row1ToScreenBottomHeight,
          colBToScreenRightWidth,
          currentSheetName,
          cellUpdate.cell.x,
          cellUpdate.cell.y,
          cellUpdate.newValue,
          historyNavigation: true,
        );
      }
    } else if (nextUpdate.key == UpdateHistory.updateColumnType) {
      for (var typeUpdate in nextUpdate.updatedColumnTypes!) {
        setColumnType(
          sheet,
          analysisResults,
          lastSelectionBySheet,
          sortStatus,
          currentSheetName,
          typeUpdate.colId!,
          typeUpdate.newColumnType!,
          updateHistory: false,
        );
      }
    }
    sheet.historyIndex++;
    notifyListeners();
    saveAndCalculate(
      sheet,
      analysisResults,
      lastSelectionBySheet,
      sortStatus,
      currentSheetName,
    );
  }
}
