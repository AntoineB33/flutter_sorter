import 'dart:math';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update.dart';


// --- Manager Class ---
class HistoryController {

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
    UpdateHistory? currentUpdateHistory,
    int row,
    int col,
    String prevValue,
    String newValue,
    bool onChange,
    bool keepPrevious,
  ) {
    String previousValue = onChange && currentUpdateHistory != null
        ? currentUpdateHistory.updatedCells![0].previousValue
        : prevValue;
    if (!keepPrevious) {
      sheet.currentUpdateHistory = null;
    }
    currentUpdateHistory ??= UpdateHistory(
      key: UpdateHistory.updateCellContent,
      timestamp: DateTime.now(),
    );
    currentUpdateHistory.updatedCells!.add(
      CellUpdateHistory(
        cell: Point(row, col),
        previousValue: previousValue,
        newValue: newValue,
      ),
    );
  }

  /// Sets up a history record for a column type change.
  void recordColumnTypeChange(
    UpdateHistory? currentUpdateHistory,
    int col,
    ColumnType prevType,
    ColumnType newType,
  ) {
    currentUpdateHistory ??= UpdateHistory(
      key: UpdateHistory.updateColumnType,
      timestamp: DateTime.now(),
    );
    currentUpdateHistory.updatedColumnTypes!.add(
      ColumnTypeUpdateHistory(
        colId: col,
        previousColumnType: prevType,
        newColumnType: newType,
      ),
    );
  }
}
