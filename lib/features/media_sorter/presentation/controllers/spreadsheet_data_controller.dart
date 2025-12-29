import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/get_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/save_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/parse_paste_data_usecase.dart';
import '../../domain/usecases/manage_waiting_tasks.dart';

class SpreadsheetDataController extends ChangeNotifier {
  final GetSheetDataUseCase _getDataUseCase;
  final SaveSheetDataUseCase _saveSheetDataUseCase;
  final ParsePasteDataUseCase _parsePasteDataUseCase;
  
  final Map<String, ManageWaitingTasks<void>> _saveExecutors = {};
  int saveDelayMs = 500;

  // --- State ---
  List<List<String>> table = [];
  List<String> columnTypes = [];
  String sheetName = "";
  List<String> availableSheets = [];
  
  // Cache to avoid re-parsing when switching tabs
  Map<String, Map<String, dynamic>> loadedSheetsData = {}; 
  
  int tableViewRows = 50;
  int tableViewCols = 50;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int get rowCount => table.length;
  int get colCount => rowCount > 0 ? table[0].length : 0;

  SpreadsheetDataController({
    required GetSheetDataUseCase getDataUseCase,
    required SaveSheetDataUseCase saveSheetDataUseCase,
    required ParsePasteDataUseCase parsePasteDataUseCase,
  })  : _getDataUseCase = getDataUseCase,
        _saveSheetDataUseCase = saveSheetDataUseCase,
        _parsePasteDataUseCase = parsePasteDataUseCase {
    init();
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    availableSheets = await _getDataUseCase.getAllSheetNames();
    sheetName = await _getDataUseCase.getLastOpenedSheetName();
    
    if (!availableSheets.contains(sheetName)) {
      availableSheets.add(sheetName);
    }

    await loadSheetByName(sheetName, init: true);
  }

  Future<void> loadSheetByName(String name, {bool init = false}) async {
    if (!_isLoading) {
      _isLoading = true;
      notifyListeners();
    }

    // Save previous sheet if switching
    if (!init && availableSheets.contains(sheetName)) {
      loadedSheetsData[sheetName] = {"table": table, "columnTypes": columnTypes};
    }

    if (availableSheets.contains(name)) {
      if (loadedSheetsData.containsKey(name)) {
        table = loadedSheetsData[name]!["table"] as List<List<String>>;
        columnTypes = loadedSheetsData[name]!["columnTypes"] as List<String>;
      } else {
        _saveExecutors[name] = ManageWaitingTasks<void>();
        try {
          var (iTable, iColumnTypes) = await _getDataUseCase.loadSheet(name);
          table = iTable;
          columnTypes = iColumnTypes;
        } catch (e) {
          debugPrint("Error parsing sheet data for $name: $e");
          table = [];
          columnTypes = [];
        }
      }
    } else {
      // New Sheet
      table = [];
      columnTypes = [];
      availableSheets.add(name);
      _saveSheetDataUseCase.saveAllSheetNames(availableSheets);
      _saveExecutors[name] = ManageWaitingTasks<void>();
    }

    loadedSheetsData[name] = {"table": table, "columnTypes": columnTypes};
    sheetName = name;
    _saveSheetDataUseCase.saveLastOpenedSheetName(name);
    
    _isLoading = false;
    notifyListeners(); 
    // Triggers listeners (AnalysisController) to re-run
  }

  String getContent(int row, int col) {
    if (row < rowCount && col < colCount) {
      return table[row][col];
    }
    return '';
  }

  void updateCell(int row, int col, String newValue) {
    if (newValue.isNotEmpty || (row < rowCount && col < colCount)) {
      if (row >= rowCount) {
        final needed = row + 1 - rowCount;
        table.addAll(List.generate(
          needed,
          (_) => List.filled(colCount, '', growable: true),
        ));
      }
      if (col >= colCount) {
        increaseColumnCount(col);
      }
      table[row][col] = newValue;
    }

    // Shrink logic
    if (newValue.isEmpty &&
        row < rowCount &&
        col < colCount &&
        (row == rowCount - 1 || col == colCount - 1) &&
        table[row][col].isNotEmpty) {
      decreaseRowCount(row);
      decreaseColumnCount(col);
    }

    _scheduleSave();
    notifyListeners(); 
  }

  // --- Column Management ---

  void increaseColumnCount(int col) {
    if (col >= colCount) {
      final needed = col + 1 - colCount;
      for (var r = 0; r < rowCount; r++) {
        table[r].addAll(List.filled(needed, '', growable: true));
      }
      columnTypes.addAll(List.filled(needed, ColumnType.attributes.name));
    }
  }

  void decreaseColumnCount(int col) {
    if (col == columnTypes.length - 1) {
      bool canRemove = true;
      while (canRemove && col > 0) {
        for (var r = 0; r < rowCount; r++) {
          if (table[r][col].isNotEmpty) {
            canRemove = false;
            break;
          }
        }
        if (canRemove) {
          for (var r = 0; r < rowCount; r++) {
            table[r].removeLast();
          }
          col--;
        }
      }
      columnTypes = columnTypes.sublist(0, col + 1);
    }
  }

  void decreaseRowCount(int row) {
    if (row == rowCount - 1) {
      while (row >= 0 && !table[row].any((cell) => cell.isNotEmpty)) {
        table.removeLast();
        row--;
      }
    }
  }

  String getColumnType(int col) {
    if (col >= colCount) return ColumnType.attributes.name;
    return columnTypes[col];
  }

  void setColumnType(int col, String type) {
    if (type == ColumnType.attributes.name) {
      if (col < colCount) {
        columnTypes[col] = type;
        decreaseColumnCount(col);
      }
    } else {
      increaseColumnCount(col);
      columnTypes[col] = type;
    }
    _scheduleSave();
    notifyListeners();
  }

  // --- Paste Parsing ---
  List<CellUpdate> parsePasteData(String text, int startRow, int startCol) {
     return _parsePasteDataUseCase.execute(text, startRow, startCol);
  }

  void _scheduleSave() {
    if (_saveExecutors[sheetName] == null) return;
    
    _saveExecutors[sheetName]!.execute(() async {
      await _saveSheetDataUseCase.saveSheet(sheetName, table, columnTypes);
      await Future.delayed(Duration(milliseconds: saveDelayMs));
    });
  }
}