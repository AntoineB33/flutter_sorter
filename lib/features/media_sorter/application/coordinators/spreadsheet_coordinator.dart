import 'dart:async';

import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/application/state/history_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/sheet_data_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/workbook_controller.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/cell.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/grid_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/sort_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/selection_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/tree_controller.dart';
import 'package:uuid/uuid.dart';
import 'package:rxdart/rxdart.dart';


class SpreadsheetCoordinator {
  final HistoryController historyController;
  final SheetDataController sheetDataController;
  final GridController gridController;
  final SortController sortController;
  final SelectionController selectionController;
  final WorkbookController workbookController;

  SpreadsheetCoordinator(this.historyController, this.sheetDataController, this.gridController, this.sortController, this.selectionController, this.workbookController) {
    init();
  }

  
  Future<void> init() async {
    await workbookController.clearAllData();
    await workbookController.loadRecentSheetIds();
    final loadSheetWait = workbookController.loadSheet(workbookController.currentSheetId, true);
    bool success = await workbookController.loadLastSelection();
    loadSheetWait.then((_) {
      
    });
    notifyListeners();
    workbookUseCase.loadLastSelections(success);
    notifyListeners();
    await sortUseCase.init();
    await workbookController.init();
    for (var sheetId in sortController.getSheetIds()) {
      sortController.launchCalculation(sheetId);
    }
  }

  
  void setPrimarySelection(
    int row,
    int col,
    bool keepSelection,
    bool scrollTo,
  ) {
    selectionController.setPrimarySelection(row, col, keepSelection);
    if (scrollTo) {
      bool saveSelection = gridController.scrollToCell(row, col);
      if (saveSelection) {
        selectionController.saveLastSelection();
      }
    }
  }
}