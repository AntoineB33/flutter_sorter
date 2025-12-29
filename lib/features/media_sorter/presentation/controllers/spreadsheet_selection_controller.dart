import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/save_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/get_sheet_data_usecase.dart';
import 'spreadsheet_data_controller.dart';

class SpreadsheetSelectionController extends ChangeNotifier {
  final SaveSheetDataUseCase _saveSheetDataUseCase;
  final GetSheetDataUseCase _getDataUseCase;
  
  // Dependency Injection
  SpreadsheetDataController? _dataController;

  Point<int> _selectionStart = const Point(0, 0);
  Point<int> _selectionEnd = const Point(0, 0);
  Map<String, Point<int>> lastSelectedCells = {};

  Point<int> get selectionStart => _selectionStart;
  Point<int> get selectionEnd => _selectionEnd;

  SpreadsheetSelectionController({
    required SaveSheetDataUseCase saveSheetDataUseCase,
    required GetSheetDataUseCase getDataUseCase,
  }) : _saveSheetDataUseCase = saveSheetDataUseCase,
       _getDataUseCase = getDataUseCase {
    _init();
  }

  void updateDataController(SpreadsheetDataController controller) {
    _dataController = controller;
    
    // Listen for sheet changes to update selection to last known point
    if (_dataController != null) {
      if (lastSelectedCells.containsKey(_dataController!.sheetName)) {
        final saved = lastSelectedCells[_dataController!.sheetName]!;
        _selectionStart = saved;
        _selectionEnd = saved;
        notifyListeners();
      }
    }
  }

  Future<void> _init() async {
    final allSheets = await _getDataUseCase.getAllSheetNames();
    lastSelectedCells = await _getDataUseCase.getAllLastSelected(allSheets);
    
    // Initial selection logic
    _selectionStart = await _getDataUseCase.getLastSelectedCell();
    _selectionEnd = _selectionStart;
    notifyListeners();
  }

  void selectCell(int row, int col) {
    final newStart = Point(row, col);
    final newEnd = Point(row, col);
    _checkSelectChange(newStart, newEnd);
  }

  void selectRange(int startRow, int startCol, int endRow, int endCol) {
    final newStart = Point(startRow, startCol);
    final newEnd = Point(endRow, endCol);
    _checkSelectChange(newStart, newEnd);
  }

  void selectAll() {
    if (_dataController == null) return;
    selectRange(0, 0, _dataController!.rowCount - 1, _dataController!.colCount - 1);
  }

  void _checkSelectChange(Point<int> newStart, Point<int> newEnd) {
    if (_selectionStart != newStart || _selectionEnd != newEnd) {
      _selectionStart = newStart;
      _selectionEnd = newEnd;
      
      // Persist
      _saveSheetDataUseCase.saveLastSelectedCell(_selectionStart);
      if (_dataController != null) {
        lastSelectedCells[_dataController!.sheetName] = _selectionStart;
        _saveSheetDataUseCase.saveAllLastSelected(lastSelectedCells);
      }
      
      notifyListeners();
    }
  }

  bool isCellSelected(int row, int col) {
    final startRow = min(_selectionStart.x, _selectionEnd.x);
    final endRow = max(_selectionStart.x, _selectionEnd.x);
    final startCol = min(_selectionStart.y, _selectionEnd.y);
    final endCol = max(_selectionStart.y, _selectionEnd.y);

    return row >= startRow && row <= endRow && col >= startCol && col <= endCol;
  }

  // --- Clipboard ---

  Future<void> copySelectionToClipboard() async {
    if (_dataController == null) return;

    final startRow = min(_selectionStart.x, _selectionEnd.x);
    final endRow = max(_selectionStart.x, _selectionEnd.x);
    final startCol = min(_selectionStart.y, _selectionEnd.y);
    final endCol = max(_selectionStart.y, _selectionEnd.y);

    StringBuffer buffer = StringBuffer();

    for (int r = startRow; r <= endRow; r++) {
      List<String> rowData = [];
      for (int c = startCol; c <= endCol; c++) {
        rowData.add(_dataController!.getContent(r, c));
      }
      buffer.write(rowData.join('\t'));
      if (r < endRow) buffer.write('\n');
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString()));
  }

  Future<void> pasteSelection() async {
    if (_dataController == null) return;

    final data = await Clipboard.getData('text/plain');
    if (data?.text == null) return;

    int startRow = min(_selectionStart.x, _selectionEnd.x);
    int startCol = min(_selectionStart.y, _selectionEnd.y);

    // Delegate parsing to DataController (which delegates to UseCase)
    final updates = _dataController!.parsePasteData(data!.text!, startRow, startCol);

    for (var update in updates) {
      _dataController!.updateCell(update.row, update.col, update.value);
    }
  }
}