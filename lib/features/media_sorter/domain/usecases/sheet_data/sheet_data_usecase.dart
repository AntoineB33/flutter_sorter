import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/core/utility/get_names.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_status.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/calculation_service.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sheet_data/parse_paste_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sheet_data/save_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/manage_waiting_tasks.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/history_service.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sort/sort_service.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/services/spreadsheet_clipboard_service.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/analysis_data_store.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/loaded_sheets_data_store.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/selection_data_store.dart';

class SheetDataUsecase {
  final LoadedSheetsDataStore loadedSheetsData;
  final HistoryService historyService;

  SheetData get currentSheet => loadedSheetsData.currentSheet;
  String get currentSheetName => loadedSheetsData.currentSheetId;
  int rowCount(SheetContent content) => content.table.length;
  int colCount(SheetContent content) =>
      content.table.isNotEmpty ? content.table[0].length : 0;

  SheetDataUsecase({
    required this.loadedSheetsData,
    required this.historyService,
  });

  void update(UpdateData updateData, bool updateHistory) {
    for (var update in updateData.updates) {
      if (update is CellUpdate) {
        updateCell(update);
      } else if (update is ColumnTypeUpdate) {
        setColumnType(update);
      } else {
        throw Exception('Unsupported update type: ${update.runtimeType}');
      }
    }
    if (updateHistory) {
      historyService.commitHistory(updateData);
    }
  }

  void increaseColumnCount(int col, SheetContent sheetContent) {
    if (col >= colCount(sheetContent)) {
      final needed = col + 1 - colCount(sheetContent);
      for (var r = 0; r < rowCount(sheetContent); r++) {
        sheetContent.table[r].addAll(List.filled(needed, '', growable: true));
      }
      sheetContent.columnTypes.addAll(
        List.filled(needed, ColumnType.attributes),
      );
    }
  }

  void setColumnType(ColumnTypeUpdate update) {
    int col = update.colId;
    ColumnType type = update.newColumnType;
    if (type == ColumnType.attributes) {
      if (col < colCount(currentSheet.sheetContent)) {
        currentSheet.sheetContent.columnTypes[col] = type;
        if (col == currentSheet.sheetContent.columnTypes.length - 1) {
          while (col > 0) {
            col--;
            if (currentSheet.sheetContent.columnTypes[col] !=
                ColumnType.attributes) {
              break;
            }
          }
          currentSheet.sheetContent.columnTypes = currentSheet
              .sheetContent
              .columnTypes
              .sublist(0, col + 1);
        }
      }
    } else {
      increaseColumnCount(col, currentSheet.sheetContent);
      currentSheet.sheetContent.columnTypes[col] = type;
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

  void updateCell(
    CellUpdate update, {
    bool onChange = false,
    bool historyNavigation = false,
    bool keepPrevious = false,
  }) {
    String prevValue = '';
    SheetContent sheetContent = currentSheet.sheetContent;
    int row = update.rowId;
    int col = update.colId;
    String newValue = update.newValue;
    if (newValue.isNotEmpty ||
        (row < rowCount(sheetContent) && col < colCount(sheetContent))) {
      if (row >= rowCount(sheetContent)) {
        final needed = row + 1 - rowCount(sheetContent);
        sheetContent.table.addAll(
          List.generate(
            needed,
            (_) => List.filled(colCount(sheetContent), '', growable: true),
          ),
        );
      }
      increaseColumnCount(col, sheetContent);
      prevValue = sheetContent.table[row][col];
      sheetContent.table[row][col] = newValue;
    }

    // Clean up empty rows/cols at the end
    if (newValue.isEmpty &&
        row < rowCount(sheetContent) &&
        col < colCount(sheetContent) &&
        (row == rowCount(sheetContent) - 1 ||
            col == colCount(sheetContent) - 1) &&
        prevValue.isNotEmpty) {
      decreaseRowCount(row, rowCount(sheetContent), sheetContent);
      if (col == colCount(sheetContent) - 1) {
        int colId = col;
        bool canRemove = true;
        while (canRemove && colId >= 0) {
          for (var r = 0; r < rowCount(sheetContent); r++) {
            if (sheetContent.table[r][colId].isNotEmpty) {
              canRemove = false;
              break;
            }
          }
          if (canRemove) {
            for (var r = 0; r < rowCount(sheetContent); r++) {
              sheetContent.table[r].removeLast();
            }
            colId--;
          }
        }
      }
    }
  }
}
