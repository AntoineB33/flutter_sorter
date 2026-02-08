import 'dart:math';
import 'package:flutter/services.dart';
import 'package:trying_flutter/features/media_sorter/data/models/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_data.dart';
import 'package:flutter/material.dart';

class SpreadsheetKeyboardDelegate {
  void Function(SheetData sheet, SelectionData selection, Map<String, SelectionData> lastSelectionBySheet, String currentSheetName, {String? initialInput}) startEditing;
  void Function(
    SelectionData selection,
    Map<String, SelectionData> lastSelectionBySheet,
    String currentSheetName,
    int row,
    int col,
    bool keepSelection, {
    bool scrollTo,
  }) setPrimarySelection;
  Future<void> Function(SheetData sheet, SelectionData selection, String currentSheetName) copySelectionToClipboard;
  Future<void> Function(SheetData sheet, SelectionData selection, String currentSheetName) pasteSelection;
  void Function(SheetData sheet, SelectionData selection, String currentSheetName) delete;
  void Function(SheetData sheet, SelectionData selection, String currentSheetName) undo;
  void Function(SheetData sheet, SelectionData selection, String currentSheetName) redo;

  SpreadsheetKeyboardDelegate(this.startEditing, this.setPrimarySelection, this.copySelectionToClipboard, this.pasteSelection, this.delete, this.undo, this.redo);

  KeyEventResult handle(BuildContext context, KeyEvent event, SelectionData selection, bool editingMode, SheetData sheet, Map<String, SelectionData> lastSelectionBySheet, String currentSheetName) {
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
      startEditing(sheet, selection, lastSelectionBySheet, currentSheetName);
      return KeyEventResult.handled;
    }

    if (logicalKey == LogicalKeyboardKey.arrowUp) {
      setPrimarySelection(
        selection,
        lastSelectionBySheet,
        currentSheetName,
        max(selection.primarySelectedCell.x - 1, 0),
        selection.primarySelectedCell.y,
        false,
      );
      return KeyEventResult.handled;
    } else if (logicalKey == LogicalKeyboardKey.arrowDown) {
      setPrimarySelection(
        selection,
        lastSelectionBySheet,
        currentSheetName,
        selection.primarySelectedCell.x + 1,
        selection.primarySelectedCell.y,
        false,
      );
      debugPrint("${selection.primarySelectedCell.x}");
      return KeyEventResult.handled;
    } else if (logicalKey == LogicalKeyboardKey.arrowLeft) {
      setPrimarySelection(
        selection,
        lastSelectionBySheet,
        currentSheetName,
        selection.primarySelectedCell.x,
        max(0, selection.primarySelectedCell.y - 1),
        false,
      );
      return KeyEventResult.handled;
    } else if (logicalKey == LogicalKeyboardKey.arrowRight) {
      setPrimarySelection(
        selection,
        lastSelectionBySheet,
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
      pasteSelection(sheet, selection, currentSheetName);
      return KeyEventResult.handled;
    } else if (keyLabel == 'delete' || keyLabel == 'backspace') {
      delete(sheet, selection, currentSheetName);
      return KeyEventResult.handled;
    } else if (isControl && keyLabel == 'z') {
      undo(sheet, selection, currentSheetName);
      return KeyEventResult.handled;
    } else if (isControl && keyLabel == 'y') {
      redo(sheet, selection, currentSheetName);
      return KeyEventResult.handled;
    }

    final bool isPrintable =
        event.character != null &&
        event.character!.isNotEmpty &&
        !isControl &&
        !isAlt &&
        logicalKey.keyId > 32;

    if (isPrintable) {
      startEditing(sheet, selection, lastSelectionBySheet, currentSheetName, initialInput: event.character);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }
}
