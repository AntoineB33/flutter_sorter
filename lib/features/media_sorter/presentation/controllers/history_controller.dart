import 'dart:math';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update.dart';


// --- Manager Class ---
class HistoryController {

  HistoryController();

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
  
  /// Clears the temporary history without saving (e.g., cancelled edit)
  void discardCurrent() {
    currentUpdateHistory = null;
  }
}
