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
import 'package:trying_flutter/utils/logger.dart';
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

  SpreadsheetCoordinator(
    this.historyController,
    this.sheetDataController,
    this.gridController,
    this.sortController,
    this.selectionController,
    this.workbookController,
    this.treeController,
  ) {
    init();
  }

  Future<void> init() async {
    await workbookController.clearAllData();
    await workbookController.loadRecentSheetIds();
    bool lastSelectionSuccess = await loadSheet(workbookController.currentSheetId, true);
    workbookController.loadLastSelections(lastSelectionSuccess);
    sortController.loadSortStatus();
    for (var sheetId in sortController.getRecentSheetIds()) {
      launchCalculation(sheetId);
    }
  }

  Future<bool> loadSheet(String sheetId, bool init) async {
    if (!sheetDataController.isLoaded(sheetId)) {
      sortController.loadAnalysisResult(sheetId).then((_) {
        treeController.onAnalysisAvailable();
      });
    }
    selectionController.stopEditing('', false);
    await workbookController.loadSheet(sheetId, init);
    if (!init) {
      selectionController.sheetSwitched();
    }
    bool lastSelectionSuccess = await selectionController.loadLastSelection();
    gridController.scrollToLastSelection();
    return lastSelectionSuccess;
  }

  void setPrimarySelection(
    int row,
    int col,
    bool keepSelection,
    bool scrollTo,
  ) {
    selectionController.setPrimarySelection(row, col, keepSelection);
    if (scrollTo) {
      gridController.scrollToCell(row, col);
    }
    selectionController.saveLastSelection();
    treeController.updateMentionsContext(row, col);
  }

  void delete() {
    setCellContent('');
  }

  void setCellContent(String newValue) {
    String sheetId = workbookController.currentSheetId;
    final primarySelectedCell = selectionController
        .getSelectionData(sheetId)
        .primarySelectedCell;
    int rowId = primarySelectedCell.x;
    int colId = primarySelectedCell.y;
    String prevValue = sheetDataController.getCellContent(
      rowId,
      colId,
      sheetId,
    );
    final updates = [CellUpdate(rowId, colId, newValue, prevValue)];
    applyUpdatesAndSort(updates, sheetId, false, false);
  }

  void applyUpdatesAndSort(
    List<UpdateUnit> updates,
    String sheetId,
    bool isFromHistory,
    bool isFromSort,
  ) {
    applyUpdatesNoSort(updates, sheetId, isFromHistory);
    if (!isFromSort) {
      sortController.lightCalculations(sheetId);
    }
    launchCalculation(sheetId);
  }

  void applyUpdatesNoSort(
    List<UpdateUnit> updates,
    String sheetId,
    bool isFromHistory,
  ) {
    sortController.applyUpdatesNoSort(updates, sheetId, isFromHistory);
  }

  Future<void> launchCalculation(String sheetId) async {
    if (!sortController.getAnalysisDone(sheetId)) {
      await sortController.analyze(sheetId);
    }
    return sortController.launchCalculation(sheetId);
  }
  
  void onTap(NodeStruct node) {
    switch (node.idOnTap) {
      case OnTapAction.selectAttribute:
        treeController.onTapCellSelect(node);
        break;
      case OnTapAction.selectCell:
        if (node.rowId != null && node.colId != null) {
          setPrimarySelection(node.rowId!, node.colId!, false, true);
        }
        break;
      default:
        logger.e("No onTap handler for node: ${node.message}");
    }
  }
}
