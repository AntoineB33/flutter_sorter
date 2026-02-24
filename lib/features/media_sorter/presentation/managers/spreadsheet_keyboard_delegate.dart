import 'dart:math';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_status.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/history/history_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/history/history_manager.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sheet_data/sheet_data_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sort/sort_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sort/sort_service.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/loaded_sheets_data_store.dart';

class SpreadsheetKeyboardDelegate {
  final HistoryManager historyManager;

  final SortService sortService;

   SpreadsheetKeyboardDelegate(this.historyManager, this.sortService);

  KeyEventResult handle(
    BuildContext context,
    KeyEvent event,
    SelectionData selection,
    bool editingMode,
    SheetData sheet,
    Map<String, AnalysisResult> analysisResults,
    Map<String, SelectionData> lastSelectionBySheet,
    SortStatus sortStatus,
    double row1ToScreenBottomHeight,
    double colBToScreenRightWidth,
    String currentSheetName,
  ) {
    if (editingMode) {
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
      startEditing(
        sheet,
        analysisResults,
        lastSelectionBySheet,
        sortStatus,
        currentSheetName,
        row1ToScreenBottomHeight,
        colBToScreenRightWidth,
      );
      return KeyEventResult.handled;
    }

    if (logicalKey == LogicalKeyboardKey.arrowUp) {
      setPrimarySelection(
        currentSheetName,
        max(selection.primarySelectedCell.x - 1, 0),
        selection.primarySelectedCell.y,
        false,
      );
      return KeyEventResult.handled;
    } else if (logicalKey == LogicalKeyboardKey.arrowDown) {
      setPrimarySelection(
        currentSheetName,
        selection.primarySelectedCell.x + 1,
        selection.primarySelectedCell.y,
        false,
      );
      debugPrint("${selection.primarySelectedCell.x}");
      return KeyEventResult.handled;
    } else if (logicalKey == LogicalKeyboardKey.arrowLeft) {
      setPrimarySelection(
        currentSheetName,
        selection.primarySelectedCell.x,
        max(0, selection.primarySelectedCell.y - 1),
        false,
      );
      return KeyEventResult.handled;
    } else if (logicalKey == LogicalKeyboardKey.arrowRight) {
      setPrimarySelection(
        currentSheetName,
        selection.primarySelectedCell.x,
        selection.primarySelectedCell.y + 1,
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
      startEditing(
        sheet,
        analysisResults,
        lastSelectionBySheet,
        sortStatus,
        currentSheetName,
        row1ToScreenBottomHeight,
        colBToScreenRightWidth,
        initialInput: event.character,
      );
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }
}
