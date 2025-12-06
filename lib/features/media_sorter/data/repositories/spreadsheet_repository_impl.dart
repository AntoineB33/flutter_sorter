import '../../domain/entities/spreadsheet_cell.dart';
import '../../domain/repositories/spreadsheet_repository.dart';
import '../datasources/local_spreadsheet_service.dart';

class SpreadsheetRepositoryImpl implements SpreadsheetRepository {
  final TableLocalDataSource dataSource;
  
  SpreadsheetRepositoryImpl(this.dataSource);
  
  @override
  Future<Map<(int, int), String>> getRegion(int startRow, int endRow) async {
    // We assume a standard viewport width (e.g., columns 0 to 20) 
    // or fetch all columns for these rows if needed.
    final rawData = await dataSource.fetchCellChunk(
      minRow: startRow,
      maxRow: endRow,
      minCol: 0,   // Assuming we want all cols or a specific visible range
      maxCol: 50,  // Tuning this prevents fetching columns off-screen
    );

    // Transform List to Map for O(1) lookup in the Controller
    final Map<(int, int), String> map = {};
    for (var cell in rawData) {
      map[(cell.row, cell.col)] = cell.value;
    }
    return map;
  }

  @override
  Future<void> updateCell(int row, int col, String value) async {
    await dataSource.saveCell(row: row, col: col, value: value);
  }
}