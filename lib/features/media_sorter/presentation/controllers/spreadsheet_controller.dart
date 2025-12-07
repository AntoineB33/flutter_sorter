import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/usecases/get_sheet_data_usecase.dart';
import '../../domain/usecases/save_sheet_data_usecase.dart'; // Assume created
import '../../domain/entities/column_type.dart';
import '../../domain/usecases/parse_paste_data_usecase.dart';

class SpreadsheetController extends ChangeNotifier {
  final GetSheetDataUseCase _getDataUseCase;
  final SaveCellUseCase _saveCellUseCase;
  final ParsePasteDataUseCase _parsePasteDataUseCase;
  
  final Map<(int, int), String> _activeCache = {};

  final Set<int> _loadingPages = {};
  
  static const int _pageSize = 100; // Fetch 100 rows at a time

  // Data Storage
  final Map<String, String> _data = {};
  final Map<int, String> _columnTypes = {}; // Stores column types
  
  // Dimensions
  int _rowCount = 100; 
  int _colCount = 20;
  bool _isLoading = false;

  // Selection State
  Point<int>? _selectionStart;
  Point<int>? _selectionEnd;

  SpreadsheetController({required GetSheetDataUseCase getDataUseCase, required SaveCellUseCase saveCellUseCase, required ParsePasteDataUseCase parsePasteDataUseCase}) 
      : _getDataUseCase = getDataUseCase,
        _saveCellUseCase = saveCellUseCase,
        _parsePasteDataUseCase = parsePasteDataUseCase;

  // Getters
  int get rowCount => _rowCount;
  int get colCount => _colCount;
  bool get isLoading => _isLoading;

  // --- Content Access ---
  String getContent(int row, int col) {
    final key = (row, col);

    // Hit: Return data immediately
    if (_activeCache.containsKey(key)) {
      return _activeCache[key]!;
    }

    // Miss: Trigger fetch if not already loading
    _requestPageLoad(row);

    // Return placeholder
    return "Loading...";
  }

  /// 3. Determines which "Page" (chunk) allows us to fetch data in bulk
  void _requestPageLoad(int row) {
    final pageIndex = row ~/ _pageSize; // e.g., row 150 is page 1

    if (_loadingPages.contains(pageIndex)) return;

    _loadingPages.add(pageIndex);
    
    // Fetch asynchronously
    _fetchPage(pageIndex);
  }

  Future<void> _fetchPage(int pageIndex) async {
    final startRow = pageIndex * _pageSize;
    final endRow = startRow + _pageSize;

    try {
      // 4. Call the UseCase
      final newChunk = await _getDataUseCase(startRow, endRow);
      
      // 5. Update the Cache
      _activeCache.addAll(newChunk);
      
      // Optional: Pruning strategy. 
      // If _activeCache > 5000 entries, remove pages far from current viewport.
      
    } catch (e) {
      print("Error loading page $pageIndex: $e");
    } finally {
      _loadingPages.remove(pageIndex);
      notifyListeners(); // Updates the UI to replace "Loading..." with text
    }
  }

  void updateCell(int row, int col, String value) {
    final key = (row, col);

    // 1. Optimistic Update (Instant Feedback)
    _activeCache[key] = value;
    
    // 2. Refresh UI
    notifyListeners();

    // 3. Persist to Database (Fire and Forget)
    _saveCellUseCase(row, col, value).catchError((e) {
      // Error Handling:
      // If the save fails, we should probably revert the UI or show a toast.
      print("Failed to save cell ($row, $col): $e");
      
      // Optional: Revert logic if needed
      // _activeCache[key] = "Error"; 
      // notifyListeners();
    });
  }

  // --- Column Logic ---
  String getColumnType(int col) {
    return _columnTypes[col] ?? ColumnType.defaultType.name;
  }

  void setColumnType(int col, String typeName) {
    _columnTypes[col] = typeName;
    notifyListeners();
  }

  /// Generates Excel-like column names (A, B, ... Z, AA, AB)
  String columnName(int colIndex) {
    String res = "";
    int index = colIndex;
    while (index >= 0) {
      res = String.fromCharCode((index % 26) + 65) + res;
      index = (index ~/ 26) - 1;
    }
    return res;
  }

  // --- Selection Logic ---
  void selectCell(int row, int col) {
    _selectionStart = Point(row, col);
    _selectionEnd = Point(row, col);
    notifyListeners();
  }

  void selectRange(int startRow, int startCol, int endRow, int endCol) {
    _selectionStart = Point(startRow, startCol);
    _selectionEnd = Point(endRow, endCol);
    notifyListeners();
  }

  bool isCellSelected(int row, int col) {
    if (_selectionStart == null || _selectionEnd == null) return false;

    final startRow = min(_selectionStart!.x, _selectionEnd!.x);
    final endRow = max(_selectionStart!.x, _selectionEnd!.x);
    final startCol = min(_selectionStart!.y, _selectionEnd!.y);
    final endCol = max(_selectionStart!.y, _selectionEnd!.y);

    return row >= startRow && row <= endRow && col >= startCol && col <= endCol;
  }

  // --- Clipboard Logic ---
  Future<String?> copySelectionToClipboard() async {
    if (_selectionStart == null || _selectionEnd == null) return null;

    final startRow = min(_selectionStart!.x, _selectionEnd!.x);
    final endRow = max(_selectionStart!.x, _selectionEnd!.x);
    final startCol = min(_selectionStart!.y, _selectionEnd!.y);
    final endCol = max(_selectionStart!.y, _selectionEnd!.y);

    StringBuffer buffer = StringBuffer();

    for (int r = startRow; r <= endRow; r++) {
      List<String> rowData = [];
      for (int c = startCol; c <= endCol; c++) {
        rowData.add(getContent(r, c));
      }
      buffer.write(rowData.join('\t')); // Tab separated for Excel compat
      if (r < endRow) buffer.write('\n');
    }

    final text = buffer.toString();
    await Clipboard.setData(ClipboardData(text: text));
    return text;
  }

  void addRows(int count) {
    _rowCount += count;
    notifyListeners();
  }

  void addColumns(int count) {
    _colCount += count;
    notifyListeners();
  }

  Future<void> pasteSelection() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text == null || _selectionStart == null) return;

    // 1. Delegate Logic to UseCase
    // We normalize selection to ensure we paste from top-left
    int startRow = min(_selectionStart!.x, _selectionEnd?.x ?? _selectionStart!.x);
    int startCol = min(_selectionStart!.y, _selectionEnd?.y ?? _selectionStart!.y);

    final List<CellUpdate> updates = _parsePasteDataUseCase(data!.text!, startRow, startCol);

    // 2. Update UI & Persist
    for (var update in updates) {
      updateCell(update.row, update.col, update.value);
    }
    
    // Batch notification is better for performance than notifying inside the loop
    notifyListeners();
  }

  void selectAll() {
    selectRange(0, 0, _rowCount - 1, _colCount - 1);
  }
}