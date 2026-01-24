import 'dart:math';
import 'package:flutter/services.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_model.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/spreadsheet_scroll_request.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/calculation_service.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/selection_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sheet_data_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/tree_controller.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/spreadsheet_stream_controller.dart';

class HistorySelectionDataTreeContrManager extends ChangeNotifier {
  // --- dependencies ---
  final SelectionController _selectionController;
  final SheetDataController _dataController;
  final TreeController _treeController;
  final SpreadsheetStreamController _streamController;
  
  // --- usecases ---
  final CalculationService calculationService = CalculationService();

  // --- getters ---
  String get sheetName => _dataController.sheetName;
  SheetModel get sheet => _dataController.sheet;
  SheetContent get sheetContent => _dataController.sheetContent;
  List<String> get availableSheets => _dataController.availableSheets;
  NodeStruct get errorRoot => _treeController.errorRoot;
  NodeStruct get warningRoot => _treeController.warningRoot;
  NodeStruct get mentionsRoot => _treeController.mentionsRoot;
  NodeStruct get searchRoot => _treeController.searchRoot;
  NodeStruct get categoriesRoot => _treeController.categoriesRoot;
  NodeStruct get distPairsRoot => _treeController.distPairsRoot;
  Stream<SpreadsheetScrollRequest> get scrollStream => _streamController.scrollStream;
  bool get editingMode => _selectionController.editingMode;
  int get tableViewRows => _selectionController.tableViewRows;
  int get tableViewCols => _selectionController.tableViewCols;
  Point<int> get primarySelectedCell => _selectionController.primarySelectedCell;
  String get previousContent => _selectionController.selection.previousContent;

  // --- setters ---
  set sheetName(String value) {
    _dataController.sheetName = value;
  }

  HistorySelectionDataTreeContrManager(
    this._selectionController,
    this._dataController,
    this._treeController,
    this._streamController,
  );

  void keepOnlyPrim() {
    _selectionController.selectedCells.clear();
    _dataController.saveLastSelection(_selectionController.selection);
    notifyListeners();
  }

  bool isCellEditing(int row, int col) =>
      _selectionController.editingMode &&
      _selectionController.primarySelectedCell.x == row &&
      _selectionController.primarySelectedCell.y == col;

  Future<void> copySelectionToClipboard() async {
    int startRow = _selectionController.primarySelectedCell.x;
    int endRow = _selectionController.primarySelectedCell.x;
    int startCol = _selectionController.primarySelectedCell.y;
    int endCol = _selectionController.primarySelectedCell.y;
    for (Point<int> cell in _selectionController.selectedCells) {
      if (cell.x < startRow) startRow = cell.x;
      if (cell.y < startCol) startCol = cell.y;
      if (cell.x > endRow) endRow = cell.x;
      if (cell.y > endCol) endCol = cell.y;
    }
    List<List<bool>> selectedCellsTable = List.generate(
      endRow - startRow + 1,
      (_) => List.generate(endCol - startCol + 1, (_) => false),
    );
    for (Point<int> cell in _selectionController.selectedCells) {
      selectedCellsTable[cell.x - startRow][cell.y - startCol] = true;
    }
    if (!selectedCellsTable.every((row) => row.every((cell) => !cell))) {
      await Clipboard.setData(
        ClipboardData(
          text: _dataController.getContent(
            _selectionController.primarySelectedCell.x,
            _selectionController.primarySelectedCell.y,
          ),
        ),
      );
      return;
    }

    StringBuffer buffer = StringBuffer();

    for (int r = startRow; r <= endRow; r++) {
      List<String> rowData = [];
      for (int c = startCol; c <= endCol; c++) {
        rowData.add(_dataController.getContent(r, c));
      }
      buffer.write(rowData.join('\t')); // Tab separated for Excel compat
      if (r < endRow) buffer.write('\n');
    }

    final text = buffer.toString();
    await Clipboard.setData(ClipboardData(text: text));
  }

}
