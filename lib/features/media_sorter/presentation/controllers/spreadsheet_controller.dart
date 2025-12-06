import 'package:flutter/material.dart';
import '../../domain/usecases/get_sheet_data_usecase.dart';
import '../../domain/usecases/save_sheet_data_usecase.dart'; // Assume created
import '../../domain/entities/spreadsheet_cell.dart';

class SpreadsheetController extends ChangeNotifier {
  final GetSheetDataUseCase _getDataUseCase;

  // For millions of rows, we cannot keep a List<List<String>> in memory easily.
  // We use a sparse map: "row_col" -> "Value".
  final Map<String, String> _data = {};
  
  int _rowCount = 1000; // Start small, can grow to millions
  int _colCount = 20;
  bool _isLoading = false;

  SpreadsheetController({required GetSheetDataUseCase getDataUseCase}) 
      : _getDataUseCase = getDataUseCase;

  int get rowCount => _rowCount;
  int get colCount => _colCount;
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final cells = await _getDataUseCase.execute();
      for (var cell in cells) {
        _data['${cell.row}_${cell.col}'] = cell.content;
      }
    } catch (e) {
      debugPrint("Error loading data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String getContent(int row, int col) {
    return _data['${row}_${col}'] ?? 'R$row : C$col'; // Default value generator for demo
  }

  void updateCell(int row, int col, String value) {
    _data['${row}_${col}'] = value;
    // Debounce save logic would go here
    notifyListeners();
  }

  void addRows(int count) {
    _rowCount += count;
    notifyListeners();
  }

  void addColumns(int count) {
    _colCount += count;
    notifyListeners();
  }
}