import '../../domain/repositories/i_spreadsheet_data_repository.dart';

class SpreadsheetDataRepository implements ISpreadsheetDataRepository {
  // Currently, this might just be in-memory data
  final List<List<String>> _inMemoryTable = []; 
  final List<String> _columnTypes = [];

  @override
  List<List<String>> get table => _inMemoryTable;

  @override
  List<String> get columnTypes => _columnTypes;

  // You can add methods to MUTATE data here, which aren't part of the 
  // 'ISpreadsheetDataRepository' if the UseCase only needs to READ data.
  void updateCell(int row, int col, String value) {
    _inMemoryTable[row][col] = value;
  }
}