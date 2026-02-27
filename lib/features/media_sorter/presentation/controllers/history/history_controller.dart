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
  List<UpdateData> get currentHistory => currentSheet.updateHistories;
  int rowCount(SheetContent content) => content.table.length;
  int colCount(SheetContent content) =>
      content.table.isNotEmpty ? content.table[0].length : 0;

  HistoryController(this.loadedSheetsDataStore);

  UpdateData? moveInUpdateHistory(int direction) {
    if (currentSheet.historyIndex + direction < 0 || currentSheet.historyIndex + direction >= currentSheet.updateHistories.length) {
      return null;
    }
    currentSheet.historyIndex += direction;
    return currentSheet.updateHistories[currentSheet.historyIndex];
  }
}
