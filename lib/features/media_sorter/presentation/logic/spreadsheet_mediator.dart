import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sheet_data_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/grid_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/history_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/selection_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sort_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/tree_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/workbook_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/delegates/spreadsheet_keyboard_delegate.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/spreadsheet_stream_controller.dart';

class SpreadsheetMediator {
  final WorkbookController workbookController;
  final GridController gridController;
  final HistoryController historyController;
  final SelectionController selectionController;
  final SheetDataController dataController;
  final TreeController treeController;
  final SortController sortController;
  final SpreadsheetStreamController streamController;
  final SpreadsheetKeyboardDelegate keyboardDelegate;

  SpreadsheetMediator({
    required this.workbookController,
    required this.gridController,
    required this.historyController,
    required this.selectionController,
    required this.dataController,
    required this.treeController,
    required this.sortController,
    required this.streamController,
    required this.keyboardDelegate,
  }) {
    _wireDependencies();
  }

  void _wireDependencies() {
    gridController.updateRowColCount = selectionController.updateRowColCount;
    gridController.canBeSorted = sortController.canBeSorted;
    gridController.getCellContent = dataController.getCellContent;
    historyController.updateCell = dataController.updateCell;
    historyController.setColumnType = dataController.setColumnType;
    historyController.saveAndCalculate = dataController.saveAndCalculate;
    selectionController.commitHistory = historyController.commitHistory;
    selectionController.discardPendingChanges =
        historyController.discardPendingChanges;
    selectionController.onChanged = dataController.onChanged;
    selectionController.getCellContent = dataController.getCellContent;
    selectionController.updateMentionsContext = (
    String currentSheetName,
    int row,
    int col) {
        treeController.updateMentionsContext(
          selectionController.lastSelectionBySheet,
          sortController.sortStatusBySheet[currentSheetName]!,
          currentSheetName,
          dataController.sheet(currentSheetName),
          sortController.lastAnalysis(currentSheetName),
          row,
          col,
        );
    };
    selectionController.triggerScrollTo = streamController.triggerScrollTo;
    selectionController.getNewRowColCount = gridController.getNewRowColCount;
    dataController.recordColumnTypeChange =
        historyController.recordColumnTypeChange;
    dataController.commitHistory = historyController.commitHistory;
    dataController.calculate = (
      SheetData sheet,
      String currentSheetName,
    ) {
      sortController.calculate(sheet, selectionController.lastSelectionBySheet, treeController.analysisResults, currentSheetName);
    };
    dataController.recordCellChange = historyController.recordCellChange;
    dataController.adjustRowHeightAfterUpdate =
        gridController.adjustRowHeightAfterUpdate;
    sortController.stopEditing = selectionController.stopEditing;
    sortController.setTable = dataController.setTable;
    sortController.canBeSorted = () {
      return sortController.canBeSortedFunc(
        dataController.sheet(workbookController.currentSheetName),
        sortController.lastAnalysis(workbookController.currentSheetName),
        workbookController.currentSheetName,
      );
    };
    sortController.currentSheetSorted = () {
      return sortController.sorted(workbookController.currentSheetName);
    };
    sortController.isFindingBestSort = () {
      return sortController.isFindingBestSortFun(workbookController.currentSheetName);
    };
    sortController.isFindingBestSortAndSort = () {
      return sortController.isFindingBestSortAndSortFun(workbookController.currentSheetName);
    };
    sortController.sortCurrentMedia = () {
      selectionController.stopEditing(
        notify: false,
      );
      sortController.sortMedia(
        dataController.sheet(workbookController.currentSheetName),
        sortController.analysisResults,
        selectionController.lastSelectionBySheet,
        workbookController.currentSheetName,
        gridController.row1ToScreenBottomHeight,
        gridController.colBToScreenRightWidth,
      );
    };
    keyboardDelegate.startEditing = selectionController.startEditing;
    keyboardDelegate.setPrimarySelection =
        selectionController.setPrimarySelection;
    keyboardDelegate.copySelectionToClipboard =
        dataController.copySelectionToClipboard;
    keyboardDelegate.pasteSelection = dataController.pasteSelection;
    keyboardDelegate.delete = dataController.delete;
    keyboardDelegate.undo = historyController.undo;
    keyboardDelegate.redo = historyController.redo;
    treeController.onCellSelected = selectionController.setPrimarySelection;
    treeController.getCellContent = dataController.getCellContent;
    treeController.toggleNodeExpansion = (
      NodeStruct node,
      bool isExpanded,
    ) {
      treeController.nodeExpansion(
        dataController.sheet(workbookController.currentSheetName),
        sortController.lastAnalysis(workbookController.currentSheetName),
        selectionController.lastSelectionBySheet,
        sortController.sortStatusBySheet[workbookController.currentSheetName]!,
        workbookController.currentSheetName,
        node,
        isExpanded,
      );
    };
  }
}
