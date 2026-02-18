import 'dart:math';
import 'package:flutter/services.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_status.dart';

class SpreadsheetKeyboardDelegate {
  late void Function(
    SheetData sheet,
    Map<String, AnalysisResult> analysisResults,
    Map<String, SelectionData> lastSelectionBySheet,
    SortStatus sortStatus,
    String currentSheetName,
    double row1ToScreenBottomHeight,
    double colBToScreenRightWidth, {
    String? initialInput,
  })
  startEditing;
  late void Function(
    String currentSheetName,
    int row,
    int col,
    bool keepSelection, {
    bool scrollTo,
  })
  setPrimarySelection;
  late Future<void> Function(
    SheetData sheet,
    SelectionData selection,
    String currentSheetName,
  )
  copySelectionToClipboard;
  late Future<void> Function(
    SheetData sheet,
    Map<String, AnalysisResult> analysisResults,
    SelectionData selection,
    SortStatus sortStatus,
    String currentSheetName,
    double row1ToScreenBottomHeight,
    double colBToScreenRightWidth,
    Map<String, SelectionData> lastSelectionBySheet,
  )
  pasteSelection;
  late void Function(
    SheetData sheet,
    Map<String, AnalysisResult> analysisResults,
    SelectionData selection,
    String currentSheetName,
    Map<String, SelectionData> lastSelectionBySheet,
    SortStatus sortStatus,
    double row1ToScreenBottomHeight,
    double colBToScreenRightWidth,
  )
  delete;
  late void Function(
    SheetData sheet,
    Map<String, AnalysisResult> analysisResults,
    SelectionData selection,
    Map<String, SelectionData> lastSelectionBySheet,
    SortStatus sortStatus,
    String currentSheetName,
    double row1ToScreenBottomHeight,
    double colBToScreenRightWidth,
  )
  undo;
  late void Function(
    SheetData sheet,
    Map<String, AnalysisResult> analysisResults,
    SelectionData selection,
    Map<String, SelectionData> lastSelectionBySheet,
    SortStatus sortStatus,
    String currentSheetName,
    double row1ToScreenBottomHeight,
    double colBToScreenRightWidth,
  )
  redo;

  SpreadsheetKeyboardDelegate();

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
      pasteSelection(
        sheet,
        analysisResults,
        selection,
        sortStatus,
        currentSheetName,
        row1ToScreenBottomHeight,
        colBToScreenRightWidth,
        lastSelectionBySheet,
      );
      return KeyEventResult.handled;
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
      undo(
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
