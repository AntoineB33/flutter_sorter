import 'dart:math';
import 'package:flutter/services.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/spreadsheet_controller.dart';
import 'package:flutter/material.dart';

class SpreadsheetKeyboardDelegate {
  final SpreadsheetController manager;

  SpreadsheetKeyboardDelegate(this.manager);

  KeyEventResult handle(BuildContext context, KeyEvent event) {
    if (manager.editingMode) {
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
      manager.startEditing();
      return KeyEventResult.handled;
    }

    if (logicalKey == LogicalKeyboardKey.arrowUp) {
      manager.setPrimarySelection(
        max(manager.primarySelectedCell.x - 1, 0),
        manager.primarySelectedCell.y,
        false,
        true,
      );
      return KeyEventResult.handled;
    } else if (logicalKey == LogicalKeyboardKey.arrowDown) {
      manager.setPrimarySelection(
        manager.primarySelectedCell.x + 1,
        manager.primarySelectedCell.y,
        false,
        true,
      );
      debugPrint("${manager.primarySelectedCell.x}");
      return KeyEventResult.handled;
    } else if (logicalKey == LogicalKeyboardKey.arrowLeft) {
      manager.setPrimarySelection(
        manager.primarySelectedCell.x,
        max(0, manager.primarySelectedCell.y - 1),
        false,
        true,
      );
      return KeyEventResult.handled;
    } else if (logicalKey == LogicalKeyboardKey.arrowRight) {
      manager.setPrimarySelection(
        manager.primarySelectedCell.x,
        manager.primarySelectedCell.y + 1,
        false,
        true,
      );
      return KeyEventResult.handled;
    }

    if (isControl && keyLabel == 'c') {
      manager.copySelectionToClipboard();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selection copied'),
          duration: Duration(milliseconds: 500),
        ),
      );
      return KeyEventResult.handled;
    } else if (isControl && keyLabel == 'v') {
      manager.pasteSelection();
      return KeyEventResult.handled;
    } else if (keyLabel == 'delete' || keyLabel == 'backspace') {
      manager.delete();
      return KeyEventResult.handled;
    } else if (isControl && keyLabel == 'z') {
      manager.undo();
      return KeyEventResult.handled;
    } else if (isControl && keyLabel == 'y') {
      manager.redo();
      return KeyEventResult.handled;
    }

    final bool isPrintable =
        event.character != null &&
        event.character!.isNotEmpty &&
        !isControl &&
        !isAlt &&
        logicalKey.keyId > 32;

    if (isPrintable) {
      manager.startEditing(initialInput: event.character);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }
}
