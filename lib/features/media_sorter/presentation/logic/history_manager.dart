import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/spreadsheet_controller.dart';

// --- Models moved here ---
class CellUpdateHistory {
  Point<int> cell;
  String previousValue;
  String newValue;
  CellUpdateHistory({
    required this.cell,
    required this.previousValue,
    required this.newValue,
  });
}

class UpdateHistory {
  static const String updateCellContent = "updateCellContent";
  static const String updateColumnType = "updateColumnType";
  final String key;
  final DateTime timestamp;
  final List<CellUpdateHistory>? updatedCells = [];
  int? colId;
  ColumnType? previousColumnType;
  ColumnType? newColumnType;
  UpdateHistory({
    required this.key,
    required this.timestamp,
    this.colId,
    this.previousColumnType,
    this.newColumnType,
  });
}

// --- Manager Class ---
class HistoryManager {
  final SpreadsheetController controller;
  final int historyMaxLength;

  UpdateHistory? currentUpdateHistory;

  HistoryManager(this.controller, {this.historyMaxLength = 100});

  /// Adds a cell change to the current temporary history object.
  /// Handles the logic for continuous typing (keeping the very first previous value).
  void recordCellChange(
    int row,
    int col,
    String prevValue,
    String newValue, {
    bool isContinuousEdit = false, // correlates to onChange
  }) {
    String actualPreviousValue = prevValue;

    // If we are continuously editing (typing), we want the previous value
    // to remain the value it was BEFORE we started typing, not the previous keystroke.
    if (isContinuousEdit &&
        currentUpdateHistory != null &&
        currentUpdateHistory!.updatedCells!.isNotEmpty) {
      actualPreviousValue =
          currentUpdateHistory!.updatedCells![0].previousValue;
    }

    currentUpdateHistory ??= UpdateHistory(
      key: UpdateHistory.updateCellContent,
      timestamp: DateTime.now(),
    );

    currentUpdateHistory!.updatedCells!.add(
      CellUpdateHistory(
        cell: Point(row, col),
        previousValue: actualPreviousValue,
        newValue: newValue,
      ),
    );
  }

  /// Sets up a history record for a column type change.
  void recordColumnTypeChange(
    int col,
    ColumnType prevType,
    ColumnType newType,
  ) {
    currentUpdateHistory ??= UpdateHistory(
      key: UpdateHistory.updateColumnType,
      timestamp: DateTime.now(),
      colId: col,
      previousColumnType: prevType,
      newColumnType: newType,
    );
  }

  /// Commits the `currentUpdateHistory` to the Sheet's permanent history stack.
  void commit() {
    if (currentUpdateHistory == null) return;

    final sheet = controller.sheet;

    // If we undid some steps and are now doing a new action, remove the "future" history
    if (sheet.historyIndex < sheet.updateHistories.length - 1) {
      sheet.updateHistories = sheet.updateHistories.sublist(
        0,
        sheet.historyIndex + 1,
      );
    }

    sheet.updateHistories.add(currentUpdateHistory!);
    sheet.historyIndex++;

    // Enforce Max Length
    if (sheet.historyIndex == historyMaxLength) {
      sheet.updateHistories.removeAt(0);
      sheet.historyIndex--;
    }

    // Reset current temp history
    currentUpdateHistory = null;
  }

  /// Clears the temporary history without saving (e.g., cancelled edit)
  void discardCurrent() {
    currentUpdateHistory = null;
  }

  void undo() {
    final sheet = controller.sheet;
    if (sheet.historyIndex < 0 || sheet.updateHistories.isEmpty) {
      return;
    }

    final lastUpdate = sheet.updateHistories[sheet.historyIndex];

    if (lastUpdate.key == UpdateHistory.updateCellContent) {
      // Revert cells
      for (var cellUpdate in lastUpdate.updatedCells!) {
        controller.updateCell(
          cellUpdate.cell.x,
          cellUpdate.cell.y,
          cellUpdate.previousValue,
          historyNavigation: true,
        );
      }
    } else if (lastUpdate.key == UpdateHistory.updateColumnType) {
      // Revert column type
      if (lastUpdate.colId != null && lastUpdate.previousColumnType != null) {
        controller.setColumnType(
          lastUpdate.colId!,
          lastUpdate.previousColumnType!,
          updateHistory: false,
        );
      }
    }

    sheet.historyIndex--;
    controller.notify(); // Call public notify method
    controller.saveAndCalculate(save: true, updateHistory: false);
  }

  void redo() {
    final sheet = controller.sheet;
    if (sheet.historyIndex + 1 >= sheet.updateHistories.length) {
      return;
    }

    final nextUpdate = sheet.updateHistories[sheet.historyIndex + 1];

    if (nextUpdate.key == UpdateHistory.updateCellContent) {
      // Re-apply cells
      for (var cellUpdate in nextUpdate.updatedCells!) {
        controller.updateCell(
          cellUpdate.cell.x,
          cellUpdate.cell.y,
          cellUpdate.newValue,
          historyNavigation: true,
        );
      }
    } else if (nextUpdate.key == UpdateHistory.updateColumnType) {
      // Re-apply column type
      if (nextUpdate.colId != null && nextUpdate.newColumnType != null) {
        controller.setColumnType(
          nextUpdate.colId!,
          nextUpdate.newColumnType!,
          updateHistory: false,
        );
      }
    }

    sheet.historyIndex++;
    controller.notify();
    controller.saveAndCalculate(save: true, updateHistory: false);
  }
}