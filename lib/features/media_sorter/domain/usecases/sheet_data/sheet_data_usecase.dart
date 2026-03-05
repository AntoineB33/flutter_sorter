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
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_data_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sort_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/calculation_service.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sheet_data/parse_paste_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sheet_data/save_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/manage_waiting_tasks.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/history_service.dart';
import 'package:trying_flutter/features/media_sorter/data/services/spreadsheet_clipboard_service.dart';
import 'package:trying_flutter/features/media_sorter/data/store/analysis_result_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/selection_cache.dart';

class SheetDataUsecase {
  final SheetDataRepository sheetDataRepository;
  final SortRepository sortRepository;

  Stream<UpdateRequest> get updateDataStream => sortRepository.updateDataStream;
  Stream<void> get sortStatusStream => sortRepository.sortStatusStream;
  String get currentSheetId => sheetDataRepository.currentSheetId;
  int rowCount() => sheetDataRepository.rowCount(currentSheetId);
  int colCount() => sheetDataRepository.colCount(currentSheetId);

  SheetDataUsecase({
    required this.sheetDataRepository,
    required this.sortRepository,
  });

  
  void update(UpdateData updateData) {
    for (var update in updateData.updates) {
      if (update is CellUpdate) {
        updateCell(update);
      } else if (update is ColumnTypeUpdate) {
        setColumnType(update);
      } else {
        throw Exception('Unsupported update type: ${update.runtimeType}');
      }
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

  
  void delete() {
    List<UpdateUnit> updates = [];
    for (Point<int> cell in selection.selectedCells) {
      updates.add(
        CellUpdate(
          cell.x,
          cell.y,
          '',
          loadedSheetsData.getCellContent(cell.x, cell.y),
        ),
      );
    }
    UpdateData updateData = UpdateData(Uuid().v4(), DateTime.now(), updates);
    update(updateData, true);
    notifyListeners();
    scheduleSheetSave(currentSheetName);
    sortService.calculate(currentSheetName);
  }
}
