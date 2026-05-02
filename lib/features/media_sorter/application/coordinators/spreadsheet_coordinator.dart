import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trying_flutter/features/media_sorter/application/state/history_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/sheet_data_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/workbook_controller.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/cell_position.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/history_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/sort_progress_data.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/grid_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/sort_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/selection_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/tree_controller.dart';
import 'package:trying_flutter/utils/logger.dart';

class SpreadsheetCoordinator extends ChangeNotifier {
  bool pageReady = false;
  bool get isPageReady => pageReady;

  final HistoryController historyController;
  final SheetDataController sheetDataController;
  final GridController gridController;
  final SortController sortController;
  final SelectionController selectionController;
  final WorkbookController workbookController;
  final TreeController treeController;

  int get currentSheetId => workbookController.currentSheetId;
  int get primarySelectedCellX => selectionController.primarySelectedCellX;
  int get primarySelectedCellY => selectionController.primarySelectedCellY;

  SpreadsheetCoordinator(
    this.historyController,
    this.sheetDataController,
    this.gridController,
    this.sortController,
    this.selectionController,
    this.workbookController,
    this.treeController,
  ) {
    historyController.addListener(() {
      notifyListeners();
    });
    selectionController.addListener(() {
      notifyListeners();
    });
    sheetDataController.addListener(() {
      notifyListeners();
    });
    gridController.addListener(() {
      notifyListeners();
    });
    sortController.addListener(() {
      notifyListeners();
    });
    workbookController.addListener(() {
      notifyListeners();
    });
    treeController.addListener(() {
      notifyListeners();
    });
    _init();
  }

  Future<void> _init() async {
    bool shouldClearData = false;
    shouldClearData =
        true; // DEV ONLY: Clear all data on every app start to avoid issues with changing data models during development
    if (shouldClearData == true) {
      await workbookController.clearAllData();
    }
    await workbookController.loadRecentSheetIds();
    await loadSheet(workbookController.currentSheetId);
    pageReady = true;
    notifyListeners();
    sortController.loadSortStatus();
    for (var sheetId in sortController.sortStatusBySheet.keys) {
      launchCalculation(sheetId);
    }
  }

  Future<void> loadSheet(int sheetId) async {
    final result = await workbookController.loadSheet(sheetId);
    if (result.isRight()) {
      afterLoadingSheet();
    }
  }

  void findBestSortToggle(bool value) {
    sortController.setFindingBestSort(currentSheetId, value);
    if (value) {
      launchCalculation(currentSheetId);
    }
  }

  void afterLoadingSheet() {
    updateTreeAndRowColCount();
    gridController.scrollToLastSelection();
    notifyListeners();
  }

  void setPrimarySelection(
    int row,
    int col,
    bool keepSelection,
    bool sameHistIdFromLast, {
    bool scrollTo = true,
  }) {
    selectionController.setPrimarySelection(
      row,
      col,
      keepSelection,
      sameHistIdFromLast,
    );
    treeController.updateMentionsContext();
    if (scrollTo) {
      gridController.scrollToCell();
    }
  }

  void delete() {
    sheetDataController.delete();
    applyUpdatesAndSort(currentSheetId, false, false, false);
  }

  void paste() async {
    final result = await sheetDataController.paste();
    result.fold(
      (failure) => logger.e("The pasted text contains unsupported characters."),
      (updates) => applyUpdatesAndSort(currentSheetId, false, false, false),
    );
  }

  void setCellContent(String newValue) {
    sheetDataController.setCellUpdate(
      newValue,
    );
    applyUpdatesAndSort(
      currentSheetId,
      false,
      false,
      selectionController.editingMode,
    );
  }

  void applyUpdatesAndSort(
    int sheetId,
    bool isFromHistory,
    bool isFromSort,
    bool isFromEditing,
  ) {
    applyUpdatesNoSort(sheetId, isFromHistory, isFromEditing);
    if (!isFromSort) {
      launchCalculation(sheetId);
    }
  }

  Future<void> launchCalculation(int sheetId) async {
    if (!sortController.getAnalysisDone(sheetId)) {
      await sortController.analyze(sheetId);
    }
    if (sortController.getBestSortPossibleFound(sheetId)) {
      return;
    }
    try {
      await for (final SortProgressDataMsg sortProgressDataMsg
          in await sortController.launchCalculation(sheetId)) {
        if (_handleSortProgressDataMsg(sortProgressDataMsg, sheetId)) {
          break;
        }
      }
    } on StateError catch (_) {
      return;
    }
  }

