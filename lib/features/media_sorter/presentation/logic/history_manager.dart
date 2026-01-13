import 'dart:math';
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

class ColumnTypeUpdateHistory {
  int? colId;
  ColumnType? previousColumnType;
  ColumnType? newColumnType;
  ColumnTypeUpdateHistory({
    required this.colId,
    required this.previousColumnType,
    required this.newColumnType,
  });
}

class UpdateHistory {
  static const String updateCellContent = "updateCellContent";
  static const String updateColumnType = "updateColumnType";
  final String key;
  final DateTime timestamp;
  final List<CellUpdateHistory>? updatedCells = [];
  final List<ColumnTypeUpdateHistory>? updatedColumnTypes = [];
  UpdateHistory({
    required this.key,
    required this.timestamp
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
    String newValue,
    bool onChange,
    bool keepPrevious,
  ) {
    String previousValue = onChange && currentUpdateHistory != null
        ? currentUpdateHistory!.updatedCells![0].previousValue
        : prevValue;
    if (!keepPrevious) {
      discardCurrent();
    }
    currentUpdateHistory ??= UpdateHistory(
      key: UpdateHistory.updateCellContent,
      timestamp: DateTime.now(),
    );
    currentUpdateHistory!.updatedCells!.add(
      CellUpdateHistory(
        cell: Point(row, col),
        previousValue: previousValue,
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
    );
    currentUpdateHistory!.updatedColumnTypes!.add(
      ColumnTypeUpdateHistory(
        colId: col,
        previousColumnType: prevType,
        newColumnType: newType,
      ),
    );
  }

  /// Commits the `currentUpdateHistory` to the Sheet's permanent history stack.
  void commit() {
    final sheet = controller.sheet;
    if (sheet.historyIndex < sheet.updateHistories.length - 1) {
      sheet.updateHistories = sheet.updateHistories.sublist(
        0,
        sheet.historyIndex + 1,
      );
    }
    sheet.updateHistories.add(currentUpdateHistory!);
    sheet.historyIndex++;
    if (sheet.historyIndex == historyMaxLength) {
      sheet.updateHistories.removeAt(0);
      sheet.historyIndex--;
    }
    discardCurrent();
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
      for (var cellUpdate in lastUpdate.updatedCells!) {
        controller.updateCell(
          cellUpdate.cell.x,
          cellUpdate.cell.y,
          cellUpdate.previousValue,
          historyNavigation: true,
        );
      }
    } else if (lastUpdate.key == UpdateHistory.updateColumnType) {
      for (var typeUpdate in lastUpdate.updatedColumnTypes!) {
        controller.setColumnType(
          typeUpdate.colId!,
          typeUpdate.previousColumnType!,
          updateHistory: false,
        );
      }
    }
    sheet.historyIndex--;
    controller.notify(); // Call public notify method
    controller.saveAndCalculate();
  }

  void redo() {
    final sheet = controller.sheet;
    if (sheet.historyIndex + 1 == sheet.updateHistories.length) {
      return;
    }
    final nextUpdate = sheet.updateHistories[sheet.historyIndex + 1];
    if (nextUpdate.key == UpdateHistory.updateCellContent) {
      for (var cellUpdate in nextUpdate.updatedCells!) {
        controller.updateCell(
          cellUpdate.cell.x,
          cellUpdate.cell.y,
          cellUpdate.newValue,
          historyNavigation: true,
        );
      }
    } else if (nextUpdate.key == UpdateHistory.updateColumnType) {
      for (var typeUpdate in nextUpdate.updatedColumnTypes!) {
        controller.setColumnType(
          typeUpdate.colId!,
          typeUpdate.newColumnType!,
          updateHistory: false,
        );
      }
    }
    sheet.historyIndex++;
    controller.notify();
    controller.saveAndCalculate();
  }
}