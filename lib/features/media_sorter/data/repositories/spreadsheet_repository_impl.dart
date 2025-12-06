import '../../domain/entities/spreadsheet_cell.dart';
import '../../domain/repositories/spreadsheet_repository.dart';

class SpreadsheetRepositoryImpl implements SpreadsheetRepository {
  // In a real app, inject a Database instance (Drift/Isar) here.
  
  // Simulating "millions" capability by generating on fly or mocking
  // because SharedPreferences will crash with >10k items.
  final Map<String, String> _inMemoryStore = {}; 

  @override
  Future<List<SpreadsheetCell>> loadSheet() async {
    // Simulate network/db delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Return empty or mocked initial data
    return []; 
  }

  @override
  Future<void> saveSheet(List<SpreadsheetCell> cells) async {
    // THIS is where you would normally write to DB
    // For now, we update our memory cache
    for(var cell in cells) {
      _inMemoryStore['${cell.row}_${cell.col}'] = cell.content;
    }
  }

  @override
  Future<void> updateCell(int row, int col, String value) async {
    _inMemoryStore['${row}_${col}'] = value;
    // Persist to actual storage here
  }
}