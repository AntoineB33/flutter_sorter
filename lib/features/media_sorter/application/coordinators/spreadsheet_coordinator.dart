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
import 'package:trying_flutter/features/media_sorter/presentation/models/scroll_request.dart';
import 'package:uuid/uuid.dart';
import 'package:rxdart/rxdart.dart';


class SpreadsheetCoordinator {
  final HistoryController historyController;
  final SheetDataController sheetDataController;
  final GridController gridController;
  final SortController sortController;
  final SelectionController selectionController;
  final WorkbookController workbookController;
  final TreeController treeController;

  SpreadsheetCoordinator(this.historyController, this.sheetDataController, this.gridController, this.sortController, this.selectionController, this.workbookController, this.treeController) {
    init();
  }

  
  Future<void> init() async {
    await workbookController.clearAllData();
    await workbookController.loadRecentSheetIds();
    bool success = await loadSheet(workbookController.currentSheetId, true);
    workbookController.loadLastSelections(success);
    sortController.init();
    for (var sheetId in sortController.getSheetIds()) {
      launchCalculation(sheetId);
    }
  }

  Future<bool> loadSheet(String sheetId, bool init) async {
    if (sheetDataController.isLoaded(sheetId)) {
      sortController.loadAnalysisResult(sheetId).then((_) {
        treeController.onAnalysisAvailable(sheetId);
      });
    }
    await workbookController.loadSheet(sheetId, init);
    bool success = await workbookController.loadLastSelection();
    gridController.scrollToLastSelection();
    return success;
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

  void applyUpdates(
    List<UpdateUnit> updates,
    String sheetId,
    bool isFromHistory,
  ) {
    sortController.applyUpdatesNoSort(updates, sheetId, isFromHistory);
    sortController.lightCalculations(sheetId);
    launchCalculation(sheetId);
  }

  Future<void> launchCalculation(String sheetId) async {
    if (!sortController.getAnalysisDone(sheetId)) {
      await sortController.analyze(sheetId);
    }
    return sortController.launchCalculation(sheetId);
  }
}