import 'dart:math';
import 'package:flutter/services.dart';
import '../../domain/usecases/parse_paste_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/spreadsheet_controller.dart';

class ClipboardManager {
  final SpreadsheetController _controller;
  final ParsePasteDataUseCase _parsePasteDataUseCase = ParsePasteDataUseCase();

  ClipboardManager(this._controller);

  
  Future<String?> copySelectionToClipboard() async {
    final startRow = min(_controller.selectionStart.x, _controller.selectionEnd.x);
    final endRow = max(_controller.selectionStart.x, _controller.selectionEnd.x);
    final startCol = min(_controller.selectionStart.y, _controller.selectionEnd.y);
    final endCol = max(_controller.selectionStart.y, _controller.selectionEnd.y);

    StringBuffer buffer = StringBuffer();

    for (int r = startRow; r <= endRow; r++) {
      List<String> rowData = [];
      for (int c = startCol; c <= endCol; c++) {
        rowData.add(_controller.getContent(r, c));
      }
      buffer.write(rowData.join('\t')); // Tab separated for Excel compat
      if (r < endRow) buffer.write('\n');
    }

    final text = buffer.toString();
    await Clipboard.setData(ClipboardData(text: text));
    return text;
  }

  Future<void> pasteSelection() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text == null) return;

    // 1. Delegate Logic to UseCase
    // We normalize selection to ensure we paste from top-left
    int startRow = min(_controller.selectionStart.x, _controller.selectionEnd.x);
    int startCol = min(_controller.selectionStart.y, _controller.selectionEnd.y);

    final List<CellUpdate> updates = _parsePasteDataUseCase.execute(
      data!.text!,
      startRow,
      startCol,
    );

    // 2. Update UI & Persist
    for (var update in updates) {
      _controller.updateCell(update.row, update.col, update.value);
    }
    _controller.saveAndCalculate();
  }
}