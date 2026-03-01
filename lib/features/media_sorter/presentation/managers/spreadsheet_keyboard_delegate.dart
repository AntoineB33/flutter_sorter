import 'dart:math';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_status.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/history_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/coordinators/history_coordinator.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/selection_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/coordinators/selection_coordinator.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sheet_data_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sort_controller.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/sort_service.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/loaded_sheets_data_store.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/selection_data_store.dart';

class SpreadsheetKeyboardDelegate {
  final SelectionController selectionController;
  final SelectionCoordinator selectionCoordinator;

  final HistoryCoordinator historyManager;

  final SortService sortService;

  final LoadedSheetsDataStore loadedSheetsDataStore;
  final SelectionDataStore selectionDataStore;

  SpreadsheetKeyboardDelegate(
    this.historyManager,
    this.selectionController,
    this.selectionCoordinator,
    this.sortService,
    this.loadedSheetsDataStore,
    this.selectionDataStore,
  );

  KeyEventResult handle(BuildContext context, KeyEvent event) {
    if (selectionDataStore.editingMode) {
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
        max(selectionController.selection.primarySelectedCell.x - 1, 0),
        selectionController.selection.primarySelectedCell.y,
        false,
      );
      return KeyEventResult.handled;
    } else if (logicalKey == LogicalKeyboardKey.arrowDown) {
      selectionController.setPrimarySelection(
        selectionDataStore.selection.primarySelectedCell.x + 1,
        selectionDataStore.selection.primarySelectedCell.y,
        false,
      );
      debugPrint("${selectionDataStore.selection.primarySelectedCell.x}");
      return KeyEventResult.handled;
    } else if (logicalKey == LogicalKeyboardKey.arrowLeft) {
      selectionController.setPrimarySelection(
        selectionDataStore.selection.primarySelectedCell.x,
        max(0, selectionDataStore.selection.primarySelectedCell.y - 1),
        false,
      );
      return KeyEventResult.handled;
    } else if (logicalKey == LogicalKeyboardKey.arrowRight) {
      selectionController.setPrimarySelection(
        selectionDataStore.selection.primarySelectedCell.x,
        selectionDataStore.selection.primarySelectedCell.y + 1,
        false,
      );
      return KeyEventResult.handled;
    }

    if (isControl && keyLabel == 'c') {
      copySelectionToClipboard(sheet, selection, currentSheetName);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selection copied'),
          duration: Duration(milliseconds: 500),
        ),
      );
      return KeyEventResult.handled;
    } else if (isControl && keyLabel == 'v') {
      sheetDataController.pasteSelection().then((toCalculate) {
        if (toCalculate) {
          sortService.calculate(currentSheetName);
        }
      });
    } else if (keyLabel == 'delete' || keyLabel == 'backspace') {
      delete(
        sheet,
        analysisResults,
        selection,
        currentSheetName,
        lastSelectionBySheet,
        sortStatus,
        row1ToScreenBottomHeight,
        colBToScreenRightWidth,
      );
      return KeyEventResult.handled;
    } else if (isControl && keyLabel == 'z') {
      historyManager.undo();
      return KeyEventResult.handled;
    } else if (isControl && keyLabel == 'y') {
      redo(
        sheet,
        analysisResults,
        selection,
        lastSelectionBySheet,
        sortStatus,
        currentSheetName,
        row1ToScreenBottomHeight,
        colBToScreenRightWidth,
      );
      return KeyEventResult.handled;
    }

    final bool isPrintable =
        event.character != null &&
        event.character!.isNotEmpty &&
        !isControl &&
        !isAlt &&
        logicalKey.keyId > 32;

    if (isPrintable) {
      selectionCoordinator.startEditing(initialInput: event.character);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }
}
