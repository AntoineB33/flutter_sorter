import '../../domain/entities/cell.dart';
import '../../domain/repositories/spreadsheet_repository.dart';
import '../datasources/spreadsheet_datasource.dart';

// Coordinates data access between the Domain and Data layers
class SpreadsheetRepositoryImpl implements SpreadsheetRepository {
  final SpreadsheetDataSource _dataSource;

  SpreadsheetRepositoryImpl(this._dataSource);

  @override
  Future<Map<String, Cell>> getSheet(String sheetId) async {
    return await _dataSource.fetchSheetData(sheetId);
  }

  @override
  Future<void> updateCell(String sheetId, int row, int col, String value) async {
    await _dataSource.saveCellData(sheetId, row, col, value);
  }
}