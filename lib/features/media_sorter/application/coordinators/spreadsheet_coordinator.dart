import 'dart:async';
import 'dart:math';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
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
    init();
  }

  Future<void> init() async {
    // await workbookController.clearAllData();
    await workbookController.loadRecentSheetIds();
    await loadSheet(workbookController.currentSheetId, true);
    pageReady = true;
    notifyListeners();
    sortController.loadSortStatus();
    for (var sheetId in sortController.getRecentSheetIds()) {
      launchCalculation(sheetId);
    }
  }

  Future<void> loadSheet(int sheetId, bool init) async {
    final result = await workbookController.loadSheet(sheetId, init);
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
    bool keepSelection, {
    bool scrollTo = true,
  }) {
    historyController.newPrimarySelection(row, col);
    treeController.updateMentionsContext();
    if (scrollTo) {
      gridController.scrollToCell();
    }
  }

  void delete() {
    final updates = sheetDataController.delete();
    applyUpdatesAndSort(updates.toMap(), currentSheetId, false, false, false);
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
    int rowId = primarySelectedCellX;
    int colId = primarySelectedCellY;
    final cellUpdate = CellUpdate(currentSheetId, rowId, colId, newValue);
    Map<String, UpdateUnit> updates = {cellUpdate.getKey(): cellUpdate};
    applyUpdatesAndSort(
      updates.lock,
      currentSheetId,
      false,
      false,
      selectionController.editingMode,
    );
  }

  void applyUpdatesAndSort(
    IMap<String, UpdateUnit> updates,
    int sheetId,
    bool isFromHistory,
    bool isFromSort,
    bool isFromEditing,
  ) {
    applyUpdatesNoSort(updates, sheetId, isFromHistory, isFromEditing);
    if (!isFromSort) {
      launchCalculation(sheetId);
    }
  }

  Future<void> launchCalculation(int sheetId) async {
    if (!sortController.getAnalysIsDone(sheetId)) {
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
    int sheetId,
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

  void sortTableWithCurrentBestSort(int sheetId) {
    final updates = sortController.sortTableWithCurrentBestSort(sheetId);
    applyUpdatesNoSort(updates.toMap(), sheetId, false, false);
    if (sortController.getToApplyOnce(sheetId)) {
      sortController.setToApplyOnce(sheetId, false);
    }
  }

  void applyUpdatesNoSort(
    IMap<String, UpdateUnit> updates,
    int sheetId,
    bool isFromHistory,
    bool isFromEditing,
  ) {
    sheetDataController.applyUpdatesNoSort(
      updates,
      sheetId,
      isFromHistory,
      isFromEditing,
    );
    gridController.adjustRowHeightAfterUpdate(currentSheetId, updates);
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
    setPrimarySelection(0, 0, true);
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
    final updatesLst = [
      ColumnTypeUpdate(currentSheetId, 1, ColumnType.dependencies),
      ColumnTypeUpdate(currentSheetId, 2, ColumnType.dependencies),
      ColumnTypeUpdate(currentSheetId, 3, ColumnType.dependencies),
      ColumnTypeUpdate(currentSheetId, 7, ColumnType.urls),
      ColumnTypeUpdate(currentSheetId, 8, ColumnType.dependencies),
    ];
    Map<String, UpdateUnit> updates = {
      for (var update in updatesLst) update.getKey(): update,
    };
    applyUpdatesAndSort(updates.lock, currentSheetId, false, false, false);
  }

  void onCellSave(String newValue, bool moveUp) {
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
    final update = ColumnTypeUpdate(currentSheetId, col, type);
    final updates = {update.getKey(): update};
    applyUpdatesAndSort(updates.lock, currentSheetId, false, false, false);
  }

  void createSheetByName(String name) {
    workbookController.createSheetByName(name);
    afterLoadingSheet();
  }
}
