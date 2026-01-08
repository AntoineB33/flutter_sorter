import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../domain/usecases/parse_paste_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/spreadsheet_controller.dart';

class ClipboardManager {
  final SpreadsheetController _controller;
  final ParsePasteDataUseCase _parsePasteDataUseCase = ParsePasteDataUseCase();

  ClipboardManager(this._controller);

  Future<void> copySelectionToClipboard() async {
    int startRow = _controller.primarySelectedCell.x;
    int endRow = _controller.primarySelectedCell.x;
    int startCol = _controller.primarySelectedCell.y;
    int endCol = _controller.primarySelectedCell.y;
    for (Point<int> cell in _controller.selection.selectedCells) {
      if (cell.x < startRow) startRow = cell.x;
      if (cell.y < startCol) startCol = cell.y;
      if (cell.x > endRow) endRow = cell.x;
      if (cell.y > endCol) endCol = cell.y;
    }
    List<List<bool>> selectedCellsTable = List.generate(
      endRow - startRow + 1,
      (_) => List.generate(endCol - startCol + 1, (_) => false),
    );
    for (Point<int> cell in _controller.selection.selectedCells) {
      selectedCellsTable[cell.x - startRow][cell.y - startCol] = true;
    }
    if (!selectedCellsTable.every((row) => row.every((cell) => !cell))) {
      await Clipboard.setData(
        ClipboardData(
          text: _controller.getContent(
            _controller.primarySelectedCell.x,
            _controller.primarySelectedCell.y,
          ),
        ),
      );
      return;
    }

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
  }

  Future<void> pasteSelection() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text == null) return;
    // if contains "
    if (data!.text!.contains('"')) {
      debugPrint('Paste data contains unsupported characters.');
      return;
    }

    final List<CellUpdate> updates = _parsePasteDataUseCase.pasteText(
      data.text!,
      _controller.primarySelectedCell.x,
      _controller.primarySelectedCell.y,
    );

    // 2. Update UI & Persist
    _controller.currentUpdateHistory = null;
    for (var update in updates) {
      _controller.updateCell(update.row, update.col, update.value, keepPrevious: true);
    }
    _controller.notify();
    _controller.saveAndCalculate(updateHistory: true);
  }

  void clearSelection(bool save) {
    for (Point<int> cell in _controller.selection.selectedCells) {
      _controller.updateCell(cell.x, cell.y, '');
    }
    if (save) {
      _controller.notify();
      _controller.saveAndCalculate();
    }
  }

  void delete() {
    for (Point<int> cell in _controller.selection.selectedCells) {
      _controller.updateCell(cell.x, cell.y, '');
    }
    _controller.updateCell(
      _controller.primarySelectedCell.x,
      _controller.primarySelectedCell.y,
      '',
    );
    _controller.notify();
    _controller.saveAndCalculate();
  }
}
