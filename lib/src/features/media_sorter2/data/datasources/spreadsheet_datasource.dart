import '../../domain/entities/cell.dart';

abstract class SpreadsheetDataSource {
  Future<Map<String, Cell>> fetchSheet();
  Future<Cell> updateCell(int row, int col, String value);
}

class InMemorySpreadsheetDataSource implements SpreadsheetDataSource {
  // Simulating a DB using a Map with "row:col" keys
  final Map<String, Cell> _cache = {};

  @override
  Future<Map<String, Cell>> fetchSheet() async {
    // Simulate network delay
    // await Future.delayed(const Duration(milliseconds: 500));
    
    // Return empty map or existing cache
    return _cache;
  }

  @override
  Future<Cell> updateCell(int row, int col, String value) async {
    // Simulate network delay
    // await Future.delayed(const Duration(milliseconds: 100));

    final cell = Cell(row: row, col: col, value: value);
    final key = '$row:$col';
    _cache[key] = cell;
    
    return cell;
  }
}