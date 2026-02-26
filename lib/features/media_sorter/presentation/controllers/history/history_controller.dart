import 'dart:math';
import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_status.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/loaded_sheets_data_store.dart';

// --- Manager Class ---
class HistoryController extends ChangeNotifier {
  final LoadedSheetsDataStore loadedSheetsDataStore;

  SheetData get currentSheet => loadedSheetsDataStore.currentSheet;
  int rowCount(SheetContent content) => content.table.length;
  int colCount(SheetContent content) =>
      content.table.isNotEmpty ? content.table[0].length : 0;

  HistoryController(this.loadedSheetsDataStore);

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
      CellUpdate(
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
      ColumnTypeUpdate(
        colId: col,
        previousColumnType: prevType,
        newColumnType: newType,
      ),
    );
  }

  List<UpdateData> moveInUpdateHistory(int direction) {
    if (currentSheet.historyIndex < 0 || currentSheet.updateHistories.isEmpty) {
      return [];
    }
    currentSheet.historyIndex += direction;
    final lastUpdate = currentSheet.updateHistories[currentSheet.historyIndex];
    return lastUpdate;
  }
}
