import 'package:trying_flutter/features/media_sorter/presentation/controllers/sheet_data_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/grid_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/history_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/selection_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sort_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/tree_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/delegates/spreadsheet_keyboard_delegate.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/spreadsheet_stream_controller.dart';

class SpreadsheetMediator {
  final GridController gridController;
  final HistoryController historyController;
  final SelectionController selectionController;
  final SheetDataController dataController;
  final TreeController treeController;
  final SortController sortController;
  final SpreadsheetStreamController streamController;
  final SpreadsheetKeyboardDelegate keyboardDelegate;

  SpreadsheetMediator({
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
    selectionController.updateMentionsContext =
        treeController.updateMentionsRoot;
    selectionController.triggerScrollTo = streamController.triggerScrollTo;
    selectionController.getNewRowColCount = gridController.getNewRowColCount;
    dataController.recordColumnTypeChange =
        historyController.recordColumnTypeChange;
    dataController.commitHistory = historyController.commitHistory;
    dataController.calculate = sortController.calculate;
    dataController.recordCellChange = historyController.recordCellChange;
    dataController.adjustRowHeightAfterUpdate =
        gridController.adjustRowHeightAfterUpdate;
    sortController.stopEditing = selectionController.stopEditing;
    sortController.setTable = dataController.setTable;
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
  }
}