  void alwaysApplySortToggle(bool toAlwaysApply) {
    if (!sortController.sortedWithCurrentBestSort(currentSheetId)) {
      _sortTableWithCurrentBestSort(currentSheetId);
    }
    sortController.setToAlwaysApplyBestSort(currentSheetId, toAlwaysApply);
  }

  bool _handleSortProgressDataMsg(
    SortProgressDataMsg sortProgressDataMsg,
    int sheetId,
  ) {
    bool stopLoop = true;
    stopLoop = sortController.handleSortProgressDataMsg(
      sortProgressDataMsg,
      sheetId,
    );
    if (sortProgressDataMsg.newBestSortFound) {
      if (sortController.willNextBestSortBeApplied(sheetId)) {
        _sortTableWithCurrentBestSort(sheetId);
      } else {
        sortController.setSortedWithCurrentBestSort(sheetId, false);
      }
    }
    return stopLoop;
  }

  void _sortTableWithCurrentBestSort(int sheetId) {
    sortController.sortTableWithCurrentBestSort(sheetId);
    applyUpdatesNoSort(sheetId, false, false);
    if (sortController.getToApplyOnce(sheetId)) {
      sortController.setToApplyOnce(sheetId, false);
    }
  }

  void applyUpdatesNoSort(int sheetId, bool isFromHistory, bool isFromEditing) {
    sheetDataController.applyUpdatesNoSort(
      sheetId,
      isFromHistory,
      isFromEditing,
    );
    gridController.adjustRowHeightAfterUpdate(currentSheetId);
    updateTreeAndRowColCount();
    if (isFromEditing) {
      gridController.scrollToCell();
    }
  }

  void updateTreeAndRowColCount() {
    gridController.updateRowCount(currentSheetId);
    gridController.updateColCount(currentSheetId);
    treeController.onAnalysisAvailable();
  }

  void onTap(NodeStruct node) {
    switch (node.idOnTap) {
      case OnTapAction.selectAttribute:
        if (node.rowId != null) {
          setPrimarySelection(node.rowId!, 0, false);
          break;
        }
        CellPosition selectedCell = treeController.onTapCellSelect(node);
        setPrimarySelection(selectedCell.rowId, selectedCell.colId, false);
        break;
      case OnTapAction.selectCell:
        if (node.rowId != null && node.colId != null) {
          setPrimarySelection(node.rowId!, node.colId!, false);
        }
        break;
      case OnTapAction.cycle:
        int found = -1;
        for (int i = 0; i < node.newChildren!.length; i++) {
          final child = node.newChildren![i];
          if (primarySelectedCellX == child.rowId) {
            found = i;
            break;
          }
        }
        if (found == -1) {
          setPrimarySelection(
            node.newChildren![0].rowId!,
            node.newChildren![0].colId!,
            false,
          );
        } else {
          final nextChild =
              node.newChildren![(found + 1) % node.newChildren!.length];
          setPrimarySelection(nextChild.rowId!, nextChild.colId!, false);
        }
        break;
      case OnTapAction.defaultAction:
        if (node.cellsToSelect == null || node.cellsToSelect!.isEmpty) {
          return;
        }
        int found = -1;
        for (int i = 0; i < node.cellsToSelect!.length; i++) {
          final child = node.cellsToSelect![i];
          if (primarySelectedCellX == child.rowId &&
              primarySelectedCellY == child.colId) {
            found = i;
            break;
          }
        }
        final nextIndex = (found == -1)
            ? 0
            : (found + 1) % node.cellsToSelect!.length;
        setPrimarySelection(
          node.cellsToSelect![nextIndex].rowId,
          node.cellsToSelect![nextIndex].colId,
          false,
        );
        break;
      default:
        logger.e("No onTap handler for node: ${node.message}");
    }
  }

  void reorderBetterButton() {
    if (!sortController.sortedWithCurrentBestSort(currentSheetId)) {
      _sortTableWithCurrentBestSort(currentSheetId);
    } else {
      sortController.setToApplyOnce(currentSheetId, true);
      if (!sortController.isCalculating(currentSheetId)) {
        launchCalculation(currentSheetId);
      }
    }
  }

  void startEditing({String? initialInput}) {
    if (!selectionController.startEditing()) {
      return;
    }
    if (initialInput != null) {
      setCellContent(initialInput);
    }
  }

