import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trying_flutter/features/media_sorter/application/state/history_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/sheet_data_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/workbook_controller.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_progress_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/grid_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/sort_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/selection_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/tree_controller.dart';
import 'package:trying_flutter/utils/logger.dart';

class SpreadsheetCoordinator {
  final HistoryController historyController;
  final SheetDataController sheetDataController;
  final GridController gridController;
  final SortController sortController;
  final SelectionController selectionController;
  final WorkbookController workbookController;
  final TreeController treeController;

  String get currentSheetId => workbookController.currentSheetId;
  Point<int> get primarySelectedCell =>
      selectionController.getSelectionData(currentSheetId).primarySelectedCell;

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
    bool lastSelectionSuccess = await loadSheet(
      workbookController.currentSheetId,
      true,
    );
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
    gridController.updateRowColCount(
      currentSheetId,
      row1ToScreenBottomHeight:
          selectionController.getScrollOffsetX(currentSheetId) +
          gridController.row1ToScreenBottomHeight,
      colBToScreenRightWidth:
          selectionController.getScrollOffsetY(currentSheetId) +
          gridController.colBToScreenRightWidth,
    );
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
      gridController.scrollToCell();
    }
    selectionController.saveLastSelection();
    treeController.updateMentionsContext(row, col);
  }

  void delete() {
    final updates = sheetDataController.delete();
    applyUpdatesAndSort(updates, currentSheetId, false, false, false);
  }

  void paste() async {
    final result = await sheetDataController.paste();
    result.fold(
      (failure) => logger.e("The pasted text contains unsupported characters."),
      (updates) =>
          applyUpdatesAndSort(updates, currentSheetId, false, false, false),
    );
  }

  void setCellContent(String newValue) {
    int rowId = primarySelectedCell.x;
    int colId = primarySelectedCell.y;
    final updates = [CellUpdate(rowId, colId, newValue)];
    applyUpdatesAndSort(
      updates,
      currentSheetId,
      false,
      false,
      selectionController.editingMode,
    );
  }

  void applyUpdatesAndSort(
    List<UpdateUnit> updates,
    String sheetId,
    bool isFromHistory,
    bool isFromSort,
    bool isFromEditing,
  ) {
    applyUpdatesNoSort(updates, sheetId, isFromHistory, isFromEditing);
    if (!isFromSort) {
      sortController.lightCalculations(sheetId);
      launchCalculation(sheetId);
    }
  }

  Future<void> launchCalculation(String sheetId) async {
    if (!sortController.getAnalysisDone(sheetId)) {
      await sortController.analyze(sheetId);
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
      sortTableWithCurrentBestSort(currentSheetId);
    }
    sortController.setToAlwaysApplyBestSort(currentSheetId, toAlwaysApply);
  }

  bool _handleSortProgressDataMsg(
    SortProgressDataMsg sortProgressDataMsg,
    String sheetId,
  ) {
    bool stopLoop = true;
    stopLoop = sortController.handleSortProgressDataMsg(
      sortProgressDataMsg,
      sheetId,
    );
    if (sortProgressDataMsg.newBestSortFound) {
      if (sortController.willNextBestSortBeApplied(sheetId)) {
        sortTableWithCurrentBestSort(sheetId);
      } else {
        sortController.setSortedWithCurrentBestSort(sheetId, false);
      }
    }
    return stopLoop;
  }

  void sortTableWithCurrentBestSort(String sheetId) {
    final List<UpdateUnit> updates = sortController
        .sortTableWithCurrentBestSort(sheetId);
    applyUpdatesNoSort(updates, sheetId, false, false);
    if (sortController.getToApplyOnce(sheetId)) {
      sortController.setToApplyOnce(sheetId, false);
    }
  }

  void applyUpdatesNoSort(
    List<UpdateUnit> updates,
    String sheetId,
    bool isFromHistory,
    bool isFromEditing,
  ) {
    sheetDataController.applyUpdatesNoSort(
      updates,
      sheetId,
      isFromHistory,
      isFromEditing,
    );
    gridController.adjustRowHeightAfterUpdate(sheetId, updates);
    if (isFromEditing) {
      gridController.scrollToCell();
    }
  }

  void onTap(NodeStruct node) {
    switch (node.idOnTap) {
      case OnTapAction.selectAttribute:
        if (node.rowId != null) {
          setPrimarySelection(node.rowId!, 0, false, true);
          break;
        }
        Point<int> selectedCell = treeController.onTapCellSelect(node);
        setPrimarySelection(selectedCell.x, selectedCell.y, false, true);
        break;
      case OnTapAction.selectCell:
        if (node.rowId != null && node.colId != null) {
          setPrimarySelection(node.rowId!, node.colId!, false, true);
        }
        break;
      case OnTapAction.cycle:
        int found = -1;
        for (int i = 0; i < node.newChildren!.length; i++) {
          final child = node.newChildren![i];
          if (primarySelectedCell.x == child.rowId) {
            found = i;
            break;
          }
        }
        if (found == -1) {
          setPrimarySelection(
            node.newChildren![0].rowId!,
            node.newChildren![0].colId!,
            false,
            true,
          );
        } else {
          final nextChild =
              node.newChildren![(found + 1) % node.newChildren!.length];
          setPrimarySelection(nextChild.rowId!, nextChild.colId!, false, true);
        }
        break;
      case OnTapAction.defaultAction:
        if (node.cellsToSelect == null || node.cellsToSelect!.isEmpty) {
          return;
        }
        int found = -1;
        for (int i = 0; i < node.cellsToSelect!.length; i++) {
          final child = node.cellsToSelect![i];
          if (primarySelectedCell.x == child.rowId &&
              primarySelectedCell.y == child.colId) {
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
          true,
        );
        break;
      default:
        logger.e("No onTap handler for node: ${node.message}");
    }
  }

  void applyBetterSortButton() {
    if (!sortController.sortedWithCurrentBestSort(currentSheetId)) {
      sortTableWithCurrentBestSort(currentSheetId);
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
    setPrimarySelection(0, 0, true, true);
    selectionController.selectAll();
  }

  void undo() {
    moveInUpdateHistory(-1);
  }

  void redo() {
    moveInUpdateHistory(1);
  }

  void moveInUpdateHistory(int direction) {
    final updateData = historyController.moveInUpdateHistory(direction);
    if (updateData != null) {
      applyUpdatesAndSort(
        updateData.updates,
        updateData.sheetId,
        true,
        false,
        false,
      );
    }
  }

  KeyEventResult handle(
    BuildContext context,
    KeyEvent event,
  ) {
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
      selectionController.setPrimarySelection(
        max(primarySelectedCell.x - 1, 0),
        primarySelectedCell.y,
        false,
      );
      return KeyEventResult.handled;
    } else if (logicalKey == LogicalKeyboardKey.arrowDown) {
      selectionController.setPrimarySelection(
        primarySelectedCell.x + 1,
        primarySelectedCell.y,
        false,
      );
      return KeyEventResult.handled;
    } else if (logicalKey == LogicalKeyboardKey.arrowLeft) {
      selectionController.setPrimarySelection(
        primarySelectedCell.x,
        max(0, primarySelectedCell.y - 1),
        false,
      );
      return KeyEventResult.handled;
    } else if (logicalKey == LogicalKeyboardKey.arrowRight) {
      selectionController.setPrimarySelection(
        primarySelectedCell.x,
        primarySelectedCell.y + 1,
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
    applyUpdatesAndSort(
      [
        ColumnTypeUpdate(1, ColumnType.dependencies),
        ColumnTypeUpdate(2, ColumnType.dependencies),
        ColumnTypeUpdate(3, ColumnType.dependencies),
        ColumnTypeUpdate(7, ColumnType.urls),
        ColumnTypeUpdate(8, ColumnType.dependencies),
      ],
      currentSheetId,
      false,
      false,
      false,
    );
  }
}