  void selectAll() {
    setPrimarySelection(0, 0, true, false);
    selectionController.selectAll();
    historyController.commitHistory(
      currentSheetId,
      HistoryType.selectionChange,
      false,
    );
  }

  void undo() {
    moveInUpdateHistory(-1);
  }

  void redo() {
    moveInUpdateHistory(1);
  }

  void moveInUpdateHistory(int direction) {
    final updateData = historyController.moveInUpdateHistory(direction);
    if (updateData.isNotEmpty) {
      applyUpdatesAndSort(updateData, currentSheetId, true, false, false);
    }
  }

  KeyEventResult handle(BuildContext context, KeyEvent event) {
    if (selectionController.editingMode) {
      return KeyEventResult.ignored;
    }

    if (event is KeyUpEvent) {
      return KeyEventResult.ignored;
    }

    final keyLabel = event.logicalKey.keyLabel.toLowerCase();
    final logicalKey = event.logicalKey;
    final isControl =
        HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;
    final isAlt = HardwareKeyboard.instance.isAltPressed;

    if (logicalKey == LogicalKeyboardKey.enter ||
        logicalKey == LogicalKeyboardKey.numpadEnter) {
      selectionController.startEditing();
      return KeyEventResult.handled;
    }

    if (logicalKey == LogicalKeyboardKey.arrowUp) {
      setPrimarySelection(
        max(primarySelectedCellX - 1, 0),
        primarySelectedCellY,
        false,
      );
      return KeyEventResult.handled;
    } else if (logicalKey == LogicalKeyboardKey.arrowDown) {
      setPrimarySelection(
        primarySelectedCellX + 1,
        primarySelectedCellY,
        false,
      );
      return KeyEventResult.handled;
    } else if (logicalKey == LogicalKeyboardKey.arrowLeft) {
      setPrimarySelection(
        primarySelectedCellX,
        max(0, primarySelectedCellY - 1),
        false,
      );
      return KeyEventResult.handled;
    } else if (logicalKey == LogicalKeyboardKey.arrowRight) {
      setPrimarySelection(
        primarySelectedCellX,
        primarySelectedCellY + 1,
        false,
      );
      return KeyEventResult.handled;
    }

    if (isControl && keyLabel == 'c') {
      sheetDataController.copyToClipboard();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selection copied'),
          duration: Duration(milliseconds: 500),
        ),
      );
      return KeyEventResult.handled;
    } else if (isControl && keyLabel == 'v') {
      paste();
    } else if (keyLabel == 'delete' || keyLabel == 'backspace') {
      delete();
      return KeyEventResult.handled;
    } else if (isControl && keyLabel == 'z') {
      undo();
      return KeyEventResult.handled;
    } else if (isControl && keyLabel == 'y') {
      redo();
      return KeyEventResult.handled;
    }

    final bool isPrintable =
        event.character != null &&
        event.character!.isNotEmpty &&
        !isControl &&
        !isAlt &&
        logicalKey.keyId > 32;

    if (isPrintable) {
      startEditing(initialInput: event.character);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void applyDefaultColumnSequence() {
    final updates = sheetDataController.setColumnType(
      1,
      ColumnType.dependencies,
    );
    updates.addAll(
      sheetDataController.setColumnType(2, ColumnType.dependencies),
    );
    updates.addAll(
      sheetDataController.setColumnType(3, ColumnType.dependencies),
    );
    updates.addAll(sheetDataController.setColumnType(7, ColumnType.urls));
    updates.addAll(
      sheetDataController.setColumnType(8, ColumnType.dependencies),
    );
    applyUpdatesAndSort(updates, currentSheetId, false, false, false);
  }

  void onCellSave(bool moveUp) {
    if (moveUp) {
      setPrimarySelection(
        max(0, primarySelectedCellX - 1),
        primarySelectedCellY,
        false,
      );
    } else {
      setPrimarySelection(
        primarySelectedCellX + 1,
        primarySelectedCellY,
        false,
      );
    }
    selectionController.stopEditing(true);
  }

  void setColumnType(int col, ColumnType type) {
    final updates = sheetDataController.setColumnType(col, type);
    applyUpdatesAndSort(updates, currentSheetId, false, false, false);
  }

  void createSheetByName(String name) {
    workbookController.createSheetByName(name);
    afterLoadingSheet();
  }
}
